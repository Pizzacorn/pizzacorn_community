import 'package:pizzacorn_community/pizzacorn_community.dart';

enum CommunityType { post, repost, quote, comment }

class CommunityModel {
  final String id;
  final String userId;
  final String userName;
  final String userUsername;
  final String userImage;
  final String text;
  final List<String> media;
  final int likesCount;
  final int commentsCount;
  final int repostCount;
  final CommunityType type;
  final String secondaryId;
  final String secondaryUserId;
  final String secondaryUserName;
  final String secondaryUserUsername;
  final String secondaryUserImage;
  final String secondaryText;
  final List<String> secondaryMedia;
  final String secondaryReplyTo;
  final String secondaryReplyToId;
  final String secondaryType;
  final String thirdId;
  final String thirdUserId;
  final String thirdUserName;
  final String thirdUserUsername;
  final String thirdUserImage;
  final String thirdText;
  final List<String> thirdMedia;
  final bool hidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityModel({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.userUsername = '',
    this.userImage = '',
    this.text = '',
    this.media = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostCount = 0,
    this.type = CommunityType.post,
    this.secondaryId = '',
    this.secondaryUserId = '',
    this.secondaryUserName = '',
    this.secondaryUserUsername = '',
    this.secondaryUserImage = '',
    this.secondaryText = '',
    this.secondaryMedia = const [],
    this.secondaryReplyTo = '',
    this.secondaryReplyToId = '',
    this.secondaryType = '',
    this.thirdId = '',
    this.thirdUserId = '',
    this.thirdUserName = '',
    this.thirdUserUsername = '',
    this.thirdUserImage = '',
    this.thirdText = '',
    this.thirdMedia = const [],
    this.hidden = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime(2000),
       updatedAt = updatedAt ?? DateTime(2000);

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userUsername: json['userUsername'] ?? '',
      userImage: json['userImage'] ?? '',
      text: json['text'] ?? '',
      media: json['media'] != null ? List<String>.from(json['media']) : [],
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      type: CommunityType.values.firstWhere(
        (communityType) => communityType.name == json['type'],
        orElse: () => CommunityType.post,
      ),
      secondaryId: json['secondaryId'] ?? '',
      secondaryUserId: json['secondaryUserId'] ?? '',
      secondaryUserName: json['secondaryUserName'] ?? '',
      secondaryUserUsername: json['secondaryUserUsername'] ?? '',
      secondaryUserImage: json['secondaryUserImage'] ?? '',
      secondaryText: json['secondaryText'] ?? '',
      secondaryMedia: json['secondaryMedia'] != null
          ? List<String>.from(json['secondaryMedia'])
          : [],
      secondaryReplyTo: json['secondaryReplyTo'] ?? '',
      secondaryReplyToId: json['secondaryReplyToId'] ?? '',
      secondaryType: json['secondaryType'] ?? '',
      thirdId: json['thirdId'] ?? '',
      thirdUserId: json['thirdUserId'] ?? '',
      thirdUserName: json['thirdUserName'] ?? '',
      thirdUserUsername: json['thirdUserUsername'] ?? '',
      thirdUserImage: json['thirdUserImage'] ?? '',
      thirdText: json['thirdText'] ?? '',
      thirdMedia: json['thirdMedia'] != null
          ? List<String>.from(json['thirdMedia'])
          : [],
      hidden: json['hidden'] ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userUsername': userUsername,
      'userImage': userImage,
      'text': text,
      'media': media,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostCount': repostCount,
      'type': type.name,
      'secondaryId': secondaryId,
      'secondaryUserId': secondaryUserId,
      'secondaryUserName': secondaryUserName,
      'secondaryUserUsername': secondaryUserUsername,
      'secondaryUserImage': secondaryUserImage,
      'secondaryText': secondaryText,
      'secondaryMedia': secondaryMedia,
      'secondaryReplyTo': secondaryReplyTo,
      'secondaryReplyToId': secondaryReplyToId,
      'secondaryType': secondaryType,
      'thirdId': thirdId,
      'thirdUserId': thirdUserId,
      'thirdUserName': thirdUserName,
      'thirdUserUsername': thirdUserUsername,
      'thirdUserImage': thirdUserImage,
      'thirdText': thirdText,
      'thirdMedia': thirdMedia,
      'hidden': hidden,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJsonCreate() {
    final Map<String, dynamic> data = toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return data;
  }

  Map<String, dynamic> toJsonUpdate() {
    final Map<String, dynamic> data = toJson();
    data.remove('id');
    data.remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();
    return data;
  }

  CommunityModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userUsername,
    String? userImage,
    String? text,
    List<String>? media,
    int? likesCount,
    int? commentsCount,
    int? repostCount,
    CommunityType? type,
    String? secondaryId,
    String? secondaryUserId,
    String? secondaryUserName,
    String? secondaryUserUsername,
    String? secondaryUserImage,
    String? secondaryText,
    List<String>? secondaryMedia,
    String? secondaryReplyTo,
    String? secondaryReplyToId,
    String? secondaryType,
    String? thirdId,
    String? thirdUserId,
    String? thirdUserName,
    String? thirdUserUsername,
    String? thirdUserImage,
    String? thirdText,
    List<String>? thirdMedia,
    bool? hidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userUsername: userUsername ?? this.userUsername,
      userImage: userImage ?? this.userImage,
      text: text ?? this.text,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostCount: repostCount ?? this.repostCount,
      type: type ?? this.type,
      secondaryId: secondaryId ?? this.secondaryId,
      secondaryUserId: secondaryUserId ?? this.secondaryUserId,
      secondaryUserName: secondaryUserName ?? this.secondaryUserName,
      secondaryUserUsername:
          secondaryUserUsername ?? this.secondaryUserUsername,
      secondaryUserImage: secondaryUserImage ?? this.secondaryUserImage,
      secondaryText: secondaryText ?? this.secondaryText,
      secondaryMedia: secondaryMedia ?? this.secondaryMedia,
      secondaryReplyTo: secondaryReplyTo ?? this.secondaryReplyTo,
      secondaryReplyToId: secondaryReplyToId ?? this.secondaryReplyToId,
      secondaryType: secondaryType ?? this.secondaryType,
      thirdId: thirdId ?? this.thirdId,
      thirdUserId: thirdUserId ?? this.thirdUserId,
      thirdUserName: thirdUserName ?? this.thirdUserName,
      thirdUserUsername: thirdUserUsername ?? this.thirdUserUsername,
      thirdUserImage: thirdUserImage ?? this.thirdUserImage,
      thirdText: thirdText ?? this.thirdText,
      thirdMedia: thirdMedia ?? this.thirdMedia,
      hidden: hidden ?? this.hidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
