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

<!-- ==================== ESPAÑOL ==================== -->

## Qué hace esta app

Los ciudadanos de Martos pueden **reportar problemas** en la vía pública (baches, alumbrado, mobiliario, limpieza...) desde su móvil. Los administradores del ayuntamiento **gestionan, priorizan y resuelven** esas incidencias en tiempo real.

---

## Funcionalidades principales

### Ciudadano

| Función | Descripción |
|---------|-------------|
| Crear incidencia | Título, descripción, dirección, prioridad y hasta 5 fotos |
| Geolocalización | La dirección se valida y geocodifica automáticamente con Google Maps |
| Seguimiento | Ver el estado de tus incidencias y las notas del administrador |
| Activación por email | Registro seguro con verificación por enlace de activación |

### Administrador

| Función | Descripción |
|---------|-------------|
| Gestión completa | Cambiar estado, prioridad, dejar notas visibles para el usuario |
| Mapa interactivo | Todas las incidencias geolocalizadas con marcadores por estado |
| Estadísticas | Gráficos por estado, prioridad y evolución mensual |
| Gestión de usuarios | Bloquear, desbloquear o eliminar usuarios |
| Filtros avanzados | Buscar y ordenar por estado, prioridad, fecha, título... |

### UX

- Modo claro / oscuro con persistencia
- Animaciones Hero entre lista y detalle
- Visor de imágenes a pantalla completa con zoom
- Teléfonos de interés con apertura directa del marcador
- Mensajes de error en español

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

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter + Provider + Dio + GoRouter |
| Backend | NestJS + TypeORM + Passport JWT |
| Base de datos | PostgreSQL (Neon) |
| Imágenes | Cloudinary |
| Emails | Resend |
| Mapas | Google Maps Platform |
| Deploy backend | Render |

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

| Variable | Descripción |
|----------|-------------|
| `DB_NAME` | Nombre de la base de datos |
| `DB_USERNAME` | Usuario de PostgreSQL |
| `DB_PASSWORD` | Contraseña de PostgreSQL |
| `DB_PORT` | Puerto de PostgreSQL |
| `HOST_API` | URL pública del backend |
| `JWT_SECRET` | Clave secreta para firmar tokens JWT |
| `BCRYPT_SALT_ROUNDS` | Rondas de hasheo de contraseñas |
| `RESEND_API_KEY` | API key de Resend para envío de emails |
| `GOOGLE_MAPS_API_KEY` | API key de Google Maps para geocodificación |
| `SEED_PASSWORD` | Contraseña genérica para usuarios del seed |

---

## Repositorios

| Proyecto | Enlace |
|----------|--------|
| Backend (NestJS) | [backendIncidenciasNest](https://github.com/DanielMVenzala/backendIncidenciasNest) |
| Frontend (Flutter) | [frontIncidenciasFlutter](https://github.com/DanielMVenzala/frontIncidenciasFlutter) |

---

<p align="center">
  Proyecto de fin de ciclo — DAM 2026
</p>

---

<!-- ==================== ENGLISH ==================== -->

<h2 align="center">English</h2>

## What is Martos Arregla?

Martos Arregla is a mobile app that lets residents of Martos (Jaen, Spain) **report urban issues** — potholes, broken streetlights, damaged furniture, littering — straight from their phone. City administrators can then **manage, prioritize and resolve** those reports in real time.

---

## Key Features

### For residents

| Feature | Details |
|---------|---------|
| Report an issue | Title, description, address, priority level and up to 5 photos |
| Geolocation | Addresses are validated and geocoded automatically via Google Maps |
| Track progress | Check the status of your reports and read admin notes |
| Email activation | Secure sign-up with a one-time activation link |

### For administrators

| Feature | Details |
|---------|---------|
| Full management | Update status, change priority, leave notes visible to the reporter |
| Interactive map | All geolocated incidents plotted on Google Maps, color-coded by status |
| Analytics | Charts by status, priority and monthly trends |
| User management | Block, unblock or delete user accounts |
| Advanced filters | Search and sort by status, priority, date, title... |

### UX

- Light / dark mode with persistence
- Hero animations between list and detail views
- Full-screen image viewer with pinch-to-zoom
- Quick-dial directory for local emergency numbers
- User-facing error messages in Spanish

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
                                 |  PostgreSQL      |
                                 |  (Neon)          |
                                 +---------+--------+
                                           |
                          +----------------+----------------+
                          |                |                |
                    Cloudinary      Google Maps       Resend
                    (images)      (geocoding)       (emails)
```

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter + Provider + Dio + GoRouter |
| Backend | NestJS + TypeORM + Passport JWT |
| Database | PostgreSQL (Neon) |
| Image storage | Cloudinary |
| Email delivery | Resend |
| Maps | Google Maps Platform |
| Backend hosting | Render |

---

## Getting Started

### Backend

```bash
git clone https://github.com/DanielMVenzala/backendIncidenciasNest.git
cd backendIncidenciasNest
npm install
# Set up your .env file with the required environment variables
npm run start:dev
```

### Frontend

```bash
git clone https://github.com/DanielMVenzala/frontIncidenciasFlutter.git
cd frontIncidenciasFlutter
flutter pub get
# Update baseUrl in lib/config/app_config.dart if running the backend locally
flutter run
```

### Build the APK

```bash
flutter build apk --release
```

---

## Environment Variables (backend)

| Variable | Purpose |
|----------|---------|
| `DB_NAME` | Database name |
| `DB_USERNAME` | PostgreSQL user |
| `DB_PASSWORD` | PostgreSQL password |
| `DB_PORT` | PostgreSQL port |
| `HOST_API` | Public backend URL |
| `JWT_SECRET` | Secret key for signing JWT tokens |
| `BCRYPT_SALT_ROUNDS` | Password hashing rounds |
| `RESEND_API_KEY` | Resend API key for transactional emails |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key for geocoding |
| `SEED_PASSWORD` | Default password used by the database seeder |

---

## Repositories

| Project | Link |
|---------|------|
| Backend (NestJS) | [backendIncidenciasNest](https://github.com/DanielMVenzala/backendIncidenciasNest) |
| Frontend (Flutter) | [frontIncidenciasFlutter](https://github.com/DanielMVenzala/frontIncidenciasFlutter) |

---

<p align="center">
  Final year project — DAM 2026
</p>
