import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityMentionSheet extends StatefulWidget {
  final String query;
  final bool isEntity;
  final bool Function({required CommunityUserModel userModel}) onSelected;

  CommunityMentionSheet({super.key, required this.query, this.isEntity = false, required this.onSelected});

  @override
  State<CommunityMentionSheet> createState() => CommunityMentionSheetState();
}

class CommunityMentionSheetState extends State<CommunityMentionSheet> {
  Timer? debounce;
  int requestId = 0;
  bool isLoading = true;
  String isError = '';
  List<CommunityUserModel> users = [];

  @override
  void initState() {
    super.initState();
    search(query: widget.query);
  }

  @override
  void didUpdateWidget(covariant CommunityMentionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query || oldWidget.isEntity != widget.isEntity) scheduleSearch(widget.query);
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  void scheduleSearch(String query) {
    debounce?.cancel();
    requestId++;
    setState(() { isLoading = true; isError = ''; users = []; });
    debounce = Timer(Duration(milliseconds: 300), () => search(query: query));
  }

  Future<void> search({required String query}) async {
    final int currentRequest = ++requestId;
    try {
      final List<CommunityUserModel> results = await
          CommunityUsersRepository().search(query: query, isEntity: widget.isEntity);
      if (!mounted || currentRequest != requestId) return;
      final CommunityUserModel currentUserModel = PizzacornCommunityConfig.currentUser;
      final Set<String> ids = {};
      final List<CommunityUserModel> filteredUsers = [];
      for (int i = 0; i < results.length; i++) {
        final CommunityUserModel userModel = results[i];
        final String username = userModel.username.replaceFirst(RegExp(r'^[@#]'), '');
        if (userModel.id.isEmpty || (!widget.isEntity && (userModel.id == currentUserModel.id ||
            PizzacornCommunityConfig.isUserBlocked(userModel.id) ||
            userModel.blockedUsers.contains(currentUserModel.id))) ||
            !CommunityMentionController.usernameExpression.hasMatch(username) ||
            !ids.add(userModel.id)) continue;
        filteredUsers.add(userModel);
      }
      setState(() { users = filteredUsers; isLoading = false; isError = ''; });
    } catch (error) {
      if (!mounted || currentRequest != requestId) return;
      setState(() { isLoading = false; isError = 'No se pudieron cargar las sugerencias.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Space(0);
    }
    if (isError.isNotEmpty) {
      return Column(children: [
        TextBody(isError),
        TextButton(
          onPressed: () => scheduleSearch(widget.query),
          child: TextBody('Reintentar'),
        ),
      ]);
    }
    if (users.isEmpty) {
      return Padding(
        padding: PADDING_ALL_SMALL,
        child: TextBody('No hay coincidencias.'),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.3),
      child: Container(
        margin: EdgeInsets.only(top: SPACE_SMALL),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: COLOR_BORDER))
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final CommunityUserModel userModel = users[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ProfileImageCustom(imageUrl: userModel.image, size: 40, singleBorder: true, innerBorderWidth: 0, outerBorderWidth: 0,),
              title: TextBody(userModel.name),
              subtitle: TextCaption('${widget.isEntity ? '#' : '@'}${userModel.username.replaceFirst(RegExp(r'^[@#]'), '')}'),
              onTap: () {
                if (!widget.onSelected(userModel: userModel)) {
                  setState(() { isError = 'La mención supera el límite de 250 caracteres.'; });
                }
              },
            );
          },
        ),
      )
    );
  }
}
