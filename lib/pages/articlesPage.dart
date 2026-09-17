import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/navigation.dart';
import 'package:frontend/config/api.dart';

class ArtcilesPage extends StatefulWidget {
  const ArtcilesPage({super.key});

  @override
  State<ArtcilesPage> createState() => _ArtcilesPageState();
}

class _ArtcilesPageState extends State<ArtcilesPage> {
  // Warna
  static const Color orange = Color(0xFFE8784A);
  static const Color darkText = Color(0xFF303030);
  static const Color greyText = Color(0xFF8D8984);
  static const Color cream = Color(0xFFF7F4F1);
  static const Color border = Color(0xFFE8E3DE);

  // User yang sedang login untuk testing
  static const int currentUserId = 7;

  // Data artikel
  List<Map<String, dynamic>> articles = [];

  // Status loading
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyArticles();
  }

  // Mengambil artikel milik user
  Future<void> fetchMyArticles() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final url = Uri.parse('${Api.posts}?authorId=$currentUserId');

      print('REQUEST URL: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        print('GAGAL MENGAMBIL ARTIKEL');

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        _showMessage('Gagal mengambil artikel');
        return;
      }

      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      if (data == null || data['posts'] == null) {
        if (!mounted) return;

        setState(() {
          articles = [];
          isLoading = false;
        });

        print('DATA POSTS TIDAK DITEMUKAN');
        return;
      }

      final List<dynamic> posts = data['posts'];

      final loadedArticles = posts
          .map((post) => Map<String, dynamic>.from(post))
          .toList();

      if (!mounted) return;

      setState(() {
        articles = loadedArticles;
        isLoading = false;
      });

      print('JUMLAH ARTIKEL: ${articles.length}');

      for (final article in articles) {
        print(
          'ID: ${article['id']} | '
          'TITLE: ${article['title']} | '
          'STATUS: ${article['status']}',
        );
      }
    } catch (e) {
      print('ERROR ARTIKEL SAYA: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Tidak dapat terhubung ke server');
    }
  }

  // Menghapus artikel
  Future<void> deleteArticle(int id) async {
    try {
      final url = Uri.parse('${Api.posts}/$id');

      print('DELETE URL: $url');

      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 15));

      print('DELETE ID $id | STATUS: ${response.statusCode}');

      print('DELETE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          articles.removeWhere(
            (article) => article['id'].toString() == id.toString(),
          );
        });

        _showMessage('Artikel berhasil dihapus');
      } else {
        _showMessage('Gagal menghapus artikel');
      }
    } catch (e) {
      print('ERROR HAPUS ARTIKEL: $e');

      _showMessage('Tidak dapat terhubung ke server');
    }
  }

  // Konfirmasi sebelum menghapus
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Hapus artikel?',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
          content: Text(
            'Artikel yang dihapus tidak dapat dikembalikan.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: greyText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: greyText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteArticle(id);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Membuka halaman edit
  void editArticle(Map<String, dynamic> article) {
    Navigator.pushNamed(context, '/WriterPage', arguments: article).then((_) {
      fetchMyArticles();
    });
  }

  // Menampilkan snackbar
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: orange,
                onRefresh: fetchMyArticles,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Artikel Saya',
                          style: GoogleFonts.rubik(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ),
                    ),

                    // Loading
                    if (isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(color: orange),
                        ),
                      )
                    // Jika belum ada artikel
                    else if (articles.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: cream,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.article_outlined,
                                  size: 30,
                                  color: greyText,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                'Belum ada artikel',
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkText,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Artikel yang kamu buat akan muncul di sini.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Menampilkan daftar artikel
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final article = articles[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _articleCard(article),
                            );
                          }, childCount: articles.length),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation
          const CustomNavbar(currentIndex: 3),
        ],
      ),
    );
  }

  // Card artikel
  Widget _articleCard(Map<String, dynamic> article) {
    final String title = article['title']?.toString() ?? 'Tanpa Judul';

    final String author = article['author']?.toString() ?? 'Penulis';

    final String category = article['category']?.toString() ?? 'Artikel';

    final String status = article['status']?.toString() ?? 'published';

    final String imageProfile = article['imageProfile']?.toString() ?? '';

    final bool isDraft = status.toLowerCase() == 'draft';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author dan status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _authorImage(imageProfile),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: greyText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _statusBadge(isDraft),
            ],
          ),

          const SizedBox(height: 14),

          // Judul
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: darkText,
            ),
          ),

          const SizedBox(height: 16),

          // Tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Edit hanya untuk draft
              if (isDraft)
                _actionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: orange,
                  onTap: () {
                    editArticle(article);
                  },
                ),

              if (isDraft) const SizedBox(width: 8),

              // Hapus artikel
              _actionButton(
                icon: Icons.delete_outline,
                label: 'Hapus',
                color: Colors.redAccent,
                onTap: () {
                  final dynamic rawId = article['id'];

                  if (rawId == null) return;

                  final int? id = int.tryParse(rawId.toString());

                  if (id != null) {
                    confirmDelete(id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Foto profil author
  Widget _authorImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _defaultAuthorImage();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultAuthorImage();
        },
      ),
    );
  }

  // Foto profil default
  Widget _defaultAuthorImage() {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFFFEEE7),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_outline, size: 20, color: orange),
    );
  }

  // Badge status
  Widget _statusBadge(bool isDraft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDraft ? const Color(0xFFFFEEE7) : const Color(0xFFEAF5E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDraft ? 'DRAFT' : 'PUBLISHED',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDraft ? orange : const Color(0xFF67A85D),
        ),
      ),
    );
  }

  // Tombol aksi
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),

            const SizedBox(width: 5),

            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
