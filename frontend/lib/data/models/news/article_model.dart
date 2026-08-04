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
}
