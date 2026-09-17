import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/api.dart';
import 'package:frontend/widgets/navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LibraryPage extends StatefulWidget {
  final int initialTab;

  const LibraryPage({super.key, this.initialTab = 0});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  static const int currentUserId = 7;

  static const Color orange = Color(0xFFE8784A);
  static const Color darkText = Color(0xFF303030);
  static const Color greyText = Color(0xFF77716D);
  static const Color cream = Color(0xFFF1EDE5);
  static const Color border = Color(0xFFE7E3DC);

  late TabController tabController;

  List<Map<String, dynamic>> likedArticles = [];
  List<Map<String, dynamic>> savedArticles = [];

  bool isLoadingLiked = true;
  bool isLoadingSaved = true;
  bool isActionLoading = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _loadLibrary();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    await Future.wait([_loadLikedArticles(), _loadSavedArticles()]);
  }

  Future<void> _loadLikedArticles() async {
    if (mounted) {
      setState(() {
        isLoadingLiked = true;
      });
    }

    try {
      final url = Uri.parse("${Api.library}/liked?userId=$currentUserId");

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      debugPrint("LIKED STATUS: ${response.statusCode}");
      debugPrint("LIKED RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil artikel yang disukai");
      }

      final body = jsonDecode(response.body);
      final data = body['data'];

      if (data != null && data['posts'] is List) {
        likedArticles = List<Map<String, dynamic>>.from(data['posts']);
      } else {
        likedArticles = [];
      }
    } catch (e) {
      debugPrint("ERROR LOAD LIKED: $e");
      likedArticles = [];
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLiked = false;
        });
      }
    }
  }

  Future<void> _loadSavedArticles() async {
    if (mounted) {
      setState(() {
        isLoadingSaved = true;
      });
    }

    try {
      final url = Uri.parse("${Api.library}/saved?userId=$currentUserId");

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      debugPrint("SAVED STATUS: ${response.statusCode}");
      debugPrint("SAVED RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil artikel yang disimpan");
      }

      final body = jsonDecode(response.body);
      final data = body['data'];

      if (data != null && data['posts'] is List) {
        savedArticles = List<Map<String, dynamic>>.from(data['posts']);
      } else {
        savedArticles = [];
      }
    } catch (e) {
      debugPrint("ERROR LOAD SAVED: $e");
      savedArticles = [];
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSaved = false;
        });
      }
    }
  }

  Future<void> _refreshLibrary() async {
    if (mounted) {
      setState(() {
        isLoadingLiked = true;
        isLoadingSaved = true;
      });
    }

    await _loadLibrary();
  }

  Future<void> _unlikeArticle(int postId) async {
    if (isActionLoading) return;

    setState(() {
      isActionLoading = true;
    });

    try {
      final url = Uri.parse(
        "${Api.library}/posts/$postId/like?userId=$currentUserId",
      );

      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 15));

      debugPrint("UNLIKE STATUS: ${response.statusCode}");
      debugPrint("UNLIKE RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal menghapus like");
      }

      if (!mounted) return;

      setState(() {
        likedArticles.removeWhere(
          (article) => article['id']?.toString() == postId.toString(),
        );
      });
    } catch (e) {
      debugPrint("ERROR UNLIKE: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus artikel dari Disukai')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> _unsaveArticle(int postId) async {
    if (isActionLoading) return;

    setState(() {
      isActionLoading = true;
    });

    try {
      final url = Uri.parse(
        "${Api.library}/posts/$postId/save?userId=$currentUserId",
      );

      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 15));

      debugPrint("UNSAVE STATUS: ${response.statusCode}");
      debugPrint("UNSAVE RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal menghapus save");
      }

      if (!mounted) return;

      setState(() {
        savedArticles.removeWhere(
          (article) => article['id']?.toString() == postId.toString(),
        );
      });
    } catch (e) {
      debugPrint("ERROR UNSAVE: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus artikel dari Disimpan'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  String getImageUrl(Map<String, dynamic> article) {
    final image = article['imageUrl'] ?? article['image_url'];

    if (image == null || image.toString().isEmpty) {
      return '';
    }

    return image.toString();
  }

  String getProfileImage(Map<String, dynamic> article) {
    final image =
        article['imageProfile'] ??
        article['image_profile'] ??
        article['profileImage'] ??
        article['profile_image'] ??
        article['avatar'] ??
        article['avatarUrl'] ??
        article['avatar_url'];

    if (image == null || image.toString().isEmpty) {
      return '';
    }

    return image.toString();
  }

  String getAuthorName(Map<String, dynamic> article) {
    return (article['author'] ??
            article['username'] ??
            article['authorName'] ??
            'Anonymous')
        .toString();
  }

  String getCategory(Map<String, dynamic> article) {
    return (article['category'] ?? article['categoryName'] ?? '').toString();
  }

  String getTitle(Map<String, dynamic> article) {
    return (article['title'] ?? 'Tanpa Judul').toString();
  }

  Widget _articleCard(Map<String, dynamic> article, {required bool isLiked}) {
    final imageUrl = getImageUrl(article);
    final profileImage = getProfileImage(article);
    final authorName = getAuthorName(article);
    final category = getCategory(article);
    final title = getTitle(article);

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          "/ArticlesDetailPage",
          arguments: article,
        );

        if (mounted) {
          await _refreshLibrary();
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: orange,
                        letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: profileImage.isNotEmpty
                            ? Image.network(
                                profileImage,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person_outline_rounded,
                                    size: 13,
                                    color: orange,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person_outline_rounded,
                                size: 13,
                                color: orange,
                              ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: greyText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          final postId = int.tryParse(
                            article['id']?.toString() ?? '',
                          );

                          if (postId == null || isActionLoading) {
                            return;
                          }

                          if (isLiked) {
                            _unlikeArticle(postId);
                          } else {
                            _unsaveArticle(postId);
                          }
                        },
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.bookmark,
                          size: 18,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _smallImagePlaceholder();
                      },
                    )
                  : _smallImagePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      height: 129,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 65,
                  height: 9,
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 130,
                  height: 14,
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 90,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: cream,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: orange),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: darkText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.5,
                color: greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallImagePlaceholder() {
    return Container(
      width: 105,
      height: 105,
      color: cream,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 25, color: greyText),
      ),
    );
  }

  Widget _likedTab() {
    if (isLoadingLiked) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _loadingCard();
        },
      );
    }

    if (likedArticles.isEmpty) {
      return RefreshIndicator(
        color: orange,
        onRefresh: _refreshLibrary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 430,
              child: _emptyState(
                icon: Icons.favorite_border,
                title: 'Belum ada artikel disukai',
                subtitle: 'Artikel yang kamu sukai akan muncul di sini.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: orange,
      onRefresh: _refreshLibrary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: likedArticles.length,
        itemBuilder: (context, index) {
          return _articleCard(likedArticles[index], isLiked: true);
        },
      ),
    );
  }

  Widget _savedTab() {
    if (isLoadingSaved) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _loadingCard();
        },
      );
    }

    if (savedArticles.isEmpty) {
      return RefreshIndicator(
        color: orange,
        onRefresh: _refreshLibrary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 430,
              child: _emptyState(
                icon: Icons.bookmark_border,
                title: 'Belum ada artikel disimpan',
                subtitle: 'Artikel yang kamu simpan akan muncul di sini.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: orange,
      onRefresh: _refreshLibrary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: savedArticles.length,
        itemBuilder: (context, index) {
          return _articleCard(savedArticles[index], isLiked: false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Library',
                  style: GoogleFonts.rubik(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: darkText,
                  unselectedLabelColor: greyText,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Disukai'),
                    Tab(text: 'Disimpan'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [_likedTab(), _savedTab()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavbar(currentIndex: 4),
    );
  }
}
