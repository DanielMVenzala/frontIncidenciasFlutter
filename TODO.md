# TODO — Mejoras futuras

## Web de administración — Martos Arregla

Panel web para la gestión avanzada del administrador. No requiere cambios en el backend — todos los endpoints ya existen.

### Stack

| Tecnología              | Para qué                                            |
| ----------------------- | --------------------------------------------------- |
| Next.js 14 (App Router) | Framework React con routing automático y SSR        |
| Tailwind CSS            | Estilos utilitarios, diseño responsive rápido       |
| Axios                   | Cliente HTTP (equivalente a Dio en Flutter)         |
| Recharts                | Gráficos para el dashboard (equivalente a fl_chart) |
| js-cookie               | Gestión de JWT en cookies                           |

### Despliegue

- **Plataforma**: Vercel (plan gratuito)
- **Repositorio**: nuevo repo `webAdminMartosArregla` en GitHub
- **URL estimada**: `https://admin-martos-arregla.vercel.app`
- Auto-deploy en cada push a main

### Pasos para implementar

1. ~~Crear proyecto Next.js con TypeScript y Tailwind~~ ✅
2. ~~Configurar Axios con interceptor JWT + proxy en next.config.mjs~~ ✅
3. ~~Implementar /login (email + contraseña, solo admins)~~ ✅
4. ~~Implementar layout con sidebar + header~~ ✅
5. ~~Implementar /dashboard con KPIs y gráficos~~ ✅
6. ~~Implementar /incidents — tabla con filtros y paginación~~ ✅
7. ~~Implementar /incidents/[id] — detalle de incidencia~~ ✅
8. ~~Implementar /users — tabla con acciones~~ ✅
9. **Desplegar en Vercel**
10. **Añadir enlace al README principal**

### Detalle de lo que falta

#### 9. Desplegar en Vercel

- Crear repo en GitHub ✅ (DanielMVenzala/web-incidencias-next)
- Conectar con Vercel
- No requiere variables de entorno (el proxy está en next.config.mjs)

#### 10. Enlace al README

- Añadir sección en el README del backend con enlace a la web

### Funcionalidades extra (opcionales)

- Botón "Descargar informe Excel" en el dashboard (`GET /incidents/report/excel`)
- Mapa con marcadores en el dashboard (Leaflet o Google Maps embed)
- Gestión masiva de incidencias (seleccionar varias y cambiar estado de golpe)
- Filtros combinados persistentes en la URL (compartibles)
- Impresión de informes directamente desde el navegador

### Endpoints que reutiliza (todos ya existen)

| Endpoint                  | Método | Uso en la web                      |
| ------------------------- | ------ | ---------------------------------- |
| `/users/login`            | POST   | Login admin                        |
| `/users`                  | GET    | Tabla de usuarios                  |
| `/users/:id`              | GET    | Detalle usuario                    |
| `/users/:id/toggle-block` | PATCH  | Bloquear/desbloquear               |
| `/users/:id`              | DELETE | Eliminar usuario                   |
| `/users/report/excel`     | GET    | Exportar usuarios                  |
| `/incidents`              | GET    | Tabla de incidencias (con filtros) |
| `/incidents/:id`          | GET    | Detalle incidencia                 |
| `/incidents/:id`          | PATCH  | Cambiar estado/prioridad           |
| `/incidents/:id`          | DELETE | Eliminar incidencia                |
| `/incidents/:id/comments` | POST   | Añadir nota                        |
| `/incidents/report/excel` | GET    | Exportar incidencias               |

### Archivos ya implementados

