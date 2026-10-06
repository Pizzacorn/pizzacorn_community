import 'package:community_example/config/imports.dart';

class SessionState {
  final bool isLoading;
  final String isError;
  final CommunityUserModel? userModel;

  SessionState({this.isLoading = false, this.isError = '', this.userModel});

  SessionState copyWith({
    bool? isLoading,
    String? isError,
    CommunityUserModel? userModel,
    bool clearUser = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      userModel: clearUser ? null : userModel ?? this.userModel,
    );
  }
}
