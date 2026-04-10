import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/requestmodel/post.dart';
import '../models/responsemodel/post.dart';

class PostService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<PostPageResponse> getAllPosts(int skip, int limit) async {
    try {
      final res = await dio.get(
        '/post',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return PostPageResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<CreatePostResponse> createPost(CreatePostRequest request) async {
    final formData = FormData();
    // Text fields
    formData.fields
      ..add(MapEntry('userId', request.userId))
      ..add(MapEntry('userModel', request.userModel))
      ..add(MapEntry('content', request.content));

    // Media files
    for (final path in request.mediaPaths) {
      final file = File(path);
      final fileName = file.uri.pathSegments.last;
      final mimeType = _getMimeType(fileName);

      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            path,
            filename: fileName,
            contentType: DioMediaType.parse(mimeType),
          ),
        ),
      );
    }

    final response = await dio.post('/post/create', data: formData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreatePostResponse.fromJson(response.data);
    }

    throw Exception('Create post failed: ${response.statusCode}');
  }

  Future<PostPageResponse> getPostByUserId(
    String userId,
    int skip,
    int limit,
  ) async {
    try {
      final res = await dio.get(
        '/post/get-by-user-id/$userId',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return PostPageResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
    };
    return map[ext] ?? 'application/octet-stream';
  }

  Future<GetCommentPageResponse> getCommentByPostId(
    String postId,
    int skip,
    int limit,
  ) async {
    try {
      final res = await dio.get(
        '/post/$postId/comment/get',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      if (res.statusCode == 200) {
        return GetCommentPageResponse.fromJson(res.data);
      } else {
        throw Exception('Failed to load comments: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  Future<CreateCommentPostResponse> createCommentByPostId(
    String postId,
    CreateCommentPostRequest request,
  ) async {
    try {
      final res = await dio.post(
        '/post/$postId/comment/create',
        //  Chuyển object request thành JSON để gửi trong Body
        data: request.toJson(),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return CreateCommentPostResponse.fromJson(res.data);
      } else {
        throw Exception('Failed to create comment: ${res.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode} - ${e.response?.data}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error creating comment: $e');
    }
  }

  Future<void> updateCommentById(
    String commentId,
    CreateCommentPostRequest request,
  ) async {
    try {
      final res = await dio.patch(
        '/post/$commentId/comment/update',
        data: request.toJson(),
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to update comment: ${res.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode} - ${e.response?.data}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error updating comment: $e');
    }
  }

  Future<void> deleteCommentById(String commentId) async {
    try {
      final res = await dio.delete('/post/$commentId/comment/delete');

      if (res.statusCode == 200 || res.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete comment: ${res.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode} - ${e.response?.data}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }
}
