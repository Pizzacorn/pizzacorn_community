import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityCreateState {
  final bool isLoading;
  final String isError;
  final List<XFile> images;
  final CommunityModel? quotePost;

  CommunityCreateState({
    this.isLoading = false,
    this.isError = '',
    this.images = const [],
    this.quotePost,
  });

  CommunityCreateState copyWith({
    bool? isLoading,
    String? isError,
    List<XFile>? images,
    CommunityModel? quotePost,
  }) {
    return CommunityCreateState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      images: images ?? this.images,
      quotePost: quotePost ?? this.quotePost,
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
    return CommunityCreateState(quotePost: arg);
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
      final List<String> urls = state.images.isEmpty
          ? []
          : await ref
                .read(communityMediaServiceProvider)
                .uploadImages(images: state.images, folder: 'community_posts');
      final CommunityModel communityModel = buildCommunityModel(
        text: content,
        media: urls,
      );
      final CommunityModel saved = await repository.save(
        communityModel: communityModel,
        isQuote: state.quotePost != null,
      );
      ref
          .read(communityControllerProvider.notifier)
          .updateLocally(
            communityModel: saved,
            params: communityParams,
            isAddition: true,
          );
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
  }) {
    final CommunityModel? quotePost = state.quotePost;
    if (quotePost == null) {
      return CommunityModel(
        type: CommunityType.post,
        text: text,
        media: media,
        createdAt: DateTime.now(),
      );
    }
    return CommunityModel(
      type: CommunityType.quote,
      text: text,
      media: media,
      secondaryId: quotePost.id,
      secondaryUserId: quotePost.userId,
      secondaryUserName: quotePost.userName,
      secondaryUserUsername: quotePost.userUsername,
      secondaryUserImage: quotePost.userImage,
      secondaryText: quotePost.text,
      secondaryMedia: quotePost.media,
      secondaryType: quotePost.type.name,
      createdAt: DateTime.now(),
    );
  }
}
