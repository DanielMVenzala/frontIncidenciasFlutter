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

