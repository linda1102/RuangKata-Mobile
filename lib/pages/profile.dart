import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/config/api.dart';
import 'package:frontend/pages/libraryPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color orange = Color(0xFFE8784A);
  static const Color darkText = Color(0xFF303030);
  static const Color greyText = Color(0xFF8D8984);
  static const Color cream = Color(0xFFF6F3EF);
  static const Color green = Color(0xFF71856D);
  static const Color border = Color(0xFFE8E3DE);

  static const int currentUserId = 7;

  int articleCount = 0;
  int likedCount = 0;
  int savedCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.posts}?authorId=$currentUserId'),
      );

      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final result = jsonDecode(response.body);

      final List<dynamic> posts = result['data']?['posts'] ?? [];

      final myPosts = posts;

      int totalLiked = 0;
      int totalSaved = 0;

      for (final post in myPosts) {
        final likes = post['likeCount'] ?? post['likesCount'] ?? post['likes'];

        final saves = post['savedCount'] ?? post['saveCount'] ?? post['saves'];

        if (likes is int) {
          totalLiked += likes;
        } else if (likes is List) {
          totalLiked += likes.length;
        }

        if (saves is int) {
          totalSaved += saves;
        } else if (saves is List) {
          totalSaved += saves.length;
        }
      }

      if (mounted) {
        setState(() {
          articleCount = myPosts.length;
          likedCount = totalLiked;
          savedCount = totalSaved;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: orange,
          onRefresh: loadProfileData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: darkText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Profile',
                      style: GoogleFonts.rubik(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF2DDD3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/ppcute.jfif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const ColoredBox(
                                    color: Color(0xFFFFEEE7),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 48,
                                      color: orange,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'ailyn',
                        style: GoogleFonts.rubik(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@ailynjes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _statItem(isLoading ? '-' : '$articleCount', 'Artikel'),
                      _verticalDivider(),
                      _statItem(isLoading ? '-' : '$likedCount', 'Disukai'),
                      _verticalDivider(),
                      _statItem(isLoading ? '-' : '$savedCount', 'Disimpan'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Tentang Saya',
                  style: GoogleFonts.rubik(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Suka membaca, menulis, dan berbagi cerita '
                  'tentang hal-hal sederhana yang menarik.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.7,
                    color: greyText,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Akun',
                  style: GoogleFonts.rubik(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 12),
                _profileMenu(
                  icon: Icons.article_outlined,
                  title: 'Artikel Saya',
                  subtitle: 'Lihat artikel yang kamu buat',
                  onTap: () {
                    Navigator.pushNamed(context, '/ArticlesPage');
                  },
                ),
                _profileMenu(
                  icon: Icons.bookmark_border,
                  title: 'Artikel Tersimpan',
                  subtitle: 'Lihat artikel yang disimpan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LibraryPage(initialTab: 1),
                      ),
                    );
                  },
                ),
                _profileMenu(
                  icon: Icons.favorite_border,
                  title: 'Artikel Disukai',
                  subtitle: 'Lihat artikel yang kamu sukai',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LibraryPage(initialTab: 0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _profileMenu(
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Keluar dari akun',
                  iconColor: orange,
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/LoginPage",
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: GoogleFonts.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: greyText),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 30, color: border);
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = green,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: greyText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 21, color: Color(0xFFAAA6A1)),
          ],
        ),
      ),
    );
  }
}
