#!/usr/bin/env bash
# Generate all Neowall preview and poster images.
# Called by install-neowall and can be re-run manually to regenerate.
# Uses Liberation-Sans (Omarchy's theme font) for consistent typography.

set -euo pipefail

DOTS="${HOME}/.local/share/omarchy-overrides"
PREVIEW_OUT_DIR="${DOTS}/neowall/previews"
POSTER_OUT_DIR="${DOTS}/neowall/posters"
PRESETS_DIR="${DOTS}/neowall/presets"
NEOWALL_SHADERS_DIR="${HOME}/.config/neowall/shaders"
USER_PREVIEWS_DIR="${HOME}/.config/neowall/previews"
USER_SHADERS_DIR="${HOME}/.config/neowall/shaders"

log() { echo "  >>> $*"; }

# Generate a preview PNG using Omarchy's theme font (Liberation-Sans).
# Three fallbacks: gradient+text → solid+text → plain solid color.
make_preview() {
  local path="$1" label="$2" subtitle="${3:-}"
  mkdir -p "$(dirname "$path")"

  # Attempt 1: gradient + annotated label with Omarchy font
  if magick -size 1536x864 gradient:'#1a1b26'-'#0f0f1a' \
    -font Liberation-Sans-Bold -pointsize 48 \
    -fill '#c0caf5' -gravity center \
    -annotate +0-20 "${label}" \
    "$path" 2>/dev/null; then
    if [[ -n "${subtitle:-}" ]]; then
      magick "$path" \
        -font Liberation-Sans -pointsize 24 \
        -fill '#565f89' -gravity center \
        -annotate +0+40 "${subtitle}" \
        "$path" 2>/dev/null || true
    fi
    return
  fi

  # Attempt 2: solid color + label
  if magick -size 1536x864 xc:'#1a1b26' \
    -font Liberation-Sans-Bold -pointsize 48 \
    -fill '#c0caf5' -gravity center \
    -annotate 0 "${label}" \
    "$path" 2>/dev/null; then
    return
  fi

  # Attempt 3: plain solid color — entry still shows up
  magick -size 1536x864 xc:'#1a1b26' "$path" 2>/dev/null || true
}

make_poster() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  magick -size 1920x1080 gradient:'#1a1b26'-'#0f0f1a' "$path" 2>/dev/null || \
    magick -size 1920x1080 xc:'#1a1b26' "$path" 2>/dev/null || true
}

# Generate preset previews
seed_presets() {
  local count=0
  if [[ ! -d "$PRESETS_DIR" ]]; then return; fi

  for f in "$PRESETS_DIR"/*.json; do
    [[ -f "$f" ]] || continue
    local preset_id preset_label preset_type
    preset_id=$(jq -r '.id // empty' "$f")
    preset_label=$(jq -r '.label // empty' "$f")
    preset_type=$(jq -r '.type // "shader"' "$f")
    [[ -n "$preset_id" ]] || continue

    make_preview "$PREVIEW_OUT_DIR/${preset_id}.png" "$preset_label" "${preset_type} preset"
    make_poster "$POSTER_OUT_DIR/${preset_id}.png"
    count=$((count + 1))
  done

  log "Seeded $count preset previews/ posters"
}

# Generate previews for bundled neowall shaders
seed_bundled_shaders() {
  local count=0
  local seen_shaders_set=false

  # Collect shader dirs: user config first, then system paths
  local dirs=()
  [[ -d "$USER_SHADERS_DIR" ]] && dirs+=("$USER_SHADERS_DIR")
  [[ -d "/usr/local/share/neowall/shaders" ]] && dirs+=("/usr/local/share/neowall/shaders")
  [[ -d "/usr/share/neowall/shaders" ]] && dirs+=("/usr/share/neowall/shaders")
  [[ -d "/usr/lib/neowall/shaders" ]] && dirs+=("/usr/lib/neowall/shaders")

  if [[ ${#dirs[@]} -eq 0 ]]; then
    return
  fi

  declare -A seen
  for dir in "${dirs[@]}"; do
    for f in "$dir"/*.glsl; do
      [[ -f "$f" ]] || continue
      local basename
      basename=$(basename "$f" .glsl)

      # Deduplicate
      if [[ -n "${seen[$basename]:-}" ]]; then continue; fi
      seen[$basename]=1

      # Skip if repo preset already covers it
      if [[ -f "$PREVIEW_OUT_DIR/${basename}.png" ]]; then continue; fi

      # Generate label from filename
      local label
      label=$(echo "$basename" | sed 's/_/ /g; s/-/ /g' | sed 's/\b\(.\)/\u\1/g')

      make_preview "$USER_PREVIEWS_DIR/${basename}.png" "$label" "bundled shader"
      count=$((count + 1))
    done
  done

  log "Seeded $count bundled shader previews"
}

# Main
rm -f "$PREVIEW_OUT_DIR"/*.png "$POSTER_OUT_DIR"/*.png "$USER_PREVIEWS_DIR"/*.png
seed_presets
seed_bundled_shaders

log "Preview seeding complete"
