import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';
import '../news/pages/news_home_page.dart';
import '../news/pages/bookmarks_page.dart';
import '../profile/profile_screen.dart';

class MainDashboardShell extends StatefulWidget {
  const MainDashboardShell({super.key});

  @override
  State<MainDashboardShell> createState() => _MainDashboardShellState();
}

class _MainDashboardShellState extends State<MainDashboardShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NewsHomePage(),
    const BookmarksPage(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-check auth status on app start
      final authProvider = context.read<AuthProvider>();
      authProvider.checkAuthStatus().then((_) {
        if (!mounted) return;
        // Sync userId to NewsProvider after auth check
        final newsProvider = context.read<NewsProvider>();
        newsProvider.setCurrentUserId(authProvider.userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NewsProvider>().setCurrentUserId(authProvider.userId);
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFFEF4444),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'Haberler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Favoriler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
