---
name: hospitable-auth
description: "Authenticate and follow conventions for the Hospitable Public API v2. Use for any Hospitable API call: PAT/OAuth headers, pagination, response envelopes, includes, rate limits, idempotency."
license: MIT
---

# Hospitable Auth & Conventions

Base: `https://public.api.hospitable.com/v2`. REST + JSON, `snake_case` on the wire.

_Probe baseline: unmarked claims verified live 2026-09-22; **TBC** = unprobed._

## Auth

```bash
export HOSPITABLE_PAT="<my.hospitable.com → Apps → API access → + Add new>"
curl -H "Authorization: Bearer $HOSPITABLE_PAT" -H "Accept: application/json" \
  https://public.api.hospitable.com/v2/user
```

- Hosts/dev: PAT — near-full access, and the ceiling: this is the maximum API access available (owner-confirmed). Stays 403: `GET reservations/{id}/enrichment` (`Invalid scope(s)`), owner accounting (plan-gated). Beyond that the user acts directly in Hospitable. Calendar pricing/availability needs Write scope.
- Vendors: OAuth2 code flow via `auth.hospitable.com/oauth/{authorize,token}`. **TBC.**
- Gated scopes (triangulated, likely unreachable): `calendar:write`, `listing:read` (gates `?include=listings`), `ical:write`, `financials:read`.

## Wire

- Headers: `Authorization: Bearer <token>`, `Accept: application/json`, `Content-Type: application/json` on writes.
- Envelopes: list `{data:[], meta:{...}, links:{next}}`, single `{data:{...}}`, calendar `{data:{days:[...],listing_id,provider,start_date,end_date}}` (bare-array variant never observed); images bare `{data:[...]}`, no meta. Errors `{status_code,reason_phrase,errors:{field:[msg]}}`, except 403-scope errors which omit `errors`.
- Pagination: `?page=&per_page=` (default 10, max 100). Use `per_page=100` + follow `links.next`, but re-append `properties[]` (`links.next` drops it → 400) and force https (`links` use http → 307). `meta.total` trustworthy.
- Includes: `?include=` comma-joined; unknown values silently ignored (`?include=billing` on `/v2/user` is a no-op), so stick to the allowlist. Properties: `user,listings,details,bookings,ical_imports`. Reservations: `guest,user,financials,financialsV2,listings,properties,review,smartlock_code,tasks` (`conversation,checkins,transactions` silently ignored on single-get).
- Money: minor units (cents), ISO-4217 currency.
- Scoping is a shared rule: reservations, inquiries, and tasks list endpoints all 400 (`The properties field is required.`) without `properties[]`. Always scope list queries to explicit property uuids.
- Idempotency: `POST /v2/reservations` requires `Idempotency-Key: <uuid>`; use a fresh uuid per logical create.

## Limits & errors (triangulated)

- Calendar read ~1000 req/min; calendar write 60 dates/call; messaging 2/min per convo, 50/5min global.
- 429: honor `X-RateLimit-Reset`, backoff + retry.
- `calendar_restricted` channel → PUT returns 422, so pre-check and surface a friendly error.
- Calendar PUT is async (200/202 accepted ≠ visible), so poll GET.

Full detail: `docs/discovery/01-auth-and-conventions.md`.
