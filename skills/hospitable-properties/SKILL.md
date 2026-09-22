---
name: hospitable-properties
description: Work with Hospitable properties and listings. Use when listing, getting, searching, tagging, imaging, quoting, or managing iCal imports for properties.
license: MIT
---

# Hospitable Properties

Needs `skills/hospitable-auth/SKILL.md` for base, headers, pagination, envelopes.

Glossary: **Property** = Hospitable-side unit (`uuid`). **Listing** = channel-side copy (read-only in v1, via `?include=listings` or `GET /v2/listings`).

## Endpoints (verified 2026-09-22 unless noted)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

curl -H "$H" "$BASE/properties?per_page=100"            # list (auto-paginate links.next)
curl -H "$H" "$BASE/properties/{uuid}"                 # get one (verified)
curl -H "$H" "$BASE/properties/search?start_date=2026-10-01&end_date=2026-10-05&adults=2"  # verified; requires start_date+end_date+adults; returns {data:[{property,pricing,availability,distance_in_km}]}
curl -H "$H" "$BASE/properties/{uuid}/images"          # verified: ordered [{url,thumbnail_url,caption,order,last_updated_at}], short-lived S3 URLs, never cache
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"tags":["cabin"]}' "$BASE/properties/{uuid}/tags"  # add 1-10 per call (TBC: GET unsupported — live probe 405, POST-only)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/properties/{uuid}/quote"  # Direct-gated quote (TBC, unprobed)
```

iCal (needs `ical:write`; redact `url` in logs):

```bash
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"url":"...","name":"..."}' "$BASE/properties/{uuid}/ical-imports"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"name":"..."}' "$BASE/properties/{uuid}/ical-imports/{icalId}"
```

Also triangulated: `GET /v2/listings`, `GET /v2/channels` (booking-platform channels + host ids).

## Gotchas

- Search requires explicit dates; surface `notAvailableReason` instead of calling unavailable "bookable".
- Images: pre-signed ~1h URLs, so fetch fresh every run.
- Quote only works for Hospitable Direct properties.

Full detail: `docs/discovery/02-endpoint-inventory.md`, `03-listings-calendar.md`.
