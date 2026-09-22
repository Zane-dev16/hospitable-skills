---
name: hospitable-calendar
description: Read and update Hospitable property calendars. Use when checking availability, rates, restrictions, blocking or unblocking dates, or changing pricing.
license: MIT
---

# Hospitable Calendar

Needs `skills/hospitable-auth/SKILL.md` for base, headers, envelopes.

## Endpoints (triangulated)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

# Read verified 2026-09-22: start_date + end_date required; returns {data:{listing_id,provider,start_date,end_date,days:[{date,day,min_stay,note,closed_for_checkin/closed_for_checkout,status:{reason,source,source_type,available},price:{amount,currency,formatted}}]}}; money in minor units
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
- PUT returns 200/202 accepted ≠ visible, so poll GET to confirm.
- `calendar_restricted` channel flag → PUT fails 422 with channel message, so surface a friendly error instead of retrying blindly.
- Reads ~1000 req/min (triangulated); writes chunked.

Full detail: `docs/discovery/03-listings-calendar.md`.
