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
    final String searchQuery = PizzacornCommunityConfig.showSearch
        ? state.searchQuery
        : '';
    final (String, String) searchParams = (searchQuery, selectedFilter);
    final AsyncValue<List<CommunityModel>>? searchResults = searchQuery.isEmpty
        ? null
        : ref.watch(communitySearchProvider(searchParams));

    return Scaffold(
      backgroundColor: PizzacornCommunityConfig.backgroundSecondaryColor,
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
        child: Column(
          children: [
            if (filters.isNotEmpty)
              SegmentedControlCustom(
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
            if (filters.isNotEmpty) Space(SPACE_SMALL),
            Expanded(
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (PizzacornCommunityConfig.showSearch)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PADDING_ALL,
                        child: TextFieldCustom(
                          hintText: 'Buscar publicaciones',
                          prefixIcon: UIconsPro.regularRounded.search,
                          onChanged: (query) {
                            ref.read(communityControllerProvider.notifier).search(query: query);
                          },
                        ),
                      ),
                    ),
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      if (searchResults != null) {
                        ref.invalidate(communitySearchProvider(searchParams));
                        await ref.read(communitySearchProvider(searchParams).future);
                        return;
                      }
                      await ref.read(paginationProvider(params).notifier).refresh();
                    },
                  ),
                  if (PizzacornCommunityConfig.showDisclaimer &&
                      PizzacornCommunityConfig.disclaimerText.trim().isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PADDING_ALL,
                        child: DisclaimerWidget(
                          text: PizzacornCommunityConfig.disclaimerText,
                        ),
                      ),
                    ),
                  if (searchResults != null)
                    searchResults.when(
                      data: (posts) => SliverPadding(
                        padding: PADDING_ALL,
                        sliver: posts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(child: TextBody('No hay publicaciones para esta búsqueda.')),
                              )
                            : SliverList.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final CommunityModel communityModel = posts[index];
                                  if (PizzacornCommunityConfig.isPostBlocked(communityModel)) {
                                    return SizedBox.shrink();
                                  }
                                  return CommunityWidget(
                                    communityModel: communityModel,
                                    params: params,
                                    onDelete: () {
                                      ref.read(communityControllerProvider.notifier).delete(
                                        communityModel: communityModel,
                                        params: params,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                      loading: () => SliverToBoxAdapter(
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
                      error: (error, stackTrace) => SliverToBoxAdapter(
                        child: Column(
                          children: [
                            TextBody('No se pudieron buscar las publicaciones.'),
                            TextButton(
                              onPressed: () => ref.invalidate(communitySearchProvider(searchParams)),
                              child: TextButtonCustom('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else SliverPadding(
                    padding: PADDING,
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
                        if (PizzacornCommunityConfig.isPostBlocked(communityModel)) {
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
                  SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
