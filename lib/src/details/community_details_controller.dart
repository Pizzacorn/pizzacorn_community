import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityDetailsState {
  final bool isLoading;
  final String isError;
  final CommunityModel communityModel;
  final List<XFile> images;
  final List<String> pollOptions;
  final CommunityAttachmentModel? attachment;

  CommunityDetailsState({
    this.isLoading = false,
    this.isError = '',
    CommunityModel? communityModel,
    this.images = const [],
    this.pollOptions = const [],
    this.attachment,
  }) : communityModel = communityModel ?? CommunityModel();

  CommunityDetailsState copyWith({
    bool? isLoading,
    String? isError,
    CommunityModel? communityModel,
    List<XFile>? images,
    List<String>? pollOptions,
    CommunityAttachmentModel? attachment,
    bool clearAttachment = false,
  }) {
    return CommunityDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      communityModel: communityModel ?? this.communityModel,
      images: images ?? this.images,
      pollOptions: pollOptions ?? this.pollOptions,
      attachment: clearAttachment ? null : attachment ?? this.attachment,
    );
  }
}

final communityDetailsProvider = NotifierProvider.autoDispose
    .family<CommunityDetailsController, CommunityDetailsState, CommunityModel>(
      CommunityDetailsController.new,
    );

class CommunityDetailsController
    extends AutoDisposeFamilyNotifier<CommunityDetailsState, CommunityModel> {
  final CommunityRepository repository = CommunityRepository();
  late CommunityMentionController textController;

  PaginationParams<CommunityModel> get detailsParams {
    return PaginationParams<CommunityModel>(
      collection: CommunityRepository.collectionName,
      identifier: 'comments_${arg.id}',
      databaseName: PizzacornCommunityConfig.databaseName,
      limit: PizzacornCommunityConfig.paginationSize,
      fromJson: (data) => CommunityModel.fromJson(data),
      itemFilter: (communityModel) =>
          !PizzacornCommunityConfig.isPostBlocked(communityModel),
      query: (query) => query
          .where('hidden', isEqualTo: false)
          .where('type', isEqualTo: CommunityType.comment.name)
          .where('secondaryId', isEqualTo: arg.id)
          .orderBy('createdAt', descending: true),
    );
  }

  @override
  CommunityDetailsState build(CommunityModel arg) {
    textController = CommunityMentionController();
    ref.onDispose(textController.dispose);
    return CommunityDetailsState(communityModel: arg);
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

  Future<void> saveComment({required BuildContext context}) async {
    final String text = textController.text.trim();
    if (text.isEmpty && state.images.isEmpty && state.pollOptions.isEmpty && state.attachment == null) return;
    if (state.pollOptions.isNotEmpty &&
        (state.pollOptions.length < 2 ||
            state.pollOptions.any((option) => option.trim().isEmpty))) {
      state = state.copyWith(isError: 'Escribe al menos dos opciones para la encuesta.');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, isError: '');
      final CommunityUploadedMedia uploadedMedia = state.images.isEmpty
          ? CommunityUploadedMedia(media: [], mediaThumbnails: [])
          : await ref
                .read(communityMediaServiceProvider)
                .uploadImageVariants(
                  images: state.images,
                  folder: 'community_comments',
                );
      final CommunityModel saved = await repository.save(
        communityModel: CommunityModel(
          type: CommunityType.comment,
          text: text,
          mentionIds: textController.mentionIds,
          media: uploadedMedia.media,
          mediaThumbnails: uploadedMedia.mediaThumbnails,
          pollOptions: state.pollOptions.map((option) => option.trim()).toList(),
          pollCounts: List<int>.filled(state.pollOptions.length, 0),
          attachment: state.attachment,
          secondaryId: state.communityModel.id,
          secondaryReplyTo: state.communityModel.userUsername,
          secondaryReplyToId: state.communityModel.userId,
        ),
        isComment: true,
      );
      textController.clear();
      state = state.copyWith(images: [], pollOptions: [], clearAttachment: true);
      if (context.mounted) FocusScope.of(context).unfocus();
      state = state.copyWith(
        communityModel: state.communityModel.copyWith(
          commentsCount: state.communityModel.commentsCount + 1,
        ),
      );
      ref.read(communityControllerProvider.notifier)
        ..updateLocally(
          communityModel: saved,
          params: detailsParams,
          isAddition: true,
        )
        ..updateLocally(
          communityModel: state.communityModel,
          params: communityParams,
        );
      ref.invalidate(postCountersFirebaseProvider(state.communityModel.id));
    } catch (error) {
      state = state.copyWith(isError: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
