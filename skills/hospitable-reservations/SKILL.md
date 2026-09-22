---
name: hospitable-reservations
description: Work with Hospitable reservations and guests. Use when listing, getting, creating, updating, cancelling, or enriching reservations.
license: MIT
---

# Hospitable Reservations

Needs `skills/hospitable-auth/SKILL.md` for base, headers, pagination, idempotency.

## Endpoints (reads verified; writes TBC — no write probe run)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

curl -H "$H" "$BASE/reservations?properties[]={uuid}&per_page=100"  # list; REQUIRES properties[]; status filter must be array, e.g. status[]=accepted
# Window every list: dateless = check-ins next 2 weeks ONLY — past/in-house stays vanish. Always pass start_date/end_date/date_query:
curl -H "$H" "$BASE/reservations?properties[]={uuid}&start_date=2026-09-01&end_date=2026-09-30&date_query=checkin&status[]=accepted&include=guest&per_page=100"
curl -H "$H" "$BASE/reservations/{uuid}"                           # get one
curl -X POST -H "$H" -H 'Content-Type: application/json' -H "Idempotency-Key: $(uuidgen)" \
  -d '{...}' "$BASE/reservations"                                  # create manual/direct (TBC, unprobed)
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/reservations/{uuid}"  # update (PUT first; PATCH fallback TBC)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"initiatedBy":"host"}' "$BASE/reservations/{uuid}/cancel"  # manual/direct only

# Enrichment K/V: correct path is /enrichment (not /enrichment-data); value:null clears (GET 403s `Invalid scope(s)` on max-access PAT — ceiling applies, see auth)
curl -H "$H" "$BASE/reservations/{uuid}/enrichment"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"smartlock_code":"1234"}' "$BASE/reservations/{uuid}/enrichment"
```

List filters: `properties[]` (required), `date_query` = `checkin|checkout|booked_at` as a separate param alongside `start_date/end_date YYYY-MM-DD` (verified semantics: checkin filters arrival, checkout filters departure, booked_at filters booking date), `booked_at` / `last_message_at` filters (response datetimes are all ISO-8601 with TZ — space format never observed in responses), `status[]` (array form — scalar `status=` 400s; observed live: `accepted,cancelled,denied`; `reservation_status.current.category` uses `not accepted` with a space; `request/checkpoint` unverified), `platform_id`, `conversation_id`, `include`.

## Gotchas

- Always send fresh `Idempotency-Key` per logical create; retry with same key.
- Update: full for manual, partial (notes, checkin/out time) for OTA.
- Cancel is manual/Direct-only, so guard before calling.
- Reservation messages (`GET|POST /v2/reservations/{id}/messages`) are out of v1 scope, but the contract is verified: `POST {body}` (no senderId) → `202 {data:{sent_reference_id}}`; confirm delivery by polling GET and matching `sent_reference_id`. Throttles triangulated: 2/min per convo, 50/5min global.
- Calendar RESERVED nights with no listed row → re-query with an explicit window before assuming a sync gap. Never message a stay you cannot resolve to a listed reservation id.
- `?include=financialsV2` returns the same `financials` key/shape (alias, no V2 distinction, no 403); `smartlock_code` present-but-null is ambiguous (no code set vs scope-gated).

Full detail: `docs/discovery/02-endpoint-inventory.md`, `04-reservations-guests-reviews.md`.
