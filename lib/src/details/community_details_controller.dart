import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityDetailsState {
  final bool isLoading;
  final String isError;
  final CommunityModel communityModel;
  final List<XFile> images;

  CommunityDetailsState({
    this.isLoading = false,
    this.isError = '',
    CommunityModel? communityModel,
    this.images = const [],
  }) : communityModel = communityModel ?? CommunityModel();

  CommunityDetailsState copyWith({
    bool? isLoading,
    String? isError,
    CommunityModel? communityModel,
    List<XFile>? images,
  }) {
    return CommunityDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      communityModel: communityModel ?? this.communityModel,
      images: images ?? this.images,
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
  late TextEditingController textController;

  PaginationParams<CommunityModel> get detailsParams {
    return PaginationParams<CommunityModel>(
      collection: CommunityRepository.collectionName,
      identifier: 'comments_${arg.id}',
      databaseName: PizzacornCommunityConfig.databaseName,
      limit: PizzacornCommunityConfig.paginationSize,
      fromJson: (data) => CommunityModel.fromJson(data),
      query: (query) => query
          .where('hidden', isEqualTo: false)
          .where('type', isEqualTo: CommunityType.comment.name)
          .where('secondaryId', isEqualTo: arg.id)
          .orderBy('createdAt', descending: true),
    );
  }

  @override
  CommunityDetailsState build(CommunityModel arg) {
    textController = TextEditingController();
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

  Future<void> saveComment({required BuildContext context}) async {
    final String text = textController.text.trim();
    if (text.isEmpty && state.images.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, isError: '');
      final List<String> urls = state.images.isEmpty
          ? []
          : await ref
                .read(communityMediaServiceProvider)
                .uploadImages(
                  images: state.images,
                  folder: 'community_comments',
                );
      final CommunityModel saved = await repository.save(
        communityModel: CommunityModel(
          type: CommunityType.comment,
          text: text,
          media: urls,
          secondaryId: state.communityModel.id,
          secondaryReplyTo: state.communityModel.userUsername,
          secondaryReplyToId: state.communityModel.userId,
        ),
        isComment: true,
      );
      textController.clear();
      state = state.copyWith(images: []);
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
