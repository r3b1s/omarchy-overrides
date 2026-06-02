# Neowall Dual-Mode Wallpaper Workflow

This repo extends Omarchy with an optional Neowall wallpaper backend for shader-driven live wallpapers. Omarchy's normal static wallpaper workflow is preserved. A separate native Neowall selector provides access to shader presets and Neowall-rendered images.

## Modes

### Static Mode (Omarchy default — swaybg)
- Triggered by any standard Omarchy wallpaper selection:
  - `SUPER+CTRL+SPACE` — Omarchy background selector
  - `omarchy theme bg set <path>`
  - `omarchy theme bg next`
  - `omarchy theme set <name>` (auto-cycles background)
- What happens:
  1. Neowall is killed if running
  2. `~/.config/omarchy/current/background` is updated
  3. `swaybg` starts with the selected image
  4. Backend state is recorded as `swaybg`

### Neowall Mode (shader/Neowall — neowall)
- Triggered by the dedicated Neowall selector:
  - `SUPER+CTRL+ALT+SPACE` — Neowall shader/wallpaper selector
  - `omarchy-neowall-select`
- What happens:
  1. `swaybg` is killed if running
  2. Neowall config is written for the selected entry
  3. `~/.config/omarchy/current/background` is set to the entry's poster/preview image
  4. Neowall starts with the selected shader or image
  5. Backend state is recorded as `neowall`

## Installation

### Prerequisites
- `curl` for downloading releases
- `jq` (available in the repo's dependency list)
- `omarchy-menu-images` and `select-by-image.qml` (shipped with Omarchy)

### Install Neowall

```bash
scripts/install/install-neowall
```

This will:
1. Discover the latest Neowall release from GitHub
2. Download the binary archive and SHA256 checksums
3. Verify the archive checksum
4. Install the `neowall` binary to `~/.local/bin/`
5. Seed bundled shaders to `~/.config/neowall/shaders/`
6. Create a default `~/.config/neowall/config.vibe`
7. Link repo-managed shaders and previews

### Update Neowall

```bash
scripts/install/install-neowall --update
```

### Dry run

```bash
scripts/install/install-neowall --dry-run
```

Shows what would be installed without making changes.

## Asset Layout

### Repo-managed
```
neowall/
├── shaders/        # .glsl shader source files
├── previews/       # preview PNGs used in the selector UI
├── posters/        # poster PNGs for lockscreen symlink
├── presets/        # JSON manifest entries
│   └── plasma.json
└── WORKFLOW.md     # this file
```

### Runtime (user)
```
~/.config/neowall/
  ├── config.vibe       # Neowall daemon config (auto-managed)
  ├── shaders/           # installed + symlinked shaders
  └── previews/          # symlinked previews, custom additions
~/.local/state/omarchy-overrides/
  └── wallpaper-backend  # current backend state (swaybg or neowall)
```

## Preset Format

Each `.json` file in `neowall/presets/` defines a selectable entry:

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
- `source`: shader filename (for type `shader`) or image path (for type `image`)

## Adding a Custom Shader

1. Add your `.glsl` file to `neowall/shaders/`
2. Add a preview PNG to `neowall/previews/<name>.png`
3. Add a poster PNG (for lockscreen) to `neowall/posters/<name>.png`
4. Add a preset JSON file to `neowall/presets/<name>.json`
5. Run `omarchy-neowall-select` to browse and select it

## Adding a Custom Image Entry to Neowall

For static images you want to use via the Neowall selector (with Neowall-style transitions):
1. Add a preset JSON file with `type: "image"` and `source` pointing to the image path
2. The preview can be the image itself (omit `previews/` entry)
3. Select it via `SUPER+CTRL+ALT+SPACE`

Omarchy theme wallpapers are automatically included in the Neowall selector as image entries.

## Verifying Active Backend

```bash
omarchy-neowall-backend status
```

Shows which backend is active and whether each process is running.

## Keybindings

| Binding | Action | Routes through |
|---|---|---|
| `SUPER+CTRL+SPACE` | Omarchy background selector (static) | `omarchy-theme-bg-set` (overridden) |
| `SUPER+CTRL+ALT+SPACE` | Neowall shader/wallpaper selector | `omarchy-neowall-select` |

## Rollback

To fully remove the Neowall integration and restore standard Omarchy behavior:

1. **Stop Neowall:**
   ```bash
   neowall kill
   ```
2. **Restore swaybg:**
   ```bash
   pkill -x swaybg
   setsid uwsm-app -- swaybg -i ~/.config/omarchy/current/background -m fill &
   ```
3. **Remove bin overrides (optional):**
   ```bash
   rm ~/.local/bin/omarchy-theme-bg-set
   rm ~/.local/bin/omarchy-neowall-select
   rm ~/.local/bin/omarchy-neowall-apply
   rm ~/.local/bin/omarchy-neowall-backend
   ```
4. **Remove Neowall runtime:**
   ```bash
   rm -rf ~/.config/neowall
   rm ~/.local/bin/neowall
   rm ~/.local/state/omarchy-overrides/wallpaper-backend
   ```
5. **Remove Neowall binding:** Edit `hypr/bindings.lua` and remove the
   `SUPER + CTRL + ALT + Space` block.
6. **Reload Hyprland:**
   ```bash
   hyprctl reload
   ```
