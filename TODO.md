# TODO — Mejoras futuras

## Documentación final del TFG

Antes de la defensa hay que cerrar la documentación del proyecto.

### Estado actual

- ✅ `LOGICA_COMPLETA.md` (raíz del backend) — documento maestro con toda la lógica técnica del sistema (backend + app móvil + web admin)
- ✅ `README.md` (raíz de cada repo) — vista comercial bilingüe para GitHub, con badges, GIF, arquitectura y stack
- ✅ `CLAUDE.md` (raíz del frontend Flutter) — índice rápido que apunta al documento maestro
- ✅ Repos sincronizados en GitHub: backend, frontend Flutter y web Next.js

### Lo que falta

- [ ] **Documento Word de la memoria del TFG** — usar `LOGICA_COMPLETA.md` como fuente única para redactarlo. Las secciones nuevas (foto de perfil, web de administración, decisiones técnicas, trabajo futuro y conclusiones) ya están incluidas.
- [ ] **Diagrama Entidad-Relación** visual de la BD — actualmente solo está en texto y tablas. Generar imagen para incluir en el Word.
- [ ] **Capturas del Excel generado** (resumen ejecutivo + listado completo) para incluir en el manual del administrador.
- [ ] **Capturas del panel web** — para incluir en el Word junto a las del móvil.

---

## Mejoras de la aplicación (post-TFG)

Las recoge la sección **24. TRABAJO FUTURO Y MEJORAS** del `LOGICA_COMPLETA.md`. Resumen rápido:

### Seguridad

- Rate limiting en login y registro con `@nestjs/throttler`
- Refresh tokens además del access token
- Verificación de propiedad en `PATCH /users/:id`
- Autenticación obligatoria en `POST /incidents` y `POST /files/incident`
- Logs de auditoría

### Funcionalidades

- Notificaciones push al usuario cuando cambia el estado de su incidencia
- Comentarios bidireccionales (que el ciudadano pueda responder al admin)
- Categorías de incidencias (limpieza, alumbrado, mobiliario...)
- Área de cobertura configurable (actualmente 5 km hardcodeado)
- Modo oscuro en la web admin

### Tests

- Tests unitarios del backend con Jest
- Tests de integración con SuperTest
- Widget tests en Flutter
- Tests E2E de la web con Playwright
