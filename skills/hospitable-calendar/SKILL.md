---
name: hospitable-calendar
description: Read and update Hospitable property calendars. Use when checking availability, rates, restrictions, blocking or unblocking dates, or changing pricing.
license: MIT
---

# Hospitable Calendar

Needs `skills/hospitable-auth/SKILL.md` for base, headers, envelopes.

## Endpoints (reads verified; writes TBC — no write probe run)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

# Read: dates OPTIONAL (missing end → start+14d; no params → today+14d, 200). Day: {date,day,min_stay,note,closed_for_checkin/closed_for_checkout,status:{reason,source,source_type,available},price:{amount,currency,formatted}}
curl -H "$H" "$BASE/properties/{uuid}/calendar?start_date=2026-10-01&end_date=2026-10-31"

# Update (TBC — no write probe run): additive, max 60 dates per call, max ~1095d out, async-apply (poll GET after)
curl -X PUT -H "$H" -H 'Content-Type: application/json' \
  -d '{"days":[{"date":"2026-10-05","available":false}]}' \
  "$BASE/properties/{uuid}/calendar"

# Range conveniences (TBC — unprobed, no writes run)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"start_date":"2026-10-05","end_date":"2026-10-08"}' "$BASE/properties/{uuid}/calendar/block"
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"start_date":"2026-10-05","end_date":"2026-10-08"}' "$BASE/properties/{uuid}/calendar/unblock"
```

## Gotchas

- Chunk updates to ≤60 dates; validate horizon before sending.
- `calendar_restricted` channel flag → PUT fails 422 with channel message, so surface a friendly error instead of retrying blindly.
- Status `reason` observed: only `AVAILABLE`/`RESERVED` (`BLOCKED` never seen); `note`/`closed_*` fields live but all null/false here. Reversed range → 400; >3y out → 400; single-day range → 200 with 1 day.
- Reads ~1000 req/min (triangulated); writes chunked.

Full detail: `docs/discovery/03-listings-calendar.md`.
