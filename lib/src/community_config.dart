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

enum CommunityNotificationType { post, like }

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
}) {
  PizzacornCommunityConfig.currentUser = currentUser ?? CommunityUserModel();
  PizzacornCommunityConfig.databaseName =
      PizzacornPaginationConfig.sanitizeDatabaseName(databaseName);
  PizzacornCommunityConfig.paginationSize = paginationSize;
  PizzacornCommunityConfig.title = title;
  PizzacornCommunityConfig.backgroundAsset = backgroundAsset;
  PizzacornCommunityConfig.onOpenProfile = onOpenProfile;
  PizzacornCommunityConfig.onSendNotification = onSendNotification;
  PizzacornCommunityConfig.onReport = onReport;
}
