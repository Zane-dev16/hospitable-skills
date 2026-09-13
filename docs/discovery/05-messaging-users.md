# 05 — Messaging / Users

## Messaging (triangulated; Stoplight TBC)

- `GET /reservations/{id}/messages` — list; poll for delivery.
- `POST /reservations/{id}/messages {body, images[]?, senderId?}` → `202 {sentReferenceId}`; poll GET and match `message.sentReferenceId`. Video attachments noted Aug 2026 changelog (TBC).
- Limits: **2/min per convo, 50/5min global** — queue + backoff in wrapper.
- Polling-new-messages guide `fzn63bghr1nhq` (nav-verified, body TBC) uses `last_message_at`; scheduled-messages guide + `GET /channels` (2026-05-18) for sender discovery via `?include=listings` (`platform_user_id`).
- `message.created` webhook verified via help article (guest or host sends; no messages >12h old; historic via API).
- Scheduled messages / short codes / custom codes / enrichable shortcodes / knowledge hub: categories nav-verified, ops TBC.

```bash
curl -X POST -H "Authorization: Bearer $PAT" -H "Content-Type: application/json" \
  -d '{"body":"Thanks — code is 4821"}' \
  https://public.api.hospitable.com/v2/reservations/$RID/messages
```

## Users / Teammates (triangulated)

- `GET /user` → `{data:{id,email,name,profile_picture}}` minimal; full billing via `GET /user?include=billing`.
- `GET /properties?include=user` gives minimal user per property.
- Teammates / Tasks categories nav-verified (changelog Apr/Sep 2026), ops TBC. Co-hosts surface inside `listings[].co_hosts[{user_id,name,channel_name}]`.
