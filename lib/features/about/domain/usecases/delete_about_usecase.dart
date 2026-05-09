import '../repositories/about_repository.dart';

class DeleteAboutUseCase {
  final AboutRepository _repository;

  DeleteAboutUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteAbout(id);
  }
}
