import 'package:community_example/config/imports.dart';

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) {
    final SessionController controller = SessionController();
    Future.microtask(controller.signIn);
    return controller;
  },
);

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(SessionState());

  Future<void> signIn() async {
    if (!mounted || state.isLoading) return;
    if (!TestConfiguration.isConfigured) {
      state = state.copyWith(isError: 'Completa la configuración de Firebase indicada en example/README.md.');
      return;
    }
    state = state.copyWith(isLoading: true, isError: '');
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: TestConfiguration.options);
      }
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: TestConfiguration.TEST_EMAIL,
            password: TestConfiguration.TEST_PASSWORD,
          );
      if (!mounted) return;
      final User? user = credential.user;
      if (user == null) throw StateError('Firebase no ha devuelto un usuario.');
      final CommunityUserModel userModel = CommunityUserModel(
        id: user.uid,
        name: user.displayName?.isNotEmpty == true
            ? user.displayName! : 'Usuario de pruebas',
        username: user.email?.split('@').first ?? 'pruebas',
        image: user.photoURL ?? '',
      );
      ConfigurePizzacornCommunity(
        currentUser: userModel,
        filters: ['Noticias', 'Eventos', 'Preguntas'],
        databaseName: TestConfiguration.DATABASE_NAME,
        usersCollection: TestConfiguration.USERS_COLLECTION.isEmpty
            ? null : TestConfiguration.USERS_COLLECTION,
        usersNicknameField: TestConfiguration.USERS_NICKNAME_FIELD.isEmpty
            ? null : TestConfiguration.USERS_NICKNAME_FIELD,
        usersNameField: TestConfiguration.USERS_NAME_FIELD.isEmpty
            ? null : TestConfiguration.USERS_NAME_FIELD,
        usersImageField: TestConfiguration.USERS_IMAGE_FIELD.isEmpty
            ? null : TestConfiguration.USERS_IMAGE_FIELD,
        usersSearchMode: TestConfiguration.usersSearchMode,
        onOpenProfile: (context, userId) async {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: TextTitle('Perfil de pruebas'),
              content: TextBody('Usuario: $userId'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: TextBody('Cerrar'),
                ),
              ],
            ),
          );
        },
      );
      state = state.copyWith(isLoading: false, userModel: userModel);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isError: error.toString());
    }
  }

  Future<void> signOut() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: '');
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ConfigurePizzacornCommunity();
      state = state.copyWith(isLoading: false, clearUser: true);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isError: error.toString());
    }
  }

}
