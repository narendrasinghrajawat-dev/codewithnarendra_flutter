import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_about_usecase.dart';
import '../../domain/usecases/create_about_usecase.dart';
import '../../domain/usecases/update_about_usecase.dart';
import '../../domain/usecases/delete_about_usecase.dart';
import 'about_state.dart';

class AboutNotifier extends StateNotifier<AboutState> {
  final GetAboutUseCase _getAboutUseCase;
  final CreateAboutUseCase _createAboutUseCase;
  final UpdateAboutUseCase _updateAboutUseCase;
  final DeleteAboutUseCase _deleteAboutUseCase;

  AboutNotifier({
    required GetAboutUseCase getAboutUseCase,
    required CreateAboutUseCase createAboutUseCase,
    required UpdateAboutUseCase updateAboutUseCase,
    required DeleteAboutUseCase deleteAboutUseCase,
  }) : _getAboutUseCase = getAboutUseCase,
       _createAboutUseCase = createAboutUseCase,
       _updateAboutUseCase = updateAboutUseCase,
       _deleteAboutUseCase = deleteAboutUseCase,
       super(const AboutState(status: AboutStatus.initial));

  Future<void> getAbout() async {
    state = state.copyWith(status: AboutStatus.loading);
    
    try {
      final about = await _getAboutUseCase();
      state = state.copyWith(
        status: AboutStatus.loaded,
        about: about,
      );
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createAbout(Map<String, dynamic> data) async {
    state = state.copyWith(status: AboutStatus.loading);
    
    try {
      await _createAboutUseCase(data);
      await getAbout();
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateAbout(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: AboutStatus.loading);
    
    try {
      await _updateAboutUseCase(id, data);
      await getAbout();
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteAbout(String id) async {
    state = state.copyWith(status: AboutStatus.loading);

    try {
      await _deleteAboutUseCase(id);
      await getAbout();
    } catch (e) {
      state = state.copyWith(
        status: AboutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
