# Hospitable Skills

Agent skills for the Hospitable Public API v2 (Core-3: Properties, Calendar, Reservations).

## Install

**Claude Code (managed plugin):**

```bash
/plugin marketplace add Zane-dev16/hospitable-skills
/plugin install hospitable-skills@zane-dev16
```

**Codex / other agents (editable files):**

```bash
npx skills@latest add Zane-dev16/hospitable-skills
```

## Skills

One skill: [`hospitable`](skills/hospitable/SKILL.md) — auth, properties, calendar, reservations. Load it for any Hospitable work.

## Auth

```bash
export HOSPITABLE_PAT="<pat from my.hospitable.com → Apps → API access>"
curl -H "Authorization: Bearer $HOSPITABLE_PAT" -H "Accept: application/json" \
  https://public.api.hospitable.com/v2/properties?per_page=10
```

Details: [`skills/hospitable/SKILL.md`](skills/hospitable/SKILL.md). Discovery notes: [`docs/discovery/`](docs/discovery/). Spec: [`specs/001-hospitable-core3-skills-library.md`](specs/001-hospitable-core3-skills-library.md).

## Verification labels

- **verified** = fetched live this repo's discovery phase
- **triangulated** = confirmed via community mirrors (kacao/keithah/silkyland), needs live probe
- **TBC** = URL from docs nav, body not fetched, so do not rely on it
