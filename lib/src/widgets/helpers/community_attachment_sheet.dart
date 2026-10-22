import 'package:pizzacorn_community/pizzacorn_community.dart';

void showCommunityAttachmentSheet({
  required BuildContext context,
  required VoidCallback onPickImages,
  required VoidCallback onCreatePoll,
  required Future<void> Function({required bool isEntity}) onPickTarget,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: PizzacornCommunityConfig.backgroundColor,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(UIconsPro.regularRounded.picture, color: COLOR_ACCENT),
            title: TextBody('Subir fotos'),
            onTap: () {
              Navigator.pop(sheetContext);
              onPickImages();
            },
          ),
          if (PizzacornCommunityConfig.showProfileAttachment &&
              PizzacornCommunityConfig.canSearchUsers)
            ListTile(
              leading: Icon(UIconsPro.regularRounded.user, color: COLOR_ACCENT),
              title: TextBody(PizzacornCommunityConfig.addProfileAttachmentText),
              onTap: () {
                Navigator.pop(sheetContext);
                onPickTarget(isEntity: false);
              },
            ),
          if (PizzacornCommunityConfig.showEntityAttachment &&
              PizzacornCommunityConfig.canSearchEntities)
            ListTile(
              leading: Icon(UIconsPro.regularRounded.building, color: COLOR_ACCENT),
              title: TextBody(PizzacornCommunityConfig.addEntityAttachmentText),
              onTap: () {
                Navigator.pop(sheetContext);
                onPickTarget(isEntity: true);
              },
            ),
          ListTile(
            leading: Icon(UIconsPro.regularRounded.list, color: COLOR_ACCENT),
            title: TextBody('Encuesta'),
            onTap: () {
              Navigator.pop(sheetContext);
              onCreatePoll();
            },
          ),
        ],
      ),
    ),
  );
}

Future<CommunityUserModel?> pickCommunityAttachment({
  required BuildContext context,
  required bool isEntity,
}) {
  return showModalBottomSheet<CommunityUserModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PizzacornCommunityConfig.backgroundColor,
    builder: (sheetContext) => CommunityAttachmentPicker(isEntity: isEntity),
  );
}

class CommunityAttachmentPicker extends StatefulWidget {
  final bool isEntity;

  CommunityAttachmentPicker({super.key, required this.isEntity});

  @override
  State<CommunityAttachmentPicker> createState() => CommunityAttachmentPickerState();
}

class CommunityAttachmentPickerState extends State<CommunityAttachmentPicker> {
  String query = '';

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: SPACE_MEDIUM,
        right: SPACE_MEDIUM,
        top: SPACE_MEDIUM,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SPACE_MEDIUM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextTitle(widget.isEntity
              ? PizzacornCommunityConfig.addEntityAttachmentText
              : PizzacornCommunityConfig.addProfileAttachmentText),
          Space(SPACE_MEDIUM),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Buscar ${widget.isEntity ? 'entidad' : 'perfil'}',
              prefixIcon: Icon(UIconsPro.regularRounded.search),
            ),
            onChanged: (value) => setState(() => query = value),
          ),
          CommunityMentionSheet(
            query: query,
            isEntity: widget.isEntity,
            onSelected: ({required CommunityUserModel userModel}) {
              Navigator.pop(context, userModel);
              return true;
            },
          ),
        ],
      ),
    ),
  );
}

class CommunityPollEditor extends StatelessWidget {
  final List<String> options;
  final ValueChanged<int> onRemove;
  final void Function(int, String) onChanged;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  CommunityPollEditor({
    super.key,
    required this.options,
    required this.onRemove,
    required this.onChanged,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: TextBody('Encuesta', fontWeight: FontWeight.bold)),
        IconButton(onPressed: onCancel, icon: Icon(Icons.close)),
      ]),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, i) => Row(children: [
          Expanded(child: TextFormField(
            key: ValueKey('poll_option_$i'),
            initialValue: options[i],
            maxLength: 100,
            decoration: InputDecoration(hintText: 'Opción ${i + 1}'),
            onChanged: (value) => onChanged(i, value),
          )),
          if (options.length > 2)
            IconButton(onPressed: () => onRemove(i), icon: Icon(Icons.close)),
        ]),
      ),
      if (options.length < 4)
        TextButton(onPressed: onAdd, child: TextButtonCustom('Añadir opción')),
    ],
  );
}
