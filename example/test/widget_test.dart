import 'package:flutter_test/flutter_test.dart';
import 'package:community_example/config/imports.dart';

class TestSessionController extends SessionController {
  int attempts = 0;

  TestSessionController({required SessionState initialState}) {
    state = initialState;
  }

  @override
  Future<void> signIn() async {
    attempts++;
    state = state.copyWith(isLoading: true, isError: '');
  }
}

void main() {
  testWidgets('Durante el acceso automático no muestra formulario ni muro', (tester) async {
    final TestSessionController controller = TestSessionController(
      initialState: SessionState(isLoading: true),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionProvider.overrideWith((ref) => controller)],
      child: MaterialApp(home: SessionPage()),
    ));
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(CommunityPage), findsNothing);
    expect(find.text('Entrar al muro'), findsNothing);
    await tester.pumpWidget(SizedBox());
  });

  testWidgets('Un fallo de acceso permite reintentar sin formulario', (tester) async {
    final TestSessionController controller = TestSessionController(
      initialState: SessionState(isError: 'No se pudo iniciar sesión'),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionProvider.overrideWith((ref) => controller)],
      child: MaterialApp(home: SessionPage()),
    ));
    expect(find.text('No se pudo iniciar sesión'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(controller.attempts, 1);
    expect(controller.state.isLoading, isTrue);
    expect(controller.state.isError, isEmpty);
    await tester.pumpWidget(SizedBox());
  });
}
