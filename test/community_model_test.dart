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
}
