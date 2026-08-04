import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/init/service_locator.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/models/news/article_model.dart';
import '../../data/models/news/category_model.dart';
import '../../data/models/news/comment_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsRemoteDataSource _newsDataSource = getIt<NewsRemoteDataSource>();

  List<CategoryModel> _categories = [];
  List<ArticleModel> _articles = [];
  List<ArticleModel> _breakingNews = [];
  List<ArticleModel> _featuredNews = [];
  List<ArticleModel> _bookmarkedArticles = [];
  List<CommentModel> _currentArticleComments = [];
  
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';
  
  bool _isOfflineSimulated = false;
  bool _isOffline = false;

  List<CategoryModel> get categories => _categories;
  List<ArticleModel> get articles => _articles;
  List<ArticleModel> get breakingNews => _breakingNews;
  List<ArticleModel> get featuredNews => _featuredNews;
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  List<CommentModel> get currentArticleComments => _currentArticleComments;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get errorMessage => _errorMessage;
  bool get isOfflineSimulated => _isOfflineSimulated;
  bool get isOffline => _isOffline;

  /// Dynamic userId from AuthProvider — set externally after login
  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  void setCurrentUserId(int? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null) {
        _newsDataSource.getBookmarks(userId).then((bookmarks) {
          _bookmarkedArticles = bookmarks;
          notifyListeners();
        }).catchError((_) {
          _bookmarkedArticles = [];
          notifyListeners();
        });
      } else {
        _bookmarkedArticles = [];
        notifyListeners();
      }
    }
  }

  Future<void> initNews() async {
    _isLoading = true;
    _errorMessage = '';
    _isOffline = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isOfflineSimulated = prefs.getBool('simulateOfflineMode') ?? false;

      if (_isOfflineSimulated) {
        _isOffline = true;
        final cached = await _loadFromCache();
        _isLoading = false;
        if (!cached) {
          _errorMessage = 'Çevrimdışı mod simüle edildi ancak önbellek bulunamadı.';
        }
        notifyListeners();
        return;
      }

      // Load categories, articles, breaking, featured in parallel
      final results = await Future.wait([
        _newsDataSource.getCategories(),
        _newsDataSource.getAllArticles(),
        _newsDataSource.getBreakingNews(),
        _newsDataSource.getFeaturedNews(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _articles = results[1] as List<ArticleModel>;
      _breakingNews = results[2] as List<ArticleModel>;
      _featuredNews = results[3] as List<ArticleModel>;

      // Load bookmarks only if user is logged in
      if (_currentUserId != null) {
        try {
          _bookmarkedArticles = await _newsDataSource.getBookmarks(_currentUserId!);
        } catch (_) {
          _bookmarkedArticles = [];
        }
      } else {
        _bookmarkedArticles = [];
      }

      // Veriler başarıyla geldi, yerel önbelleğe kaydet
      await _saveToCache();
    } catch (e) {
      _isOffline = true;
      final cached = await _loadFromCache();
      if (!cached) {
        _errorMessage = 'Haberler yüklenirken hata oluştu ve çevrimdışı önbellek bulunamadı: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(CategoryModel? category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    if (_isOffline) {
      final prefs = await SharedPreferences.getInstance();
      final artStr = prefs.getString('cached_articles');
      if (artStr != null) {
        final List<dynamic> artJson = jsonDecode(artStr);
        final allArticles = artJson.map((json) => ArticleModel.fromJson(json)).toList();
        if (category == null) {
          _articles = allArticles;
        } else {
          _articles = allArticles.where((a) => a.categoryId == category.id).toList();
        }
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      if (category == null) {
        _articles = await _newsDataSource.getAllArticles();
      } else {
        _articles = await _newsDataSource.getArticlesByCategory(category.id);
      }
    } catch (e) {
      _errorMessage = 'Kategori haberleri yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      return selectCategory(_selectedCategory);
    }
    _isSearching = true;
    notifyListeners();

    try {
      _articles = await _newsDataSource.searchArticles(query);
    } catch (e) {
      _errorMessage = 'Arama yapılırken hata oluştu: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadComments(int articleId) async {
    try {
      _currentArticleComments = await _newsDataSource.getComments(articleId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addComment(int articleId, String userName, String content) async {
    final success = await _newsDataSource.addComment(articleId, userName, content);
    if (success) {
      await loadComments(articleId);
    }
    return success;
  }

  Future<void> toggleBookmark(ArticleModel article) async {
    final userId = _currentUserId ?? 1;
    final success = await _newsDataSource.toggleBookmark(userId, article.id);
    if (success) {
      _bookmarkedArticles = await _newsDataSource.getBookmarks(userId);
      notifyListeners();
    }
  }

  bool isArticleBookmarked(int articleId) {
    return _bookmarkedArticles.any((a) => a.id == articleId);
  }

  /// Increment article view count
  Future<void> incrementViewCount(int articleId) async {
    await _newsDataSource.incrementViewCount(articleId);
    _updateLocalViewCount(articleId);
  }

  /// Increment article like count  
  Future<void> incrementLikeCount(int articleId) async {
    await _newsDataSource.incrementLikeCount(articleId);
    _updateLocalLikeCount(articleId);
  }

  void _updateLocalViewCount(int articleId) {
    bool updated = false;
    for (var list in [_articles, _breakingNews, _featuredNews, _bookmarkedArticles]) {
      final index = list.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        list[index] = list[index].copyWith(viewCount: list[index].viewCount + 1);
        updated = true;
      }
    }
    if (updated) notifyListeners();
  }

  void _updateLocalLikeCount(int articleId) {
    bool updated = false;
    for (var list in [_articles, _breakingNews, _featuredNews, _bookmarkedArticles]) {
      final index = list.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        list[index] = list[index].copyWith(likeCount: list[index].likeCount + 1);
        updated = true;
      }
    }
    if (updated) notifyListeners();
  }

  Future<bool> publishNews({
    required String title,
    required String summary,
    required String content,
    required String coverImageUrl,
    required int categoryId,
    required String authorName,
    required bool isBreaking,
    required bool isFeatured,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _newsDataSource.addArticle(
      title: title,
      summary: summary,
      content: content,
      coverImageUrl: coverImageUrl,
      categoryId: categoryId,
      authorName: authorName,
      isBreaking: isBreaking,
      isFeatured: isFeatured,
    );

    if (success) {
      await initNews();
    } else {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_categories', jsonEncode(_categories.map((c) => c.toJson()).toList()));
      await prefs.setString('cached_articles', jsonEncode(_articles.map((a) => a.toJson()).toList()));
      await prefs.setString('cached_breakingNews', jsonEncode(_breakingNews.map((a) => a.toJson()).toList()));
      await prefs.setString('cached_featuredNews', jsonEncode(_featuredNews.map((a) => a.toJson()).toList()));
    } catch (e) {
      debugPrint('Önbellek kaydetme hatası: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final catStr = prefs.getString('cached_categories');
      final artStr = prefs.getString('cached_articles');
      final brkStr = prefs.getString('cached_breakingNews');
      final ftrStr = prefs.getString('cached_featuredNews');

      if (catStr != null && artStr != null) {
        final List<dynamic> catJson = jsonDecode(catStr);
        final List<dynamic> artJson = jsonDecode(artStr);
        final List<dynamic> brkJson = brkStr != null ? jsonDecode(brkStr) : [];
        final List<dynamic> ftrJson = ftrStr != null ? jsonDecode(ftrStr) : [];

        _categories = catJson.map((json) => CategoryModel.fromJson(json)).toList();
        _articles = artJson.map((json) => ArticleModel.fromJson(json)).toList();
        _breakingNews = brkJson.map((json) => ArticleModel.fromJson(json)).toList();
        _featuredNews = ftrJson.map((json) => ArticleModel.fromJson(json)).toList();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Önbellek okuma hatası: $e');
      return false;
    }
  }

  Future<void> toggleOfflineSimulation(bool value) async {
    _isOfflineSimulated = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('simulateOfflineMode', value);
    notifyListeners();
    await initNews();
  }
}
