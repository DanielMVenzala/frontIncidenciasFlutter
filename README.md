<h1 align="center">Martos Arregla</h1>

<p align="center">
  <strong>App móvil para la gestión de incidencias urbanas del municipio de Martos (Jaén)</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs" alt="NestJS">
  <img src="https://img.shields.io/badge/PostgreSQL-Neon-4169E1?logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Deploy-Render-46E3B7?logo=render" alt="Render">
</p>

---

<p align="center">
  <img src="assets/images/Animation.gif" alt="Demo de la app" width="300">
</p>

---



## Qué hace esta app

Los ciudadanos de Martos pueden **reportar problemas** en la vía pública (baches, alumbrado, mobiliario, limpieza...) desde su móvil. Los administradores del ayuntamiento **gestionan, priorizan y resuelven** esas incidencias en tiempo real.

---

## Funcionalidades principales

### Ciudadano

| Función              | Descripción                                                          |
| -------------------- | -------------------------------------------------------------------- |
| Crear incidencia     | Título, descripción, dirección, prioridad y hasta 5 fotos            |
| Geolocalización      | La dirección se valida y geocodifica automáticamente con Google Maps |
| Seguimiento          | Ver el estado de tus incidencias y las notas del administrador       |
| Activación por email | Registro seguro con verificación por enlace de activación            |

### Administrador

| Función             | Descripción                                                     |
| ------------------- | --------------------------------------------------------------- |
| Gestión completa    | Cambiar estado, prioridad, dejar notas visibles para el usuario |
| Mapa interactivo    | Todas las incidencias geolocalizadas con marcadores por estado  |
| Estadísticas        | Gráficos por estado, prioridad y evolución mensual              |
| Gestión de usuarios | Bloquear, desbloquear o eliminar usuarios                       |
| Filtros avanzados   | Buscar y ordenar por estado, prioridad, fecha, título...        |

### UX

- Modo claro / oscuro con persistencia
- Animaciones Hero entre lista y detalle
- Visor de imágenes a pantalla completa con zoom
- Teléfonos de interés con apertura directa del marcador
- Mensajes de error en español

---

## Decisiones técnicas destacables

- **De Nodemailer/SMTP a Resend.** El plan gratuito de Render bloquea conexiones SMTP salientes, así que migré el envío de emails (activación de cuenta y reset de contraseña) a la API HTTP de Resend manteniendo la misma DX.
- **Validación geográfica con la fórmula Haversine.** El backend rechaza cualquier dirección que esté a más de 5 km del centro de Martos, asegurando que las incidencias pertenecen al municipio.
- **Google Places enrutado por el backend.** La API key de Google Maps está restringida al paquete Android + huella SHA-1, así que el autocompletado de direcciones se hace desde el servidor para que la clave nunca salga del dispositivo.
- **Reset de contraseña sin deep links.** El email de recuperación abre un formulario HTML servido por el propio backend, evitando la complejidad de configurar deep links nativos en Android.
- **Informes Excel generados en runtime.** Multi-hoja (resumen ejecutivo + listado completo) con `exceljs`, filtros automáticos en cabeceras y panes congelados. Descarga directa al móvil con `path_provider` + `open_filex`.
- **Token UUID de un solo uso** para activar cuentas y resetear contraseñas, con expiración temporal y borrado tras el primer uso.

## Seguridad

JWT con Passport, contraseñas hasheadas con bcrypt (10 salt rounds), guards de roles personalizados, activación de cuenta obligatoria por email, bloqueo administrativo de cuentas, validación estricta de DTOs con `class-validator` (whitelist + forbidNonWhitelisted) y mitigación de enumeración de usuarios en el endpoint de recuperación de contraseña.

---

## Arquitectura

```
Flutter (Dart)                    NestJS (TypeScript)
+------------------+             +---------------------+
|  UI (Pages)      |             |  Controllers        |
|  Providers       | --- HTTP -->|  Services           |
|  Services (Dio)  |   (JWT)    |  TypeORM Entities   |
+------------------+             +---------------------+
                                          |
                                 +--------+--------+
                                 |  PostgreSQL      |
                                 |  (Neon)          |
                                 +---------+--------+
                                           |
                          +----------------+----------------+
                          |                |                |
                    Cloudinary      Google Maps       Resend
                    (imágenes)    (geocoding)       (emails)
```

---

## Stack tecnológico

| Capa           | Tecnología                          |
| -------------- | ----------------------------------- |
| Frontend       | Flutter + Provider + Dio + GoRouter |
| Backend        | NestJS + TypeORM + Passport JWT     |
| Base de datos  | PostgreSQL (Neon)                   |
| Imágenes       | Cloudinary                          |
| Emails         | Resend                              |
| Mapas          | Google Maps Platform                |
| Deploy backend | Render                              |

---

## Cómo ejecutar en local

### Backend

```bash
git clone https://github.com/DanielMVenzala/backendIncidenciasNest.git
cd backendIncidenciasNest
npm install
# Configurar .env con las variables de entorno necesarias
npm run start:dev
```

### Frontend

```bash
git clone https://github.com/DanielMVenzala/frontIncidenciasFlutter.git
cd frontIncidenciasFlutter
flutter pub get
# Cambiar baseUrl en lib/config/app_config.dart si usas backend local
flutter run
```

