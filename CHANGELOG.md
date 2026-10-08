## 0.0.11

- Añade callbacks de menciones con el ID mencionado y el ID de la publicación guardada.
- Añade `onReportTweet` después de guardar denuncias y conserva `onReport` como alternativa.
- Permite pasar IDs bloqueados a la configuración y completa las páginas del muro con publicaciones visibles.
- Actualiza la app de pruebas para consumir el checkout local de `pizzacorn_ui`.

## 0.0.10

- Añade `onTapUser` para abrir perfiles desde las fotos, conservando `onOpenProfile` como alternativa.
- Deja el editor de publicaciones blanco, sin bordes ni relleno, con el texto «¿Qué esta pasando?».

## 0.0.9

- Mantiene el filtro del muro fijo en la parte superior y sin padding exterior.
- Sitúa el buscador y las publicaciones en el contenido desplazable debajo del filtro.

## 0.0.8

- Permite configurar los fondos principal y secundario solo para la comunidad.
- Añade un buscador opcional de publicaciones con Firestore Enterprise y filtro por categoría.
- Limita `uicons_pro` a las versiones compatibles con `pizzacorn_ui`.

## 0.0.7

- Deja de reexportar `pizzacorn_ui` desde `config/imports.dart`.
- Mantiene la API de `pizzacorn_ui` disponible desde el barrel público de comunidad, excluyendo las colisiones existentes.
- Añade filtros opcionales para el muro y la publicación, con colores configurables para el control segmentado.
- Añade menciones de usuarios y entidades en publicaciones y citas, con búsqueda configurable.

## 0.0.6

- Añade el enlace del repositorio en los metadatos del paquete.

## 0.0.5

- Compacta la barra de respuesta en comentarios.
- Hace que el campo de respuesta crezca hasta cuatro líneas al escribir.
- Cambia la barra de respuesta a `COLOR_BACKGROUND`.

## 0.0.4

- Añade imágenes en respuestas de comentarios.
- Comprime las imágenes seleccionadas antes de subirlas para acelerar la publicación.
- Evita errores de Firestore cuando una publicación llega sin id válido.
- Ajusta la caja de respuesta para que suba con el teclado.

## 0.0.3

- Hace que el toque de like actualice corazón, color y contador localmente antes de sincronizar con Firebase.

## 0.0.2

- Elimina la cabecera superior de `CommunityPage`.
- Añade `floatingButtonHeight` para ajustar la separación inferior del botón de publicar.

## 0.0.1

- Primera versión pública.
- Añade `CommunityPage()` con publicaciones, imágenes, likes y comentarios.
- Incluye citas, reposts, reportes y paginación Firestore.
