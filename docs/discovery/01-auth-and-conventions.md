# 01 — Auth & Conventions

## Auth

Header: `Authorization: Bearer <PAT|OAuth2>` + `Accept: application/json` (and `Content-Type: application/json` on writes).

- **PAT (hosts/dev):** `my.hospitable.com → Apps → API access → + Add new`. Full access by default. Read vs Write split (calendar pricing/availability needs Write). Verified via help article.
- **OAuth2 (vendors):** auth-code flow via `auth.hospitable.com/oauth/{authorize,token}`. Scopes requested at authorize. TBC (not fetched).
- Relevant scopes (triangulated from SDK probes + docs snippets): `property:read`, `calendar:read`, `calendar:write` (gated — request via `team-platform@hospitable.com`), `listing:read` (gates `?include=listings`), `ical:write`, `financials:read` (gates `financialsV2` include).

## Headers / envelope

- List: `{data: [], meta: {current_page, last_page, per_page, total}, links: {first, last, prev, next}}`.
- Single: `{data: {...}}` (SDKs unwrap; `/user` same inconsistency). Handle both `{data: X}` and `{data: {days: [...]}}` on calendar (community OpenAPI models `{data: CalendarDay[]}` vs SDK `{data: {days}}`).
- Wire `snake_case`; SDKs expose `camelCase`. Convert at boundary.

## Pagination

`?page=&per_page=` (default 10, max 100). Wrapper: `per_page=100` + follow `links.next` (`listAll` helper). Guide URL `dbc4b7ed7eb1b-pagination` verified, body TBC.

## Includes

`?include=` comma-joined sideloads. Unknown values **silently ignored** (200, no extra fields) — wrapper must allowlist. Known: properties → `user,listings,details,bookings,ical_imports` (last gated on `listings`, undocumented); reservations → `guest,user,financials,financialsV2,listings,properties,review,smartlock_code,tasks,conversation,checkins,transactions`. Guide `465fd4d45e4b3-including-resources` URL verified, body TBC.

## Rate limits / errors (triangulated, TBC)

- Calendar read: `1000 req/min` per vendor/PAT. Calendar write: chunk `60 dates/request`. Messaging: `2/min` per convo, `50/5min` global.
- 429: honor `X-RateLimit-Reset`, retry with backoff. `calendar_restricted` PUT → `422 {status_code:422, reason_phrase:"This property has a channel that is calendar restricted..."}`. `PUT` calendar is async (200/202 `accepted` ≠ visible yet — poll GET).
- Http-responses guide `6a0626f943b78-http-responses` URL verified, body TBC.

## Environments

Only production base known. No sandbox documented (TBC). Use a test property + PAT for dev.

## Idempotency

`POST /v2/reservations` (manual/direct create) requires `Idempotency-Key: <uuid>` (Nov 2025 changelog, triangulated). Always send fresh uuid per logical create; retry with same key.
