#!/bin/bash

set -euo pipefail

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
INSTALL_ROOT="${USER_HOME}/.local/opt/caido"
RELEASES_DIR="${INSTALL_ROOT}/releases"
CURRENT_LINK="${INSTALL_ROOT}/current"
BIN_DIR="${USER_HOME}/.local/bin"
BIN_LINK="${BIN_DIR}/caido"
APPLICATIONS_DIR="${USER_HOME}/.local/share/applications"
DESKTOP_FILE="${APPLICATIONS_DIR}/caido.desktop"

SCRIPT_NAME=$(basename "$0")
TMP_DIR=""

cleanup() {
  if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}"
  fi
}

trap cleanup EXIT

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [command]

Commands:
  install         Install or update Caido to the latest x86_64 AppImage release
  update          Update Caido only if a newer release is available
  check           Check whether a newer release is available
  latest          Print the latest GitHub release tag
  uninstall       Remove Caido, its desktop entry, and installed files
  help            Show this help text

Notes:
  - Installs to ${INSTALL_ROOT}
  - Adds a launcher at ${DESKTOP_FILE}
  - Creates a runnable symlink at ${BIN_LINK}
EOF
}

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

require_platform() {
  local os arch
  os=$(uname -s)
  arch=$(uname -m)

  [[ "$os" == "Linux" ]] || die "Caido AppImage installation is only supported on Linux."
  [[ "$arch" == "x86_64" ]] || die "This script only supports x86_64. Detected: ${arch}"
}

http_get() {
  curl --fail --silent --show-error --location "$1"
}

download_file() {
  local url="$1"
  local output="$2"
  curl --fail --silent --show-error --location --output "$output" "$url"
}

current_version() {
  if [[ -L "${CURRENT_LINK}" && -f "${CURRENT_LINK}/VERSION" ]]; then
    cat "${CURRENT_LINK}/VERSION"
  fi
}

latest_release_tag() {
  http_get "https://api.github.com/repos/caido/caido/releases/latest" | jq -r '.tag_name'
}

latest_release_manifest() {
  http_get "https://caido.download/releases/latest"
}

