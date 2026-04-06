# Omarchy Overrides

Opinionated take on an opinionated distro. Idempotent and easily uncoupled (hopefully).

An attempt at heavy customization that's easily updated and doesn't risk breaking the core system.

Always a work-in-progress.

## Setup
The one-liner is intended to be ran on a fresh [omarchy](https://omarchy.org/) installation.

```sh
curl -fsSL https://raw.githubusercontent.com/reg1z/omarchy-overrides/refs/heads/main/scripts/get-dots | bash
```

Clones the repo and launches the setup script.

## Updating
When updating the system, it's best to use `sever-and-update`.

![demo](https://raw.githubusercontent.com/reg1z/media-assets/refs/heads/main/omarchy-overrides/update-demo.gif)

`sever-and-update` decouples all overrides -- temporarily severing all symlinks, restores changes made to the internal omarchy git repo (`~/.local/share/omarchy`) -- then runs `omarchy-update` and other misc updates (flatpak/npm/pulling latest changes from this repo) before re-applying overrides. Unless prompted in the terminal for input, it's best to leave things alone during this process.
