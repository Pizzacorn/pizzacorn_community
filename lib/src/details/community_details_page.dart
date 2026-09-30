import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityDetailsPage extends ConsumerWidget {
  final CommunityModel communityModel;

  CommunityDetailsPage({super.key, required this.communityModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommunityDetailsState state = ref.watch(
      communityDetailsProvider(communityModel),
    );
    final CommunityDetailsController controller = ref.read(
      communityDetailsProvider(communityModel).notifier,
    );

    return Scaffold(
      backgroundColor: COLOR_BACKGROUND_SECONDARY,
      resizeToAvoidBottomInset: true,
      appBar: AppBarBack(
        context: context,
        title: 'Publicación',
        color: COLOR_BACKGROUND,
      ),
      body: Loading(
        loading: state.isLoading,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return ref
                    .read(paginationProvider(controller.detailsParams).notifier)
                    .refresh();
              },
            ),
            SliverToBoxAdapter(
              child: CommunityWidget(
                communityModel: state.communityModel,
                params: communityParams,
                noNavigation: true,
                onDelete: () {
                  ref
                      .read(communityControllerProvider.notifier)
                      .delete(
                        communityModel: state.communityModel,
                        params: communityParams,
                      );
                  goBack(context);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: PADDING_ALL,
                child: TextBody(
                  'Respuestas',
                  color: COLOR_SUBTEXT,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverPadding(
              padding: PADDING,
              sliver: SliverListCustom<CommunityModel>(
                params: controller.detailsParams,
                itemPlaceholder: CommunityModel(),
                idExtractor: (commentModel) => commentModel.id,
                emptyWidget: Center(
                  child: TextBody('Todavía no hay respuestas.'),
                ),
                itemBuilder: (commentModel) {
                  return CommunityWidget(
                    communityModel: commentModel,
                    params: controller.detailsParams,
                    onDelete: () {
                      ref
                          .read(communityControllerProvider.notifier)
                          .delete(
                            communityModel: commentModel,
                            params: controller.detailsParams,
                          );
                    },
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: Space(SPACE_BIGGER)),
          ],
        ),
      ),
      bottomSheet: AnimatedPadding(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: COLOR_BACKGROUND,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DOUBLE_PADDING_SMALL,
                vertical: DOUBLE_PADDING_SMALL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.images.isNotEmpty) ...[
                    CommunitySelectedImages(
                      images: state.images,
                      onRemoveImage: controller.removeImage,
                      height: 110,
                      width: 140,
                    ),
                    Space(SPACE_SMALL),
                  ],
                  Row(
                    children: [
                      IconButton(
                        onPressed: controller.pickImages,
                        icon: Icon(
                          UIconsPro.regularRounded.gallery,
                          color: COLOR_ACCENT,
                        ),
                      ),
                      Expanded(
                        child: TextFieldCustom(
                          controller: controller.textController,
                          hintText: 'Añade una respuesta',
                          textCapitalization: TextCapitalization.sentences,
                          textInputType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            controller.saveComment(context: context),
                        icon: Icon(Icons.send_rounded, color: COLOR_ACCENT),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
