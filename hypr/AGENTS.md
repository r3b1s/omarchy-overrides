# omarchy-overrides/hypr
This folder houses hyprland-specific configurations & overrides.

Hyprland is frequently updated and its documentation is in a constant state of flux.

## Use only the official Hypr-ecosystem source code as authoritative, canonical reference documentation
To ensure you have the most up-to-date sources of information, please only use the official hyprland-wiki + hyprland source code as authoritative sources of information. A local copy of these repositories should always be kept on the system. Please attempt to fetch/pull the latest changes before beginning the process of researching these references.
- To ensure you use reference the correct version of the wiki / hyprland source code for a locally installed instance of hyprland, run `hyprctl version` to cross reference the installed version with its corresponding version of the wiki. The wiki maintains documentation for most previous editions of hyprland.
- Local copies of the source code are located at:
  - `~/Repos/hyprland-wiki`
  - `~/Repos/Hyprland`
  - If these are not present, please `mkdir -p ~/Repos` and attempt to clone them to this folder via `git clone https://github.com/hyprwm/hyprland-wiki.git` & `git clone https://github.com/hyprwm/Hyprland.git`. This should be attempted before ever considering retrieval of canonical information via any web search/exploration.
- Other sources of information, such as other third party sites, forums, or information internalized within language models via finetuning/training is often out of date by the time a user makes a request involving hyprland configurations like those defined in this folder.