### Generar APK

```bash
flutter build apk --release
```

---

## Variables de entorno (backend)

| Variable              | Descripción                                 |
| --------------------- | ------------------------------------------- |
| `DB_NAME`             | Nombre de la base de datos                  |
| `DB_USERNAME`         | Usuario de PostgreSQL                       |
| `DB_PASSWORD`         | Contraseña de PostgreSQL                    |
| `DB_PORT`             | Puerto de PostgreSQL                        |
| `HOST_API`            | URL pública del backend                     |
| `JWT_SECRET`          | Clave secreta para firmar tokens JWT        |
| `BCRYPT_SALT_ROUNDS`  | Rondas de hasheo de contraseñas             |
| `RESEND_API_KEY`      | API key de Resend para envío de emails      |
| `GOOGLE_MAPS_API_KEY` | API key de Google Maps para geocodificación |
| `SEED_PASSWORD`       | Contraseña genérica para usuarios del seed  |

---

## Repositorios

| Proyecto           | Enlace                                                                               |
| ------------------ | ------------------------------------------------------------------------------------ |
| Backend (NestJS)   | [backendIncidenciasNest](https://github.com/DanielMVenzala/backendIncidenciasNest)   |
| Frontend (Flutter) | [frontIncidenciasFlutter](https://github.com/DanielMVenzala/frontIncidenciasFlutter) |
| Panel web (Next.js) | [web-incidencias-next](https://github.com/DanielMVenzala/web-incidencias-next) |

---

<p align="center">
  Proyecto de fin de ciclo — Desarrollo de Aplicaciones Multiplataforma (DAM) 2026
</p>

-->

---

<h1 align="center">Martos Arregla</h1>

<p align="center">
  <strong>A mobile app to report and manage urban issues in Martos (Jaén, Spain)</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs" alt="NestJS">
  <img src="https://img.shields.io/badge/PostgreSQL-Neon-4169E1?logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Deploy-Render-46E3B7?logo=render" alt="Render">
</p>

---

<p align="center">
  <img src="assets/images/Animation.gif" alt="App demo" width="300">
</p>

---

## What it does *(in production)*

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
| Web admin panel      | Full Next.js dashboard with batch editing, advanced filters and SSR          |

> Admins can also work from the **dedicated web panel** ([web-incidencias-next](https://github.com/DanielMVenzala/web-incidencias-next)), built in Next.js + Tailwind. It shares the same REST API and adds bulk editing, sortable columns and richer filtering for desktop workflows.

### Polish

- Light and dark themes that stick across sessions
- Hero animations when drilling into a report from the list
- Pinch-to-zoom photo viewer with a paged carousel
- Quick-dial directory for council and emergency numbers
- Spanish-localised error messages end-to-end

---

## Technical highlights

- **Swapped Nodemailer/SMTP for Resend.** Render's free tier blocks outbound SMTP, so I migrated all transactional email (account activation and password reset) to Resend's HTTP API while keeping the same DX.
- **Geographic gating with the Haversine formula.** The backend rejects any address that sits more than 5 km away from Martos centre, guaranteeing that incidents actually belong to the municipality.
- **Google Places routed through the backend.** The Maps API key is locked down to the Android app's package + SHA-1 fingerprint, so address autocomplete is proxied via the server — the key never leaves the device or hits a public log.
- **Password reset with no deep links.** The recovery email opens an HTML form served by the backend itself, sidestepping the pain of wiring native deep links on Android.
- **Excel reports generated on the fly.** Multi-sheet workbooks (executive summary + full backlog) built with `exceljs`, including auto-filters and frozen headers. Direct download to the device with `path_provider` + `open_filex`.
- **Single-use UUID tokens** for both account activation and password reset, with time-bound expiry and one-shot consumption.

## Security

JWT auth via Passport, bcrypt-hashed passwords (10 salt rounds), custom role-based guards on every sensitive endpoint, mandatory email activation, admin-driven account blocking, strict DTO validation with `class-validator` (whitelist + forbidNonWhitelisted) and protection against user enumeration on the password reset endpoint.

---

## Architecture

```
Flutter mobile app          Next.js admin panel
+------------------+        +---------------------+
|  UI (Pages)      |        |  Pages (App Router) |
|  Providers       |        |  Components         |
|  Services (Dio)  |        |  Services (Axios)   |
+--------+---------+        +---------+-----------+
         \                            /
          \   HTTP + JWT             /
           \                        /
            v                      v
         +-----------------------------+
         |      NestJS REST API        |
         |  Controllers · Services     |
         |  TypeORM · Guards · DTOs    |
         +--------------+--------------+
                        |
              +---------+---------+
              |    PostgreSQL     |
              |       (Neon)      |
              +---------+---------+
                        |
        +---------------+---------------+
        |               |               |
   Cloudinary     Google Maps        Resend
    (images)      (geocoding)        (emails)
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
| Web admin (Next.js) | [web-incidencias-next](https://github.com/DanielMVenzala/web-incidencias-next) |

---

<p align="center">
  Final-year project for the Multiplatform App Development course (Spain) — 2026
</p>

---
