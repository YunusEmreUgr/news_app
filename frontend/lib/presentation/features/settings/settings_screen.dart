import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _breakingNewsNotifications = true;
  bool _dailyDigestNotifications = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Uygulama Ayarları', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Görünüm & Tema', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              activeThumbColor: const Color(0xFFEF4444),
              secondary: const Icon(Icons.dark_mode_outlined, color: Colors.white),
              title: const Text('Koyu Tema (Dark Mode)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Göz yormayan koyu arayüz', style: TextStyle(color: Colors.white38, fontSize: 11)),
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('Bildirim Tercihleri', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: const Color(0xFFEF4444),
                  secondary: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                  title: const Text('Son Dakika Bildirimleri', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Flaş ve önemli haber uyarıları', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: _breakingNewsNotifications,
                  onChanged: (val) => setState(() => _breakingNewsNotifications = val),
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  activeThumbColor: const Color(0xFFEF4444),
                  secondary: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
                  title: const Text('Günlük Özet Bülten', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Günün öne çıkan gelişmeleri', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: _dailyDigestNotifications,
                  onChanged: (val) => setState(() => _dailyDigestNotifications = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Genel', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: Colors.white),
                  title: const Text('Uygulama Dili', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Türkçe (TR)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {},
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: Colors.white),
                  title: const Text('Önbelleği Temizle', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Görsel ve veri önbelleğini boşaltır', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Uygulama önbelleği temizlendi.')),
                    );
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.white),
                  title: Text('Hakkında', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Haberim Enterprise Edition v1.2.0', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
