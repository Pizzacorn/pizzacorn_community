import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityPage extends ConsumerWidget {
  final int floatingButtonHeight;

  CommunityPage({super.key, this.floatingButtonHeight = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommunityUserModel currentUser = PizzacornCommunityConfig.currentUser;
    final CommunityState state = ref.watch(communityControllerProvider);
    final List<String> filters = PizzacornCommunityConfig.filters;
    final String selectedFilter = filters.contains(state.selectedFilter)
        ? state.selectedFilter
        : '';
    final PaginationParams<CommunityModel> params = communityParamsForFilter(
      filter: selectedFilter,
    );

    return Scaffold(
      backgroundColor: COLOR_BACKGROUND_SECONDARY,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: floatingButtonHeight.toDouble()),
        child: FloatingActionButton(
          backgroundColor: COLOR_ACCENT,
          onPressed: () => goTo(context, CommunityCreatePage()),
          child: Icon(Icons.add, color: COLOR_TEXT_BUTTONS),
        ),
      ),
      body: Container(
        key: ValueKey(currentUser.id),
        decoration: PizzacornCommunityConfig.backgroundAsset == null
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  opacity: 0.15,
                  image: AssetImage(PizzacornCommunityConfig.backgroundAsset!),
                ),
              ),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            if (filters.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: PADDING_ALL,
                  child: SegmentedControlCustom(
                    items: ['Todos', ...filters],
                    thumbColor: PizzacornCommunityConfig.filterColor,
                    activeTextColor: PizzacornCommunityConfig.filterTextColor,
                    inactiveTextColor: PizzacornCommunityConfig.filterTextColor,
                    currentIndex: selectedFilter.isEmpty
                        ? 0
                        : filters.indexOf(selectedFilter) + 1,
                    onValueChanged: (index) {
                      ref.read(communityControllerProvider.notifier).selectFilter(
                        filter: index == 0 ? '' : filters[index - 1],
                      );
                    },
                  ),
                ),
              ),
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return ref.read(paginationProvider(params).notifier).refresh();
              },
            ),
            SliverPadding(
              padding: PADDING_ALL,
              sliver: SliverListCustom<CommunityModel>(
                params: params,
                itemPlaceholder: CommunityModel(),
                idExtractor: (communityModel) => communityModel.id,
                emptyWidget: Center(
                  child: Padding(
                    padding: PADDING_ALL,
                    child: TextBody('Todavía no hay publicaciones.'),
                  ),
                ),
                itemBuilder: (communityModel) {
                  if (currentUser.blockedUsers.contains(
                    communityModel.userId,
                  )) {
                    return SizedBox.shrink();
                  }
                  return CommunityWidget(
                    communityModel: communityModel,
                    params: params,
                    onDelete: () {
                      ref
                          .read(communityControllerProvider.notifier)
                          .delete(
                            communityModel: communityModel,
                            params: params,
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
    );
  }
}
