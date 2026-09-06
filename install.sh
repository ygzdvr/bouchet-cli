#!/usr/bin/env bash
# Install bouchet-cli: dashboards + shell aliases
set -euo pipefail

REPO="${BOUCHET_CLI_REPO:-ygzdvr/bouchet-cli}"
BRANCH="${BOUCHET_CLI_BRANCH:-main}"
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

ALIAS_BLOCK='# --- bouchet-cli aliases ---
alias g="git"

# fresh session
alias cl="claude --dangerously-skip-permissions"
alias cx="codex --yolo"
# resume previous session
alias clr="claude --dangerously-skip-permissions --resume"
alias cxr="codex --yolo resume"

alias lm="$HOME/.local/bin/lm"
alias limits="$HOME/.local/bin/lm"
alias status="$HOME/.local/bin/status"
alias st="$HOME/.local/bin/status"'

add_if_missing() {
  local rc="$1" name="$2" line="$3"
  grep -qE "^[[:space:]]*alias ${name}=" "$rc" 2>/dev/null || printf '%s\n' "$line" >> "$rc"
}

add_aliases() {
  local rc="$1"
  touch "$rc"
  if grep -q 'bouchet-cli aliases' "$rc"; then
    return
  fi
  if grep -q 'lm-status aliases' "$rc"; then
    sed -i 's/lm-status aliases/bouchet-cli aliases/' "$rc"
    add_if_missing "$rc" g 'alias g="git"'
    add_if_missing "$rc" cl 'alias cl="claude --dangerously-skip-permissions"'
    add_if_missing "$rc" cx 'alias cx="codex --yolo"'
    add_if_missing "$rc" clr 'alias clr="claude --dangerously-skip-permissions --resume"'
    add_if_missing "$rc" cxr 'alias cxr="codex --yolo resume"'
    return
  fi
  printf '\n%s\n' "$ALIAS_BLOCK" >> "$rc"
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
echo "Installed aliases:"
echo "  g              git"
echo "  cl / clr       Claude (skip permissions; clr resumes)"
echo "  cx / cxr       Codex (--yolo; cxr resumes)"
echo "  lm / limits    AI coding limits"
echo "  status / st    Slurm / YCRC cluster dashboard"
echo
echo "Reload your shell once:  source ~/.bashrc"
echo "Then run:  lm   or   limits"
echo "           status   or   st"
echo "           cl  /  cx  /  clr  /  cxr"
