# Incidencias Martos

Aplicacion movil para la gestion de incidencias urbanas del municipio de Martos (Jaen). Desarrollada con Flutter y conectada a un backend en NestJS.

---

## Como funciona la app

### 1. Registro y activacion de cuenta

- Abre la app y pulsa **Registrarse**.
- Introduce tu nombre, correo electronico y contrasena.
- Recibiras un email con un enlace para activar tu cuenta.
- Pulsa el enlace desde el movil o navegador y tu cuenta quedara activa.
- Vuelve a la app e inicia sesion con tus credenciales.

### 2. Menu principal (usuario)

Tras iniciar sesion veras el menu con las siguientes opciones:

- **Abrir incidencia** — Crear una nueva incidencia.
- **Mis incidencias** — Consultar el listado de tus incidencias.
- **Mi perfil** — Editar tu nombre o cambiar la contrasena.
- **Telefonos de interes** — Directorio de telefonos utiles del municipio. Al pulsar un telefono se abre el marcador de llamada.
- **Cerrar sesion** — Salir de la app.

### 3. Crear una incidencia

1. Pulsa **Abrir incidencia** en el menu.
2. Rellena el titulo, la descripcion y la direccion (debe ser una direccion real de Martos).
3. Selecciona la prioridad (baja, media, alta o critica).
4. Anade fotos pulsando **Anadir fotos**. Puedes elegir de la galeria o hacer fotos con la camara (hasta 5).
5. Pulsa **Crear incidencia**. La direccion se geocodificara automaticamente para aparecer en el mapa.

### 4. Consultar mis incidencias

- En **Mis incidencias** veras todas las que has creado con su estado actual.
- Pulsa en cualquiera para ver el detalle completo: fotos (con zoom al pulsar), descripcion, direccion, prioridad, estado y las notas que haya dejado el administrador.
- Las fotos se pueden recorrer con flechas laterales y al pulsar una se abre a pantalla completa con zoom.

### 5. Menu principal (administrador)

El administrador tiene opciones adicionales:

- **Todas las incidencias** — Listado completo con filtros por estado, prioridad, titulo, descripcion y fecha. Se puede ordenar por cualquier criterio.
- **Mapa de incidencias** — Mapa de Google Maps centrado en Martos con marcadores de colores segun el estado (naranja = pendiente, azul = en progreso, verde = resuelta). Las incidencias rechazadas no aparecen.
- **Gestionar usuarios** — Listado de todos los usuarios registrados. Desde aqui se puede bloquear/desbloquear o eliminar usuarios.
- **Estadisticas** — Panel con graficos: tarjetas resumen, grafico donut por estado, barras por prioridad y evolucion mensual.

### 6. Gestionar una incidencia (administrador)

1. Accede al detalle de cualquier incidencia.
2. Cambia el estado (pendiente, en progreso, resuelta, rechazada) o la prioridad.
3. Deja notas en el apartado de comentarios (por ejemplo: "Se ha enviado un operario"). Estas notas son visibles para el usuario como un timeline.

### 7. Bloquear un usuario

- En **Gestionar usuarios**, pulsa el icono de candado junto al usuario.
- Confirma la accion. El usuario vera un mensaje indicando que su cuenta ha sido bloqueada al intentar iniciar sesion.
- Para desbloquearlo, pulsa el mismo icono de nuevo.

### 8. Modo oscuro

- Pulsa el icono de sol/luna en la esquina del menu principal para alternar entre modo claro y oscuro. La preferencia se guarda automaticamente.

---

## Requisitos tecnicos

- **Android 5.0** (API 21) o superior
- Conexion a Internet para comunicarse con el backend
- Permisos de camara y galeria para adjuntar fotos

## Compilar el APK

```bash
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.
