# Hospitable skill

One agent skill for the Hospitable Public API v2: properties, search, images, calendar, reservations, enrichment, and messaging. The source is `skills/hospitable/SKILL.md`, and the build produces full and read-only installs with the write examples stripped from the read-only copy.

Details that are not setup live in [docs/notes.md](docs/notes.md).

## Setup

Pick full or read-only, then add the token and check the connection.

Claude Code (full):

```bash
/plugin marketplace add Zane-dev16/hospitable-skills
/plugin install hospitable-skills@zane-dev16
```

Claude Code (read-only):

```bash
/plugin install hospitable-skills-readonly@zane-dev16
```

Codex and other agents (default mode is full):

```bash
npx skills@latest add Zane-dev16/hospitable-skills
./scripts/install.sh --mode readonly
```

Add the token (create it in Hospitable under Apps → API access):

```bash
export HOSPITABLE_PAT="<your token>"
```

Verify:

```bash
curl -H "Authorization: Bearer $HOSPITABLE_PAT" -H "Accept: application/json" \
  https://public.api.hospitable.com/v2/user
```

A 200 with your user object means the token works.

License: MIT (see LICENSE).
