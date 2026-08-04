import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _biography = 'Haberim uygulamasında tarafsız haberlerin sadık takipçisi.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<UserProvider>().fetchProfile();
      }
      _loadBiography();
    });
  }

  Future<void> _loadBiography() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biography = prefs.getString('user_biography') ?? 'Haberim uygulamasında tarafsız haberlerin sadık takipçisi.';
      });
    }
  }

  Future<void> _saveBiography(String bio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_biography', bio);
    if (mounted) {
      setState(() {
        _biography = bio;
      });
    }
  }

  void _showEditBioDialog(BuildContext context) {
    final bioController = TextEditingController(text: _biography);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Biyografiyi Düzenle', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: bioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Kendinizden bahsedin...',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF4444))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () async {
                await _saveBiography(bioController.text.trim());
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Şifre Değiştir', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Mevcut Şifre',
                  isPassword: true,
                  controller: currentPassController,
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Yeni Şifre',
                  isPassword: true,
                  controller: newPassController,
                  validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final cur = currentPassController.text.trim();
                  final newP = newPassController.text.trim();

                  final success = await context.read<UserProvider>().changePassword(cur, newP);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
                      );
                    } else {
                      final error = context.read<UserProvider>().errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Şifre değiştirilemedi.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Hesabınızı Silmek İstediğinize Emin Misiniz?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text(
            'Bu işlem geri alınamaz. KVKK/GDPR "Unutulma Hakkı" kapsamında tüm verileriniz silinecektir. Lütfen onaylayın.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () async {
                final success = await userProvider.deleteAccount();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    await authProvider.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hesabınız ve tüm verileriniz başarıyla silindi.')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(userProvider.errorMessage ?? 'Hesap silinirken hata oluştu.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Evet, Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Kullanıcı Profilim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: !isAuthenticated
          ? _buildGuestView(context)
          : userProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF4444)))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            child: const Icon(Icons.person, size: 54, color: Color(0xFFEF4444)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile != null ? '${profile.firstName} ${profile.lastName}' : 'Haberim Okuru',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (authProvider.canPublish || (profile?.email == 'admin@template.com'))
                          const Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Icon(Icons.verified, color: Color(0xFF38BDF8), size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? 'okur@haberim.com',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    
                    // Biography Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            _biography,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
                          ),
                          const SizedBox(height: 4),
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: () => _showEditBioDialog(context),
                            icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF38BDF8)),
                            label: const Text('Biyografiyi Düzenle', style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gamification & Statistics Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Okuma İstatistikleri & Seviye',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Okunan Haber', '24'),
                              _buildStatColumn('Okur Puanı', '240 XP'),
                              _buildStatColumn('Seviye', 'Sadık Okur 🏆'),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 24),
                          const Text(
                            'Kazanılan Rozetler',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: const [
                              Chip(
                                labelPadding: EdgeInsets.zero,
                                avatar: CircleAvatar(backgroundColor: Colors.transparent, child: Text('💬')),
                                label: Text('İlk Yorum', style: TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                              Chip(
                                labelPadding: EdgeInsets.zero,
                                avatar: CircleAvatar(backgroundColor: Colors.transparent, child: Text('📰')),
                                label: Text('Haber Gurusu', style: TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                              Chip(
                                labelPadding: EdgeInsets.zero,
                                avatar: CircleAvatar(backgroundColor: Colors.transparent, child: Text('🦉')),
                                label: Text('Gece Kuşu', style: TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Roles / Claims Section Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Hesap Yetki Seviyesi',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (authProvider.userClaims.isNotEmpty
                                    ? authProvider.userClaims
                                    : ['Okur Kullanıcı'])
                                .map(
                                  (claim) => Chip(
                                    backgroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(color: Color(0xFF38BDF8)),
                                    label: Text(
                                      claim,
                                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    avatar: const Icon(Icons.verified_user, size: 16, color: Color(0xFF38BDF8)),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Settings Card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        onTap: () => _showChangePasswordDialog(context),
                        leading: const Icon(Icons.lock_outline, color: Colors.white70),
                        title: const Text('Şifre Değiştir', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // App Settings Link
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        leading: const Icon(Icons.settings_outlined, color: Colors.white70),
                        title: const Text('Uygulama Ayarları', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    CustomButton(
                      text: 'Oturumu Kapat',
                      backgroundColor: const Color(0xFFEF4444),
                      onPressed: () async {
                        await authProvider.logout();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Delete Account Button (GDPR)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Hesabımı Sil (GDPR)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Oturum Açılmadı',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Haberlere yorum yapmak, kişiselleştirilmiş içerik ve favorilere erişmek için oturum açınız.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Giriş Yap / Kayıt Ol',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
