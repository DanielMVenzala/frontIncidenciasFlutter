<p align="center">
  Proyecto de fin de ciclo — DAM 2026
</p>

-->

---

## What it does

Martos Arregla puts the city in your pocket. Residents can snap a photo of anything that needs fixing — a pothole, a broken streetlight, fly-tipping, a damaged bench — and send it straight to the town hall. From the other side, council staff get a live dashboard to triage, prioritise and close down reports without ever leaving the app.

---

## Highlights

### What residents can do

| Feature           | What it gives you                                                          |
| ----------------- | -------------------------------------------------------------------------- |
| File a report     | Title, description, address, priority and up to 5 photos                   |
| Smart address     | Autocomplete and validation against real Martos streets via Google Maps    |
| Live tracking     | Follow your report from "pending" to "resolved" with notes from staff      |
| Secure onboarding | Email-based sign-up with a one-time activation link and password recovery  |

### What admins get

| Feature              | What it gives you                                                            |
| -------------------- | ---------------------------------------------------------------------------- |
| Triage dashboard     | Update status, set priority and leave public notes on any report             |
| Live map             | Every active incident pinned on a Google Map and colour-coded by status      |
| Insights             | Charts and KPIs broken down by status, priority and month                    |
| Excel export         | One-tap download with two sheets: an executive summary and the full backlog  |
| User management      | Block, unblock or remove accounts when something goes sideways               |
| Powerful filtering   | Search and sort the backlog by status, priority, date or free text           |

### Polish

- Light and dark themes that stick across sessions
- Hero animations when drilling into a report from the list
- Pinch-to-zoom photo viewer with a paged carousel
- Quick-dial directory for council and emergency numbers
- Spanish-localised error messages end-to-end

---

## Architecture

```
Flutter (Dart)                    NestJS (TypeScript)
+------------------+             +---------------------+
|  UI (Pages)      |             |  Controllers        |
|  Providers       | --- HTTP -->|  Services           |
|  Services (Dio)  |   (JWT)    |  TypeORM Entities   |
+------------------+             +---------------------+
                                          |
                                 +--------+--------+
                                 |   PostgreSQL    |
                                 |     (Neon)      |
                                 +--------+--------+
                                          |
                          +---------------+---------------+
                          |               |               |
                    Cloudinary      Google Maps        Resend
                     (images)       (geocoding)        (emails)
```

---

## Tech stack

| Layer                | Tooling                              |
| -------------------- | ------------------------------------ |
| Frontend             | Flutter, Provider, Dio, GoRouter     |
| Backend              | NestJS, TypeORM, Passport JWT        |
| Database             | PostgreSQL on Neon                   |
| Image storage        | Cloudinary                           |
| Transactional email  | Resend                               |
| Maps & geocoding     | Google Maps Platform                 |
| Backend hosting      | Render                               |

---

## Run it locally

### Backend

```bash
git clone https://github.com/DanielMVenzala/backendIncidenciasNest.git
cd backendIncidenciasNest
npm install
# Drop your secrets into .env (see the table below)
npm run start:dev
```

### Frontend

```bash
git clone https://github.com/DanielMVenzala/frontIncidenciasFlutter.git
cd frontIncidenciasFlutter
flutter pub get
# Point lib/config/app_config.dart at your local backend if needed
flutter run
```

### Ship a release APK

```bash
flutter build apk --release
```

---

## Backend environment variables

| Variable              | Purpose                                                           |
| --------------------- | ----------------------------------------------------------------- |
| `DB_NAME`             | Database name                                                     |
| `DB_USERNAME`         | PostgreSQL username                                               |
| `DB_PASSWORD`         | PostgreSQL password                                               |
| `DB_PORT`             | PostgreSQL port                                                   |
| `HOST_API`            | Public URL where the backend is reachable                         |
| `JWT_SECRET`          | Secret used to sign and verify JWT tokens                         |
| `BCRYPT_SALT_ROUNDS`  | bcrypt cost factor for password hashing                           |
| `RESEND_API_KEY`      | API key for sending transactional email through Resend            |
| `GOOGLE_MAPS_API_KEY` | Backend Google Maps key for Geocoding and Places (no app limit)   |
| `SEED_PASSWORD`       | Generic password assigned to every user created by the seeder     |

---

## Repositories

| Project            | Link                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------ |
| Backend (NestJS)   | [backendIncidenciasNest](https://github.com/DanielMVenzala/backendIncidenciasNest)   |
| Frontend (Flutter) | [frontIncidenciasFlutter](https://github.com/DanielMVenzala/frontIncidenciasFlutter) |

---

<p align="center">
  Final degree project — DAM 2026
</p>

---
