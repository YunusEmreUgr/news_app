import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            CustomCard(
              backgroundColor: theme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kurumsal Frontend Template',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clean Architecture, JWT Auth, Design System & Auto Refresh Interceptor hazır.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oturum & Yetkiler (Claims)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.security, color: theme.primaryColor),
                    ),
                    title: const Text('Aktif Oturum'),
                    subtitle: Text(
                      authProvider.isAuthenticated
                          ? 'Oturum Açık (Token Aktif)'
                          : 'Misafir',
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kullanıcı Claims/Roller:',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        if (authProvider.userClaims.isEmpty)
                          const Text('Henüz atanmış bir claim bulunmuyor.')
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: authProvider.userClaims
                                .map((claim) => Chip(
                                      label: Text(claim),
                                      backgroundColor:
                                          theme.primaryColor.withValues(alpha: 0.1),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hızlı İşlemler',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 32, color: theme.primaryColor),
                        const SizedBox(height: 8),
                        const Text('Ürün Kataloğu'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 32, color: theme.primaryColor),
                        const SizedBox(height: 8),
                        const Text('Profilim'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Column(
                      children: [
                        Icon(Icons.tune, size: 32, color: theme.primaryColor),
                        const SizedBox(height: 8),
                        const Text('Ayarlar'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
