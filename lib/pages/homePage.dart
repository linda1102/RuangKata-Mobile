import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/config/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color orange = Color(0xFFE8784A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF252525);
  static const Color grey = Color(0xFF77736D);
  static const Color cream = Color(0xFFF1EDE5);
  static const Color border = Color(0xFFE7E3DC);

  List<dynamic> posts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getPosts();
  }
  Future<void> getPosts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http
          .get(
            Uri.parse(Api.posts),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          posts = result['data']['posts'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Gagal mengambil data artikel.";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Tidak dapat terhubung ke server.";
        isLoading = false;
      });
    }
  }
  void _openArticleDetail(dynamic post) {
    Navigator.pushNamed(
      context,
      "/ArticlesDetailPage",
      arguments: post,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      body: SafeArea(
        child: RefreshIndicator(
          color: orange,
          onRefresh: getPosts,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _header(),

                const SizedBox(height: 28),
                Text(
                  "Trending",

                  style: GoogleFonts.rubik(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: black,
                  ),
                ),

                const SizedBox(height: 14),
                if (isLoading)
                  _loadingFeatured()
                else if (errorMessage != null)
                  _errorWidget()
                else if (posts.isEmpty)
                  _emptyWidget()
                else
                  _featuredCard(posts.first),

                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Expanded(
                      child: Text(
                        "Artikel terbaru",

                        style: GoogleFonts.rubik(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: black,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/ExplorerPage",
                        );
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8,
                        ),

                        child: Text(
                          "Lihat semua",

                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                if (isLoading)
                  Column(
                    children: List.generate(
                      3,

                      (index) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _articleLoadingCard(),
                      ),
                    ),
                  )
                else if (errorMessage != null)
                  _errorWidget()
                else if (posts.length <= 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                    ),

                    child: Center(
                      child: Text(
                        "Belum ada artikel lainnya.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: grey,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: posts
                        .skip(1)
                        .map(
                          (post) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),

                            child: _articleCard(post),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(
        currentIndex: 0,
      ),
    );
  }
  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                "RuangKata",

                style: GoogleFonts.rubik(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: orange,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Temukan cerita, ide, dan inspirasi.",

                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: grey,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/ProfilePage",
            );
          },

          child: Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: border,
                width: 1,
              ),
            ),

            clipBehavior: Clip.antiAlias,

            child: Image.asset(
              "assets/images/ppcute.jfif",

              fit: BoxFit.cover,

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.person_outline_rounded,
                  color: grey,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  Widget _featuredCard(dynamic post) {
    final String title =
        post['title']?.toString() ?? "Tanpa Judul";

    final String category =
        post['category']?.toString().trim() ?? "";

    final String imageUrl =
        post['imageUrl']?.toString() ??
        post['image_url']?.toString() ??
        "";
    final String author =
        post['author']?.toString() ?? "Anonymous";
    final String imageProfile =
        post['imageProfile']?.toString() ?? "";

    return GestureDetector(
      onTap: () {
        _openArticleDetail(post);
      },

      child: Container(
        width: double.infinity,
        height: 215,

        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(22),
        ),

        clipBehavior: Clip.antiAlias,

        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.20),
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
              ),
            ),
            if (category.isNotEmpty)
              Positioned(
                top: 14,
                left: 14,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    category,

                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 14,
              right: 14,

              child: Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: black,
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 52,

              child: Text(
                title,

                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.rubik(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: white,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,

              child: Row(
                children: [
                  // AUTHOR IMAGE
                  Container(
                    width: 31,
                    height: 31,

                    decoration: const BoxDecoration(
                      color: cream,
                      shape: BoxShape.circle,
                    ),

                    clipBehavior: Clip.antiAlias,

                    child: imageProfile.isNotEmpty
                        ? Image.network(
                            imageProfile,

                            width: 31,
                            height: 31,

                            fit: BoxFit.cover,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: orange,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: orange,
                          ),
                  ),

                  const SizedBox(width: 8),

                  // AUTHOR NAME
                  Expanded(
                    child: Text(
                      author,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: white,
                      ),
                    ),
                  ),

                  // BOOKMARK
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _articleCard(dynamic post) {
    final String title =
        post['title']?.toString() ?? "Tanpa Judul";

    final String category =
        post['category']?.toString().trim() ?? "";

    final String imageUrl =
        post['imageUrl']?.toString() ??
        post['image_url']?.toString() ??
        "";

    final String author =
        post['author']?.toString() ??
        post['username']?.toString() ??
        "Anonymous";

    final String imageProfile =
        post['imageProfile']?.toString() ?? "";

    return GestureDetector(
      onTap: () {
        _openArticleDetail(post);
      },

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
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
                      color: black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // AUTHOR IMAGE
                      Container(
                        width: 24,
                        height: 24,

                        decoration: const BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                        ),

                        clipBehavior: Clip.antiAlias,

                        child: imageProfile.isNotEmpty
                            ? Image.network(
                                imageProfile,
                                fit: BoxFit.cover,

                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
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
                          author,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: grey,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 17,
                        color: grey,
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

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
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
  Widget _loadingFeatured() {
    return Container(
      width: double.infinity,
      height: 215,

      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
      ),

      child: const Center(
        child: CircularProgressIndicator(
          color: orange,
        ),
      ),
    );
  }
  Widget _articleLoadingCard() {
    return Container(
      width: double.infinity,
      height: 130,

      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
      ),

      child: const Center(
        child: CircularProgressIndicator(
          color: orange,
          strokeWidth: 2,
        ),
      ),
    );
  }
  Widget _errorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 30,
            color: grey,
          ),

          const SizedBox(height: 10),

          Text(
            errorMessage ?? "Terjadi kesalahan.",

            textAlign: TextAlign.center,

            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: grey,
            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: getPosts,

            child: Text(
              "Coba lagi",

              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _emptyWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.article_outlined,
            size: 35,
            color: grey,
          ),

          const SizedBox(height: 10),

          Text(
            "Belum ada artikel.",

            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }
  Widget _imagePlaceholder() {
    return Container(
      color: cream,

      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: grey,
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
        child: Icon(
          Icons.image_outlined,
          size: 25,
          color: grey,
        ),
      ),
    );
  }
}