# 001 Hyprland Lua Migration

This is the first decision document in this repository, even though the repository itself has existed for far longer.

## Context

I migrated my Hyprland overrides from hyprlang `.conf` files to Hyprland 0.55 Lua configuration files so they can work with the latest Omarchy dev channel. I staged the conversion in `hypr_lua/` first, then copied those files into `~/.config/hypr/` for live validation after upgrading.

## Decisions

I kept `hypr_lua/` as a staging directory only. The Lua modules use final runtime require paths like `require("hypr.bindings")`, because the files are intended to live in `~/.config/hypr/` once activated.

I preserved Omarchy's upstream Lua entrypoint structure and load order where possible. Defaults load first, then theme overrides, then my personal overrides, so my configuration remains compatible with Omarchy's current model instead of replacing it wholesale.

I kept non-compositor Hypr ecosystem files as `.conf` files. Files like `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, and `xdph.conf` were not part of this migration because Omarchy and Hyprland still treat those separately.

I converted bindings with helpers, but I kept unbinds explicit at the call sites. This makes the resulting Lua easier to audit against the original `bindings.conf` and avoids hiding behavior inside helpers like `scratchpad()`.

I preserved the original keycode variable table in Lua. I chose this over raw `code:*` literals in the binding body so the Lua file remains close to the original configuration and easier to compare during future migrations.

I used `layout_opts` for workspace rules instead of the old hyprlang `layoutopt` spelling. Hyprland 0.55's Lua stubs show `layout_opts` as the supported field, and live validation confirmed `layoutopt` causes config errors.

I kept known 0.54-era settings when parity mattered, but annotated risky ones. For example, `blur.new_optimizations` is kept for parity and marked for validation because Hyprland's option surface changes between releases.

I fixed obvious broken references from the original hyprlang config instead of preserving them exactly. In particular, the Lua config uses concrete Obsidian and task manager descriptions/commands where the old config referenced undefined variables.

## Validation

I validated the Lua files with a parser before activating them. After copying the files into `~/.config/hypr/`, I used `hyprctl reload` and `hyprctl configerrors` to catch live Hyprland 0.55 API issues.

The first live failure came from Lua's multiple return values: `string.gsub()` returned both the replaced string and a replacement count, and the count was accidentally passed as the `opts` argument to my `bind()` helper. I fixed that by wrapping the `gsub()` calls in parentheses so only the first return value is passed.

The second live failure came from `layoutopt`; I fixed it by using `layout_opts` with a table shape matching the installed Hyprland Lua stubs.

## Outcome

The migrated Lua configuration now reloads cleanly on Hyprland 0.55, and `hyprctl configerrors` reports no errors. The staged `hypr_lua/` copy remains the source version of my converted overrides, while the active copies live under `~/.config/hypr/`.
