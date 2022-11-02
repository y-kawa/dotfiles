#!/usr/bin/env bash
set -x

echo "$0"
echo "$(dirname "$0")"
CUR_DIR="$(cd "$(dirname "$0")" || exit 1; pwd)"
REPO_DIR="$(cd "$(dirname "$0")/.." || exit 1; pwd)"

ln -sfv "$CUR_DIR/.zshrc" "$HOME/.zshrc"