latest_appimage_info() {
  latest_release_manifest | jq -r '
    . as $release
    | .links[]
    | select(.kind == "desktop" and .os == "linux" and .arch == "x86_64" and .format == "AppImage")
    | [$release.version, .link, (.hash // "")]
    | @tsv
  '
}

parse_checksum_file() {
  local checksum_file="$1"
  awk 'match($0, /[0-9a-fA-F]{64,128}/) { print substr($0, RSTART, RLENGTH); exit }' "${checksum_file}"
}

verify_download() {
  local appimage_path="$1"
  local download_url="$2"
  local checksum_path actual_hash expected_hash

  checksum_path="${TMP_DIR}/caido.AppImage.sha512"
  if download_file "${download_url}.sha512" "${checksum_path}"; then
    expected_hash=$(parse_checksum_file "${checksum_path}")
    [[ -n "${expected_hash}" ]] || die "Failed to parse SHA-512 checksum."
    actual_hash=$(sha512sum "${appimage_path}" | awk '{print $1}')
    [[ "${actual_hash}" == "${expected_hash}" ]] || die "SHA-512 checksum verification failed."
    log "Verified download with SHA-512."
    return 0
  fi

  checksum_path="${TMP_DIR}/caido.AppImage.sha256"
  if download_file "${download_url}.sha256" "${checksum_path}"; then
    expected_hash=$(parse_checksum_file "${checksum_path}")
    [[ -n "${expected_hash}" ]] || die "Failed to parse SHA-256 checksum."
    actual_hash=$(sha256sum "${appimage_path}" | awk '{print $1}')
    [[ "${actual_hash}" == "${expected_hash}" ]] || die "SHA-256 checksum verification failed."
    log "Verified download with SHA-256."
    return 0
  fi

  die "No checksum file was available for ${download_url}."
}

write_launcher() {
  mkdir -p "${BIN_DIR}"
  ln -sfn "${CURRENT_LINK}/caido.AppImage" "${BIN_LINK}"
}

write_desktop_entry() {
  mkdir -p "${APPLICATIONS_DIR}"

  cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Type=Application
Name=Caido
Comment=Caido Desktop
Exec=${BIN_LINK} %U
Terminal=false
Categories=Development;Security;Network;
StartupNotify=true
EOF
}

refresh_desktop_database() {
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${APPLICATIONS_DIR}" >/dev/null 2>&1 || true
  fi
}

install_latest() {
  local mode="${1:-install}"
  local installed_version latest_tag info latest_version download_url api_hash
  local target_dir target_appimage

  installed_version=$(current_version || true)
  latest_tag=$(latest_release_tag)
  info=$(latest_appimage_info)

  [[ -n "${info}" ]] || die "Failed to locate the latest Linux x86_64 AppImage."

  IFS=$'\t' read -r latest_version download_url api_hash <<< "${info}"

  [[ "v${latest_version}" == "${latest_tag}" ]] || die "GitHub latest release (${latest_tag}) does not match manifest version (v${latest_version})."

  if [[ "${installed_version:-}" == "${latest_version}" ]]; then
    if [[ "${mode}" == "update" ]]; then
      log "Caido is already up to date at v${installed_version}."
    else
      log "Caido v${installed_version} is already installed."
    fi
    return 0
  fi

  TMP_DIR=$(mktemp -d)
  target_dir="${RELEASES_DIR}/v${latest_version}"
  target_appimage="${target_dir}/caido.AppImage"

  mkdir -p "${target_dir}"

  log "Downloading Caido ${latest_tag}..."
  download_file "${download_url}" "${TMP_DIR}/caido.AppImage"
  verify_download "${TMP_DIR}/caido.AppImage" "${download_url}"

  install -Dm755 "${TMP_DIR}/caido.AppImage" "${target_appimage}"
  printf '%s\n' "${latest_version}" > "${target_dir}/VERSION"

  mkdir -p "${INSTALL_ROOT}"
  ln -sfn "${target_dir}" "${CURRENT_LINK}"
  write_launcher
  write_desktop_entry
  refresh_desktop_database

  log "Installed Caido ${latest_tag}."
  if [[ -n "${installed_version:-}" ]]; then
    log "Previous version: v${installed_version}"
  fi
  if [[ -n "${api_hash}" && "${api_hash}" != "null" ]]; then
    log "Release metadata also advertises a hash via caido.download."
  fi
}

check_update() {
  local installed_version latest_tag latest_version download_url api_hash
  installed_version=$(current_version || true)
  latest_tag=$(latest_release_tag)

  IFS=$'\t' read -r latest_version download_url api_hash <<< "$(latest_appimage_info)"

  if [[ -z "${installed_version:-}" ]]; then
    log "Caido is not installed. Latest available release: ${latest_tag}"
    return 0
  fi

  if [[ "${installed_version}" == "${latest_version}" ]]; then
    log "Caido is up to date at ${latest_tag}."
  else
    log "Update available: installed v${installed_version}, latest ${latest_tag}."
  fi
}

uninstall_caido() {
  rm -f "${BIN_LINK}"
  rm -f "${DESKTOP_FILE}"
  rm -rf "${INSTALL_ROOT}"
  refresh_desktop_database
  log "Caido has been uninstalled."
}

main() {
  local command="${1:-install}"

  require_platform
  require_cmd curl
  require_cmd jq
  require_cmd install
  require_cmd sha256sum
  require_cmd sha512sum

  case "${command}" in
    install)
      install_latest "install"
      ;;
    update)
      install_latest "update"
      ;;
    check)
      check_update
      ;;
    latest)
      latest_release_tag
      ;;
    uninstall)
      uninstall_caido
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
