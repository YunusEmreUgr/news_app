import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../providers/news_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _breakingNewsNotifications = true;
  bool _dailyDigestNotifications = true;
  bool _forceUpdateSim = false;
  bool _maintenanceSim = false;
  bool _dataSaver = false;
  String _silentHours = '23:00 - 08:00';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _forceUpdateSim = prefs.getBool('simulateForceUpdate') ?? false;
      _maintenanceSim = prefs.getBool('simulateMaintenance') ?? false;
      _dataSaver = prefs.getBool('dataSaverMode') ?? false;
      _silentHours = prefs.getString('silentHours') ?? '23:00 - 08:00';
    });
  }

  Future<void> _setBoolPreference(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  void _showSilentHoursDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Sessiz Saatleri Seçin', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              '22:00 - 07:00',
              '23:00 - 08:00',
              '00:00 - 06:00',
              '01:00 - 07:00'
            ].map((hours) => ListTile(
              dense: true,
              title: Text(hours, style: const TextStyle(color: Colors.white70)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('silentHours', hours);
                setState(() {
                  _silentHours = hours;
                });
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
            )).toList(),
          ),
        );
      },
    );
  }

  void _showLicensesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Açık Kaynak Lisansları', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('flutter_secure_storage:\nBSD 3-Clause License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('shared_preferences:\nBSD 3-Clause License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('provider:\nMIT License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('dio:\nMIT License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('jwt_decoder:\nMIT License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('intl:\nBSD 3-Clause License\n', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat', style: TextStyle(color: Colors.white54)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

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
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.snooze_outlined, color: Colors.white),
                  title: const Text('Sessiz Saatler', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Gece rahatsız etme modu: $_silentHours', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: _showSilentHoursDialog,
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
                  subtitle: Text(localeProvider.locale.languageCode == 'tr' ? 'Türkçe (TR)' : 'English (EN)', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    localeProvider.toggleLocale();
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  activeThumbColor: const Color(0xFFEF4444),
                  secondary: const Icon(Icons.data_usage_outlined, color: Colors.white),
                  title: const Text('Veri Tasarrufu Modu', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Düşük çözünürlüklü haber resimleri yükler', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: _dataSaver,
                  onChanged: (val) {
                    setState(() => _dataSaver = val);
                    _setBoolPreference('dataSaverMode', val);
                  },
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
                ListTile(
                  leading: const Icon(Icons.policy_outlined, color: Colors.white),
                  title: const Text('Açık Kaynak Lisansları', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Kullanılan kütüphaneler ve lisans hakları', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  onTap: _showLicensesDialog,
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
          const SizedBox(height: 20),

          const Text('Test & Simülatör Araçları', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13)),
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
                  secondary: const Icon(Icons.wifi_off_outlined, color: Colors.white),
                  title: const Text('Çevrimdışı Modu Simüle Et', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('İnternet bağlantısını keser ve önbellekten okur', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: context.watch<NewsProvider>().isOfflineSimulated,
                  onChanged: (val) {
                    context.read<NewsProvider>().toggleOfflineSimulation(val);
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  activeThumbColor: const Color(0xFFEF4444),
                  secondary: const Icon(Icons.system_update_outlined, color: Colors.white),
                  title: const Text('Zorunlu Güncelleme (Force Update)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Açılışta zorunlu güncelleme ekranını gösterir', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: _forceUpdateSim,
                  onChanged: (val) {
                    setState(() => _forceUpdateSim = val);
                    _setBoolPreference('simulateForceUpdate', val);
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  activeThumbColor: const Color(0xFFEF4444),
                  secondary: const Icon(Icons.build_circle_outlined, color: Colors.white),
                  title: const Text('Bakım Modu (Maintenance)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Açılışta planlı bakım modu ekranını gösterir', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  value: _maintenanceSim,
                  onChanged: (val) {
                    setState(() => _maintenanceSim = val);
                    _setBoolPreference('simulateMaintenance', val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
