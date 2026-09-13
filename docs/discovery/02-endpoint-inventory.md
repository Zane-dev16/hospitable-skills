# 02 — Endpoint Inventory

Status: `nav-verified` = URL confirmed from fetched nav index; `triangulated` = path probed in kacao/keithah/silkyland/api-evangelist; `TBC` = inferred from category name only. Stoplight bodies all JS-rendered (verified on Get Properties) — details via mirrors.

## Properties / Listings / Calendar (12)

| Method/Path | Purpose | Status |
| --- | --- | --- |
| `GET /v2/properties` | list properties (`include,page,per_page,tags[]`) | nav-verified + triangulated |
| `GET /v2/properties/search` | availability/pricing search (≤90d window, ≤3y out; returns all + `notAvailableReason`) | nav-verified + triangulated |
| `GET /v2/properties/{uuid}` | one property | nav-verified + triangulated |
| `GET /v2/properties/{uuid}/images` | ordered images (pre-signed S3 URLs) | nav-verified + triangulated |
| `GET /v2/properties/{uuid}/calendar` | read days (`start_date,end_date` required) | nav-verified + triangulated |
| `PUT /v2/properties/{uuid}/calendar` | update days (additive, async, ≤60 dates/call, ≤1095d out) | nav-verified + triangulated |
| `POST /v2/properties/{uuid}/calendar/block` | range block convenience | triangulated (silkyland) |
| `POST /v2/properties/{uuid}/calendar/unblock` | range unblock | triangulated |
| `POST /v2/properties/{uuid}/ical-imports` | create iCal import (`ical:write`) | nav-verified + triangulated |
| `PUT /v2/properties/{uuid}/ical-imports/{icalId}` | update/resync iCal import | nav-verified + triangulated |
| `POST /v2/properties/{uuid}/quote` | Direct quote (Direct-gated) | nav-verified + triangulated |
| `GET+POST /v2/properties/{uuid}/tags` | list org tags / add 1–10 per call | nav-verified + triangulated |
| `GET /v2/listings` | account-wide channel listings | triangulated |
| `GET /v2/channels` | booking-platform channels + host ids (added ~2026-05-18) | triangulated |

## Reservations / Guests (9)

| Method/Path | Purpose | Status |
| --- | --- | --- |
| `GET /v2/reservations` | list (requires `properties[]`; `date_query`, `booked_at`, `last_message_at`, `status`, `include`) | nav-verified (Get Reservations page) + triangulated |
| `GET /v2/reservations/{uuid}` | one reservation | triangulated |
| `POST /v2/reservations` | create manual/direct (+`Idempotency-Key`) | triangulated |
| `PUT /v2/reservations/{uuid}` | update manual (full) / OTA (partial: notes, checkin/out time) | triangulated (PATCH drift in silkyland — try PUT first) |
| `POST /v2/reservations/{uuid}/cancel` | cancel manual/direct (`initiatedBy`) | triangulated |
| `GET /v2/reservations/{uuid}/enrichment` | read K/V (e.g. `smartlock_code`) | triangulated |
| `PUT /v2/reservations/{uuid}/enrichment` | write K/V (`value:null` clears) | triangulated |
| `GET /v2/reservations/{id}/messages` | list messages | triangulated |
| `POST /v2/reservations/{id}/messages` | send (`{body,images[],senderId?}` → 202 `sentReferenceId`) | triangulated |

## Messaging / Users / Misc reads (TBC unless noted)

| Method/Path | Purpose | Status |
| --- | --- | --- |
| `GET /v2/user` (+`?include=billing`) | current user (minimal by default) | triangulated |
| `GET /v2/inquiries` family | pre-booking inquiries | TBC (guide `hejtr2jhgbblr` nav-verified) |
| `GET /v2/reviews` / property-reviews | list reviews | triangulated (keithah: property-reviews) |
| `POST /v2/reviews/{id}/respond` | respond to review | triangulated (keithah: review-respond) |
| `GET /v2/scheduled-messages` family | scheduled messages CRUD | TBC (changelog May 2026) |
| `GET /v2/tasks` + `/v2/teammates` | Tasks/Teammates (Apr/Sep 2026) | TBC |
| `GET /v2/smart-devices` family | smart devices / smartlock codes | TBC |
| `GET /v2/transactions`, `/v2/upsells` | transactions, upsells | TBC |
| `GET /v2/owners`, `/v2/businesses`, `/v2/owner-statements`, `/v2/owner-statement-transactions` | owner accounting (writes added 2026) | TBC |
| `GET /v2/notifications`, `/v2/short-codes`, `/v2/custom-codes`, `/v2/enrichable-shortcodes`, `/v2/knowledge-hub` | messaging helpers | TBC |
| Webhook subscribe: `POST /v2/webhooks` family + `receive-reservation-post` | subscribe/list webhooks | TBC (help article verified for events/retries) |

**Count: 14 triangulated property/listing/calendar + 9 reservations/messaging + ~15 TBC = ~38 ops.** Treat TBC paths as unconfirmed until Stoplight crawl or live probe.
