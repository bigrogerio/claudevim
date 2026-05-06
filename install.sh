#!/usr/bin/env bash
# install.sh — link claudevim into ~/.config and into a bin dir on PATH.
#
# Override the bin dir explicitly:
#   CLAUDEVIM_BIN_DIR=/some/path ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG_LINK="$HOME/.config/claudevim"

# ---------------------------------------------------------------------------
# 1. Validate dependencies before touching the filesystem.
# ---------------------------------------------------------------------------
require_cmd() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  ✓ %s\n' "$cmd"
  else
    printf '  ✗ %s — %s\n' "$cmd" "$hint"
    return 1
  fi
}

echo "==> Checking required tools"
missing=0
require_cmd nvim        "install neovim 0.12+ (e.g. brew install neovim)" || missing=1
require_cmd claude      "install claude code (https://docs.claude.com/en/docs/claude-code)" || missing=1
require_cmd tree-sitter "install the tree-sitter CLI (e.g. brew install tree-sitter-cli)" || missing=1
require_cmd git         "install git" || missing=1
if [ $missing -ne 0 ]; then
  echo
  echo "Aborting install. Install the tools marked ✗ above and re-run."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Pick a bin dir on PATH that we can write to.
# ---------------------------------------------------------------------------
echo
echo "==> Locating a writable bin directory on PATH"

candidates=()
if [ -n "${CLAUDEVIM_BIN_DIR:-}" ]; then
  candidates+=("$CLAUDEVIM_BIN_DIR")
fi
candidates+=(
  "/opt/homebrew/bin"   # Apple Silicon Homebrew
  "/usr/local/bin"      # Intel Homebrew / common Linux
  "$HOME/.local/bin"    # XDG-style user-local bin
)

BIN_DIR=""
for dir in "${candidates[@]}"; do
  if [ -z "$dir" ]; then continue; fi
  if [ -d "$dir" ] && [ -w "$dir" ]; then
    BIN_DIR="$dir"
    break
  fi
  if [ "$dir" = "$HOME/.local/bin" ]; then
    if mkdir -p "$dir" 2>/dev/null && [ -w "$dir" ]; then
      BIN_DIR="$dir"
      break
    fi
  fi
done

if [ -z "$BIN_DIR" ]; then
  echo "  ✗ no writable bin dir found in: ${candidates[*]}"
  echo "    Set CLAUDEVIM_BIN_DIR=/some/path on PATH and re-run."
  exit 1
fi
printf '  ✓ %s\n' "$BIN_DIR"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "  ! note: $BIN_DIR is NOT on your PATH."
    echo "    Add this to your shell rc and reopen the terminal:"
    echo "      export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

BIN_LINK="$BIN_DIR/claudevim"

# ---------------------------------------------------------------------------
# 3. Create symlinks.
# ---------------------------------------------------------------------------
echo
echo "==> Creating symlinks"

# Refuse to clobber a real config dir; only replace if it doesn't exist or is
# a symlink.
if [ -e "$CONFIG_LINK" ] && [ ! -L "$CONFIG_LINK" ]; then
  echo "  ✗ $CONFIG_LINK exists and is NOT a symlink (real directory or file)."
  echo "    Move it aside first: mv \"$CONFIG_LINK\" \"$CONFIG_LINK.bak\""
  exit 1
fi
ln -sfn "$REPO/nvim" "$CONFIG_LINK"
printf '  ✓ %s -> %s\n' "$CONFIG_LINK" "$REPO/nvim"

if [ -e "$BIN_LINK" ] && [ ! -L "$BIN_LINK" ]; then
  echo "  ✗ $BIN_LINK exists and is NOT a symlink (real file)."
  echo "    Move it aside first: mv \"$BIN_LINK\" \"$BIN_LINK.bak\""
  exit 1
fi
chmod +x "$REPO/bin/claudevim"
ln -sfn "$REPO/bin/claudevim" "$BIN_LINK"
printf '  ✓ %s -> %s\n' "$BIN_LINK" "$REPO/bin/claudevim"

echo
echo "claudevim installed."
echo "Run:    claudevim"
echo "Resume: claudevim --resume"
