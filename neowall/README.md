# Neowall Managed Assets

Repo-managed Neowall assets for the dual-mode wallpaper workflow.

## Layout

```
neowall/
├── shaders/     # .glsl shader source files (repo copies, installed to ~/.config/neowall/shaders/)
├── previews/    # preview PNGs shown in the selector UI
├── posters/     # poster PNGs used for lockscreen/Omarchy background symlink
├── presets/     # JSON manifest files defining selectable entries
└── README.md
```

## Preset Format

Each `.json` file in `presets/` defines one selectable entry:

```json
{
  "type": "shader",
  "id": "matrix-rain",
  "label": "Matrix Rain",
  "source": "matrix_rain.glsl"
}
```

- `type`: `"shader"` or `"image"`
- `id`: unique identifier; also used to find preview (`previews/<id>.png`) and poster (`posters/<id>.png`)
- `label`: human-readable name shown in the selector
- `source`: filename (for shaders, relative to shaders/ dir) or path (for images)

Image-type entries can also reference wallpaper files directly (for Omarchy compatibility).
