---
name: hospitable-auth
description: Authenticate and follow conventions for the Hospitable Public API v2. Use for any Hospitable API call — PAT/OAuth headers, pagination, response envelopes, includes, rate limits, idempotency.
---

# Hospitable Auth & Conventions

Base: `https://public.api.hospitable.com/v2`. REST + JSON, `snake_case` on the wire.

## Auth

```bash
export HOSPITABLE_PAT="<my.hospitable.com → Apps → API access → + Add new>"
curl -H "Authorization: Bearer $HOSPITABLE_PAT" -H "Accept: application/json" \
  https://public.api.hospitable.com/v2/user
```

- Hosts/dev: PAT, full access by default; calendar pricing/availability needs Write scope. **Verified.**
- Vendors: OAuth2 code flow via `auth.hospitable.com/oauth/{authorize,token}`. **TBC.**
- Gated scopes (triangulated): `calendar:write` (request via `team-platform@hospitable.com`), `listing:read` (gates `?include=listings`), `ical:write`, `financials:read`.

## Wire

- Headers: `Authorization: Bearer <token>`, `Accept: application/json`, `Content-Type: application/json` on writes.
- Envelopes: list `{data:[], meta:{...}, links:{next}}`, single `{data:{...}}`, calendar `{data:{days:[...]}}` or `{data:[...]}` — unwrap both.
- Pagination: `?page=&per_page=` (default 10, max 100). Use `per_page=100` + follow `links.next`.
- Includes: `?include=` comma-joined; unknown values silently ignored — allowlist only. Properties: `user,listings,details,bookings,ical_imports`. Reservations: `guest,user,financials,financialsV2,listings,properties,review,smartlock_code,tasks,conversation,checkins,transactions`.
- Money: minor units (cents), ISO-4217 currency.
- Idempotency: `POST /v2/reservations` requires `Idempotency-Key: <uuid>` — fresh uuid per logical create.

## Limits & errors (triangulated)

- Calendar read ~1000 req/min; calendar write 60 dates/call; messaging 2/min per convo, 50/5min global.
- 429: honor `X-RateLimit-Reset`, backoff + retry.
- `calendar_restricted` channel → PUT returns 422 — pre-check and surface friendly error.
- Calendar PUT is async (200/202 accepted ≠ visible) — poll GET.

Full detail: `docs/discovery/01-auth-and-conventions.md`.
