#!/usr/bin/env bash
# Install lm (AI usage) and status (Slurm/YCRC cluster dashboard) into ~/.local/bin
set -euo pipefail

REPO="${LM_STATUS_REPO:-ygzdvr/lm-status}"
BRANCH="${LM_STATUS_BRANCH:-main}"
DEST="${PREFIX:-$HOME/.local/bin}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

mkdir -p "$DEST"

here=""
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "-" && -f "${BASH_SOURCE[0]}" ]]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

copy_or_fetch() {
  local name="$1"
  if [[ -n "$here" && -f "$here/bin/$name" ]]; then
    cp "$here/bin/$name" "$DEST/$name"
  else
    command -v curl >/dev/null 2>&1 || { echo "curl is required for one-line install" >&2; exit 1; }
    curl -fsSL "https://raw.githubusercontent.com/${REPO}/${BRANCH}/bin/${name}" -o "$DEST/$name"
  fi
  chmod +x "$DEST/$name"
}

copy_or_fetch lm
copy_or_fetch status
ln -sfn status "$DEST/st"

if ! [[ ":$PATH:" == *":$DEST:"* ]]; then
  echo
  echo "Add this to ~/.bashrc (Yale accounts usually already have it):"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo "then:  source ~/.bashrc"
fi

echo
echo "Installed:"
echo "  $DEST/lm      AI coding limits (Claude + Codex)"
echo "  $DEST/status  Slurm / YCRC cluster dashboard"
echo "  $DEST/st      same as status"
echo
echo "Run:  lm"
echo "      status"
echo "      st"
