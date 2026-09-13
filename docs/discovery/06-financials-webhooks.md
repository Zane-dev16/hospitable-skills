# 06 — Financials / Transactions / Webhooks

## Financials (triangulated)

- **Write (create reservation):** flat cents `{accommodation,cleaningFee?,petFee?,extraGuestFee?,tax?,platformFee?,hostServiceFee?}`.
- **Read (`?include=financials`):** nested `guest{accommodation,averageNightlyRate,fees[],discounts[] (NEGATIVE),taxes[],totalPrice} / host{accommodation,accommodationBreakdown[],guestFees[],hostFees[] (NEGATIVE),revenue}`; line items `{amount (minor, can be negative), formatted, label, category}`. `financialsV2` needs `financials:read` scope.
- `GET /properties/search` pricing: `{daily[{date,currency,formatted_string}],total,total_without_taxes}`.
- Currencies guide `ofr9ft9to2ata` nav-verified, body TBC. Amounts minor units; currency ISO4217.
- Transactions / Upsells / Owners / Businesses / Owner statements / Owner-statement-transactions: categories nav-verified; owner-statement writes + expense CRUD noted in 2026 changelog (TBC — needs Stoplight crawl).

## Webhooks (verified via help article fetch)

- v2 has more triggers + data than v1. Events: `reservation.created|changed`, `property.created|changed|deleted|merged`, `message.created`, `review.created`.
- Setup: URL in app; expects `200 OK` else retry ×5 (`1s,5s,10s,1h,6h`). From `38.80.170.0/24` — whitelist. JSON POST.
- No per-period resend; only bulk "Send historic webhooks" (Accepted reservations only). `message.created` skips >12h-old.
- Tech ref `k4ctofvqu0w8g-hospitable-api-v2-webhooks` nav-verified, body TBC; payload example at `0c89462f0c6f5-receive-reservation-post` (TBC).
