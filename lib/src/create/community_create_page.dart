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
                    size: 45,
                    singleBorder: true,
                    innerBorderWidth: 0,
                    outerBorderWidth: 0,
                  ),
                  Space(SPACE_MEDIUM),
                  Expanded(
                    child: CommunityMentionField(
                      controller: controller.textController,
                    ),
                  ),
                ],
              ),
              if (PizzacornCommunityConfig.filters.isNotEmpty) ...[
                Space(SPACE_BIG),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextBody('Añade un filtro', fontWeight: FontWeight.bold),
                ),
                Space(SPACE_SMALL),
                SegmentedControlCustom(
                  items: PizzacornCommunityConfig.filters,
                  thumbColor: PizzacornCommunityConfig.filterColor,
                  activeTextColor: PizzacornCommunityConfig.filterTextColor,
                  inactiveTextColor: PizzacornCommunityConfig.filterTextColor,
                  currentIndex: PizzacornCommunityConfig.filters.contains(
                    state.selectedFilter,
                  )
                      ? PizzacornCommunityConfig.filters.indexOf(state.selectedFilter)
                      : 0,
                  onValueChanged: (index) {
                    controller.selectFilter(
                      filter: PizzacornCommunityConfig.filters[index],
                    );
                  },
                ),
              ],
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
      bottomSheet: Container(
        height: 90,
        decoration: BoxDecoration(
          color: COLOR_BACKGROUND,
          border: Border(top: BorderSide(color: COLOR_BORDER))
        ),
        child: Padding(
          padding: PADDING_ALL,
          child: Row(
            children: [
              IconButton(
                onPressed: controller.pickImages,
                iconSize: 22,
                icon: Icon(UIconsPro.regularRounded.picture, color: COLOR_ACCENT),
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
      )
    );
  }
}
