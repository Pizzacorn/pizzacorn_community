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
  static String title = 'Comunidad';
  static String? backgroundAsset;
  static CommunityProfileCallback? onOpenProfile;
  static CommunityNotificationCallback? onSendNotification;
  static CommunityReportCallback? onReport;
  static CommunitySearchUsersCallback? onSearchUsers;
  static String? usersCollection;
  static String? usersNicknameField;
  static String? usersNameField;
  static String? usersImageField;
  static CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal;

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
  String title = 'Comunidad',
  String? backgroundAsset,
  CommunityProfileCallback? onOpenProfile,
  CommunityNotificationCallback? onSendNotification,
  CommunityReportCallback? onReport,
  CommunitySearchUsersCallback? onSearchUsers,
  String? usersCollection,
  String? usersNicknameField,
  String? usersNameField,
  String? usersImageField,
  CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal,
}) {
  if ((usersCollection != null || usersNicknameField != null) &&
      (usersCollection == null || usersCollection.trim().isEmpty ||
       usersNicknameField == null || usersNicknameField.trim().isEmpty)) {
    throw ArgumentError('Indica usersCollection y usersNicknameField juntos.');
  }
  PizzacornCommunityConfig.currentUser = currentUser ?? CommunityUserModel();
  PizzacornCommunityConfig.databaseName =
      PizzacornPaginationConfig.sanitizeDatabaseName(databaseName);
  PizzacornCommunityConfig.paginationSize = paginationSize;
  PizzacornCommunityConfig.title = title;
  PizzacornCommunityConfig.backgroundAsset = backgroundAsset;
  PizzacornCommunityConfig.onOpenProfile = onOpenProfile;
  PizzacornCommunityConfig.onSendNotification = onSendNotification;
  PizzacornCommunityConfig.onReport = onReport;
  PizzacornCommunityConfig.onSearchUsers = onSearchUsers;
  PizzacornCommunityConfig.usersCollection = usersCollection;
  PizzacornCommunityConfig.usersNicknameField = usersNicknameField;
  PizzacornCommunityConfig.usersNameField = usersNameField;
  PizzacornCommunityConfig.usersImageField = usersImageField;
  PizzacornCommunityConfig.usersSearchMode = usersSearchMode;
}
