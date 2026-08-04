import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_template/presentation/providers/news_provider.dart';
import 'package:frontend_template/presentation/providers/auth_provider.dart';
import 'package:frontend_template/data/models/news/article_model.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'article_detail_page.dart';
import 'bookmarks_page.dart';
import 'publish_news_page.dart';

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().initNews();
    });
  }

  void _navigateToPublish() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Haber yayınlayabilmek için Giriş yapmalısınız.'),
          action: SnackBarAction(
            label: 'Giriş Yap',
            textColor: const Color(0xFFEF4444),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PublishNewsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HABERİM',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SON DAKİKA',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            tooltip: 'Favori Haberler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksPage()),
              );
            },
          ),
          if (authProvider.canPublish)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
              tooltip: 'Haber Ekle',
              onPressed: _navigateToPublish,
            ),
        ],
      ),
      body: Column(
        children: [
          if (newsProvider.isOffline)
            Container(
              width: double.infinity,
              color: const Color(0xFFD97706),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Çevrimdışı Mod - Önbellekten Okunuyor',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          Expanded(
            child: newsProvider.isLoading
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SkeletonLoader.categories(),
                        SkeletonLoader.headline(),
                        SkeletonLoader.newsList(),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => newsProvider.initNews(),
                    color: const Color(0xFFEF4444),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          _buildSearchBar(newsProvider),

                          // Breaking News Ticker
                          if (newsProvider.breakingNews.isNotEmpty)
                            _buildBreakingNewsTicker(newsProvider.breakingNews),

                          // Featured Carousel
                          if (newsProvider.featuredNews.isNotEmpty)
                            _buildFeaturedSection(newsProvider.featuredNews),

                          // Category Filter Chips
                          _buildCategoryFilter(newsProvider),

                          // Articles Section Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  newsProvider.selectedCategory?.name ?? 'En Son Haberler',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${newsProvider.articles.length} Haber',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // Articles List
                          if (newsProvider.articles.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'Bu kategoride henüz haber bulunmuyor.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: newsProvider.articles.length,
                              itemBuilder: (context, index) {
                                final article = newsProvider.articles[index];
                                return _buildArticleCard(context, article, newsProvider);
                              },
                            ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: authProvider.canPublish
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFEF4444),
              onPressed: _navigateToPublish,
              icon: const Icon(Icons.create, color: Colors.white),
              label: const Text('Haber Yayınla', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildSearchBar(NewsProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.white54),
          hintText: 'Haber başlığı veya içerik ara...',
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    provider.search('');
                  },
                )
              : null,
        ),
        onChanged: (val) {
          provider.search(val);
        },
      ),
    );
  }

  Widget _buildBreakingNewsTicker(List<ArticleModel> breakingArticles) {
    final article = breakingArticles.first;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF450A0A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'FLAŞ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                article.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(List<ArticleModel> featured) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 12, bottom: 8),
          child: Text(
            'Öne Çıkan Manşetler',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final item = featured[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ArticleDetailPage(article: item)),
                  );
                },
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                      image: NetworkImage(item.coverImageUrl ?? 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category!.name,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(NewsProvider provider) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 14),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: 'Tümü',
            isSelected: provider.selectedCategory == null,
            onTap: () => provider.selectCategory(null),
          ),
          ...provider.categories.map(
            (cat) => _buildChip(
              label: cat.name,
              isSelected: provider.selectedCategory?.id == cat.id,
              onTap: () => provider.selectCategory(cat),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article, NewsProvider provider) {
    final isBookmarked = provider.isArticleBookmarked(article.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.coverImageUrl ?? 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[800],
                  child: const Icon(Icons.newspaper, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.category?.name ?? 'Haber',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? const Color(0xFFEF4444) : Colors.white38,
                          size: 20,
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
                          provider.toggleBookmark(article);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text('${article.viewCount}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text('${article.likeCount}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
