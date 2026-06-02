# AGENTS — Neowall Dual-Mode Wallpaper

Read this file before editing any Neowall-related scripts, shaders, configs, or presets in this repo.

## Architecture Overview

This repo extends Omarchy with an optional Neowall wallpaper backend. The design uses **two explicit modes** determined by which keybinding the user invokes:

| Mode | Trigger | Backend | Symlink |
|------|---------|---------|---------|
| Static (Omarchy) | `SUPER+CTRL+SPACE` or any `omarchy theme bg *` command | `swaybg` | `~/.config/omarchy/current/background` → selected image |
| Native Neowall | `SUPER+CTRL+ALT+SPACE` | `neowall` | `~/.config/omarchy/current/background` → poster/preview PNG |

**Key architectural rule:** Both modes always update `~/.config/omarchy/current/background`. That symlink is the contract with Hyprlock (lockscreen), Hyprland autostart, and any other Omarchy consumer. In Neowall shader mode it points to a **poster/preview image**, not the shader itself.

### Core Scripts

| Script | Role | Location |
|--------|------|----------|
| `omarchy-theme-bg-set` (override) | Shadows Omarchy's default. Kills neowall, updates symlink, starts swaybg. All static Omarchy flows route here via PATH. | `bin/` |
| `omarchy-neowall-select` | Opens the Neowall selector. Generates previews for presets + bundled shaders, launches `omarchy-menu-images`, resolves selection, calls `omarchy-neowall-apply`. | `bin/` |
| `omarchy-neowall-apply` | Applies a Neowall entry. Writes `config.vibe`, sets symlink, kills swaybg, starts neowall. Handles preset JSON, bare bundled shaders, and raw images. | `bin/` |
| `omarchy-neowall-backend` | Reads/writes the active backend state file. | `bin/` |
| `install-neowall` | Installs/updates/uninstalls neowall from GitHub releases. | `scripts/install/` |

### Asset Layout

```
neowall/
├── AGENTS.md        ← this file
├── README.md        → asset layout documentation
├── WORKFLOW.md      → user-facing workflow docs (install, use, rollback)
├── shaders/         → repo-managed .glsl shader source files
├── previews/        → generated preview PNGs (regenerated each selector use)
├── posters/         → generated poster PNGs for lockscreen (regenerated each selector use)
├── presets/         → JSON manifest files defining selectable entries
└── tests/           → bats test suite
```

Runtime (user-scoped, not in repo):
```
~/.config/neowall/
├── config.vibe      → Neowall daemon config (auto-written by omarchy-neowall-apply)
├── shaders/         → installed + symlinked shader files
└── previews/        → generated previews for bundled shaders
~/.local/state/omarchy-overrides/
└── wallpaper-backend  → current backend state ("swaybg" or "neowall")
```

### State File

The backend state file lives at `~/.local/state/omarchy-overrides/wallpaper-backend`.
Valid values: `swaybg` or `neowall`.

Read with: `omarchy-neowall-backend read`
Write with: `omarchy-neowall-backend write <backend>`
Status: `omarchy-neowall-backend status`

## Neowall Daemon Internals

### How neowall runs

Single C binary, **no separate daemon tool**. Everything goes through the same binary:

```bash
neowall              # Start daemon (foreground by default)
neowall kill         # Stop daemon
neowall -c <config>  # Use a specific config file
```

### Runtime Commands

All control is through CLI commands sent to the running daemon:

| Command | Action |
|---------|--------|
| `neowall` | Start daemon |
| `neowall kill` | Stop daemon |
| `neowall next` | Cycle to next item in queue |
| `neowall set <N>` | Jump to index N in the startup-built queue |
| `neowall pause` | Pause cycling |
| `neowall resume` | Resume cycling |
| `neowall pause-shader` | Freeze shader animation |
| `neowall resume-shader` | Resume shader animation |
| `neowall list` | Show current queue |
| `neowall current` | Show what's playing |
| `neowall status` | Show daemon status |

**CRITICAL: No `neowall set --file <path>` exists.** The daemon builds its queue once at startup from `config.vibe`. You cannot inject arbitrary files at runtime. To change wallpaper, you must rewrite `config.vibe` and restart the daemon with `neowall kill && neowall`. There is no SIGHUP, no hot-reload, no inotify.

The README incorrectly lists `neowall reload` — **this command does not exist** in any release. Only `kill && restart` works.

### Config File Format (VIBE)

Neowall config lives at `~/.config/neowall/config.vibe`. Simple bracket-based format:

```vibe
# Comments start with #
default {
  shader plasma.glsl
  shader_speed 1.0
}
```

**Sections:**

| Section | Purpose |
|---------|---------|
| `default { }` | Global settings for all monitors |
| `output { <NAME> { } }` | Per-monitor overrides |

**Options (inside `default {}` or `output {}`):**

