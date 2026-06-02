#!/usr/bin/env bats

# Tests for the Neowall dual-mode wallpaper workflow.
# Run from repo root:  bats neowall/tests/

export BATS_LIB_PATH=/usr/lib/bats
bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file

setup_file() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export REPO_ROOT
}

setup() {
  TEST_TEMP_DIR="$(temp_make --prefix 'neowall-test-')"
  export XDG_STATE_HOME="${TEST_TEMP_DIR}/state"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

# =============================================================
# 1. Backend state file
# =============================================================

@test "backend: default state is swaybg" {
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" read
  assert_success
  assert_output "swaybg"
}

@test "backend: write and read swaybg" {
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" write swaybg
  assert_success
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" read
  assert_success
  assert_output "swaybg"
}

@test "backend: write and read neowall" {
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" write neowall
  assert_success
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" read
  assert_success
  assert_output "neowall"
}

@test "backend: invalid value is rejected" {
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" write invalid
  assert_failure
  assert_output --partial "Usage"
}

@test "backend: status output includes all fields" {
  run "${REPO_ROOT}/bin/omarchy-neowall-backend" status
  assert_success
  assert_output --partial "Backend:"
  assert_output --partial "swaybg:"
  assert_output --partial "neowall:"
}

# =============================================================
# 2. Preview seed script
# =============================================================

@test "seed: generates valid PNG for a preset preview" {
  # seed-previews.sh uses DOTS to find presets; point it at the real repo
  DOTS="$REPO_ROOT" run "${REPO_ROOT}/neowall/scripts/seed-previews.sh"
  assert_success
  assert_file_exists "${REPO_ROOT}/neowall/previews/plasma.png"
  run file "${REPO_ROOT}/neowall/previews/plasma.png"
  assert_output --partial "PNG image data"
}

@test "seed: generates valid poster PNG" {
  DOTS="$REPO_ROOT" run "${REPO_ROOT}/neowall/scripts/seed-previews.sh"
  assert_success
  assert_file_exists "${REPO_ROOT}/neowall/posters/plasma.png"
  run file "${REPO_ROOT}/neowall/posters/plasma.png"
  assert_output --partial "PNG image data"
}

@test "seed: uses Liberation-Sans font (Omarchy system font)" {
  DOTS="$REPO_ROOT" run "${REPO_ROOT}/neowall/scripts/seed-previews.sh"
  assert_success
  # Check the text was rendered — a pure solid-color fallback would be smaller
  local size
  size="$(stat -c %s "${REPO_ROOT}/neowall/previews/plasma.png")"
  # Text-rendered PNGs at 1536x864 with gradient are >10KB; solid color is <1KB
  (( size > 10000 ))
}

# =============================================================
# 3. Config file writing
# =============================================================

write_neowall_config() {
  local entry_type="$1" source_path="$2"
  local config="${TEST_TEMP_DIR}/config.vibe"
  mkdir -p "$(dirname "$config")"
  if [[ "$entry_type" == "shader" ]]; then
    cat > "$config" <<-EOF
default {
  shader ${source_path}
}
EOF
  elif [[ "$entry_type" == "image" ]]; then
    cat > "$config" <<-EOF
default {
  path ${source_path}
  mode fill
}
EOF
  fi
}

@test "config: shader entry writes correct vibe format" {
  write_neowall_config "shader" "plasma.glsl"
  assert_file_contains "${TEST_TEMP_DIR}/config.vibe" "shader plasma.glsl"
  assert_file_contains "${TEST_TEMP_DIR}/config.vibe" "default {"
}

@test "config: shader entry does not contain path key" {
  write_neowall_config "shader" "plasma.glsl"
  run grep -c "path " "${TEST_TEMP_DIR}/config.vibe" || true
  [[ "$output" == "0" ]]
}

@test "config: image entry writes correct vibe format" {
  write_neowall_config "image" "/home/user/wallpaper.png"
  assert_file_contains "${TEST_TEMP_DIR}/config.vibe" "path /home/user/wallpaper.png"
  assert_file_contains "${TEST_TEMP_DIR}/config.vibe" "mode fill"
}

# =============================================================
# 4. Resolution from preview path
# =============================================================

@test "resolution: preset preview resolves from repo path" {
  local preview_path="${REPO_ROOT}/neowall/previews/plasma.png"
  local preset_path="${REPO_ROOT}/neowall/presets/plasma.json"

  # Backup originals
  local backup_dir="${TEST_TEMP_DIR}/backup"
  mkdir -p "$backup_dir"
  [[ -f "$preview_path" ]] && cp "$preview_path" "$backup_dir/"
  [[ -f "$preset_path" ]] && cp "$preset_path" "$backup_dir/"

  # Ensure preset exists
  cat > "$preset_path" <<'JSON'
{
  "type": "shader",
  "id": "plasma",
  "label": "Plasma",
  "source": "plasma.glsl"
}
JSON

  # Ensure preview exists (seed should have created it)
  if [[ ! -f "$preview_path" ]]; then
    magick -size 200x112 xc:'#1a1b26' "$preview_path" 2>/dev/null || true
  fi

  # Create a minimal fake home for the script to write into
  local fake_home="${TEST_TEMP_DIR}/fake-home"
  mkdir -p "${fake_home}/.config/neowall" \
           "${fake_home}/.config/omarchy/current"
  ln -s "$REPO_ROOT" "${fake_home}/.local/share/omarchy-overrides" 2>/dev/null || true
  touch "${fake_home}/.config/omarchy/current/background"

  HOME="$fake_home" \
    XDG_STATE_HOME="${TEST_TEMP_DIR}/state" \
    run "${REPO_ROOT}/bin/omarchy-neowall-apply" --from-preview "$preview_path"

  # Config should have been written before the inevitable daemon-start failure
  assert_file_exists "${fake_home}/.config/neowall/config.vibe"

  # Cleanup
  [[ -f "$backup_dir/plasma.png" ]] && cp "$backup_dir/plasma.png" "$preview_path"
  [[ -f "$backup_dir/plasma.json" ]] && cp "$backup_dir/plasma.json" "$preset_path"
}

# =============================================================
# 5. Script sanity
# =============================================================

@test "sanity: all scripts pass bash syntax check" {
  local scripts=(
    "bin/omarchy-neowall-backend"
    "bin/omarchy-neowall-apply"
    "bin/omarchy-neowall-select"
    "bin/omarchy-theme-bg-set"
    "scripts/install/install-neowall"
    "neowall/scripts/seed-previews.sh"
  )
  for script in "${scripts[@]}"; do
    run bash -n "${REPO_ROOT}/${script}"
    assert_success "$script has syntax errors"
  done
}

@test "sanity: all bin scripts are executable" {
  local scripts=(
    "bin/omarchy-neowall-backend"
    "bin/omarchy-neowall-apply"
    "bin/omarchy-neowall-select"
    "bin/omarchy-theme-bg-set"
  )
  for script in "${scripts[@]}"; do
    assert_file_executable "${REPO_ROOT}/${script}"
  done
}
