import 'package:community_example/config/imports.dart';

class SessionPage extends ConsumerWidget {
  SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState state = ref.watch(sessionProvider);
    final SessionController controller = ref.read(sessionProvider.notifier);
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      appBar: SessionAppBar(),
      body: Loading(
        loading: state.isLoading,
        child: state.userModel != null
            ? ProviderScope(
                key: ValueKey(state.userModel!.id),
                child: CommunityPage(),
              )
            : Center(
                child: Padding(
                  padding: PADDING_ALL,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextBody(state.isError.isEmpty
                          ? 'Conectando con la cuenta de pruebas…'
                          : state.isError),
                      if (!state.isLoading && state.isError.isNotEmpty) ...[
                        Space(SPACE_MEDIUM),
                        ButtonCustom(text: 'Reintentar', onPressed: controller.signIn),
                      ],
                      if (!state.isLoading && state.isError.isEmpty) ...[
                        Space(SPACE_MEDIUM),
                        ButtonCustom(text: 'Abrir comunidad', onPressed: controller.signIn),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
