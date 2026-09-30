import 'package:pizzacorn_community/pizzacorn_community.dart';

class ReportCommunityBottom extends StatefulWidget {
  final CommunityModel communityModel;

  ReportCommunityBottom({super.key, required this.communityModel});

  @override
  State<ReportCommunityBottom> createState() => ReportCommunityBottomState();
}

class ReportCommunityBottomState extends State<ReportCommunityBottom> {
  bool isLoading = false;
  int selected = 0;
  final List<String> reasons = [
    'Contenido inapropiado',
    'Spam',
    'Contenido de odio',
    'Información falsa',
  ];

  @override
  Widget build(BuildContext context) {
    return Loading(
      loading: isLoading,
      child: Scaffold(
        appBar: AppBarClose(context: context, title: 'Reportar publicación'),
        body: Padding(
          padding: PADDING_ALL,
          child: ListView(
            children: [
              TextTitle('Reportar publicación', textAlign: TextAlign.center),
              Space(SPACE_SMALL),
              TextBody(
                'Selecciona el motivo del reporte. Revisaremos la publicación.',
                textAlign: TextAlign.center,
                maxlines: 5,
              ),
              Space(SPACE_MEDIUM),
              SelectorList(
                reasons,
                selectedIndex: selected,
                onChanged: (value) => setState(() => selected = value),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomSheetCustomOneButton(
          title: 'Enviar reporte',
          onPressed: sendReport,
        ),
      ),
    );
  }

  Future<void> sendReport() async {
    setState(() => isLoading = true);
    try {
      await CommunityRepository().report(
        communityModel: widget.communityModel,
        reason: reasons[selected],
      );
      if (mounted) {
        openSnackbar(
          context,
          text: 'Reporte enviado correctamente. Gracias por tu ayuda.',
          isDone: true,
        );
        goBack(context);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
