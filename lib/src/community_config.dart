import 'package:pizzacorn_community/pizzacorn_community.dart';

typedef CommunityProfileCallback =
    FutureOr<void> Function(BuildContext context, String userId);
typedef CommunityNotificationCallback =
    FutureOr<void> Function(
      CommunityNotificationType notificationType,
      CommunityModel communityModel,
    );
typedef CommunityReportCallback =
    FutureOr<void> Function(CommunityModel communityModel, String reason);

typedef CommunitySearchUsersCallback =
    Future<List<CommunityUserModel>> Function({required String query});

enum CommunityNotificationType { post, like }

enum CommunityUsersSearchMode { normal, enterprise }

class CommunityUserModel {
  final String id;
  final String name;
  final String username;
  final String image;
  final List<String> blockedUsers;

  CommunityUserModel({
    this.id = '',
    this.name = '',
    this.username = '',
    this.image = '',
    this.blockedUsers = const [],
  });
}

class PizzacornCommunityConfig {
  static CommunityUserModel currentUser = CommunityUserModel();
  static String? databaseName;
  static int paginationSize = 20;
  static bool showSearch = false;
  static String title = 'Comunidad';
  static String? backgroundAsset;
  static Color? customBackgroundColor;
  static Color? customBackgroundSecondaryColor;
  static Color get backgroundColor => customBackgroundColor ?? COLOR_BACKGROUND;
  static Color get backgroundSecondaryColor =>
      customBackgroundSecondaryColor ?? COLOR_BACKGROUND_SECONDARY;
  static List<String> filters = const [];
  static Color? filterColor;
  static Color? filterTextColor;
  static CommunityProfileCallback? onOpenProfile;
  static CommunityProfileCallback? onTapUser;
  static CommunityProfileCallback? onTapUserMention;
  static CommunityProfileCallback? onTapEntityMention;
  static CommunityNotificationCallback? onSendNotification;
  static CommunityReportCallback? onReport;
  static CommunitySearchUsersCallback? onSearchUsers;
  static String? usersCollection;
  static String? usersNicknameField;
  static String? usersNameField;
  static String? usersImageField;
  static CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal;
  static String? entitiesCollection;
  static String? entitiesNicknameField;
  static String? entitiesNameField;
  static String? entitiesImageField;
  static CommunitySearchUsersCallback? onSearchEntities;
  static CommunityUsersSearchMode entitiesSearchMode = CommunityUsersSearchMode.normal;
  static Color usersMentionColor = Colors.blue;
  static Color entitiesMentionColor = Colors.blue;

  static bool get canSearchEntities => onSearchEntities != null ||
      (entitiesCollection != null && entitiesNicknameField != null);

  static bool get canSearchUsers => onSearchUsers != null ||
      (usersCollection != null && usersNicknameField != null);

  static FirebaseFirestore get database {
    return PizzacornPaginationConfig.getFirestore(databaseName: databaseName);
  }
}

void ConfigurePizzacornCommunity({
  CommunityUserModel? currentUser,
  String? databaseName,
  int paginationSize = 20,
  bool showSearch = false,
  String title = 'Comunidad',
  String? backgroundAsset,
  Color? backgroundColor,
  Color? backgroundSecondaryColor,
  List<String> filters = const [],
  Color? filterColor,
  Color? filterTextColor,
  CommunityProfileCallback? onOpenProfile,
  CommunityProfileCallback? onTapUser,
  CommunityProfileCallback? onTapUserMention,
  CommunityProfileCallback? onTapEntityMention,
  CommunityNotificationCallback? onSendNotification,
  CommunityReportCallback? onReport,
  CommunitySearchUsersCallback? onSearchUsers,
  String? usersCollection,
  String? usersNicknameField,
  String? usersNameField,
  String? usersImageField,
  CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal,
  String? entitiesCollection,
  String? entitiesNicknameField,
  String? entitiesNameField,
  String? entitiesImageField,
  CommunitySearchUsersCallback? onSearchEntities,
  CommunityUsersSearchMode entitiesSearchMode = CommunityUsersSearchMode.normal,
  Color usersMentionColor = Colors.blue,
  Color entitiesMentionColor = Colors.blue,
}) {
  if ((entitiesCollection != null || entitiesNicknameField != null) &&
      (entitiesCollection == null || entitiesCollection.trim().isEmpty ||
       entitiesNicknameField == null || entitiesNicknameField.trim().isEmpty)) {
    throw ArgumentError('Indica entitiesCollection y entitiesNicknameField juntos.');
  }
  if ((usersCollection != null || usersNicknameField != null) &&
      (usersCollection == null || usersCollection.trim().isEmpty ||
       usersNicknameField == null || usersNicknameField.trim().isEmpty)) {
    throw ArgumentError('Indica usersCollection y usersNicknameField juntos.');
  }
  PizzacornCommunityConfig.currentUser = currentUser ?? CommunityUserModel();
  PizzacornCommunityConfig.databaseName =
      PizzacornPaginationConfig.sanitizeDatabaseName(databaseName);
  PizzacornCommunityConfig.paginationSize = paginationSize;
  PizzacornCommunityConfig.showSearch = showSearch;
  PizzacornCommunityConfig.title = title;
  PizzacornCommunityConfig.backgroundAsset = backgroundAsset;
  PizzacornCommunityConfig.customBackgroundColor = backgroundColor;
  PizzacornCommunityConfig.customBackgroundSecondaryColor =
      backgroundSecondaryColor;
  PizzacornCommunityConfig.filters = List.unmodifiable(filters);
  PizzacornCommunityConfig.filterColor = filterColor;
  PizzacornCommunityConfig.filterTextColor = filterTextColor;
  PizzacornCommunityConfig.onOpenProfile = onOpenProfile;
  PizzacornCommunityConfig.onTapUser = onTapUser;
  PizzacornCommunityConfig.onTapUserMention = onTapUserMention;
  PizzacornCommunityConfig.onTapEntityMention = onTapEntityMention;
  PizzacornCommunityConfig.onSendNotification = onSendNotification;
  PizzacornCommunityConfig.onReport = onReport;
  PizzacornCommunityConfig.onSearchUsers = onSearchUsers;
  PizzacornCommunityConfig.usersCollection = usersCollection;
  PizzacornCommunityConfig.usersNicknameField = usersNicknameField;
  PizzacornCommunityConfig.usersNameField = usersNameField;
  PizzacornCommunityConfig.usersImageField = usersImageField;
  PizzacornCommunityConfig.usersSearchMode = usersSearchMode;
  PizzacornCommunityConfig.entitiesCollection = entitiesCollection;
  PizzacornCommunityConfig.entitiesNicknameField = entitiesNicknameField;
  PizzacornCommunityConfig.entitiesNameField = entitiesNameField;
  PizzacornCommunityConfig.entitiesImageField = entitiesImageField;
  PizzacornCommunityConfig.onSearchEntities = onSearchEntities;
  PizzacornCommunityConfig.entitiesSearchMode = entitiesSearchMode;
  PizzacornCommunityConfig.usersMentionColor = usersMentionColor;
  PizzacornCommunityConfig.entitiesMentionColor = entitiesMentionColor;
}
