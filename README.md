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

Firebase debe estar inicializado antes de abrir `CommunityPage()`. Para permitir
la selección de imágenes en iOS, añade `NSPhotoLibraryUsageDescription` en
`ios/Runner/Info.plist`.

## Índices Firestore

Firestore solicitará crear estos índices compuestos la primera vez que se usen:

- `Community`: `hidden`, `type`, `createdAt`.
- `Community`: `hidden`, `type`, `secondaryId`, `createdAt`.
