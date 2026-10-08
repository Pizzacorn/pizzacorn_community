import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityCreateState {
  final bool isLoading;
  final String isError;
  final List<XFile> images;
  final CommunityModel? quotePost;
  final String selectedFilter;

  CommunityCreateState({
    this.isLoading = false,
    this.isError = '',
    this.images = const [],
    this.quotePost,
    this.selectedFilter = '',
  });

  CommunityCreateState copyWith({
    bool? isLoading,
    String? isError,
    List<XFile>? images,
    CommunityModel? quotePost,
    String? selectedFilter,
  }) {
    return CommunityCreateState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      images: images ?? this.images,
      quotePost: quotePost ?? this.quotePost,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

final communityCreateProvider = NotifierProvider.autoDispose
    .family<CommunityCreateController, CommunityCreateState, CommunityModel?>(
      CommunityCreateController.new,
    );

class CommunityCreateController
    extends AutoDisposeFamilyNotifier<CommunityCreateState, CommunityModel?> {
  final CommunityRepository repository = CommunityRepository();
  late CommunityMentionController textController;

  @override
  CommunityCreateState build(CommunityModel? arg) {
    textController = CommunityMentionController();
    ref.onDispose(textController.dispose);
    final List<String> filters = PizzacornCommunityConfig.filters;
    final String initialFilter = arg != null && filters.contains(arg.filter)
        ? arg.filter
        : filters.isEmpty
            ? ''
            : filters.first;
    return CommunityCreateState(quotePost: arg, selectedFilter: initialFilter);
  }

  void selectFilter({required String filter}) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> pickImages() async {
    final List<XFile> picked = await ref
        .read(communityMediaServiceProvider)
        .pickImages();
    if (picked.isNotEmpty) {
      state = state.copyWith(images: [...state.images, ...picked]);
    }
  }

  void removeImage({required int index}) {
    final List<XFile> images = List.from(state.images);
    images.removeAt(index);
    state = state.copyWith(images: images);
  }

  Future<void> savePost({required BuildContext context}) async {
    final String content = textController.text.trim();
    if (content.isEmpty && state.images.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, isError: '');
      final CommunityUploadedMedia uploadedMedia = state.images.isEmpty
          ? CommunityUploadedMedia(media: [], mediaThumbnails: [])
          : await ref
                .read(communityMediaServiceProvider)
                .uploadImageVariants(images: state.images, folder: 'community_posts');
      final CommunityModel communityModel = buildCommunityModel(
        text: content,
        media: uploadedMedia.media,
        mediaThumbnails: uploadedMedia.mediaThumbnails,
      );
      final CommunityModel saved = await repository.save(
        communityModel: communityModel,
        isQuote: state.quotePost != null,
      );
      final CommunityController communityController = ref.read(
        communityControllerProvider.notifier,
      );
      communityController.updateLocally(
        communityModel: saved,
        params: communityParams,
        isAddition: true,
      );
      final String activeFilter = ref.read(communityControllerProvider).selectedFilter;
      if (activeFilter.isNotEmpty && activeFilter == saved.filter) {
        communityController.updateLocally(
          communityModel: saved,
          params: communityParamsForFilter(filter: activeFilter),
          isAddition: true,
        );
      }
      if (context.mounted) goBack(context);
    } catch (error) {
      state = state.copyWith(isError: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  CommunityModel buildCommunityModel({
    required String text,
    required List<String> media,
    required List<String> mediaThumbnails,
  }) {
    final CommunityModel? quotePost = state.quotePost;
    if (quotePost == null) {
      return CommunityModel(
        type: CommunityType.post,
        filter: state.selectedFilter,
        text: text,
        mentionIds: textController.mentionIds,
        media: media,
        mediaThumbnails: mediaThumbnails,
        createdAt: DateTime.now(),
      );
    }
    return CommunityModel(
      type: CommunityType.quote,
      filter: state.selectedFilter,
      text: text,
        mentionIds: textController.mentionIds,
      media: media,
      mediaThumbnails: mediaThumbnails,
      secondaryId: quotePost.id,
      secondaryUserId: quotePost.userId,
      secondaryUserName: quotePost.userName,
      secondaryUserUsername: quotePost.userUsername,
      secondaryUserImage: quotePost.userImage,
      secondaryText: quotePost.text,
      secondaryMentionIds: quotePost.mentionIds,
      secondaryMedia: quotePost.media,
      secondaryMediaThumbnails: quotePost.mediaThumbnails,
      secondaryType: quotePost.type.name,
      createdAt: DateTime.now(),
    );
  }
}
