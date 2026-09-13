---
title: Hospitable Core-3 Skills Library v1
status: ready-for-agent
tracker: local-file
triage: ready-for-agent
scope: properties + calendar + reservations
source: grilling 2026-09-13 + docs/discovery/00-07
---

## Problem Statement

As a host/operator who works through AI agents, I want to automate Hospitable work (check what I own, check availability and price, manage bookings) without hand-reading Stoplight docs every time, so that routine operations become repeatable agent tasks instead of bespoke API spelunking. Today the Public API v2 docs are JS-rendered and fragmented across guides, the endpoint surface is wide (~34 triangulated ops plus TBC domains), and auth, pagination, envelope, and rate-limit quirks are only documented by triangulation — so every agent session re-discovers the same ground truth.

## Solution

A public, mattpocock-structured skills library that gives AI agents three small, composable skills covering the Core-3 domains (Properties, Calendar, Reservations), sharing one auth convention (Bearer PAT from environment) and verified against a live test Property with read-only smokes. Agents load only the skill they need, copy a minimal request pattern, and get correct behavior on pagination, envelopes, includes, idempotency, and throttles without re-learning quirks.

## User Stories

1. As an agent operator, I want to list all Properties I manage, so that I can resolve which Property uuid to act on.
2. As an agent operator, I want to get a single Property by uuid, so that I can confirm identity before calendar or booking work.
3. As an agent operator, I want to search Properties by availability and pricing window, so that I can answer "what is free and what does it cost."
4. As an agent operator, I want unavailable search results to explain notAvailableReason, so that I do not misreport a Property as bookable.
5. As an agent operator, I want to list Property images with ordering preserved, so that I can confirm the correct unit visually.
6. As an agent operator, I want image URLs treated as short-lived pre-signed values, so that I never persist or cache a dead link.
7. As an agent operator, I want to read a Property calendar for a date range, so that I can see availability, rates, and restrictions.
8. As an agent operator, I want calendar reads validated for required start and end dates, so that I fail fast instead of getting a cryptic API error.
9. As an agent operator, I want to update calendar days in compliant chunks, so that I never exceed per-call date limits.
10. As an agent operator, I want block and unblock range operations, so that holds can be placed and released without hand-building day arrays.
11. As an agent operator, I want calendar writes to warn that application is async, so that I poll a fresh read instead of assuming immediate visibility.
12. As an agent operator, I want calendar_restricted channel conditions surfaced as a friendly pre-check, so that a 422 never surprises me.
13. As an agent operator, I want to list Reservations scoped to explicit Properties, so that queries stay bounded and supported.
14. As an agent operator, I want to filter Reservations by status, booking window, and last-message time, so that triage views are possible.
15. As an agent operator, I want to get a single Reservation by uuid, so that detail work starts from a known record.
16. As an agent operator, I want to create manual and Direct Reservations with an Idempotency-Key, so that retries never double-book.
17. As an agent operator, I want to update manual Reservations fully and channel Reservations partially, so that I respect what each origin allows.
18. As an agent operator, I want to cancel manual and Direct Reservations with an explicit initiator, so that cancellations are auditable.
19. As an agent operator, I want to read and write Reservation Enrichment key-values at the correct path, so that smartlock codes and overrides land where Hospitable expects.
20. As an agent operator, I want money always expressed in minor units with ISO currency, so that amounts are never ambiguous.
21. As an agent operator, I want paginated lists to auto-follow continuation links, so that I get complete results with one intent.
22. As an agent operator, I want response envelopes unwrapped uniformly, so that single-object and calendar-days shapes do not require per-call parsing.
23. As an agent operator, I want include sideloads restricted to an allowlist, so that silently ignored values never create false confidence.
24. As an agent operator, I want rate-limit backoff honored, so that bursts degrade gracefully instead of failing.
25. As an agent operator, I want scope-error hints that distinguish PAT full-access from gated capabilities, so that I know when to request elevation versus fix my call.
26. As an agent operator, I want secrets confined to environment variables with redaction guidance, so that tokens, wifi secrets, iCal URLs, and guest PII never land in the repo.
27. As a Claude Code user, I want the library installable as a managed plugin, so that updates arrive without forking.
28. As a Codex or other-agent user, I want the library installable as editable skill files, so that I can adapt them to my repo.
29. As a contributor, I want discovery notes retained alongside the skills, so that verified versus TBC claims stay auditable.
30. As a contributor, I want TBC domains left out of v1, so that unprobed paths do not ship as false promises.

