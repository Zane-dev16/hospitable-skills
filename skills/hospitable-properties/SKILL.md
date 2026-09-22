---
name: hospitable-properties
description: Work with Hospitable properties and listings. Use when listing, getting, searching, tagging, imaging, quoting, or managing iCal imports for properties.
license: MIT
---

# Hospitable Properties

Needs `skills/hospitable-auth/SKILL.md` for base, headers, pagination, envelopes.

Glossary: **Property** = Hospitable-side unit (`uuid`). **Listing** = channel-side copy (read-only in v1, via `?include=listings`).

## Endpoints (reads verified; writes TBC)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

curl -H "$H" "$BASE/properties?per_page=100"            # list (auto-paginate links.next)
curl -H "$H" "$BASE/properties/{uuid}"                 # get one
curl -H "$H" "$BASE/properties/search?start_date=2026-10-01&end_date=2026-10-05&adults=2"  # requires start_date+end_date+adults; returns {data:[{property,pricing,availability,distance_in_km}]}
curl -H "$H" "$BASE/properties/{uuid}/images"          # ordered [{url,thumbnail_url,caption,order,last_updated_at}] — fetch fresh every run, never cache (observed stable asset URLs, not expiring S3 links)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"tags":["cabin"]}' "$BASE/properties/{uuid}/tags"  # add 1-10 per call (POST-only — GET 405s)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/properties/{uuid}/quote"  # Direct-only (TBC, unprobed)
```

iCal (needs `ical:write`; redact `url` in logs):

```bash
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"url":"...","name":"..."}' "$BASE/properties/{uuid}/ical-imports"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"name":"..."}' "$BASE/properties/{uuid}/ical-imports/{icalId}"
```

Also: `GET /v2/channels` 200 `[{user_id,name,login,platform,picture}]` (platforms: homeaway,booking,airbnb,manual,direct; redact `login` email); `GET /v2/listings` 404s on this account — use `?include=listings` instead.

## Gotchas

- Unavailable search results carry `pricing.daily[]` with `pricing.total=null` and `availability.details[]` reasons (observed: `property_not_available,minimum_stay_not_met,maximum_number_of_guests_exceeded,pets_not_allowed`) — surface the reason, never call it bookable. Window rules (exact): >90d → 400, >3y out → 400, past start → 400, end<start → 400; same-day start=end → 200 `{data:[]}`.
- Quote only works for Hospitable Direct properties.

Full detail: `docs/discovery/02-endpoint-inventory.md`, `03-listings-calendar.md`.
