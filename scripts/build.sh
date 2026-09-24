#!/usr/bin/env bash
# Build the two installable skill modes from the single source.
#   Full:     everything (default mode at install).
#   Readonly: WRITE blocks stripped + read-only banner; must contain zero write examples.
set -euo pipefail
cd "$(dirname "$0")/.."

SRC=skills/hospitable/SKILL.md
VERSION=$(cat VERSION)
FULL=plugins/hospitable
RO=plugins/hospitable-readonly

FULL_BANNER='> Full-access build: reads run freely; writes (calendar updates, reservation changes, messages) require explicit approval each time.'
RO_BANNER='> Read-only build: GET requests only. Refuse calendar updates, reservation changes, enrichment writes, and message sends; tell the user which access the task needs.'
RO_DESC='description: "Work with the Hospitable Public API v2 (read-only). Use for Hospitable reads: auth headers, properties, search, images, calendar reads, reservations, or message history."'

# 1. Markers balanced and present.
o=$(grep -c 'WRITE-BEGIN' "$SRC")
c=$(grep -c 'WRITE-END' "$SRC")
[ "$o" = "$c" ] && [ "$o" -gt 0 ] || {
	echo "FAIL: unbalanced WRITE markers ($o/$c)"
	exit 1
}

rm -rf "$FULL" "$RO"
mkdir -p "$FULL/skills/hospitable" "$RO/skills/hospitable"

insert_banner() { # $1=banner $2=src $3=dest
	awk -v banner="$1" 'BEGIN{d=0} /^---$/ {d++; print; if (d==2) print banner; next} {print}' "$2" >"$3"
}

# 2. Full = source + banner.
insert_banner "$FULL_BANNER" "$SRC" "$FULL/skills/hospitable/SKILL.md"

# 3. Readonly = strip WRITE blocks + banner + read-only description.
sed '/<!-- WRITE-BEGIN -->/,/<!-- WRITE-END -->/d' "$SRC" | sed 's/Reads verified; every write below is TBC — no write probe has ever run on this account\./Reads verified. This build contains no write examples — see the full-access build for those (all TBC)./' >"$RO/skills/hospitable/SKILL.md.tmp"
SRC_DESC=$(sed -n 's/^description: .*/&/p' "$SRC" | head -1)
awk -v banner="$RO_BANNER" -v desc="$RO_DESC" -v srcdesc="$SRC_DESC" \
	'BEGIN{d=0} /^---$/ {d++; print; if (d==2) print banner; next} $0==srcdesc {print desc; next} {print}' \
	"$RO/skills/hospitable/SKILL.md.tmp" >"$RO/skills/hospitable/SKILL.md"
rm "$RO/skills/hospitable/SKILL.md.tmp"

# 4. Per-mode plugin manifests (single version source).
mkmanifest() { # $1=dir $2=name $3=desc
	cat >"$1/plugin.json" <<EOF
{"author": {"name": "Irell Zane"}, "description": "$3", "homepage": "https://github.com/Zane-dev16/hospitable-skills", "keywords": ["hospitable", "skills", "api"], "license": "MIT", "name": "$2", "repository": "https://github.com/Zane-dev16/hospitable-skills", "skills": ["./skills/hospitable"], "version": "$VERSION"}
EOF
}
mkmanifest "$FULL" hospitable-skills "Agent skills for the Hospitable Public API v2 (properties, calendar, reservations). Full access: reads plus calendar, reservation, and messaging writes."
mkmanifest "$RO" hospitable-skills-readonly "Agent skills for the Hospitable Public API v2 (properties, calendar, reservations). Read-only: no examples for any write operation."

# 5. Gate: readonly must contain zero write examples or marker leftovers;
#    full must contain the write blocks.
if grep -nE 'curl +-X|WRITE-(BEGIN|END)' "$RO/skills/hospitable/SKILL.md"; then
	echo "FAIL: readonly build contains write examples or markers"
	exit 1
fi
grep -q 'calendar/block' "$FULL/skills/hospitable/SKILL.md" || {
	echo "FAIL: full build lost write blocks"
	exit 1
}
grep -q 'Idempotency-Key' "$FULL/skills/hospitable/SKILL.md" || {
	echo "FAIL: full build lost write blocks"
	exit 1
}
python3 -c "import json; [json.load(open(f)) for f in ['$FULL/plugin.json','$RO/plugin.json','.claude-plugin/marketplace.json']]"
echo "OK: built full + readonly ($VERSION), gates green"
