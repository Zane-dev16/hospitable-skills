# Hospitable API v2 — Discovery Overview

Goal: `skills-library` wrapper around Hospitable Public API v2 (hosts via PAT, vendors via OAuth2).
Base: `https://public.api.hospitable.com/v2`. Wire: REST + JSON, `snake_case`, version in path (`/v2/...`).

## Base URLs (verified 2026-09-13 via fetch_content)

| What | URL | Status |
| --- | --- | --- |
| Production API | `https://public.api.hospitable.com/v2` | verified (curl target in deep dives, SDK probed) |
| OAuth authorize | `https://auth.hospitable.com/oauth/authorize` | TBC — recon-cited, not fetched |
| OAuth token | `https://auth.hospitable.com/oauth/token` | TBC — recon-cited, not fetched |
| Docs hub | `https://developer.hospitable.com/` | verified URL, body JS-rendered (`l.observe` shell) |
| Public API index | `https://developer.hospitable.com/docs/public-api-docs` | **verified** — nav HTML fetched, lists all guides + categories |
| App (PAT issuance) | `https://my.hospitable.com` → Apps → API access | verified via help article fetch |
| PAT help | `https://help.hospitable.com/en/articles/8609392-accessing-the-public-api-with-a-personal-access-token-pat` | verified (fetched, 3046 chars) |
| Webhooks help | `https://help.hospitable.com/en/articles/10008203-webhooks-for-reservations-properties-messages-and-reviews` | **verified** — full body fetched |
| MCP help | `https://help.hospitable.com/en/articles/14424057-connect-an-ai-agent-to-hospitable-using-mcp` | TBC |
| Community changelog | `https://community.hospitable.com/hospitable-changelog-3` | TBC |

## Versioning

- **v2 (current):** path-prefix `/v2/...`, OAuth2 + PAT, more webhook triggers + data points. Stoplight tag `v2.0`.
- **v1 (legacy):** API-key auth, legacy webhooks. Migration guide exists: `.../2p4a352p4mxqo-who-is-this-guide-for` (URL from nav, body TBC).
- Changelog is dated entries (seen: Tasks/Teammates Apr 2026, scheduled messages May 2026, video attachments Aug 2026, Tasks Sep 2026). Index: `.../changelog-changelog` (URL verified, body TBC).

## Docs index (all URLs verified from fetched nav; bodies TBC unless noted)

Prefix: `https://developer.hospitable.com/docs/public-api-docs/`

Guides: `d862b3ee512e6-introduction`, `xpyjv51qyelmp-authentication` (fetch → JS-render error, URL ok), `api~2Dversioning-docs`, `webhooks-docs`, `changelog-changelog`, `6a0626f943b78-http-responses`, `dbc4b7ed7eb1b-pagination`, `465fd4d45e4b3-including-resources`, `g5sgfn6j7b0aw-reservation-statuses`, `hriol5oneuh9u-calendar-restriction`, `plg2456pollingnewbookings-polling-new-bookings`, `fzn63bghr1nhq-polling-new-guest-messages`, `doiwsvlu4x6qr-updating-reservations`, `hejtr2jhgbblr-inquiry-resource`, `ofr9ft9to2ata-currencies`, `03fvv8cmnjlqw-partner-portal`, `dp985j2ujsjem-hospitable-api-v2` (Stoplight ref), `k4ctofvqu0w8g-hospitable-api-v2-webhooks` (webhook ref).
Properties (10 ops, URLs verified from nav, bodies Stoplight-error — e.g. `qc4x36uhxinx3-get-properties` fetched → Stoplight shell): `dz41u3tx6iy20-search-properties`, `7fu6aoxy7h0o4-get-property-by-uuid`, `qpa4niiposx20-get-property-images`, `d97fb82987ff6-get-property-calendar`, `lziaxr9e1j27m-update-property-calendar`, `create~2Dical~2Dimport-create-i-cal-import`, `update~2Dical~2Dimport-update-i-cal-import`, `gr9c7bzvso5cv-generate-a-quote`, `m5e2369yzo949-tag-a-property`.
Categories with sub-pages under Stoplight ref (names verified, op URLs TBC): Transactions, Upsells, Enrichable Shortcodes, User, Inquiries, Reservations, Messaging, Reviews, Knowledge Hub, Tasks, Teammates, Smart devices, Scheduled messages, Channels, Short codes, Custom codes, Notifications, Owners, Owner statements, Businesses, Owner statement transactions, Schemas, Webhooks.

Community OpenAPI mirrors (triangulation, not official): `github.com/api-evangelist/hospitable` (`openapi/*.yml`), `github.com/keithah/hospitable-python` (`openapi.yaml`, 10 paths), `github.com/silkyland/hospitable-skill`, `kacao/hospitable` TS SDK (probed live 2026-04-11, v0.7.3).

## Glossary

- **Property:** Hospitable-side unit (`uuid`). Has listings (channel copies).
- **Listing:** channel-side copy (Airbnb/Vrbo/Booking/Direct/manual). No `/listings` CRUD; read via `?include=listings` or `GET /listings` / `GET /channels`.
- **PAT:** Personal Access Token, per-host, full access by default.
- **Enrichment:** per-reservation K/V (`smartlock_code`, wifi overrides). Real path `/enrichment` (not `/enrichment-data`).
- **minor units:** money as cents (`15000` = $150.00).
- **calendar_restricted:** Airbnb downgraded-scope flag; blocks calendar PUT with 422.

Verification legend: **verified** = fetched this phase; **TBC** = URL from nav/recon, body not fetched (JS-rendered or unfetched).
