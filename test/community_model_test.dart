import 'package:flutter_test/flutter_test.dart';
import 'package:pizzacorn_community/pizzacorn_community.dart';

void main() {
  test('CommunityPage permite ajustar la altura del botón de publicar', () {
    final CommunityPage communityPage = CommunityPage(
      floatingButtonHeight: 150,
    );

    expect(communityPage.floatingButtonHeight, 150);
  });

  test('CommunityModel conserva valores y fechas', () {
    final DateTime createdAt = DateTime(2026, 6, 2);
    final CommunityModel communityModel = CommunityModel.fromJson({
      'id': 'post-1',
      'userId': 'user-1',
      'text': 'Hola comunidad',
      'type': 'quote',
      'createdAt': createdAt,
    });

    expect(communityModel.id, 'post-1');
    expect(communityModel.type, CommunityType.quote);
    expect(communityModel.createdAt, createdAt);
    expect(communityModel.toJsonUpdate().containsKey('id'), isFalse);
    expect(communityModel.toJsonUpdate().containsKey('createdAt'), isFalse);
  });

  test('CommunityModel usa valores seguros por defecto', () {
    final CommunityModel communityModel = CommunityModel.fromJson({});

    expect(communityModel.id, '');
    expect(communityModel.media, isEmpty);
    expect(communityModel.createdAt, DateTime(2000));
  });

  test('IDs bloqueados configurados se suman a los del usuario', () {
    ConfigurePizzacornCommunity(
      currentUser: CommunityUserModel(blockedUsers: ['bloqueado-en-modelo']),
      blockedUserIds: ['bloqueado-en-configuracion'],
    );

    expect(PizzacornCommunityConfig.isUserBlocked('bloqueado-en-modelo'), isTrue);
    expect(PizzacornCommunityConfig.isUserBlocked('bloqueado-en-configuracion'), isTrue);
    expect(PizzacornCommunityConfig.isUserBlocked('visible'), isFalse);

    ConfigurePizzacornCommunity();
    expect(PizzacornCommunityConfig.isUserBlocked('bloqueado-en-configuracion'), isFalse);
  });

  test('Oculta publicaciones propias, compartidas y citadas de bloqueados', () {
    ConfigurePizzacornCommunity(blockedUserIds: ['bloqueado']);

    expect(PizzacornCommunityConfig.isPostBlocked(
      CommunityModel(userId: 'bloqueado'),
    ), isTrue);
    expect(PizzacornCommunityConfig.isPostBlocked(
      CommunityModel(
        userId: 'visible',
        type: CommunityType.repost,
        secondaryUserId: 'bloqueado',
      ),
    ), isTrue);
    expect(PizzacornCommunityConfig.isPostBlocked(
      CommunityModel(
        userId: 'visible',
        type: CommunityType.quote,
        thirdUserId: 'bloqueado',
      ),
    ), isTrue);
    expect(PizzacornCommunityConfig.isPostBlocked(
      CommunityModel(userId: 'visible'),
    ), isFalse);

    ConfigurePizzacornCommunity();
  });

  test('onReportTweet recibe publicación y motivo con prioridad sobre onReport', () async {
    final CommunityModel communityModel = CommunityModel(id: 'post-1');
    final List<String> calls = [];
    ConfigurePizzacornCommunity(
      onReport: (postModel, reason) => calls.add('anterior:$reason'),
      onReportTweet: (postModel, reason) {
        expect(identical(postModel, communityModel), isTrue);
        calls.add('nuevo:$reason');
      },
    );

    await CommunityRepository().notifyReport(
      communityModel: communityModel,
      reason: 'Spam',
    );
    expect(calls, ['nuevo:Spam']);

    ConfigurePizzacornCommunity(
      onReport: (postModel, reason) => calls.add('anterior:$reason'),
    );
    await CommunityRepository().notifyReport(
      communityModel: communityModel,
      reason: 'Contenido inapropiado',
    );
    expect(calls.last, 'anterior:Contenido inapropiado');
    ConfigurePizzacornCommunity();
  });
}
