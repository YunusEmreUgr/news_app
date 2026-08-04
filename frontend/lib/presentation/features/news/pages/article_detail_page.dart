import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_template/presentation/providers/news_provider.dart';
import 'package:frontend_template/presentation/providers/auth_provider.dart';
import 'package:frontend_template/data/models/news/article_model.dart';
import 'package:intl/intl.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  double _fontSize = 16.0;

  late int _likeCount;
  late int _viewCount;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.article.likeCount;
    _viewCount = widget.article.viewCount + 1; // Increment locally immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = context.read<NewsProvider>();
      newsProvider.loadComments(widget.article.id);
      newsProvider.incrementViewCount(widget.article.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isBookmarked = newsProvider.isArticleBookmarked(widget.article.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? const Color(0xFFEF4444) : Colors.white,
                  ),
                  onPressed: () => newsProvider.toggleBookmark(widget.article),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.article.coverImageUrl ?? 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF0F172A).withValues(alpha: 0.9)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date & Font Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.article.category?.name ?? 'Gündem',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease, color: Colors.white70),
                            onPressed: () {
                              if (_fontSize > 12) setState(() => _fontSize -= 2);
                            },
                          ),
                          Text('${_fontSize.toInt()}pt', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          IconButton(
                            icon: const Icon(Icons.text_increase, color: Colors.white70),
                            onPressed: () {
                              if (_fontSize < 24) setState(() => _fontSize += 2);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Article Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author & Date Info Bar with View/Like info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFEF4444),
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.authorName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(widget.article.publishedAt),
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, color: Colors.white38, size: 16),
                          const SizedBox(width: 4),
                          Text('$_viewCount', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () {
                              if (_isLiked) return;
                              setState(() {
                                _isLiked = true;
                                _likeCount++;
                              });
                              newsProvider.incrementLikeCount(widget.article.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Haber beğenildi!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isLiked ? const Color(0xFFEF4444).withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isLiked ? const Color(0xFFEF4444) : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: _isLiked ? const Color(0xFFEF4444) : Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$_likeCount', style: TextStyle(
                                    color: _isLiked ? const Color(0xFFEF4444) : Colors.white54,
                                    fontSize: 12,
                                    fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 32),

                  // Summary Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.article.summary,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: _fontSize,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Article Content Text
                  Text(
                    widget.article.content,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: _fontSize,
                      height: 1.6,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 40),

                  // Comments Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Yorumlar',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${newsProvider.currentArticleComments.length} Yorum',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Add Comment Box with Auth Check
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!authProvider.isAuthenticated)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Yorum yapabilmek için lütfen oturum açınız.',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/login'),
                                  child: const Text('Giriş Yap', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        TextField(
                          controller: _nameController,
                          enabled: authProvider.isAuthenticated,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Adınız Soyadınız',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(color: Colors.white10),
                        TextField(
                          controller: _commentController,
                          enabled: authProvider.isAuthenticated,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Düşüncelerinizi paylaşın...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            onPressed: () async {
                              if (!authProvider.isAuthenticated) {
                                Navigator.pushNamed(context, '/login');
                                return;
                              }
                              final name = _nameController.text.trim();
                              final comment = _commentController.text.trim();
                              if (comment.isNotEmpty) {
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await newsProvider.addComment(
                                  widget.article.id,
                                  name.isEmpty ? 'Okur' : name,
                                  comment,
                                );
                                if (success) {
                                  _commentController.clear();
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Yorumunuz gönderildi!')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.send, size: 16, color: Colors.white),
                            label: const Text('Gönder', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comment List
                  ...newsProvider.currentArticleComments.map(
                    (c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c.userName,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                DateFormat('HH:mm').format(c.createdAt),
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.content,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
