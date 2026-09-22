---
name: hospitable
description: "Work with the Hospitable Public API v2. Use for any Hospitable call: auth headers, properties, search, images, calendar reads and updates, reservations, enrichment, or messaging."
license: MIT
---

# Hospitable (Public API v2)

Base: `https://public.api.hospitable.com/v2`. REST + JSON, `snake_case` on the wire.

_Probe baseline: unmarked claims verified live 2026-09-22; **TBC** = unprobed. Reads verified; every write below is TBC — no write probe has ever run on this account._

```bash
export HOSPITABLE_PAT="<my.hospitable.com → Apps → API access → + Add new>"
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"
```

## Auth and ceiling

- Hosts/dev PAT is near-full access **and the ceiling**: this is the maximum API access available (owner-confirmed). Stays 403: `GET reservations/{id}/enrichment` (`Invalid scope(s)`), owner accounting (plan-gated). Beyond that the user acts directly in Hospitable.
- Vendors: OAuth2 code flow via `auth.hospitable.com/oauth/{authorize,token}`. **TBC.**
- Gated scopes (triangulated, likely unreachable): `calendar:write`, `listing:read` (gates `?include=listings`), `ical:write`, `financials:read`.

## Wire conventions

- Headers: `Authorization: Bearer <token>`, `Accept: application/json`, `Content-Type: application/json` on writes.
- Envelopes: list `{data:[], meta:{...}, links:{next}}`, single `{data:{...}}`, calendar `{data:{days:[...],listing_id,provider,start_date,end_date}}` (bare-array variant never observed); images bare `{data:[...]}`, no meta. Errors `{status_code,reason_phrase,errors:{field:[msg]}}`, except 403-scope errors which omit `errors`.
- Pagination: `?page=&per_page=` (default 10, max 100). Use `per_page=100` + follow `links.next`, but re-append `properties[]` (`links.next` drops it → 400) and force https (`links` use http → 307). `meta.total` trustworthy.
- Scoping is a shared rule: reservations, inquiries, and tasks lists all 400 (`The properties field is required.`) without `properties[]`. Always scope to explicit property uuids.
- Includes: `?include=` comma-joined; unknown values silently ignored (`?include=billing` on `/v2/user` is a no-op). Properties: `user,listings,details,bookings,ical_imports`. Reservations: `guest,user,financials,financialsV2,listings,properties,review,smartlock_code,tasks` (`conversation,checkins,transactions` silently ignored on single-get).
- Money: minor units (cents), ISO-4217 currency.
- Idempotency: `POST /v2/reservations` requires `Idempotency-Key: <uuid>`; fresh uuid per logical create, same key on retry.

## Limits and errors (triangulated)

- Calendar read ~1000 req/min; calendar write 60 dates/call; messaging 2/min per convo, 50/5min global.
- 429: honor `X-RateLimit-Reset`, backoff + retry.
- `calendar_restricted` → PUT returns 422, so pre-check and surface a friendly error instead of retrying blindly.
- Calendar PUT is async (200/202 accepted ≠ visible), so poll GET.

## Properties

Glossary: **Property** = Hospitable-side unit (`uuid`). **Listing** = channel-side copy (read-only in v1, via `?include=listings`).

```bash
curl -H "$H" "$BASE/properties?per_page=100"            # list (auto-paginate links.next)
curl -H "$H" "$BASE/properties/{uuid}"                 # get one
curl -H "$H" "$BASE/properties/search?start_date=2026-10-01&end_date=2026-10-05&adults=2"  # requires start_date+end_date+adults; returns {data:[{property,pricing,availability,distance_in_km}]}
curl -H "$H" "$BASE/properties/{uuid}/images"          # ordered [{url,thumbnail_url,caption,order,last_updated_at}] — fetch fresh every run, never cache (observed stable asset URLs, not expiring S3 links)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"tags":["cabin"]}' "$BASE/properties/{uuid}/tags"  # add 1-10 per call (POST-only — GET 405s)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/properties/{uuid}/quote"  # Direct-only (TBC, unprobed)
```

iCal (needs `ical:write`; redact `url` in logs) — TBC, unprobed:

```bash
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"url":"...","name":"..."}' "$BASE/properties/{uuid}/ical-imports"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"name":"..."}' "$BASE/properties/{uuid}/ical-imports/{icalId}"
```

