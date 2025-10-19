#!/usr/bin/env bash
set -euo pipefail

PRIMARY_REMOTE="${KSO_REMOTE_BASE:-https://dep.karmaos.ovh/kso}"
FALLBACK_REMOTE="https://dep.karmaos.ovh/karma"

need_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "This installer must run as root. Re‑run with: sudo bash"
    exit 1
  fi
}

require_bin() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }
}

install_kso() {
  echo ">>> Installing KSO core to /usr/local/bin/kso"
  tmp="$(mktemp)"
  if curl -fsSL "$PRIMARY_REMOTE/kso" -o "$tmp"; then
    :
  elif curl -fsSL "$FALLBACK_REMOTE/kso" -o "$tmp"; then
    :
  else
    echo "Failed to download kso core from $PRIMARY_REMOTE (and fallback)."
    exit 1
  fi
  install -m 0755 "$tmp" /usr/local/bin/kso
  rm -f "$tmp"
}

post_init() {
  echo ">>> Initializing KSO…"
  /usr/local/bin/kso init || true
  echo ">>> Done. Try: kso help"
}

main() {
  need_root
  require_bin curl
  require_bin install
  install_kso
  post_init
}

main "$@"
