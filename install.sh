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

add_aliases() {
  local rc="$1"
  touch "$rc"
  if grep -q 'lm-status aliases' "$rc"; then
    return
  fi
  cat >> "$rc" <<'EOF'

# --- lm-status aliases ---
alias lm="$HOME/.local/bin/lm"
alias limits="$HOME/.local/bin/lm"
alias status="$HOME/.local/bin/status"
alias st="$HOME/.local/bin/status"
EOF
}

if [[ -f "$HOME/.aliases.sh" ]]; then
  add_aliases "$HOME/.aliases.sh"
else
  add_aliases "$HOME/.bashrc"
fi

if ! [[ ":$PATH:" == *":$DEST:"* ]]; then
  echo
  echo "Add this to ~/.bashrc (Yale accounts usually already have it):"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo
echo "Installed aliases:  lm  limits  status  st"
echo "  lm / limits   AI coding limits (Claude + Codex)"
echo "  status / st   Slurm / YCRC cluster dashboard"
echo
echo "Reload your shell once:  source ~/.bashrc"
echo "Then run:  lm   or   limits"
echo "           status   or   st"