| Option | Values | Default | Notes |
|--------|--------|---------|-------|
| `shader <name.glsl>` | filename in `~/.config/neowall/shaders/` or absolute path | — | Mutually exclusive with `path` |
| `shader_speed` | float | `1.0` | Only affects shaders |
| `path <file-or-dir/>` | single file or directory (trailing `/` = dir mode) | — | PNG/JPEG only. Mutually exclusive with `shader` |
| `mode` | `fill`, `fit`, `center`, `stretch`, `tile` | `fill` | Images only |
| `duration` | seconds | `0` (no cycling) | Works with path dirs and shader dirs |
| `transition` | `fade`, `slide_left`, `slide_right`, `glitch`, `pixelate`, `none` | `fade` | Images only |
| `transition_duration` | milliseconds | `300` | Images only |

**Global options** (outside any section):

| Option | Values | Default |
|--------|--------|---------|
| `mouse_interaction` | `true` / `false` | `true` |
| `pause_on_fullscreen` | `true` / `false` | `true` |
| `pause_coverage_threshold` | 0.0–1.0 | `0.8` |

**Important restrictions:**
- `shader` and `path` are mutually exclusive within the same section
- `mode` only applies to images, not shaders
- `transition` only applies to images, not shaders
- `shader_speed` only applies to shaders, not images
- Config is read once at startup — **no hot-reload**

### Example configs

```vibe
# Shader mode
default {
  shader matrix_rain.glsl
  shader_speed 1.0
}
```

```vibe
# Image mode
default {
  path /path/to/image.png
  mode fill
}
```

```vibe
# Image directory slideshow
default {
  path ~/Pictures/Wallpapers/
  duration 300
  transition fade
  mode fill
}
```

```vibe
# Multi-monitor
output {
  eDP-1  { shader plasma.glsl }
  HDMI-A-1 { path ~/Pictures/wallpaper.png mode fill }
}
```

### Shader Resolution

When neowall encounters a shader filename like `plasma.glsl`, it resolves it in order:
1. `~/.config/neowall/shaders/<name>.glsl`
2. System shader directory (compile-time defined, typically `/usr/local/share/neowall/shaders/` or `/usr/share/neowall/shaders/`)

Shader filenames are bare names — no path traversal, no `../`. Only the filename matters.

## Repo Preset Format

Preset JSON files in `neowall/presets/` define selectable entries:

```json
{
  "type": "shader",
  "id": "plasma",
  "label": "Plasma",
  "source": "plasma.glsl"
}
```

Fields:
- `type`: `"shader"` or `"image"`
- `id`: unique identifier; also resolves to `previews/<id>.png` and `posters/<id>.png`
- `label`: human-readable name shown in the selector
- `source`: for shader type, the shader filename; for image type, a file path

The selector generates preview and poster images automatically using ImageMagick. Previews are regenerated every time the selector opens (no cache guard).

## Writing Shaders for Neowall

### Required Uniforms

Neowall uses **Shadertoy-compatible** uniform names. This is the most common mistake:

```glsl
#version 100
precision highp float;

uniform float iTime;          // NOT "time" — "iTime" or it stays 0
uniform vec2 iResolution;     // NOT "resolution" — "iResolution" or it stays 0
uniform vec4 iMouse;          // Optional: mouse position
uniform vec4 iDate;           // Optional: date (year, month, day, seconds)
uniform int iFrame;           // Optional: frame counter (always 0 in neowall)

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float t = iTime;

    vec3 color = vec3(
        0.5 + 0.5 * sin(uv.x * 3.0 + t),
        0.5 + 0.5 * cos(uv.y * 3.0 + t),
        0.5 + 0.5 * sin((uv.x + uv.y) * 2.0 + t)
    );

    gl_FragColor = vec4(color, 1.0);
}
```

**ALWAYS USE `iTime` AND `iResolution`.** Using `time` or `resolution` (the raw GLSL names) will compile but produce a black screen because those uniforms are not bound.

### Shadertoy Compatibility

Most Shadertoy shaders work with minimal changes:
- `iChannel0` through `iChannel4` for texture samplers
- `iChannelTime[4]` for per-channel time
- `iChannelResolution[4]` for per-channel resolution
- `iMouse` for mouse input
- `iDate` for date vector
- `iFrame` for frame counter (always 0, so not useful for animation)

### GLSL Version

Use `#version 100` (GLSL ES 2.0) for maximum compatibility:
```glsl
#version 100
precision highp float;
```

Neowall also supports OpenGL 3.3 desktop GLSL (`#version 330`). If you need desktop features (e.g., `texture()` vs `texture2D()`), use `#version 330`.

### Reactive Shaders

Neowall provides system-reactive uniforms beyond Shadertoy:
- `iCpu`, `iRam`, `iBattery` — system metrics
- `iAudioLevel`, `iAudioBass/Mid/Treble/Beat` — audio FFT (requires `parec`)
- `iTimeOfDay` — real time of day
- `iKeyEnergy` — keyboard activity

These are documented in `docs/REACTIVE_SHADERS.md` in the neowall repo.

### Known Pitfalls

