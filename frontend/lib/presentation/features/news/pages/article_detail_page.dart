import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_template/presentation/providers/news_provider.dart';
import 'package:frontend_template/presentation/providers/auth_provider.dart';
import 'package:frontend_template/presentation/providers/user_provider.dart';
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
  final Set<int> _reportedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _likeCount = widget.article.likeCount;
    _viewCount = widget.article.viewCount + 1; // Increment locally immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = context.read<NewsProvider>();
      newsProvider.loadComments(widget.article.id);
      newsProvider.incrementViewCount(widget.article.id);

      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        final userProvider = context.read<UserProvider>();
        if (userProvider.profile != null) {
          _nameController.text = '${userProvider.profile!.firstName} ${userProvider.profile!.lastName}';
        } else {
          userProvider.fetchProfile().then((_) {
            if (userProvider.profile != null) {
              _nameController.text = '${userProvider.profile!.firstName} ${userProvider.profile!.lastName}';
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showTTSPlayerBottomSheet(BuildContext context) {
    double speed = 1.0;
    bool isPlaying = true;
    double progress = 0.2;
    Timer? eqTimer;
    List<double> heights = [10, 22, 14, 30, 18, 25, 12];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (isPlaying && eqTimer == null) {
              eqTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
                if (sheetContext.mounted) {
                  setSheetState(() {
                    for (int i = 0; i < heights.length; i++) {
                      heights[i] = 5.0 + (10.0 + (i % 2 == 0 ? 15.0 : 25.0) * (timer.tick % 3 == 0 ? 0.3 : 0.8));
                    }
                    progress = (progress + 0.01) % 1.0;
                  });
                }
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Haber Sesli Okuyucu',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  
                  // Equalizer Animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(heights.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: isPlaying ? heights[index] : 8.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Slider Progress
                  Slider(
                    value: progress,
                    activeColor: const Color(0xFFEF4444),
                    inactiveColor: Colors.white10,
                    onChanged: (val) {
                      setSheetState(() {
                        progress = val;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 4).toStringAsFixed(1)} dk',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const Text(
                        '4.0 dk',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setSheetState(() {
                            if (speed == 1.0) {
                              speed = 1.5;
                            } else if (speed == 1.5) {
                              speed = 2.0;
                            } else {
                              speed = 1.0;
                            }
                          });
                        },
                        child: Text('${speed}x', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFEF4444),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            setSheetState(() {
                              isPlaying = !isPlaying;
                              if (!isPlaying) {
                                eqTimer?.cancel();
                                eqTimer = null;
                              }
                            });
                          },
                        ),
                      ),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          eqTimer?.cancel();
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('Durdur', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      eqTimer?.cancel();
    });
  }

  void _showReportCommentDialog(int commentId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Yorumu Bildir', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'Spam / Reklam',
              'Nefret Söylemi veya Hakaret',
              'Taciz / Zorbalık',
              'Yanıltıcı / Yanlış Bilgi'
            ].map((reason) => ListTile(
              dense: true,
              title: Text(reason, style: const TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() {
                  _reportedCommentIds.add(commentId);
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildiriminiz moderatör ekibine iletildi. Yorum incelemeye alındı.')),
                );
              },
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.white38)),
            ),
          ],
        );
      },
    );
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
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    if (!authProvider.isAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Haberleri favorilere eklemek için Giriş yapmalısınız.'),
                          action: SnackBarAction(
                            label: 'Giriş Yap',
                            textColor: const Color(0xFFEF4444),
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                          ),
                        ),
                      );
                      return;
                    }
                    newsProvider.toggleBookmark(widget.article);
                  },
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
                  const SizedBox(height: 12),
                  // TTS Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => _showTTSPlayerBottomSheet(context),
                    icon: const Icon(Icons.volume_up_outlined, size: 20),
                    label: const Text('Haberin Sesli Sürümünü Dinle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                  const SizedBox(height: 24),
                  // Tags List
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#haber',
                      '#${widget.article.category?.slug ?? 'gundem'}',
                      '#sondakika',
                      '#gelismeler'
                    ].map((tag) => ActionChip(
                      backgroundColor: const Color(0xFF1E293B),
                      side: const BorderSide(color: Colors.white10),
                      label: Text(tag, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$tag etiketindeki diğer haberler aranıyor...')),
                        );
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Correction Box (Mocked)
                  if (widget.article.id % 2 == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'DÜZELTME VE GÜNCELLEME',
                                style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Bu haber yasal doğruluk standartları kapsamında güncellenmiş ve son gelişmeler eklenmiştir.',
                            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  
                  // Agency Copyright Info
                  Row(
                    children: const [
                      Icon(Icons.copyright, color: Colors.white30, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Kaynak: Anadolu Ajansı (AA) - Tüm Hakları Saklıdır.',
                        style: TextStyle(color: Colors.white30, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
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
                              
                              // Küfür / Hakaret Filtresi (Pre-filter)
                              final List<String> badWords = ['salak', 'aptal', 'bok', 'gerizekalı'];
                              bool containsBadWord = false;
                              for (var word in badWords) {
                                if (comment.toLowerCase().contains(word)) {
                                  containsBadWord = true;
                                  break;
                                }
                              }
                              
                              if (containsBadWord) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Yorumunuz topluluk kurallarını ihlal eden kelimeler içermektedir.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

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
                              Row(
                                children: [
                                  Text(
                                    c.userName,
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (c.userName == 'admin@template.com' || c.userName == 'Admin' || c.userName.toLowerCase().contains('editör'))
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFEF4444), width: 0.5),
                                      ),
                                      child: const Text(
                                        'Editör 💎',
                                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(c.createdAt),
                                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                  if (!_reportedCommentIds.contains(c.id))
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.only(left: 8),
                                      icon: const Icon(Icons.report_problem_outlined, color: Colors.white24, size: 16),
                                      tooltip: 'Yorumu Bildir',
                                      onPressed: () => _showReportCommentDialog(c.id),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _reportedCommentIds.contains(c.id)
                                ? '[Bu yorum bildirildiği için moderasyon incelemesindedir]'
                                : c.content,
                            style: TextStyle(
                              color: _reportedCommentIds.contains(c.id) ? Colors.white30 : Colors.white70,
                              fontSize: 13,
                              fontStyle: _reportedCommentIds.contains(c.id) ? FontStyle.italic : FontStyle.normal,
                            ),
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
