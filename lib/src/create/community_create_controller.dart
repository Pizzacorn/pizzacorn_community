import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityCreateState {
  final bool isLoading;
  final String isError;
  final List<XFile> images;
  final List<String> pollOptions;
  final CommunityAttachmentModel? attachment;
  final CommunityModel? quotePost;
  final String selectedFilter;

  CommunityCreateState({
    this.isLoading = false,
    this.isError = '',
    this.images = const [],
    this.pollOptions = const [],
    this.attachment,
    this.quotePost,
    this.selectedFilter = '',
  });

  CommunityCreateState copyWith({
    bool? isLoading,
    String? isError,
    List<XFile>? images,
    List<String>? pollOptions,
    CommunityAttachmentModel? attachment,
    bool clearAttachment = false,
    CommunityModel? quotePost,
    String? selectedFilter,
  }) {
    return CommunityCreateState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      images: images ?? this.images,
      pollOptions: pollOptions ?? this.pollOptions,
      attachment: clearAttachment ? null : attachment ?? this.attachment,
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
    final int? maxPostImages = PizzacornCommunityConfig.maxPostImages;
    if (maxPostImages != null && state.images.length >= maxPostImages) {
      state = state.copyWith(isError: 'Máximo $maxPostImages imágenes por publicación.');
      return;
    }
    final List<XFile> picked = await ref
        .read(communityMediaServiceProvider)
        .pickImages();
    if (picked.isNotEmpty) {
      final int available = maxPostImages == null
          ? picked.length
          : maxPostImages - state.images.length;
      state = state.copyWith(
        images: [...state.images, ...picked.take(available)],
        isError: picked.length > available
            ? 'Máximo $maxPostImages imágenes por publicación.'
            : '',
      );
    }
  }

  void removeImage({required int index}) {
    final List<XFile> images = List.from(state.images);
    images.removeAt(index);
    state = state.copyWith(images: images);
  }

  void createPoll() => state = state.copyWith(pollOptions: ['', '']);

  void cancelPoll() => state = state.copyWith(pollOptions: []);

  void addPollOption() {
    if (state.pollOptions.length < 4) {
      state = state.copyWith(pollOptions: [...state.pollOptions, '']);
    }
  }

  void removePollOption(int index) {
    final options = List<String>.from(state.pollOptions)..removeAt(index);
    state = state.copyWith(pollOptions: options);
  }

  void changePollOption(int index, String value) {
    final options = List<String>.from(state.pollOptions);
    options[index] = value;
    state = state.copyWith(pollOptions: options);
  }

  void attachTarget({required CommunityUserModel targetModel, required bool isEntity}) {
    state = state.copyWith(attachment: CommunityAttachmentModel.fromUser(
      targetModel: targetModel,
      isEntity: isEntity,
    ));
  }

  void removeAttachment() => state = state.copyWith(clearAttachment: true);

  Future<void> savePost({required BuildContext context}) async {
    final String content = textController.text.trim();
    if (content.isEmpty && state.images.isEmpty && state.pollOptions.isEmpty && state.attachment == null) return;
    if (state.pollOptions.isNotEmpty &&
        (state.pollOptions.length < 2 ||
            state.pollOptions.any((option) => option.trim().isEmpty))) {
      state = state.copyWith(isError: 'Escribe al menos dos opciones para la encuesta.');
      return;
    }
    final int? maxPostImages = PizzacornCommunityConfig.maxPostImages;
    if (maxPostImages != null && state.images.length > maxPostImages) {
      state = state.copyWith(isError: 'Máximo $maxPostImages imágenes por publicación.');
      return;
    }

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
        pollOptions: state.pollOptions.map((option) => option.trim()).toList(),
        pollCounts: List<int>.filled(state.pollOptions.length, 0),
        attachment: state.attachment,
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
      pollOptions: state.pollOptions.map((option) => option.trim()).toList(),
      pollCounts: List<int>.filled(state.pollOptions.length, 0),
      attachment: state.attachment,
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
