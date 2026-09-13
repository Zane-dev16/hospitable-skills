# 03 — Listings / Properties / Calendar

Base `https://public.api.hospitable.com/v2`, `Authorization: Bearer <PAT|OAuth>`. Sources: kacao SDK models + api-evangelist mirrors + search snippets (Stoplight bodies JS-walled, verified).

## Properties

```bash
curl -H "Authorization: Bearer $PAT" -H "Accept: application/json" \
  "https://public.api.hospitable.com/v2/properties?include=user,listings,details,bookings&per_page=50"
```

- `GET /properties`: `include` (unknown ignored), `page/per_page` (max 100), `tags[]`. → `{data: Property[], meta, links}`.
- `GET /properties/{uuid}`: same includes → `{data: Property}`. 404 on bad UUID.
- Core `Property`: `id,name,public_name,picture,timezone,list,calendar_restricted,currency,address{...coordinates as strings},capacity,property_type,room_type,amenities[],tags[] (free-text),house_rules,room_details,checkin/checkout HH:MM,parent_child`.
- Includes: `user{id,email,name,profile_picture}` (billing only via `GET /user?include=billing`); `listings` (needs `listing:read`); `details` (ops fields + **unredacted `wifi_password`** — don't log); `bookings{fees,occupancy_based_rules,listing_markups,discounts?,security_deposits?,booking_policies,site_urls}`; `ical_imports` gated on `include=listings` (undocumented).
- `GET /properties/search?start_date=&end_date=&adults=` (+children/infants/pets/location/site_url): ≤90d window, ≤3y out. **Returns all props; unbookable carry `availability.details.notAvailableReason`.** Item: `{property, pricing{daily[{date,currency,formatted_string}],total,total_without_taxes}, availability{available,details[]}, distance_in_km}`.
- Tags: `GET .../tags → {data:[{id,name}]}` (org registry, ≠ free-text `Property.tags`); `POST {tags:string[]}` 1–10/call else 422.
- Images: `GET .../images → {data:[{url,thumbnail_url,caption,order,last_updated_at}]}`. **Pre-signed S3 (~1h) — never cache.**
- Quote: `POST .../quote {checkin_date,checkout_date,guests:{adults,...},guest_details?,promo_code?}`. Direct-gated, return shape unprobed.
- iCal: scope `ical:write`. Create `{url (.ics),name?,host?}` / update `{url?,name?,host?,resync?}` → `{data:{id,url,name,host,last_sync_at,disconnected_at}}`. **`url` is a credential — redact in logs.**

## Listings / Channels (no CRUD)

1. `GET /listings` (`page,per_page`) → `{data:[{id,property_id,platform,platform_id,name,status}]}`.
2. `?include=listings` — canonical: `{platform,platform_id,platform_user_id,platform_picture,platform_name,platform_email,co_hosts[]}`. Use for sender discovery (`platform:"airbnb",platform_id,platform_user_id`).
3. `GET /channels` (~2026-05-18): platforms + host ids. Needs `property:read`.

## Calendar

```bash
curl -H "Authorization: Bearer $PAT" \
  "https://public.api.hospitable.com/v2/properties/$UUID/calendar?start_date=2026-10-01&end_date=2026-10-31"
# PUT: {"note":"...","dates":[{"date":"2026-10-01","price":{"amount":15000},"available":true,"min_stay":2,...}]}
```

- GET needs `property:read`+`calendar:read`, both dates `YYYY-MM-DD`. → `{data:{listing_id,provider,start_date,end_date,days:[{date,day,min_stay,status{reason:AVAILABLE|RESERVED|BLOCKED,source_type,source,available},price{amount minor,currency,formatted},closed_for_checkin,closed_for_checkout}]}}`.
- PUT needs `property:read`+`calendar:write`. **Additive merge, async (poll GET), ≤60 dates/call, ≤1095d out.** Per-date: `date*,price?{amount},available?,min_stay?,closed_for_checkin/out?,note?|null`. Top-level `note` default; `""|null` clears; 512 chars. Use `PUT {dates:[]}` (silkyland `PATCH {days:[]}` is drift).
- `POST .../calendar/block|unblock {startDate,endDate,reason?}` convenience (camelCase).
- Quirks: `calendar_restricted=true` → PUT 422 (fix in Airbnb); `price.amount` minor units; coordinates strings; unknown `include` fails open; lead-platform sync can override Manual writes.
