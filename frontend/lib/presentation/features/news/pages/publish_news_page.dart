import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_template/presentation/providers/news_provider.dart';
import 'package:frontend_template/presentation/providers/user_provider.dart';

class PublishNewsPage extends StatefulWidget {
  const PublishNewsPage({super.key});

  @override
  State<PublishNewsPage> createState() => _PublishNewsPageState();
}

class _PublishNewsPageState extends State<PublishNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _authorController = TextEditingController(text: 'Editör Masası');

  int _selectedCategoryId = 1;
  bool _isBreaking = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile != null) {
        _authorController.text = '${userProvider.profile!.firstName} ${userProvider.profile!.lastName}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Yeni Haber Yayınla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF4444)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    _buildTextField(
                      controller: _titleController,
                      label: 'Haber Başlığı',
                      hint: 'Dikkat çekici başlığı giriniz',
                      validator: (v) => v == null || v.isEmpty ? 'Başlık zorunludur' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Selector Dropdown
                    const Text('Kategori', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedCategoryId,
                          dropdownColor: const Color(0xFF1E293B),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          items: newsProvider.categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategoryId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cover Image URL
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Kapak Görsel URL',
                      hint: 'https://images.unsplash.com/...',
                      validator: (v) => v == null || v.isEmpty ? 'Görsel linki giriniz' : null,
                    ),
                    const SizedBox(height: 16),

                    // Summary Input
                    _buildTextField(
                      controller: _summaryController,
                      label: 'Kısa Özet',
                      hint: 'Haberin özetini giriniz',
                      maxLines: 2,
                      validator: (v) => v == null || v.isEmpty ? 'Özet zorunludur' : null,
                    ),
                    const SizedBox(height: 16),

                    // Full Content Input
                    _buildTextField(
                      controller: _contentController,
                      label: 'Detaylı Haber İçeriği',
                      hint: 'Haber metnini giriniz...',
                      maxLines: 6,
                      validator: (v) => v == null || v.isEmpty ? 'Haber metni zorunludur' : null,
                    ),
                    const SizedBox(height: 16),

                    // Author Name Input
                    _buildTextField(
                      controller: _authorController,
                      label: 'Yazar / Yayıncı Adı',
                      hint: 'Editör adı',
                    ),
                    const SizedBox(height: 16),

                    // Switches for Breaking & Featured
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFEF4444),
                      title: const Text('Son Dakika / Flaş Haber Yap', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Kırmızı flaş bant alanında görünür', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      value: _isBreaking,
                      onChanged: (v) => setState(() => _isBreaking = v),
                    ),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF38BDF8),
                      title: const Text('Manşet / Öne Çıkarılan Haber Yap', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Üst manşet slider alanında gösterilir', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      value: _isFeatured,
                      onChanged: (v) => setState(() => _isFeatured = v),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final success = await newsProvider.publishNews(
                              title: _titleController.text.trim(),
                              summary: _summaryController.text.trim(),
                              content: _contentController.text.trim(),
                              coverImageUrl: _imageUrlController.text.trim().isEmpty
                                  ? 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800'
                                  : _imageUrlController.text.trim(),
                              categoryId: _selectedCategoryId,
                              authorName: _authorController.text.trim(),
                              isBreaking: _isBreaking,
                              isFeatured: _isFeatured,
                            );

                            if (success) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Haber başarıyla yayınlandı!')),
                              );
                              navigator.pop();
                            }
                          }
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text('HABERİ YAYINLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
          ),
        ),
      ],
    );
  }
}
