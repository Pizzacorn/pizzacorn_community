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
      backgroundColor: PizzacornCommunityConfig.backgroundColor,
      appBar: AppBarBack(
        context: context,
        color: PizzacornCommunityConfig.backgroundColor,
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
                    onPressed: currentUser.id.isEmpty ||
                            (PizzacornCommunityConfig.onTapUser == null &&
                                PizzacornCommunityConfig.onOpenProfile == null)
                        ? null
                        : () {
                            final CommunityProfileCallback onTapUser =
                                PizzacornCommunityConfig.onTapUser ??
                                PizzacornCommunityConfig.onOpenProfile!;
                            onTapUser(context, currentUser.id);
                          },
                  ),
                  Space(SPACE_SMALLEST),
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
                Padding(
                  padding: EdgeInsets.only(left: 45 + SPACE_SMALLEST),
                  child: CommunitySelectedImages(
                    images: state.images,
                    onRemoveImage: controller.removeImage,
                  ),
                ),
              ],
              if (state.isError.isNotEmpty) ...[
                Space(SPACE_SMALL),
                TextCaption(state.isError, color: COLOR_ERROR),
              ],
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 90,
        decoration: BoxDecoration(
          color: PizzacornCommunityConfig.backgroundColor,
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
