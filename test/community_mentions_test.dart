import 'package:flutter_test/flutter_test.dart';
import 'package:pizzacorn_community/pizzacorn_community.dart';

void main() {
  testWidgets('La foto abre el perfil con el callback nuevo o el anterior', (tester) async {
    final List<String> opened = [];
    ConfigurePizzacornCommunity(
      onTapUser: (context, id) { opened.add('nuevo:$id'); },
      onOpenProfile: (context, id) { opened.add('anterior:$id'); },
    );
    addTearDown(() => ConfigurePizzacornCommunity());
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityPrincipalContent(
      communityModel: CommunityModel(userId: 'author', createdAt: DateTime.now()),
    ))));
    await tester.tap(find.byType(ProfileImageCustom));
    expect(opened, ['nuevo:author']);

    ConfigurePizzacornCommunity(
      onOpenProfile: (context, id) { opened.add('anterior:$id'); },
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityPrincipalContent(
      communityModel: CommunityModel(secondaryUserId: 'quoted', createdAt: DateTime.now()),
      isSecondary: true,
    ))));
    await tester.tap(find.byType(ProfileImageCustom));
    expect(opened, ['nuevo:author', 'anterior:quoted']);
    await tester.pumpWidget(SizedBox());
  });

  testWidgets('El editor muestra un campo blanco sin borde y con el texto solicitado', (tester) async {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityMentionField(
      controller: controller,
    ))));
    final TextField textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration!.hintText, '¿Qué esta pasando?');
    expect(textField.decoration!.filled, isFalse);
    expect(textField.decoration!.border, InputBorder.none);
    expect(textField.decoration!.focusedBorder, InputBorder.none);
    final ColoredBox background = tester.widget<ColoredBox>(find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(ColoredBox),
    ).first);
    expect(background.color, Colors.white);
    await tester.pumpWidget(SizedBox());
  });

  test('Los IDs seleccionados sobreviven la serialización y se omiten al borrar el texto', () {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    controller.value = TextEditingValue(text: '#ent', selection: TextSelection.collapsed(offset: 4));
    controller.insertMention(userModel: CommunityUserModel(id: 'entity-id', username: 'entidad'), range: controller.activeMention!);
    final CommunityModel restoredModel = CommunityModel.fromJson(CommunityModel(
      text: controller.text,
      mentionIds: controller.mentionIds,
      secondaryMentionIds: {'@ana': 'user-id'},
    ).toJson());
    expect(restoredModel.copyWith().mentionIds['#entidad'], 'entity-id');
    expect(restoredModel.toJsonCreate()['secondaryMentionIds'], {'@ana': 'user-id'});
    expect(restoredModel.toJsonUpdate()['mentionIds'], {'#entidad': 'entity-id'});
    controller.text = '';
    expect(controller.mentionIds, isEmpty);
  });

  testWidgets('Callbacks reciben IDs solo en lectura', (tester) async {
    final List<String> received = [];
    ConfigurePizzacornCommunity(
      onTapUserMention: (context, id) { received.add('user:$id'); },
      onTapEntityMention: (context, id) { received.add('entity:$id'); },
    );
    addTearDown(() => ConfigurePizzacornCommunity());
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityClickableText(
      text: '@ana #entidad', mentionIds: {'@ana': 'uid', '#entidad': 'eid'},
    ))));
    final RichText richText = tester.widget<RichText>(find.descendant(
      of: find.byType(CommunityClickableText), matching: find.byType(RichText),
    ));
    final List<InlineSpan> spans = (richText.text as TextSpan).children!;
    ((spans[1] as TextSpan).recognizer as TapGestureRecognizer).onTap!();
    ((spans[3] as TextSpan).recognizer as TapGestureRecognizer).onTap!();
    expect(received, ['user:uid', 'entity:eid']);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityClickableText(
      text: '@ana #entidad', mentionIds: {'@ana': 'uid', '#entidad': 'eid'}, mentionsEnabled: false,
    ))));
    final RichText disabledText = tester.widget<RichText>(find.descendant(
      of: find.byType(CommunityClickableText), matching: find.byType(RichText),
    ));
    final List<InlineSpan> disabledSpans = (disabledText.text as TextSpan).children!;
    expect((disabledSpans[1] as TextSpan).recognizer, isNull);
    expect((disabledSpans[3] as TextSpan).recognizer, isNull);
    await tester.pumpWidget(SizedBox());
  });

  testWidgets('Cambia de usuarios a entidades sin mezclar sugerencias', (tester) async {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    ConfigurePizzacornCommunity(
      currentUser: CommunityUserModel(id: 'same-id'),
      onSearchUsers: ({required String query}) async => [
        CommunityUserModel(id: 'user-id', name: 'Ana', username: 'ana'),
      ],
      onSearchEntities: ({required String query}) async => [
        CommunityUserModel(id: 'same-id', name: 'Entidad', username: 'entidad'),
      ],
      usersMentionColor: Colors.red,
      entitiesMentionColor: Colors.green,
    );
    addTearDown(() => ConfigurePizzacornCommunity());
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommunityMentionField(controller: controller))));
    await tester.enterText(find.byType(TextField), '@a');
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#a');
    await tester.pump();
    await tester.pump(Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsNothing);
    await tester.tap(find.text('Entidad'));
    await tester.pumpAndSettle();
    expect(controller.text, '#entidad ');
    final List<TextSpan> spans = CommunityMentionController.spans(text: '@ana #entidad');
    expect(spans[1].style!.decorationColor, Colors.red);
    expect(spans[3].style!.decorationColor, Colors.green);
    expect(spans[3].style!.decoration, TextDecoration.underline);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
    await tester.pumpWidget(SizedBox());
  });

  test('Completa una mención en mitad del texto conservando el resto', () {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    controller.value = TextEditingValue(
      text: 'Hola @an mañana',
      selection: TextSelection.collapsed(offset: 8),
    );
    expect(controller.insertMention(
      userModel: CommunityUserModel(id: '1', username: 'ana'),
      range: controller.activeMention!,
    ), isTrue);
    expect(controller.text, 'Hola @ana  mañana');
    expect(controller.selection.extentOffset, 10);
  });

  test('No abre menciones para correos ni selecciones de texto', () {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    controller.value = TextEditingValue(
      text: 'ana@example', selection: TextSelection.collapsed(offset: 11),
    );
    expect(controller.activeMention, isNull);
    controller.value = TextEditingValue(
      text: '@ana', selection: TextSelection(baseOffset: 0, extentOffset: 4),
    );
    expect(controller.activeMention, isNull);
  });

  test('No inserta menciones que superan el límite de publicación', () {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    final String text = '${'x' * 245} @';
    controller.value = TextEditingValue(
      text: text, selection: TextSelection.collapsed(offset: text.length),
    );
    expect(controller.insertMention(
      userModel: CommunityUserModel(id: '1', username: 'nombrelargo'),
      range: controller.activeMention!,
    ), isFalse);
    expect(controller.text, text);
  });

  testWidgets('Abre sugerencias al escribir @ e inserta el usuario seleccionado', (tester) async {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    addTearDown(() { PizzacornCommunityConfig.onSearchUsers = null; });
    PizzacornCommunityConfig.onSearchUsers = ({required String query}) async => [
      CommunityUserModel(id: 'ana-id', name: 'Ana', username: 'ana'),
    ];
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: CommunityMentionField(controller: controller),
    )));
    await tester.enterText(find.byType(TextField), 'Hola @');
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.enterText(find.byType(TextField), 'Hola @an');
    await tester.pump();
    await tester.pump(Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    expect(controller.text, 'Hola @ana ');
    expect(find.text('Ana'), findsNothing);
    final List<TextSpan> spans = CommunityMentionController.spans(text: controller.text);
    expect(spans[1].text, '@ana');
    expect(spans[1].style!.color, Colors.blue);
    await tester.pumpWidget(SizedBox());
  });

  test('Completa y colorea un email usado como nickname', () {
    final CommunityMentionController controller = CommunityMentionController();
    addTearDown(controller.dispose);
    controller.value = TextEditingValue(text: '@an', selection: TextSelection.collapsed(offset: 3));
    expect(controller.insertMention(
      userModel: CommunityUserModel(id: 'ana', username: 'ana.test@example.com'),
      range: controller.activeMention!,
    ), isTrue);
    expect(controller.text, '@ana.test@example.com ');
    expect(CommunityMentionController.spans(text: controller.text)[1].text, '@ana.test@example.com');
  });
}
