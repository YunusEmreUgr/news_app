import 'category_model.dart';

class ArticleModel {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String? coverImageUrl;
  final int categoryId;
  final String authorName;
  final int viewCount;
  final int likeCount;
  final bool isBreaking;
  final bool isFeatured;
  final DateTime publishedAt;
  final CategoryModel? category;

  ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.coverImageUrl,
    required this.categoryId,
    required this.authorName,
    required this.viewCount,
    required this.likeCount,
    required this.isBreaking,
    required this.isFeatured,
    required this.publishedAt,
    this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? json['Id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      summary: json['summary'] ?? json['Summary'] ?? '',
      content: json['content'] ?? json['Content'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? json['CoverImageUrl'] ?? json['cover_image_url'],
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      authorName: json['authorName'] ?? json['AuthorName'] ?? 'Haberim Editörü',
      viewCount: json['viewCount'] ?? json['ViewCount'] ?? 0,
      likeCount: json['likeCount'] ?? json['LikeCount'] ?? 0,
      isBreaking: json['isBreaking'] ?? json['IsBreaking'] ?? false,
      isFeatured: json['isFeatured'] ?? json['IsFeatured'] ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'categoryId': categoryId,
      'authorName': authorName,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isBreaking': isBreaking,
      'isFeatured': isFeatured,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  ArticleModel copyWith({
    int? id,
    String? title,
    String? summary,
    String? content,
    String? coverImageUrl,
    int? categoryId,
    String? authorName,
    int? viewCount,
    int? likeCount,
    bool? isBreaking,
    bool? isFeatured,
    DateTime? publishedAt,
    CategoryModel? category,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categoryId: categoryId ?? this.categoryId,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isBreaking: isBreaking ?? this.isBreaking,
      isFeatured: isFeatured ?? this.isFeatured,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
    );
  }
}
