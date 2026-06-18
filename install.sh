#!/bin/sh
set -eu

REPO_URL="https://raw.githubusercontent.com/jeremysball/always-be-sessioning/main/abs.sh"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/abs"

mkdir -p "$INSTALL_DIR"
tmp_file=$(mktemp "$INSTALL_DIR/.abs.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

if ! curl -fsSL "$REPO_URL" -o "$tmp_file"; then
    echo "install.sh: failed to download $REPO_URL" >&2
    exit 1
fi

if [ ! -s "$tmp_file" ]; then
    echo "install.sh: downloaded file is empty" >&2
    exit 1
fi

chmod +x "$tmp_file"
mv "$tmp_file" "$INSTALL_PATH"

echo "Installed abs to $INSTALL_PATH"

case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo "Note: $INSTALL_DIR is not on your PATH yet." >&2
        echo "See the README's PATH setup section for your shell." >&2
        ;;
esac

if ! command -v claude >/dev/null 2>&1; then
    echo "Note: claude was not found on your PATH. abs needs it installed and authenticated." >&2
fi

echo ""
echo "Get started with:"
echo "  abs run    # start the daemon"
echo "  abs logs   # follow its log"
