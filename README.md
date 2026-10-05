# pizzacorn_community

Muro social reutilizable de Pizzacorn para Flutter y Firebase.

## Uso

Añade la dependencia y exporta la librería desde el barrel de tu app:

```yaml
dependencies:
  pizzacorn_community: ^0.0.5
```

```dart
export 'package:pizzacorn_community/pizzacorn_community.dart';
```

Configura el usuario después del login o al restaurar la sesión:

```dart
ConfigurePizzacornCommunity(
  currentUser: CommunityUserModel(
    id: USER.id,
    name: USER.name,
    username: USER.username,
    image: USER.image,
    blockedUsers: USER.blockedUsers,
  ),
  onOpenProfile: (context, userId) async {
    // Abre aquí el perfil propio de tu aplicación.
  },
);
```

Antes de mostrar el muro, inicializa los datos de fecha de `intl` para la locale
española usada por las fechas de las publicaciones:

```dart
await initializeDateFormatting('es_ES');
```

Importa `package:intl/date_symbol_data_local.dart` y haz esta llamada una vez al
arrancar la aplicación, antes de `runApp`.

Abre el muro directamente:

```dart
CommunityPage(
  floatingButtonHeight: 150,
)
```

`floatingButtonHeight` define la separación inferior del botón para publicar.
Su valor por defecto es `0`.

La colección Firestore utilizada es `Community`. Los reportes se guardan en
`Reports`. Las imágenes se almacenan en `community_posts/{userId}` y las
respuestas con imagen en `community_comments/{userId}`.

## Configuración nativa

### Menciones

Indica `usersCollection` y `usersNicknameField` en `ConfigurePizzacornCommunity`
para activar el selector al escribir `@` en una publicación o cita. Por ejemplo,
si tu colección se llama `users` y el campo es `nickname`:

```dart
ConfigurePizzacornCommunity(
  currentUser: CommunityUserModel(id: USER.id),
  usersCollection: 'users',
  usersNicknameField: 'nickname',
  usersSearchMode: CommunityUsersSearchMode.normal,
);
```

La búsqueda usa la misma instancia y `databaseName` que la comunidad. El ID del
usuario es el ID del documento. Opcionalmente configura `usersNameField` y
`usersImageField`; si no se indican, se muestra el nickname sin foto.
Los nombres de campo admiten rutas anidadas con puntos. El nickname debe ser
un string sin `@` inicial. También se admiten emails como identificador de mención.
Las sugerencias aparecen debajo del editor y se actualizan al escribir o mover el
cursor dentro de una mención. Al seleccionar, desaparecen y el editor conserva el foco.

En modo `normal` (predeterminado), la consulta ordena por nickname y obtiene hasta 20 documentos. Con texto busca
por prefijo, distinguiendo mayúsculas y minúsculas; sin texto muestra las primeras
sugerencias. Requiere permiso de lectura e indexación del campo configurado en
Firestore. No descarga toda la colección ni crea campos auxiliares.

Para Enterprise usa `usersSearchMode: CommunityUsersSearchMode.enterprise`.
Ejecuta un Pipeline con `SearchStage` como primera etapa después de la colección,
buscando el texto en el campo de nickname configurado, con un máximo de 20 resultados.
Utiliza búsqueda de texto de Enterprise, no la búsqueda por prefijo del modo normal.
Sin texto, obtiene sugerencias con un Pipeline ordenado por nickname.
Requiere una base Enterprise y el índice de búsqueda correspondiente; no cambia
automáticamente de modo si falla. Usa `databaseName` para seleccionar tu base.
Consulta la [documentación de búsqueda Enterprise](https://firebase.google.com/docs/firestore/enterprise/text-search).
La API requiere `cloud_firestore >=6.6.0`. Las rutas de campo en este modo deben
usar letras ASCII, números y guiones bajos, separadas por puntos y sin comenzar por un número.

Se conserva `onSearchUsers` como alternativa opcional con prioridad sobre la
colección: recibe `query` como parámetro nombrado y devuelve
`Future<List<CommunityUserModel>>`. Sin ninguna fuente configurada no se abre el
selector. Se excluyen el usuario actual y sus IDs bloqueados; los bloqueos del
otro usuario solo pueden filtrarse si el callback devuelve `blockedUsers`.

Al seleccionar, se inserta `@username` en el cursor respetando el límite de 250
caracteres. Las menciones aparecen en azul tanto en el editor como en el muro y
se guardan dentro de `text`. Esta función no envía notificaciones ni persiste IDs
de destinatarios; la integración del endpoint queda pendiente.

Firebase debe estar inicializado antes de abrir `CommunityPage()`. Para permitir
la selección de imágenes en iOS, añade `NSPhotoLibraryUsageDescription` en
`ios/Runner/Info.plist`.

## Índices Firestore

Firestore solicitará crear estos índices compuestos la primera vez que se usen:

- `Community`: `hidden`, `type`, `createdAt`.
- `Community`: `hidden`, `type`, `secondaryId`, `createdAt`.
