---
name: hospitable-reservations
description: Work with Hospitable reservations and guests. Use when listing, getting, creating, updating, cancelling, or enriching reservations.
---

# Hospitable Reservations

Needs `skills/hospitable-auth/SKILL.md` for base, headers, pagination, money (minor units), idempotency.

## Endpoints (triangulated)

```bash
BASE=https://public.api.hospitable.com/v2
H='Authorization: Bearer '"$HOSPITABLE_PAT"

curl -H "$H" "$BASE/reservations?properties[]={uuid}&per_page=100"  # list REQUIRES properties[]
curl -H "$H" "$BASE/reservations/{uuid}"                           # get one
curl -X POST -H "$H" -H 'Content-Type: application/json' -H "Idempotency-Key: $(uuidgen)" \
  -d '{...}' "$BASE/reservations"                                  # create manual/direct
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{...}' "$BASE/reservations/{uuid}"  # update (PUT first; PATCH fallback TBC)
curl -X POST -H "$H" -H 'Content-Type: application/json' -d '{"initiatedBy":"host"}' "$BASE/reservations/{uuid}/cancel"  # manual/direct only

# Enrichment K/V — correct path is /enrichment (not /enrichment-data); value:null clears
curl -H "$H" "$BASE/reservations/{uuid}/enrichment"
curl -X PUT -H "$H" -H 'Content-Type: application/json' -d '{"smartlock_code":"1234"}' "$BASE/reservations/{uuid}/enrichment"
```

List filters: `properties[]` (required), `date_query`, `booked_at`, `last_message_at` (space format), `status`, `include`.

## Gotchas

- Always send fresh `Idempotency-Key` per logical create; retry with same key.
- Update: full for manual, partial (notes, checkin/out time) for OTA.
- Cancel is manual/Direct-only — guard before calling.
- Reservation messages (`GET|POST /v2/reservations/{id}/messages`) belong to messaging (out of v1 scope) — noted here only to avoid confusion.

Full detail: `docs/discovery/02-endpoint-inventory.md`, `04-reservations-guests-reviews.md`.
