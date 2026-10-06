import 'package:community_example/config/imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(ProviderScope(child: CommunityExampleApp()));
}

class CommunityExampleApp extends StatelessWidget {
  CommunityExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community · Pruebas',
      debugShowCheckedModeBanner: false,
      home: SessionPage(),
    );
  }
}
