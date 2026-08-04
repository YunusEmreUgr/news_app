import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showForceUpdate = false;
  bool _showMaintenance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    bool hasRouted = false;
    
    // Timeout guard: 4 saniye sonra her halükarda ana sayfaya ilerlet (fallback)
    final timeoutTimer = Timer(const Duration(seconds: 4), () {
      if (!hasRouted && mounted) {
        hasRouted = true;
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus();
      
      final prefs = await SharedPreferences.getInstance();
      
      // Test simülatörü ayarları
      final forceUpdate = prefs.getBool('simulateForceUpdate') ?? false;
      final maintenance = prefs.getBool('simulateMaintenance') ?? false;
      
      if (forceUpdate) {
        timeoutTimer.cancel();
        if (mounted) {
          setState(() {
            _showForceUpdate = true;
          });
        }
        return;
      }
      
      if (maintenance) {
        timeoutTimer.cancel();
        if (mounted) {
          setState(() {
            _showMaintenance = true;
          });
        }
        return;
      }

      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted || hasRouted) return;
      
      hasRouted = true;
      timeoutTimer.cancel();
      
      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (_) {
      if (!hasRouted && mounted) {
        hasRouted = true;
        timeoutTimer.cancel();
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForceUpdate) {
      return _buildBlockingScreen(
        icon: Icons.system_update_outlined,
        color: const Color(0xFFEF4444),
        title: 'GÜNCELLEME GEREKLİ',
        subtitle: 'Uygulamanın bu sürümü artık desteklenmiyor. Devam edebilmek için lütfen en son sürüme güncelleyin.',
        buttonText: 'Şimdi Güncelle',
        onPressed: () {
          // Mock market link trigger
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uygulama mağazasına yönlendiriliyorsunuz...')),
          );
        },
      );
    }

    if (_showMaintenance) {
      return _buildBlockingScreen(
        icon: Icons.build_circle_outlined,
        color: const Color(0xFFF59E0B),
        title: 'PLANLI BAKIM',
        subtitle: 'Sizlere daha iyi bir deneyim sunabilmek için sistemlerimizde bakım çalışması yapıyoruz. Lütfen daha sonra tekrar deneyin.',
        buttonText: 'Destek Talebi',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destek hattına bağlanılıyor...')),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper,
                size: 72,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'HABERİM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Son Dakika ve Güncel Gelişmeler',
              style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockingScreen({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