## Implementation Decisions

- Ship three focused skills (Properties, Calendar, Reservations) plus one shared auth and conventions reference, following small and composable skill design.
- Adopt the standard skill-library layout (namespaced skill directories each with a skill manifest, per-agent invocation policies, a plugin manifest for managed install, human docs alongside).
- Standardize on the production versioned base with path-prefix versioning, REST over JSON, snake_case on the wire, and Bearer PAT from the environment; document the vendor OAuth flow as out-of-scope for v1 but name its authorize and token roles.
- Define the shared client behavior once: header injection, envelope unwrapping across single, list, and calendar-days shapes, pagination with large page size plus continuation following, include allowlisting, retry with backoff on rate limiting, idempotency key generation on manual and Direct creates, and friendly mapping of channel-restriction and scope errors.
- Define the Properties capability as list with auto-pagination, single get, availability and pricing search with required-field guards and unavailability-reason surfacing, tag listing and bounded add, ordered image reads with no-cache treatment, Direct-gated quoting, and iCal import create and update with URL redaction.
- Define the Calendar capability as range reads with date validation, chunked additive updates bounded by per-call date count and forward horizon, range block and unblock conveniences, async-application polling guidance, and channel-restriction pre-checks.
- Define the Reservations capability as list requiring explicit Property scope with date, status, and message-activity filters, single get, idempotent create, origin-aware update with a preferred verb plus documented fallback, manual-only cancel with initiator, and Enrichment reads and writes at the correct nested path with null-clears semantics.
- Treat money as minor units throughout with explicit currency, and surface nested financial line items including negative adjustments without redefining settlement or payout accounting.
- Keep Listing as a read-side concept reached via sideloads or channel reads, not as a v1 create and update surface.
- Preserve the discovery corpus as the audit trail, with every claim labeled verified versus triangulated versus to-be-confirmed, and carry the six open questions forward without blocking v1.
- Dual distribution from a single layout: managed plugin install path and editable-files install path, with install guidance in the readme.
- No new persistent domain vocabulary beyond the discovery glossary (Property as uuid-identified unit, Listing as channel-side copy, PAT, Enrichment, minor units, calendar_restricted).

## Testing Decisions

- A good test verifies externally observable behavior through the public interface, not implementation details: an agent loading a skill can perform the real operation and get the expected outcome; no assertions on internal helpers, file layout, or prompt wording.
- Test at one high seam wherever possible: the live HTTPS boundary against the production versioned API using a test Property and a read-only PAT. Fewer seams is better; the ideal number is one.
- Modules under test: Properties reads and search, Calendar reads, Reservations list and get. Writes (calendar updates, reservation create and update and cancel, enrichment writes, messaging sends) stay behind an explicit opt-in flag against a dedicated test Property and are never part of the default run.
- Prior art: none in this repo (greenfield). The only executable precedent is the community SDK probes cited in discovery, which inform the smoke shape but are not adopted as fixtures. Default runs must be side-effect free; no checked-in fixtures containing guest PII, tokens, or pre-signed URLs.

## Out of Scope

- Messaging and inbox send flows including throttles and sender resolution.
- Financial payouts, transactions, upsells, owner accounting, and full settlement schema.
- Webhook subscription, verification, routing, and historic resend.
- Tasks, teammates, scheduled messages, smart devices and smartlock provisioning, channels, short and custom codes, knowledge hub, notifications, inquiries, and reviews response flows.
- Vendor OAuth app provisioning, scope grants, and sandbox environments.
- Per-endpoint typed models and recorded response fixtures for to-be-confirmed domains.
- Multi-language SDKs: no dedicated client package beyond skill-embedded request patterns in v1.

## Further Notes

- No issue tracker or triage vocabulary is configured in this repo (setup flow not yet run); this spec is published as a local file and marked ready-for-agent so a future tracker import is trivial.
- Distribution naming, license choice for the public repo, and changelog mechanics are deferred to the publish step under standard-commit guidelines and are not decided here.
- Stoplight endpoint bodies and several guide bodies remain JS-rendered and were triangulated via community mirrors; any skill example that depends on a triangulated shape should retain its verification label until a live probe or Stoplight crawl confirms it.
