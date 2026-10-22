import 'package:pizzacorn_community/pizzacorn_community.dart';

typedef CommunityProfileCallback =
    FutureOr<void> Function(BuildContext context, String userId);
typedef CommunityMentionedCallback =
    FutureOr<void> Function(String mentionedId, String postId);
typedef CommunityNotificationCallback =
    FutureOr<void> Function(
      CommunityNotificationType notificationType,
      CommunityModel communityModel,
    );
typedef CommunityReportCallback =
    FutureOr<void> Function(CommunityModel communityModel, String reason);

typedef CommunitySearchUsersCallback =
    Future<List<CommunityUserModel>> Function({required String query});
typedef CommunityAttachmentTextCallback =
    String Function(CommunityUserModel targetModel);
typedef CommunityAttachmentPressedCallback =
    FutureOr<void> Function(BuildContext context, CommunityAttachmentModel attachmentModel);

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
  static List<String> blockedUserIds = const [];
  static String? databaseName;
  static int paginationSize = 20;
  static int? maxPostImages;
  static bool showSearch = false;
  static bool showDisclaimer = false;
  static String disclaimerText = '';
  static TextStyle? disclaimerTextStyle;
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
  static bool showFilterChips = false;
  static Map<String, Color> filterChipColors = const {};
  static List<String> hiddenFilterChips = const [];
  static CommunityProfileCallback? onOpenProfile;
  static CommunityProfileCallback? onTapUser;
  static CommunityProfileCallback? onTapUserMention;
  static CommunityProfileCallback? onTapEntityMention;
  static CommunityProfileCallback? onUserMentionPressed;
  static CommunityProfileCallback? onEntitieMentionPressed;
  static CommunityMentionedCallback? onUserMentioned;
  static CommunityMentionedCallback? onEntitieMentioned;
  static CommunityNotificationCallback? onSendNotification;
  static CommunityReportCallback? onReport;
  static CommunityReportCallback? onReportTweet;
  static CommunitySearchUsersCallback? onSearchUsers;
  static String? usersCollection;
  static String? usersNicknameField;
  static String? usersNameField;
  static String? usersImageField;
  static String? usersVerifyField;
  static Color? verifiedBorderColor;
  static double verifiedBorderWidth = 2;
  static Color? verifiedTickBackgroundColor;
  static CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal;
  static String? entitiesCollection;
  static String? entitiesNicknameField;
  static String? entitiesNameField;
  static String? entitiesImageField;
  static String? entitiesVerifyField;
  static CommunitySearchUsersCallback? onSearchEntities;
  static CommunityUsersSearchMode entitiesSearchMode = CommunityUsersSearchMode.normal;
  static bool showProfileAttachment = true;
  static bool showEntityAttachment = true;
  static String addProfileAttachmentText = 'Añadir perfil';
  static String addEntityAttachmentText = 'Añadir entidad';
  static String viewProfileAttachmentText = 'Ver perfil';
  static String viewEntityAttachmentText = 'Ver entidad';
  static CommunityAttachmentTextCallback? profileAttachmentTitle;
  static CommunityAttachmentTextCallback? profileAttachmentBody;
  static CommunityAttachmentTextCallback? profileAttachmentChip;
  static CommunityAttachmentTextCallback? entityAttachmentTitle;
  static CommunityAttachmentTextCallback? entityAttachmentBody;
  static CommunityAttachmentTextCallback? entityAttachmentChip;
  static CommunityAttachmentPressedCallback? onProfileAttachmentPressed;
  static CommunityAttachmentPressedCallback? onEntityAttachmentPressed;
  static Color? profileAttachmentButtonColor;
  static Color? profileAttachmentButtonTextColor;
  static Color? profileAttachmentButtonBorderColor;
  static double profileAttachmentButtonBorderWidth = 1;
  static Color? entityAttachmentButtonColor;
  static Color? entityAttachmentButtonTextColor;
  static Color? entityAttachmentButtonBorderColor;
  static double entityAttachmentButtonBorderWidth = 1;
  static Color usersMentionColor = Colors.blue;
  static Color entitiesMentionColor = Colors.blue;

  static bool get canSearchEntities => onSearchEntities != null ||
      (entitiesCollection != null && entitiesNicknameField != null);

  static bool get canSearchUsers => onSearchUsers != null ||
      (usersCollection != null && usersNicknameField != null);

  static bool isUserBlocked(String userId) => userId.isNotEmpty &&
      (blockedUserIds.contains(userId) || currentUser.blockedUsers.contains(userId));

  static bool isPostBlocked(CommunityModel communityModel) =>
      isUserBlocked(communityModel.userId) ||
      ((communityModel.type == CommunityType.repost ||
          communityModel.type == CommunityType.quote) &&
          (isUserBlocked(communityModel.secondaryUserId) ||
              isUserBlocked(communityModel.thirdUserId)));

  static FirebaseFirestore get database {
    return PizzacornPaginationConfig.getFirestore(databaseName: databaseName);
  }
}

