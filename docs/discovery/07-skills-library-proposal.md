# 07 — Skills-Library Proposal

## Modules → endpoints

- `client`: Bearer inject, `snake_case` wire, envelope unwrap (`{data}`/`{data,meta,links}`/calendar `{data:{days}}` vs `[{...}]`), 429/`X-RateLimit-Reset` backoff, scope-error hints (PAT vs `team-platform@hospitable.com`), `calendar_restricted` pre-check → friendly 422.
- `properties`: `list (autoPaginate links.next, per_page=100)` / `get` / `search` (required-field guard + `notAvailableReason` surfacing) / `tags` (1–10 guard) / `images` (**no-cache**, 1h S3) / `quote` (Direct-gated) / `ical` (redact `url`).
- `calendar`: `get` (date validation) / `update` (**60-chunk + 1095d guard + async-poll note**) / `block|unblock`.
- `reservations`: `list` (require `properties[]`, `last_message_at` space format) / `get` / `create` (`Idempotency-Key`) / `update` (PUT first, PATCH fallback) / `cancel` (manual-only guard) / `enrichment` (correct `/enrichment` path).
- `messaging`: `send` (202 `sentReferenceId` poll; 2/min + 50/5min throttle) / `resolveSenders` via `include=listings`.
- `financials`: read-narrow helpers (negative-line-item aware), write-flat builder.
- `webhooks`: verify source IP `38.80.170.0/24`, event router, historic-resend note.
- `users`: `me (+billing)` / co-host resolve.

## Config

`HOSPITABLE_PAT` (or OAuth token), base override, `per_page=100`, throttle defaults, log-redactions (`wifi_password`, iCal `url`, guest PII).

## Testing

One `assert`-based smoke per module against live test property (list/get/search/calendar-get only; no writes by default). Writes behind explicit flag + dedicated test property. No fixtures/frameworks.

## Open questions

1. Exact paths for Tasks/Teammates/Scheduled-messages/Smart-devices/Owner-statements/Transactions/Upsells? (Stoplight crawl or live probe needed.)
2. Review respond + enrichment key registry exact shapes?
3. OAuth scope names + sandbox existence?
4. `PUT` vs `PATCH` on reservations — confirm against live API?
5. Calendar async delay bounds for poll defaults?
6. `financialsV2` full schema?

Skipped: per-endpoint typed models for TBC domains — add when probed. Add full response fixtures when live probe succeeds.
