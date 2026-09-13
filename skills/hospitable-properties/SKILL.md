---
name: hospitable-properties
description: Work with Hospitable properties and listings. Use when listing, getting, searching, tagging, imaging, quoting, or managing iCal imports for properties.
---

# Hospitable Properties

Needs `skills/hospitable-auth/SKILL.md` for base, headers, pagination, envelopes.

Glossary: **Property** = Hospitable-side unit (`uuid`). **Listing** = channel-side copy (read-only in v1, via `?include=listings` or `GET /v2/listings`).

## Endpoints (triangulated unless noted)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

curl -H "$H" "$BASE/properties?per_page=100"            # list (auto-paginate links.next)
curl -H "$H" "$BASE/properties/{uuid}"                 # get one
curl -H "$H" "$BASE/properties/search?check_in=2026-10-01&check_out=2026-10-05"  # availability+pricing (<=90d window, <=3y out; surfaces notAvailableReason)
curl -H "$H" "$BASE/properties/{uuid}/images"          # ordered images — short-lived S3 URLs, never cache
curl -H "$H" "$BASE/properties/{uuid}/tags"            # list org tags
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"tags":["cabin"]}' "$BASE/properties/{uuid}/tags"  # add 1-10 per call
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/properties/{uuid}/quote"  # Direct-gated quote
```

iCal (needs `ical:write`; redact `url` in logs):

```bash
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"url":"...","name":"..."}' "$BASE/properties/{uuid}/ical-imports"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"name":"..."}' "$BASE/properties/{uuid}/ical-imports/{icalId}"
```

Also triangulated: `GET /v2/listings`, `GET /v2/channels` (booking-platform channels + host ids).

## Gotchas

- Search requires explicit dates; surface `notAvailableReason` instead of calling unavailable "bookable".
- Images: pre-signed ~1h URLs — fetch fresh every run.
- Quote only works for Hospitable Direct properties.

Full detail: `docs/discovery/02-endpoint-inventory.md`, `03-listings-calendar.md`.