```
web_incidencias/
├── app/
│   ├── layout.tsx                 ✅ Layout global (Poppins + AuthProvider)
│   ├── page.tsx                   ✅ Redirect a /dashboard
│   ├── globals.css                ✅ Estilos base
│   ├── login/
│   │   └── page.tsx               ✅ Login exclusivo para admins
│   ├── dashboard/
│   │   ├── layout.tsx             ✅ Layout autenticado (usa AdminLayout)
│   │   └── page.tsx               ✅ KPIs, gráficos de estado/prioridad/evolución
│   ├── users/
│   │   ├── layout.tsx             ✅ Layout autenticado (usa AdminLayout)
│   │   └── page.tsx               ✅ Tabla, filtros, bloqueo/desbloqueo, eliminar, Excel
│   └── incidents/
│       ├── layout.tsx             ✅ Layout autenticado (usa AdminLayout)
│       ├── page.tsx               ✅ Tabla paginada, filtros, ordenación, export Excel
│       └── [id]/
│           └── page.tsx           ✅ Detalle, galería, comentarios, editar, eliminar
├── components/
│   ├── Sidebar.tsx                ✅ Navegación lateral
│   ├── Header.tsx                 ✅ Barra superior con nombre admin + logout
│   ├── StatsCard.tsx              ✅ Tarjeta de KPI
│   ├── StatusChart.tsx            ✅ Gráfico donut por estado
│   ├── PriorityChart.tsx          ✅ Gráfico barras por prioridad
│   ├── MonthlyChart.tsx           ✅ Gráfico evolución mensual
│   ├── AdminLayout.tsx            ✅ Layout compartido (sidebar + header)
│   ├── ConfirmDialog.tsx          ✅ Diálogo de confirmación reutilizable
│   ├── StatusBadge.tsx            ✅ Badge de estado con color
│   └── PriorityBadge.tsx          ✅ Badge de prioridad con color
├── services/
│   ├── api.ts                     ✅ Axios con interceptor JWT
│   ├── auth.service.ts            ✅ Login, logout, verificar sesión
│   ├── incidents.service.ts       ✅ getIncidents()
│   └── users.service.ts           ✅ getUsers, toggleBlock, deleteUser, downloadExcel
├── hooks/
│   └── useAuth.tsx                ✅ AuthProvider + hook useAuth
├── middleware.ts                  ✅ Protección de rutas por cookie
├── next.config.mjs                ✅ Proxy rewrites al backend en Render
├── tailwind.config.ts             ✅ Colores custom (paleta Martos Arregla)
├── .env.local                     ✅ API URL
└── public/
    └── logo.png                   ✅ Logo de Martos Arregla
```

---

## Documentación unificada del TFG

Documento maestro que conecte los 3 proyectos (backend + app + web) como un sistema completo. Se elaborará cuando la app y la web estén desplegadas y estables.

### Qué incluir

- **Documento único** `DOCUMENTACION_TFG.md` en la raíz del backend, unificando LOGICA_COMPLETA.md + CLAUDE.md
- **README del backend** — actualmente no existe. Añadir descripción, cómo ejecutar, endpoints y variables de entorno
- **Actualizar LOGICA_COMPLETA.md** con los últimos cambios que faltan:
  - Foto de perfil de usuario (Cloudinary)
  - Descarga de informes Excel desde el frontend (path_provider + open_filex)
  - Colores actualizados del mapa (leyenda alineada con pines de Google Maps)
  - Web de administración (cuando esté implementada)
- **Diagramas**:
  - Esquema de base de datos visual (tablas users, incidents, incident_images, incident_comments + relaciones)
  - Diagrama de arquitectura del sistema completo (backend + app Flutter + web Next.js + servicios externos)
  - Mapa de pantallas de la app y la web con accesos por rol
- **Capturas de pantalla** de las pantallas principales de la app y la web
- **Sección de la web admin** — arquitectura, stack, páginas, decisiones técnicas

### Orden de ejecución

1. Terminar la web de administración
2. Desplegar la web en Vercel
3. Actualizar LOGICA_COMPLETA.md con todo lo nuevo
4. Crear README del backend
5. Crear DOCUMENTACION_TFG.md unificado
6. Usar ese documento como fuente para Claude Desktop al redactar la memoria Word
