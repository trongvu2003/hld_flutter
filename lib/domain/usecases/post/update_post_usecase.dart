import '../../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<void> call({
    required String postId,
    String? content,
    List<String>? mediaPaths,
    List<String>? imagePaths,
  }) {
    return repository.updatePost(
      postId: postId,
      content: content,
      mediaPaths: mediaPaths,
      imagePaths: imagePaths,
    );
  }
}
