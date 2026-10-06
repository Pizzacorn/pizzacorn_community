import 'package:community_example/config/imports.dart';

class TestConfiguration {
  static const String TEST_EMAIL = 'hola@pizzacorn.es';
  static const String TEST_PASSWORD = '123123';
  static const String API_KEY = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDDsdhIkA9b2OXjsNjIY69eB2fBwfyi12E',
  );
  static const String APP_ID = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:75367582656:android:e6c94d8a76a8b85a44d625',
  );
  static const String PROJECT_ID = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'pizzacorn-community',
  );
  static const String SENDER_ID = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '75367582656',
  );
  static const String STORAGE_BUCKET = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'pizzacorn-community.firebasestorage.app',
  );
  static const String IOS_BUNDLE_ID = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  static const String DATABASE_NAME = String.fromEnvironment('FIRESTORE_DATABASE');
  static const String USERS_COLLECTION = String.fromEnvironment(
    'COMMUNITY_USERS_COLLECTION', defaultValue: 'Users',
  );
  static const String USERS_NICKNAME_FIELD = String.fromEnvironment(
    'COMMUNITY_USERS_NICKNAME_FIELD', defaultValue: 'email',
  );
  static const String USERS_NAME_FIELD = String.fromEnvironment('COMMUNITY_USERS_NAME_FIELD');
  static const String USERS_IMAGE_FIELD = String.fromEnvironment('COMMUNITY_USERS_IMAGE_FIELD', defaultValue: "image");
  static const String USERS_SEARCH_MODE = String.fromEnvironment(
    'COMMUNITY_USERS_SEARCH_MODE',
    defaultValue: 'normal',
  );

  static CommunityUsersSearchMode get usersSearchMode {
    switch (USERS_SEARCH_MODE) {
      case 'normal':
        return CommunityUsersSearchMode.normal;
      case 'enterprise':
        return CommunityUsersSearchMode.enterprise;
      default:
        throw StateError('COMMUNITY_USERS_SEARCH_MODE debe ser normal o enterprise.');
    }
  }

  static bool get isConfigured =>
      API_KEY.isNotEmpty && APP_ID.isNotEmpty && PROJECT_ID.isNotEmpty &&
      SENDER_ID.isNotEmpty && STORAGE_BUCKET.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
    apiKey: API_KEY,
    appId: APP_ID,
    messagingSenderId: SENDER_ID,
    projectId: PROJECT_ID,
    storageBucket: STORAGE_BUCKET,
    iosBundleId: IOS_BUNDLE_ID.isEmpty ? null : IOS_BUNDLE_ID,
  );
}
