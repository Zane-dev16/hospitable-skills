#!/usr/bin/env bash
# Editable-files install: scripts/install.sh [--mode full|readonly] [--dest DIR]
# Default mode is full; default dest is ~/.agents/skills.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE=full
DEST="$HOME/.agents/skills"
while [ $# -gt 0 ]; do
	case "$1" in
	--mode)
		MODE="$2"
		shift 2
		;;
	--dest)
		DEST="$2"
		shift 2
		;;
	*)
		echo "usage: install.sh [--mode full|readonly] [--dest DIR]"
		exit 2
		;;
	esac
done
[ "$MODE" = full ] || [ "$MODE" = readonly ] || {
	echo "mode must be full|readonly"
	exit 2
}

./scripts/build.sh >/dev/null
if [ "$MODE" = full ]; then SRC=plugins/hospitable/skills/hospitable; else SRC=plugins/hospitable-readonly/skills/hospitable; fi
mkdir -p "$DEST"
rm -rf "$DEST/hospitable"
cp -r "$SRC" "$DEST/hospitable"
echo "OK: installed hospitable ($MODE) to $DEST/hospitable"
