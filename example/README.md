# Community · App de pruebas

App Android/iOS que usa `pizzacorn_community` mediante `path: ../` y el
checkout hermano `pizzacorn_ui` mediante `path: ../../pizzacorn_ui`.
Los cambios en ambas librerías se prueban aquí sin publicar en pub.dev.

El ejemplo fija `uicons_pro` a `1.1.0` mediante `dependency_overrides`: la versión
`1.2.0` renombra iconos que todavía utiliza `pizzacorn_ui`. Esta excepción
solo afecta a la app de pruebas; no cambia las dependencias publicadas del paquete.

## Configuración pendiente

El ejemplo está apuntado al proyecto Firebase `pizzacorn-community`. Al arrancar
inicia sesión automáticamente con `hola@pizzacorn.es` y la contraseña de pruebas
configurada en `TestConfiguration.TEST_PASSWORD`, y abre el muro sin formulario.
Si falla, muestra el error y permite reintentar. Las credenciales están únicamente
en la app de ejemplo.

1. Android ya está registrado como `pizzacorn.community.com`; el archivo
   `android/app/google-services.json` contiene el app ID y la API key nativos.
2. El ejemplo ya incluye esos valores en sus ajustes locales ignorados por Git y
   también tiene valores predeterminados, así que no necesita un archivo dart-define
   para Android.
3. Para iOS, registra `es.pizzacorn.communityExample`, descarga su configuración
   nativa y completa `config/firebase.ios.json` con su app ID y bundle ID.
4. Deja `FIRESTORE_DATABASE` vacío para `(default)` o escribe el nombre exacto de la base.
5. Habilita Email/Password en Authentication; la cuenta de pruebas debe existir.
   La app no registra cuentas ni crea documentos de usuario.

Android usa el app ID y la API key de `google-services.json`. El ID de base de datos
Firestore no aparece en ese archivo; si el proyecto usa una base nombrada en vez de
`(default)`, establece `FIRESTORE_DATABASE` con su ID exacto.

Firebase se inicializa con opciones explícitas. El acceso implementado es únicamente
correo/contraseña; no requiere configurar Google Sign-In ni sus URL schemes.
Si tu proyecto usa otro método de acceso, adapta el controlador antes de probarlo.
No añadas contraseñas, cuentas de servicio ni claves privadas al JSON.

El perfil del muro usa el UID real de Authentication y su nombre/foto si existen;
no lee colecciones de perfiles externas. El botón de perfil muestra el UID en un diálogo.
No se envían notificaciones push: no se configura `onSendNotification`.

## Ejecutar en Android

Conecta el móvil por USB, activa depuración USB y autoriza el ordenador.
Desde esta carpeta:

```powershell
flutter pub get
flutter devices
flutter run -d ID_DEL_MOVIL
```

Pulsa `r` para hot reload y `R` para hot restart. Si cambias el JSON o código nativo,
detén y vuelve a ejecutar la app. También se puede ejecutar `flutter run`
para comprobar la pantalla inicial.

En iOS necesitas macOS, Xcode y firma con tu equipo de desarrollo. Usa el JSON de iOS
con el mismo comando. Ya está incluida la descripción de acceso a la fototeca.

## Datos, permisos e índices

La app utiliza las rutas reales del paquete:

- Firestore: `Community`, subcolecciones `Likes` y `Reposts`, y `Reports`.
- Storage: `community_posts/{userId}` y `community_comments/{userId}`.

Comprueba las reglas de la base y del bucket elegidos con las cuentas de prueba.
No se despliegan reglas ni índices ni se habilita acceso público automáticamente.
Consulta el README del paquete para los índices documentados y crea los índices
exactos que Firestore solicite según las consultas ejecutadas. Un inicio de sesión
correcto no garantiza permisos de lectura/escritura.

Las reglas preparadas para el proyecto están en `../firestore.rules`. Desde la raíz
del repositorio, se pueden publicar con:

```powershell
firebase deploy --only firestore:rules --project pizzacorn-community
```

Ese comando sustituye las reglas activas de Firestore por el archivo local; revísalo
antes de ejecutarlo si el proyecto ya contiene permisos para otras aplicaciones.

## Recorrido manual

### Probar menciones

Los archivos `config/firebase.*.json` incluyen las opciones de menciones.
La prueba actual usa `Users`, campo `email`, modo `normal` y base `(default)`.
Las sugerencias aparecen debajo del editor mientras escribes, sin abrir un modal.
Completa `COMMUNITY_USERS_COLLECTION` y `COMMUNITY_USERS_NICKNAME_FIELD` con los
nombres reales. Opcionalmente configura `COMMUNITY_USERS_NAME_FIELD` y
`COMMUNITY_USERS_IMAGE_FIELD`. El ID del documento debe identificar al usuario.
Sin colección y nickname configurados, el selector permanece desactivado.

Usa `COMMUNITY_USERS_SEARCH_MODE: "normal"` para búsqueda por prefijo o
`"enterprise"` para SearchStage. En Enterprise, `FIRESTORE_DATABASE` debe apuntar
a tu base Enterprise (vacío solo si es la predeterminada) y debe existir el índice
de búsqueda. Esta base también se usa para las publicaciones de la app.

Desde `example`, inicia la app cargando la configuración:

```powershell
flutter run --dart-define-from-file=config/firebase.android.json
```

Entra con una cuenta, crea una publicación y escribe `@`. Busca otra cuenta,
selecciónala y comprueba el autocompletado azul. Publica y comprueba que se conserva
en el muro. Reinicia la ejecución para cambiar el modo o el JSON.

Authentication no crea perfiles Firestore: la colección debe contener documentos
de otros usuarios con nickname válido. Las reglas locales actuales no incluyen
lectura de `Users`; añade los permisos apropiados a la colección
real antes de probar. No se han creado perfiles, índices ni desplegado reglas.

- Publicar texto e imágenes; comprobar selección, permisos y subida.
- Abrir el detalle, comentar con texto e imagen y comprobar teclado y scroll.
- Dar/quitar likes, hacer repost y citar desde dos cuentas.
- Refrescar, cargar más publicaciones y comprobar el estado vacío.
- Reportar y eliminar contenido según los permisos reales.
- Probar sin conexión, recuperar conexión y comprobar errores.
- Cerrar sesión y entrar con otra cuenta; verificar autoría y contadores.

Las acciones escriben datos reales en el proyecto configurado. La app no los borra
automáticamente al salir.

## Verificaciones automatizadas

```powershell
flutter test --no-pub
```

Los tests comprueban el arranque sin configuración y el bloqueo de acceso sin Firebase.
No sustituyen las pruebas del muro en móvil con Firebase real.
