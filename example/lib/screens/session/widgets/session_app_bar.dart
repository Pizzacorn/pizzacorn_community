import 'package:community_example/config/imports.dart';

class SessionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  SessionAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    return AppBar(
      title: TextTitle('Community · Pruebas'),
      actions: [
        if (state.userModel != null)
          TextButton(
            onPressed: state.isLoading
                ? null : () => ref.read(sessionProvider.notifier).signOut(),
            child: TextBody('Salir'),
          ),
      ],
    );
  }
}
