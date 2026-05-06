#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG_LINK="$HOME/.config/claudevim"
BIN_LINK="/opt/homebrew/bin/claudevim"

echo "==> Linking $REPO/nvim -> $CONFIG_LINK"
ln -sfn "$REPO/nvim" "$CONFIG_LINK"

echo "==> Linking $REPO/bin/claudevim -> $BIN_LINK"
chmod +x "$REPO/bin/claudevim"
ln -sfn "$REPO/bin/claudevim" "$BIN_LINK"

echo
echo "claudevim installed."
echo "Run:    claudevim"
echo "Resume: claudevim --resume"