- `#version 100` shaders use `texture2D()`, not `texture()`. `#version 330` uses `texture()`.
- `gl_FragColor` is the output in `#version 100`. In `#version 330` you declare `out vec4 fragColor`.
- Shaders with `dFdx`/`dFdxFine`/etc need `#extension GL_OES_standard_derivatives : enable` under GLES.
- Very heavy raymarching shaders can peg GPU at 100%, especially on HiDPI. Use `shader_fps 30` in config.
- SVG and JPEG XL are only supported as static images (no animation).

## The Selector Flow (How It Works)

When the user presses `SUPER+CTRL+ALT+SPACE`:

1. **Hyprland** runs `bin/omarchy-neowall-select` (path is hardcoded in `hypr/bindings.lua`)
2. **The script generates previews:**
   a. Iterates `neowall/presets/*.json`, generates labelled gradient PNG for each
   b. Scans `~/.config/neowall/shaders/` + system shader dirs, generates previews for each bundled shader
   c. Generates poster images for lockscreen compatibility
3. **Builds a directory list:** repo `previews/`, user `previews/`, Omarchy wallpaper dirs
4. **Launches `omarchy-menu-images`** with those directories (reuses Omarchy's Quickshell QML UI)
5. **User picks an entry** — `omarchy-menu-images` returns the image path
6. **Calls `omarchy-neowall-apply --from-preview <path>`**:
   - If path matches a repo preset → apply from JSON
   - If path matches a bundled shader → apply as bare shader entry
   - Otherwise → apply as raw image
7. **Applies the entry:**
   - Writes `~/.config/neowall/config.vibe`
   - Updates `~/.config/omarchy/current/background`
   - Kills `swaybg` if running
   - Records backend state
   - Restarts neowall

## Backend Switching Logic

### Omarchy static mode (any Omarchy wallpaper action → `omarchy-theme-bg-set` override):
1. Kill neowall if running
2. Set `~/.config/omarchy/current/background` → the chosen image
3. Write state: `swaybg`
4. Kill swaybg, restart swaybg

### Neowall native mode (`SUPER+CTRL+ALT+SPACE` → selector → apply):
1. Kill swaybg if running
2. Write `~/.config/neowall/config.vibe`
3. Set `~/.config/omarchy/current/background` → poster/preview PNG
4. Write state: `neowall`
5. Kill neowall, restart neowall

### Install → uninstall flow:
- `scripts/install/install-neowall` with `--update` or `--uninstall`
- Uninstall kills neowall, removes binary, removes runtime config, restores swaybg

## Preview Image Generation

Preview images are generated by `omarchy-neowall-select` using ImageMagick.
Three escalating attempts:
1. Gradient background + text annotation (no explicit font — ImageMagick default)
2. Solid background + text annotation
3. Plain solid color (guaranteed to produce a valid PNG)

No `-font` flag is used — relying on ImageMagick's internal default avoids font-not-found failures that plague Arch systems.

## Installing Neowall

```bash
scripts/install/install-neowall          # Install latest
scripts/install/install-neowall --update # Update
scripts/install/install-neowall --uninstall # Remove
```

The install script:
1. Resolves the latest release tag from GitHub API
2. Downloads the binary archive and `SHA256SUMS.txt`
3. Verifies the SHA256 checksum (unsigned — GitHub HTTPS + checksum only)
4. Installs `neowall` binary to `~/.local/bin/`
5. Seeds bundled shaders (from binary tarball, or falls back to source tarball)
6. Links repo-managed shaders and previews
7. Creates a default `config.vibe`

## PATH Precedence

This repo depends on `~/.local/bin/` being earlier in `PATH` than `~/.local/share/omarchy/bin/`. The override `omarchy-theme-bg-set` in `bin/` is symlinked to `~/.local/bin/` by `scripts/link-bins`, and because of PATH order it intercepts all `omarchy-theme-bg-set` calls from Omarchy scripts.

## Testing

Tests use `bats` (Bash Automated Testing System):

```bash
bats neowall/tests/
```

Test files cover: backend state file, preview generation, config writing, preset resolution, and script sanity checks. Tests are self-contained (create temp dirs, clean up after themselves).

## Common Mistakes to Avoid

1. **Using `time`/`resolution` uniform names** in shaders — must be `iTime`/`iResolution` for neowall compatibility.
2. **Using `-font <name>` in ImageMagick** — will fail on many Arch setups. Omit the font flag entirely and use ImageMagick's default.
3. **Assuming neowall can hot-reload or accept runtime paths** — it cannot. Every config change requires `kill && restart`.
4. **Editing files in `~/.local/share/omarchy/`** — never modify upstream Omarchy. All overrides go in this repo or `~/.config/`.
5. **Forgetting the poster image** — when neowall shows a shader, the lockscreen/hyprlock still needs an image at `~/.config/omarchy/current/background`. Always set it.
6. **Using neowall's `reload` command** — it doesn't exist. Kill and restart.
