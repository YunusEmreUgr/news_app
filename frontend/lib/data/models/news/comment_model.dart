class CommentModel {
  final int id;
  final int articleId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.articleId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? json['Id'] ?? 0,
      articleId: json['articleId'] ?? json['ArticleId'] ?? 0,
      userName: json['userName'] ?? json['UserName'] ?? 'Kullanıcı',
      content: json['content'] ?? json['Content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'userName': userName,
      'content': content,
    };
  }
}
