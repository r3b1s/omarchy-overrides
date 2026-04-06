#!/usr/bin/env bash
set -euo pipefail

REPO="rtk-ai/rtk"
BINARY_NAME="rtk"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
ASSET_NAME="rtk-x86_64-unknown-linux-musl.tar.gz"

# --- helpers ---

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

require_cmd() {
  command -v "$1" &>/dev/null || die "'$1' is required but not installed"
}

fetch_latest_version() {
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"\(.*\)".*/\1/'
}

installed_version() {
  if command -v "$BINARY_NAME" &>/dev/null; then
    "$BINARY_NAME" --version 2>/dev/null | awk '{print $2}' || echo "unknown"
  else
    echo "none"
  fi
}

download_and_verify() {
  local version="$1"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" RETURN

  local base_url="https://github.com/${REPO}/releases/download/${version}"

  info "Downloading ${ASSET_NAME} (${version})..."
  curl -fsSL "${base_url}/${ASSET_NAME}" -o "${tmpdir}/${ASSET_NAME}" \
    || die "Failed to download binary"

  info "Downloading checksums..."
  curl -fsSL "${base_url}/checksums.txt" -o "${tmpdir}/checksums.txt" \
    || die "Failed to download checksums"

  info "Verifying checksum..."
  # checksums.txt entries use the bare filename; run sha256sum from inside tmpdir
  local expected actual
  expected=$(grep " ${ASSET_NAME}$" "${tmpdir}/checksums.txt" | awk '{print $1}')
  [[ -n "$expected" ]] || die "No checksum entry found for ${ASSET_NAME}"

  actual=$(sha256sum "${tmpdir}/${ASSET_NAME}" | awk '{print $1}')

  if [[ "$expected" != "$actual" ]]; then
    die "Checksum mismatch!
  expected: ${expected}
  actual:   ${actual}
Aborting installation."
  fi
  info "Checksum OK"

  info "Extracting..."
  tar -xzf "${tmpdir}/${ASSET_NAME}" -C "${tmpdir}"

  local binary
  binary=$(find "$tmpdir" -maxdepth 2 -type f -name "$BINARY_NAME" | head -1)
  [[ -n "$binary" ]] || die "Binary '${BINARY_NAME}' not found in archive"

  install -Dm755 "$binary" "${INSTALL_DIR}/${BINARY_NAME}"
  info "Installed ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}"
}

# --- subcommands ---

cmd_install() {
  [[ ! -f "${INSTALL_DIR}/${BINARY_NAME}" ]] \
    || die "'${BINARY_NAME}' is already installed at ${INSTALL_DIR}/${BINARY_NAME}. Use 'update' to upgrade."

  require_cmd curl
  require_cmd sha256sum
  require_cmd tar

  local version
  version=$(fetch_latest_version)
  [[ -n "$version" ]] || die "Could not determine latest version"

  info "Latest version: ${version}"
  download_and_verify "$version"
  info "Installation complete. Run 'rtk --version' to verify."
}

cmd_update() {
  require_cmd curl
  require_cmd sha256sum
  require_cmd tar

  local latest installed
  latest=$(fetch_latest_version)
  [[ -n "$latest" ]] || die "Could not determine latest version"

  installed=$(installed_version)

  if [[ "$installed" != "none" && "v${installed}" == "$latest" ]]; then
    info "Already up to date (${installed}). Nothing to do."
    exit 0
  fi

  info "Updating ${BINARY_NAME}: ${installed} -> ${latest}"
  download_and_verify "$latest"
  info "Update complete."
}

cmd_uninstall() {
  local target="${INSTALL_DIR}/${BINARY_NAME}"
  if [[ ! -f "$target" ]]; then
    info "'${BINARY_NAME}' is not installed at ${target}."
    exit 0
  fi
  rm "$target"
  info "Removed ${target}."
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  install     Download and install the latest rtk binary
  update      Upgrade to the latest version (no-op if already current)
  uninstall   Remove the installed binary

Environment:
  INSTALL_DIR   Where to install the binary (default: /usr/local/bin)
EOF
}

# --- entrypoint ---

case "${1:-}" in
  install)   cmd_install ;;
  update)    cmd_update ;;
  uninstall) cmd_uninstall ;;
  *)         usage; exit 1 ;;
esac
