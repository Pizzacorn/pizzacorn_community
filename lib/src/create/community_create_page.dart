import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityCreatePage extends ConsumerWidget {
  final CommunityModel? quotePost;

  CommunityCreatePage({super.key, this.quotePost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommunityCreateState state = ref.watch(
      communityCreateProvider(quotePost),
    );
    final CommunityCreateController controller = ref.read(
      communityCreateProvider(quotePost).notifier,
    );
    final CommunityUserModel currentUser = PizzacornCommunityConfig.currentUser;

    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      appBar: AppBarBack(
        context: context,
        title: state.quotePost == null
            ? 'Nueva publicación'
            : 'Citar publicación',
      ),
      body: Loading(
        loading: state.isLoading,
        child: SingleChildScrollView(
          padding: PADDING_ALL,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileImageCustom(
                    imageUrl: currentUser.image,
                    size: 40,
                    singleBorder: true,
                    innerBorderWidth: 0,
                    outerBorderWidth: 0,
                  ),
                  Space(SPACE_MEDIUM),
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 15,
                      maxLength: 250,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: '¿Qué está pasando?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.quotePost != null) ...[
                Space(SPACE_MEDIUM),
                IgnorePointer(
                  child: CommunityWidget(
                    communityModel: state.quotePost!,
                    params: communityParams,
                    isQuotePreview: true,
                    onDelete: () {},
                  ),
                ),
              ],
              if (state.images.isNotEmpty) ...[
                Space(SPACE_MEDIUM),
                CommunitySelectedImages(
                  images: state.images,
                  onRemoveImage: controller.removeImage,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: PADDING_ALL,
        child: Row(
          children: [
            IconButton(
              onPressed: controller.pickImages,
              icon: Icon(UIconsPro.regularRounded.gallery, color: COLOR_ACCENT),
            ),
            Space(SPACE_MEDIUM),
            Expanded(
              child: ButtonCustom(
                text: 'Publicar',
                onPressed: () => controller.savePost(context: context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
