# 002 Hyprland 0.55 Script Migration

## Context

I updated my staged Hyprland 0.55 configuration to account for the new Lua dispatcher syntax introduced in Hyprland 0.55. The existing `hypr/scripts/` directory remains my legacy hyprlang-era reference, while `hypr_lua/` is the source tree for my Hyprland 0.55+ configuration.

I used the Hyprland wiki and the 0.55 release notes as the source of truth. The main change that mattered here is that `hyprctl dispatch` now expects a Lua dispatcher expression, such as `hl.dsp.layout("...")`, rather than legacy dispatcher names like `layoutmsg`, `resizeactive`, or `submap`.

## Decisions

I did not modify anything under `hypr/`. Those files are still the pre-0.55 reference implementation.

I added new script counterparts under `hypr_lua/scripts/` instead of rewriting the old scripts in place:

- `center-mfact-daemon`
- `delta-resize`
- `master-roll`
- `orientation-cycle`

I kept runtime script references pointed at `~/.config/hypr/scripts/...`. That path is the intended XDG config installation target, so the Lua files should continue to reference it even though the source copies live in `hypr_lua/scripts/`.

I updated `hypr_lua/*.lua` only where the Lua configuration itself still contained legacy Hyprland command syntax. In particular, I replaced `hyprctl dispatch layoutmsg ...` and `hyprctl dispatch submap ...` forms with Lua dispatcher expressions.

I preserved the existing shell-script behavior as much as possible. The master layout helpers still maintain per-workspace orientation state in `/tmp/hypr_orientation_state_ws-*`, still handle special workspaces, and still apply the center-master `mfact` correction.

## Fullscreen Bindings

I found that the initial Lua conversion of the fullscreen bindings did not perfectly match the old `bindings.conf` behavior. The old hyprlang bindings used `fullscreenstate` directly:

- `SUPER + F`: maximize active window with `fullscreenstate, 1, -1`
- `SUPER + SHIFT + F`: window fullscreen with client unaware, `2, 0`
- `SUPER + CTRL + F`: client fullscreen with window unaware, `0, 2`
- `SUPER + ALT + F`: typical fullscreen, `3, 3`
- `SUPER + SHIFT + CTRL + F`: default state, `0, 0`

For the Lua config, I added `action = "toggle"` to the fullscreen variants so they toggle rather than only set the state. The exception is the default-state binding, where I used `action = "set"` because that binding is intended to reset the window state.

`SUPER + F` needed one extra fix. Even with `action = "toggle"`, Hyprland 0.55 did not toggle maximize back off correctly when using `{ internal = 1, client = -1 }`. I changed that binding to run an explicit conditional command: if `hyprctl activewindow -j` reports `.fullscreen == 1`, it sets internal fullscreen back to `0`; otherwise, it sets internal fullscreen to maximize state `1`.

## Validation

I validated the new scripts with shell syntax checks and executable-bit checks.

I searched `hypr_lua/` to confirm there were no remaining legacy command forms for:

- `layoutmsg`
- `resizeactive`
- `dispatch submap`

I verified the new Lua dispatcher parser with:

```sh
hyprctl dispatch 'hl.dsp.no_op()'
```

I reloaded Hyprland and checked for configuration errors:

```sh
hyprctl reload
hyprctl configerrors
```

Both reload and config error checks passed.

## Outcome

The `hypr_lua/` tree now has Hyprland 0.55-compatible script sources and no longer relies on legacy `hyprctl dispatch` command syntax for the migrated script paths and related Lua call sites.

The master layout orientation and roll helpers continue to work with the new Lua dispatcher model. The VM passthrough submap commands use the new `hl.dsp.submap(...)` form. The resize helper now uses `hl.dsp.window.resize(...)` instead of `resizeactive`.

The fullscreen bindings now behave much closer to the original `bindings.conf` behavior, including a working maximize toggle on `SUPER + F`.
