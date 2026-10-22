import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityAttachmentModel {
  final String type;
  final String targetId;
  final String name;
  final String username;
  final String image;
  final String title;
  final String body;
  final String chip;

  CommunityAttachmentModel({
    this.type = '',
    this.targetId = '',
    this.name = '',
    this.username = '',
    this.image = '',
    this.title = '',
    this.body = '',
    this.chip = '',
  });

  factory CommunityAttachmentModel.fromUser({
    required CommunityUserModel targetModel,
    required bool isEntity,
  }) {
    return CommunityAttachmentModel(
      type: isEntity ? 'entity' : 'profile',
      targetId: targetModel.id,
      name: targetModel.name,
      username: targetModel.username,
      image: targetModel.image,
      title: (isEntity
          ? PizzacornCommunityConfig.entityAttachmentTitle
          : PizzacornCommunityConfig.profileAttachmentTitle)?.call(targetModel) ?? targetModel.name,
      body: (isEntity
          ? PizzacornCommunityConfig.entityAttachmentBody
          : PizzacornCommunityConfig.profileAttachmentBody)?.call(targetModel) ?? targetModel.username,
      chip: (isEntity
          ? PizzacornCommunityConfig.entityAttachmentChip
          : PizzacornCommunityConfig.profileAttachmentChip)?.call(targetModel) ??
          (isEntity ? 'Entidad' : 'Perfil'),
    );
  }

  factory CommunityAttachmentModel.fromJson(Map<String, dynamic> json) {
    return CommunityAttachmentModel(
      type: json['type'] is String ? json['type'] : '',
      targetId: json['targetId'] is String ? json['targetId'] : '',
      name: json['name'] is String ? json['name'] : '',
      username: json['username'] is String ? json['username'] : '',
      image: json['image'] is String ? json['image'] : '',
      title: json['title'] is String ? json['title'] : '',
      body: json['body'] is String ? json['body'] : '',
      chip: json['chip'] is String ? json['chip'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'targetId': targetId,
    'name': name,
    'username': username,
    'image': image,
    'title': title,
    'body': body,
    'chip': chip,
  };

  CommunityAttachmentModel copyWith({
    String? type,
    String? targetId,
    String? name,
    String? username,
    String? image,
    String? title,
    String? body,
    String? chip,
  }) => CommunityAttachmentModel(
    type: type ?? this.type,
    targetId: targetId ?? this.targetId,
    name: name ?? this.name,
    username: username ?? this.username,
    image: image ?? this.image,
    title: title ?? this.title,
    body: body ?? this.body,
    chip: chip ?? this.chip,
  );
}