void ConfigurePizzacornCommunity({
  CommunityUserModel? currentUser,
  List<String> blockedUserIds = const [],
  String? databaseName,
  int paginationSize = 20,
  int? maxPostImages,
  bool showSearch = false,
  bool showDisclaimer = false,
  String disclaimerText = '',
  TextStyle? disclaimerTextStyle,
  String title = 'Comunidad',
  String? backgroundAsset,
  Color? backgroundColor,
  Color? backgroundSecondaryColor,
  List<String> filters = const [],
  Color? filterColor,
  Color? filterTextColor,
  bool showFilterChips = false,
  Map<String, Color> filterChipColors = const {},
  List<String> hiddenFilterChips = const [],
  CommunityProfileCallback? onOpenProfile,
  CommunityProfileCallback? onTapUser,
  CommunityProfileCallback? onTapUserMention,
  CommunityProfileCallback? onTapEntityMention,
  CommunityProfileCallback? onUserMentionPressed,
  CommunityProfileCallback? onEntitieMentionPressed,
  CommunityMentionedCallback? onUserMentioned,
  CommunityMentionedCallback? onEntitieMentioned,
  CommunityNotificationCallback? onSendNotification,
  CommunityReportCallback? onReport,
  CommunityReportCallback? onReportTweet,
  CommunitySearchUsersCallback? onSearchUsers,
  String? usersCollection,
  String? usersNicknameField,
  String? usersNameField,
  String? usersImageField,
  String? usersVerifyField,
  Color? verifiedBorderColor,
  double verifiedBorderWidth = 2,
  Color? verifiedTickBackgroundColor,
  CommunityUsersSearchMode usersSearchMode = CommunityUsersSearchMode.normal,
  String? entitiesCollection,
  String? entitiesNicknameField,
  String? entitiesNameField,
  String? entitiesImageField,
  String? entitiesVerifyField,
  CommunitySearchUsersCallback? onSearchEntities,
  CommunityUsersSearchMode entitiesSearchMode = CommunityUsersSearchMode.normal,
  bool showProfileAttachment = true,
  bool showEntityAttachment = true,
  String addProfileAttachmentText = 'Añadir perfil',
  String addEntityAttachmentText = 'Añadir entidad',
  String viewProfileAttachmentText = 'Ver perfil',
  String viewEntityAttachmentText = 'Ver entidad',
  CommunityAttachmentTextCallback? profileAttachmentTitle,
  CommunityAttachmentTextCallback? profileAttachmentBody,
  CommunityAttachmentTextCallback? profileAttachmentChip,
  CommunityAttachmentTextCallback? entityAttachmentTitle,
  CommunityAttachmentTextCallback? entityAttachmentBody,
  CommunityAttachmentTextCallback? entityAttachmentChip,
  CommunityAttachmentPressedCallback? onProfileAttachmentPressed,
  CommunityAttachmentPressedCallback? onEntityAttachmentPressed,
  Color? profileAttachmentButtonColor,
  Color? profileAttachmentButtonTextColor,
  Color? profileAttachmentButtonBorderColor,
  double profileAttachmentButtonBorderWidth = 1,
  Color? entityAttachmentButtonColor,
  Color? entityAttachmentButtonTextColor,
  Color? entityAttachmentButtonBorderColor,
  double entityAttachmentButtonBorderWidth = 1,
  Color usersMentionColor = Colors.blue,
  Color entitiesMentionColor = Colors.blue,
}) {
  if (maxPostImages != null && maxPostImages < 1) {
    throw ArgumentError.value(maxPostImages, 'maxPostImages', 'Debe ser mayor que cero.');
  }
  if (verifiedBorderWidth < 0) {
    throw ArgumentError.value(verifiedBorderWidth, 'verifiedBorderWidth',
        'No puede ser negativo.');
  }
  if (profileAttachmentButtonBorderWidth < 0 || entityAttachmentButtonBorderWidth < 0) {
    throw ArgumentError('El grosor del borde del botón no puede ser negativo.');
  }
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
  PizzacornCommunityConfig.blockedUserIds = List.unmodifiable(blockedUserIds);
  PizzacornCommunityConfig.databaseName =
      PizzacornPaginationConfig.sanitizeDatabaseName(databaseName);
  PizzacornCommunityConfig.paginationSize = paginationSize;
  PizzacornCommunityConfig.maxPostImages = maxPostImages;
  PizzacornCommunityConfig.showSearch = showSearch;
  PizzacornCommunityConfig.showDisclaimer = showDisclaimer;
  PizzacornCommunityConfig.disclaimerText = disclaimerText;
  PizzacornCommunityConfig.disclaimerTextStyle = disclaimerTextStyle;
  PizzacornCommunityConfig.title = title;
  PizzacornCommunityConfig.backgroundAsset = backgroundAsset;
  PizzacornCommunityConfig.customBackgroundColor = backgroundColor;
  PizzacornCommunityConfig.customBackgroundSecondaryColor =
      backgroundSecondaryColor;
  PizzacornCommunityConfig.filters = List.unmodifiable(filters);
  PizzacornCommunityConfig.filterColor = filterColor;
  PizzacornCommunityConfig.filterTextColor = filterTextColor;
  PizzacornCommunityConfig.showFilterChips = showFilterChips;
  PizzacornCommunityConfig.filterChipColors = Map.unmodifiable(filterChipColors);
  PizzacornCommunityConfig.hiddenFilterChips = List.unmodifiable(hiddenFilterChips);
  PizzacornCommunityConfig.onOpenProfile = onOpenProfile;
  PizzacornCommunityConfig.onTapUser = onTapUser;
  PizzacornCommunityConfig.onTapUserMention = onTapUserMention;
  PizzacornCommunityConfig.onTapEntityMention = onTapEntityMention;
  PizzacornCommunityConfig.onUserMentionPressed = onUserMentionPressed;
  PizzacornCommunityConfig.onEntitieMentionPressed = onEntitieMentionPressed;
  PizzacornCommunityConfig.onUserMentioned = onUserMentioned;
  PizzacornCommunityConfig.onEntitieMentioned = onEntitieMentioned;
  PizzacornCommunityConfig.onSendNotification = onSendNotification;
  PizzacornCommunityConfig.onReport = onReport;
  PizzacornCommunityConfig.onReportTweet = onReportTweet;
  PizzacornCommunityConfig.onSearchUsers = onSearchUsers;
  PizzacornCommunityConfig.usersCollection = usersCollection;
  PizzacornCommunityConfig.usersNicknameField = usersNicknameField;
  PizzacornCommunityConfig.usersNameField = usersNameField;
  PizzacornCommunityConfig.usersImageField = usersImageField;
  PizzacornCommunityConfig.usersVerifyField = usersVerifyField;
  PizzacornCommunityConfig.verifiedBorderColor = verifiedBorderColor;
  PizzacornCommunityConfig.verifiedBorderWidth = verifiedBorderWidth;
  PizzacornCommunityConfig.verifiedTickBackgroundColor = verifiedTickBackgroundColor;
  PizzacornCommunityConfig.usersSearchMode = usersSearchMode;
  PizzacornCommunityConfig.entitiesCollection = entitiesCollection;
  PizzacornCommunityConfig.entitiesNicknameField = entitiesNicknameField;
  PizzacornCommunityConfig.entitiesNameField = entitiesNameField;
  PizzacornCommunityConfig.entitiesImageField = entitiesImageField;
  PizzacornCommunityConfig.entitiesVerifyField = entitiesVerifyField;
  PizzacornCommunityConfig.onSearchEntities = onSearchEntities;
  PizzacornCommunityConfig.entitiesSearchMode = entitiesSearchMode;
  PizzacornCommunityConfig.showProfileAttachment = showProfileAttachment;
  PizzacornCommunityConfig.showEntityAttachment = showEntityAttachment;
  PizzacornCommunityConfig.addProfileAttachmentText = addProfileAttachmentText;
  PizzacornCommunityConfig.addEntityAttachmentText = addEntityAttachmentText;
  PizzacornCommunityConfig.viewProfileAttachmentText = viewProfileAttachmentText;
  PizzacornCommunityConfig.viewEntityAttachmentText = viewEntityAttachmentText;
  PizzacornCommunityConfig.profileAttachmentTitle = profileAttachmentTitle;
  PizzacornCommunityConfig.profileAttachmentBody = profileAttachmentBody;
  PizzacornCommunityConfig.profileAttachmentChip = profileAttachmentChip;
  PizzacornCommunityConfig.entityAttachmentTitle = entityAttachmentTitle;
  PizzacornCommunityConfig.entityAttachmentBody = entityAttachmentBody;
  PizzacornCommunityConfig.entityAttachmentChip = entityAttachmentChip;
  PizzacornCommunityConfig.onProfileAttachmentPressed = onProfileAttachmentPressed;
  PizzacornCommunityConfig.onEntityAttachmentPressed = onEntityAttachmentPressed;
  PizzacornCommunityConfig.profileAttachmentButtonColor = profileAttachmentButtonColor;
  PizzacornCommunityConfig.profileAttachmentButtonTextColor = profileAttachmentButtonTextColor;
  PizzacornCommunityConfig.profileAttachmentButtonBorderColor = profileAttachmentButtonBorderColor;
  PizzacornCommunityConfig.profileAttachmentButtonBorderWidth = profileAttachmentButtonBorderWidth;
  PizzacornCommunityConfig.entityAttachmentButtonColor = entityAttachmentButtonColor;
  PizzacornCommunityConfig.entityAttachmentButtonTextColor = entityAttachmentButtonTextColor;
  PizzacornCommunityConfig.entityAttachmentButtonBorderColor = entityAttachmentButtonBorderColor;
  PizzacornCommunityConfig.entityAttachmentButtonBorderWidth = entityAttachmentButtonBorderWidth;
  PizzacornCommunityConfig.usersMentionColor = usersMentionColor;
  PizzacornCommunityConfig.entitiesMentionColor = entitiesMentionColor;
}