`GET /v2/channels` 200 `[{user_id,name,login,platform,picture}]` (platforms: homeaway,booking,airbnb,manual,direct; redact `login` email); `GET /v2/listings` 404s — use `?include=listings` instead.

Search rules: unavailable results carry `pricing.daily[]` with `pricing.total=null` and `availability.details[]` reasons (observed: `property_not_available,minimum_stay_not_met,maximum_number_of_guests_exceeded,pets_not_allowed`) — surface the reason, never call it bookable. Window rules (exact): >90d → 400, >3y out → 400, past start → 400, end<start → 400; same-day start=end → 200 `{data:[]}`. Quote works for Hospitable Direct properties only.

## Calendar

```bash
# Read: dates OPTIONAL (missing end → start+14d; no params → today+14d, 200). Day: {date,day,min_stay,note,closed_for_checkin/closed_for_checkout,status:{reason,source,source_type,available},price:{amount,currency,formatted}}
curl -H "$H" "$BASE/properties/{uuid}/calendar?start_date=2026-10-01&end_date=2026-10-31"

# Update (TBC): additive, max 60 dates per call, max ~1095d out, async-apply (poll GET after)
curl -X PUT -H "$H" -H 'Content-Type: application/json' \
  -d '{"days":[{"date":"2026-10-05","available":false}]}' \
  "$BASE/properties/{uuid}/calendar"

# Range conveniences (TBC, unprobed)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"start_date":"2026-10-05","end_date":"2026-10-08"}' "$BASE/properties/{uuid}/calendar/block"
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"start_date":"2026-10-05","end_date":"2026-10-08"}' "$BASE/properties/{uuid}/calendar/unblock"
```

Status `reason` observed: only `AVAILABLE`/`RESERVED` (`BLOCKED` never seen); `note`/`closed_*` fields live but all null/false here. Reversed range → 400; >3y out → 400; single-day range → 200 with 1 day.

## Reservations

```bash
curl -H "$H" "$BASE/reservations?properties[]={uuid}&per_page=100"  # list; REQUIRES properties[]; status filter must be array, e.g. status[]=accepted
# Window every list: dateless = check-ins next 2 weeks ONLY — past/in-house stays vanish. Always pass start_date/end_date/date_query:
curl -H "$H" "$BASE/reservations?properties[]={uuid}&start_date=2026-09-01&end_date=2026-09-30&date_query=checkin&status[]=accepted&include=guest&per_page=100"
curl -H "$H" "$BASE/reservations/{uuid}"                           # get one
curl -X POST -H "$H" -H 'Content-Type: application/json' -H "Idempotency-Key: $(uuidgen)" \
  -d '{...}' "$BASE/reservations"                                  # create manual/direct (TBC)
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/reservations/{uuid}"  # update (PUT first; PATCH fallback TBC)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"initiatedBy":"host"}' "$BASE/reservations/{uuid}/cancel"  # manual/Direct-only (TBC)

# Enrichment K/V: correct path is /enrichment (not /enrichment-data); value:null clears (GET 403s `Invalid scope(s)` on max-access PAT — ceiling applies)
curl -H "$H" "$BASE/reservations/{uuid}/enrichment"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"smartlock_code":"1234"}' "$BASE/reservations/{uuid}/enrichment"
```

List filters: `date_query` = `checkin|checkout|booked_at` alongside `start_date/end_date YYYY-MM-DD` (checkin filters arrival, checkout filters departure, booked_at filters booking date); response datetimes are all ISO-8601 with TZ. `status[]`: observed `accepted,cancelled,denied`; `reservation_status.current.category` uses `not accepted` with a space; `request/checkpoint` unverified. Also: `platform_id`, `conversation_id`.

Rules: fresh `Idempotency-Key` per logical create, same key on retry. Update is full for manual, partial (notes, checkin/out time) for OTA. Cancel is manual/Direct-only — guard before calling. Calendar RESERVED nights with no listed row → re-query with an explicit window before assuming a sync gap. Never message a stay you cannot resolve to a listed reservation id. `?include=financialsV2` is an alias returning the same `financials` shape; `smartlock_code` present-but-null is ambiguous (unset vs scope-gated).

Messaging (`GET|POST /v2/reservations/{id}/messages`) is out of v1 scope, but the contract is verified: `POST {body}` (no senderId) → `202 {data:{sent_reference_id}}`; confirm delivery by polling GET and matching `sent_reference_id`.
