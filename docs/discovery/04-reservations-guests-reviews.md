# 04 — Reservations / Guests / Reviews

Sources: kacao v0.7.3 path table + silkyland types/client + api-evangelist mirrors + changelog/help. Stoplight bodies JS-walled — paths triangulated, not doc-fetched.

## Reservations

```bash
curl -H "Authorization: Bearer $PAT" \
 "https://public.api.hospitable.com/v2/reservations?properties[]=PROP&start_date=2026-09-01&end_date=2026-10-01&date_query=checkin&status[]=accepted&include=guest,financials,review&per_page=100"
```

- `GET /reservations`: **requires `properties[]`** else 400. `start_date/end_date YYYY-MM-DD`, `date_query=checkin|checkout` (default checkin), `booked_at Y-m-d H:i:s` (new-booking poll), `last_message_at YYYY-MM-DD HH:MM:SS` (**space, not ISO**), `status`, `platform_id`, `conversation_id`, `include`, `page/per_page`. No dates = check-ins next 2 wks. Helpers: `getUpcoming` = `status=accepted,date_query=checkin,start=today`; `getInHouse` = `date_query=checkout,start=today` + client filter `arrival<=today`.
- `GET /reservations/{uuid}?include=`.
- `POST /reservations` (manual/direct only, `Idempotency-Key: uuid` required): `{propertyId,currency,arrivalDate,departureDate,guest:{firstName,lastName,email?,phone?},guests:{adults,children?,infants?},financials:{accommodation,cleaningFee?,petFee?,extraGuestFee?,tax?,platformFee?,hostServiceFee?}}` — flat cents, ≠ read shape. → `platform=manual`.
- `PUT /reservations/{uuid}` (canonical; silkyland PATCH = drift): manual = full payload; OTA (Jul 2026+) partial `notes|note`, `checkin_time/checkout_time HH:MM`. OTA date/guest/money changes on channel only.
- `POST /reservations/{uuid}/cancel {initiatedBy:'host'|'guest'}` — manual/direct only; OTA cancel unsupported.
- Enrichment: `GET|PUT /reservations/{uuid}/enrichment {key e.g. smartlock_code, value:string|null}` (null clears). **Not `/enrichment-data`** (404).
- Object: `{id,code,platform,platform_id,booking_date,arrival_date,departure_date,check_in/out,nights,stay_type,ownerStay,reservation_status{current{category,sub_category},history[]},guests{total,adult,child,infant,pet},conversation_id,last_message_at,notes}`. Categories seen: `request|accepted|cancelled|not_accepted` + sub-categories (full machine TBC — Enums guide `g5sgfn6j7b0aw` nav-verified, body TBC).
- `include`: `guest,user,financials,financialsV2 (needs financials:read),listings,properties,review,smartlock_code,tasks (May 2026+),conversation,checkins,transactions`.

## Guests

Via `?include=guest` + reservation `guest/guests` blocks; no standalone `/guests` CRUD found (TBC). PII — redact email/phone in logs.

## Reviews

- `GET` property-reviews + `POST .../respond` triangulated from keithah `openapi.yaml` (10 paths). Exact paths TBC — confirm via Stoplight crawl or probe.
- `review.created` webhook (Airbnb + direct), `review` include on reservations. Changelog mentions guest reviews (TBC).
