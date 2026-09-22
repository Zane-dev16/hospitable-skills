# Hospitable skill

One agent skill for the Hospitable Public API v2: properties, calendar, reservations.

## Setup

**1. Install the skill.**

Claude Code:

```bash
/plugin marketplace add Zane-dev16/hospitable-skills
/plugin install hospitable-skills@zane-dev16
```

Codex / other agents:

```bash
npx skills@latest add Zane-dev16/hospitable-skills
```

**2. Add your token.**

Mint it in Hospitable: Apps → API access → new personal access token. Export it; never commit it:

```bash
export HOSPITABLE_PAT="<your token>"
```

**3. Verify it works.**

```bash
curl -H "Authorization: Bearer $HOSPITABLE_PAT" -H "Accept: application/json" \
  https://public.api.hospitable.com/v2/user
```

A `200` with your user object means you are in. Then ask your agent to list properties, check October availability, or show a booking. The skill holds the endpoints, filters, and gotchas.

## Notes

- Reads run freely. Writes (calendar updates, reservation changes, messages) require explicit approval each time.
- This token is the maximum API access available. Anything it cannot reach requires action directly in Hospitable.
- Skill claims marked **verified** were probed live. **TBC** means unprobed and unsafe to rely on.
