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

    if (PizzacornCommunityConfig.isPostBlocked(state.communityModel)) {
      return Scaffold(
        backgroundColor: PizzacornCommunityConfig.backgroundSecondaryColor,
        appBar: AppBarBack(
          context: context,
          title: 'Publicación',
          color: PizzacornCommunityConfig.backgroundColor,
        ),
        body: Center(child: TextBody('Publicación no disponible.')),
      );
    }

    return Scaffold(
      backgroundColor: PizzacornCommunityConfig.backgroundSecondaryColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBarBack(
        context: context,
        title: 'Publicación',
        color: PizzacornCommunityConfig.backgroundColor,
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
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: PizzacornCommunityConfig.backgroundColor
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SPACE_SMALL,
            vertical: SPACE_MEDIUM,
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
              if (state.pollOptions.isNotEmpty) CommunityPollEditor(
                options: state.pollOptions,
                onRemove: controller.removePollOption,
                onChanged: controller.changePollOption,
                onAdd: controller.addPollOption,
                onCancel: controller.cancelPoll,
              ),
              if (state.attachment != null) ...[
                CommunityAttachedCard(
                  attachmentModel: state.attachment!,
                  onRemove: controller.removeAttachment,
                ),
                Space(SPACE_SMALL),
              ],
              if (state.isError.isNotEmpty) TextCaption(state.isError, color: COLOR_ERROR),
              CommunityCommentComposer(
                controller: controller.textController,
                onPickImages: controller.pickImages,
                onCreatePoll: controller.createPoll,
                onPickTarget: ({required bool isEntity}) async {
                  final CommunityUserModel? targetModel = await pickCommunityAttachment(
                    context: context,
                    isEntity: isEntity,
                  );
                  if (targetModel != null) {
                    controller.attachTarget(targetModel: targetModel, isEntity: isEntity);
                  }
                },
                onSend: () => controller.saveComment(context: context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
