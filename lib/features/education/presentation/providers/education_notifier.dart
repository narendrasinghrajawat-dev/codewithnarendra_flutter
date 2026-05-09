import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_education_usecase.dart';
import '../../domain/usecases/create_education_usecase.dart';
import '../../domain/usecases/update_education_usecase.dart';
import '../../domain/usecases/delete_education_usecase.dart';
import 'education_state.dart';

class EducationNotifier extends StateNotifier<EducationState> {
  final GetEducationUseCase _getEducationUseCase;
  final CreateEducationUseCase _createEducationUseCase;
  final UpdateEducationUseCase _updateEducationUseCase;
  final DeleteEducationUseCase _deleteEducationUseCase;

  EducationNotifier({
    required GetEducationUseCase getEducationUseCase,
    required CreateEducationUseCase createEducationUseCase,
    required UpdateEducationUseCase updateEducationUseCase,
    required DeleteEducationUseCase deleteEducationUseCase,
  })  : _getEducationUseCase = getEducationUseCase,
        _createEducationUseCase = createEducationUseCase,
        _updateEducationUseCase = updateEducationUseCase,
        _deleteEducationUseCase = deleteEducationUseCase,
        super(const EducationState(status: EducationStatus.initial));

  Future<void> getEducation() async {
    state = state.copyWith(status: EducationStatus.loading);
    
    try {
      final educationList = await _getEducationUseCase();
      state = state.copyWith(
        status: EducationStatus.loaded,
        educationList: educationList,
      );
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createEducation(Map<String, dynamic> data) async {
    state = state.copyWith(status: EducationStatus.loading);
    
    try {
      await _createEducationUseCase(data);
      // Refresh education list after creating
      await getEducation();
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateEducation(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: EducationStatus.loading);
    
    try {
      await _updateEducationUseCase(id, data);
      // Refresh education list after updating
      await getEducation();
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteEducation(String id) async {
    state = state.copyWith(status: EducationStatus.loading);
    
    try {
      await _deleteEducationUseCase(id);
      // Refresh education list after deleting
      await getEducation();
    } catch (e) {
      state = state.copyWith(
        status: EducationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectEducation(Map<String, dynamic> education) {
    state = state.copyWith(selectedEducation: education);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
