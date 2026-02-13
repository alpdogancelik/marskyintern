import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/settings_models.dart';
import '../domain/repositories/settings_repositories.dart';

class ProfileState {
  const ProfileState({
    required this.profile,
    this.isSaving = false,
    this.errorMessage,
  });

  final UserProfile profile;
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isSaving,
    Object? errorMessage = _sentinel,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileState>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository)..load();
});

class ProfileController extends StateNotifier<AsyncValue<ProfileState>> {
  ProfileController(this._repository) : super(const AsyncLoading());

  final ProfileRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = await _repository.getProfile();
      return ProfileState(profile: profile);
    });
  }

  Future<bool> save(UserProfile nextProfile) async {
    final current = state.valueOrNull;
    if (current == null) {
      return false;
    }

    state = AsyncData(current.copyWith(isSaving: true, errorMessage: null));
    try {
      await _repository.saveProfile(nextProfile);
      state = AsyncData(
        current.copyWith(
          profile: nextProfile,
          isSaving: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }
}
