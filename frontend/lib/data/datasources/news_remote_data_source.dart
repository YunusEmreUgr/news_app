import '../../core/network/dio_client.dart';
import '../models/news/article_model.dart';
import '../models/news/category_model.dart';
import '../models/news/comment_model.dart';

class NewsRemoteDataSource {
  final DioClient _dioClient;

  NewsRemoteDataSource(this._dioClient);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get('/categories');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<ArticleModel>> getAllArticles() async {
    final response = await _dioClient.get('/articles');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<ArticleModel>> getArticlesByCategory(int categoryId) async {
    final response = await _dioClient.get('/articles/category/$categoryId');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<ArticleModel>> getBreakingNews() async {
    final response = await _dioClient.get('/articles/breaking');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<ArticleModel>> getFeaturedNews() async {
    final response = await _dioClient.get('/articles/featured');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<ArticleModel>> searchArticles(String query) async {
    final response = await _dioClient.get('/articles/search', queryParameters: {'q': query});
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<ArticleModel?> getArticleById(int id) async {
    final response = await _dioClient.get('/articles/$id');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data != null && data is Map) {
      return ArticleModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<bool> addArticle({
    required String title,
    required String summary,
    required String content,
    required String coverImageUrl,
    required int categoryId,
    required String authorName,
    required bool isBreaking,
    required bool isFeatured,
  }) async {
    final response = await _dioClient.post('/articles', data: {
      'title': title,
      'summary': summary,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'categoryId': categoryId,
      'authorName': authorName,
      'isBreaking': isBreaking,
      'isFeatured': isFeatured,
    });
    return response['success'] == true;
  }

  Future<List<CommentModel>> getComments(int articleId) async {
    final response = await _dioClient.get('/comments/article/$articleId');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<bool> addComment(int articleId, String userName, String content) async {
    final response = await _dioClient.post('/comments', data: {
      'articleId': articleId,
      'userName': userName,
      'content': content,
    });
    return response['success'] == true;
  }

  Future<List<ArticleModel>> getBookmarks(int userId) async {
    final response = await _dioClient.get('/bookmarks/user/$userId');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<bool> toggleBookmark(int userId, int articleId) async {
    final response = await _dioClient.post('/bookmarks/toggle', queryParameters: {
      'userId': userId,
      'articleId': articleId,
    });
    return response['success'] == true;
  }

  Future<bool> isBookmarked(int userId, int articleId) async {
    final response = await _dioClient.get('/bookmarks/check', queryParameters: {
      'userId': userId,
      'articleId': articleId,
    });
    final data = response.containsKey('data') ? response['data'] : false;
    return data == true;
  }

  Future<void> incrementViewCount(int articleId) async {
    try {
      await _dioClient.post('/articles/$articleId/view');
    } catch (_) {}
  }

  Future<void> incrementLikeCount(int articleId) async {
    try {
      await _dioClient.post('/articles/$articleId/like');
    } catch (_) {}
  }
}
