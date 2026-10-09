## 0.0.17

- Muestra el estado de verificación del autor desde una colección y un campo configurables, con borde de foto y color del tick personalizables.
- Permite mostrar un aviso configurable encima del muro y reserva 120 px al final de la lista para barras inferiores.

## 0.0.16

- Oculta la acción de comentar dentro del detalle para evitar abrir la misma publicación repetidamente.
- Abre los comentarios de la publicación original al pulsar comentar en un repost.

## 0.0.15

- Permite mostrar la chip del filtro de cada publicación, configurar su color y ocultar filtros concretos.
- Permite limitar las imágenes de una publicación desde la configuración y avisa al superar el máximo.
- Muestra `+N` sobre la cuarta imagen del grid cuando quedan más imágenes en la galería.

## 0.0.14

- Sube una miniatura de cada foto junto a la imagen de buena calidad y usa la miniatura en el muro.
- Abre las fotos a buena calidad en una galería con navegación por gestos.
- Conserva la visualización de publicaciones anteriores y las miniaturas en citas y reposts.

## 0.0.13

- Añade separación entre los filtros y las publicaciones del muro.
- Acerca el campo de creación al avatar y alinea lateralmente las imágenes adjuntas con el campo.

## 0.0.12

- Actualiza `pizzacorn_ui` para corregir el tipo del filtro de publicaciones bloqueadas en la paginación.
- Añade una prueba de regresión con `CommunityModel` a través del provider dinámico.

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
