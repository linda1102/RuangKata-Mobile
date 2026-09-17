import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api.dart';

class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const ArticleDetailPage({super.key, required this.post});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  static const int currentUserId = 7;

  static const Color orange = Color(0xFFE8784A);
  static const Color black = Color(0xFF252525);
  static const Color grey = Color(0xFF77736D);
  static const Color greyLight = Color(0xFFA6A19A);
  static const Color cream = Color(0xFFF5F1EB);
  static const Color border = Color(0xFFE8E3DC);

  bool isLiked = false;
  bool isSaved = false;

  bool isLikeLoading = false;
  bool isSaveLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
    _checkSaveStatus();
  }

  int? get postId {
    final dynamic id = widget.post['id'];

    if (id == null) {
      return null;
    }

    return int.tryParse(id.toString());
  }

  Future<void> _checkLikeStatus() async {
    if (postId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${Api.library}/posts/$postId/like?userId=$currentUserId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          isLiked = data['liked'] == true;
        });
      }
    } catch (e) {
      debugPrint("CHECK LIKE ERROR: $e");
    }
  }

  Future<void> _toggleLike() async {
    if (postId == null || isLikeLoading) return;

    setState(() {
      isLikeLoading = true;
    });

    try {
      http.Response response;

      if (isLiked) {
        response = await http.delete(
          Uri.parse("${Api.library}/posts/$postId/like?userId=$currentUserId"),
        );
      } else {
        response = await http.post(
          Uri.parse("${Api.library}/posts/$postId/like"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": currentUserId}),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        setState(() {
          isLiked = !isLiked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLiked ? "Artikel disukai" : "Like dibatalkan",
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        debugPrint("LIKE STATUS: ${response.statusCode}");
        debugPrint("LIKE BODY: ${response.body}");

        _showError("Gagal mengubah like");
      }
    } catch (e) {
      debugPrint("LIKE ERROR: $e");
      _showError("Tidak dapat terhubung ke server");
    } finally {
      if (mounted) {
        setState(() {
          isLikeLoading = false;
        });
      }
    }
  }

  Future<void> _checkSaveStatus() async {
    if (postId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${Api.library}/posts/$postId/save?userId=$currentUserId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          isSaved = data['saved'] == true;
        });
      }
    } catch (e) {
      debugPrint("CHECK SAVE ERROR: $e");
    }
  }

  Future<void> _toggleSave() async {
    if (postId == null || isSaveLoading) return;

    setState(() {
      isSaveLoading = true;
    });

    try {
      http.Response response;

      if (isSaved) {
        response = await http.delete(
          Uri.parse("${Api.library}/posts/$postId/save?userId=$currentUserId"),
        );
      } else {
        response = await http.post(
          Uri.parse("${Api.library}/posts/$postId/save"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": currentUserId}),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        setState(() {
          isSaved = !isSaved;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved ? "Artikel disimpan" : "Artikel dihapus dari Library",
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        debugPrint("SAVE STATUS: ${response.statusCode}");
        debugPrint("SAVE BODY: ${response.body}");

        _showError("Gagal mengubah simpanan");
      }
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      _showError("Tidak dapat terhubung ke server");
    } finally {
      if (mounted) {
        setState(() {
          isSaveLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
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
    final String title = widget.post['title']?.toString() ?? 'Tanpa Judul';

    final String content =
        widget.post['content']?.toString() ?? 'Belum ada isi artikel.';

    final String imageUrl =
        widget.post['imageUrl']?.toString() ??
        widget.post['image_url']?.toString() ??
        '';

    final String imageProfile = widget.post['imageProfile']?.toString() ?? '';

    final String author =
        widget.post['author']?.toString() ??
        widget.post['username']?.toString() ??
        'Penulis';

    final String date =
        widget.post['createdAt']?.toString() ??
        widget.post['created_at']?.toString() ??
        '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: black,
            size: 19,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ScrollConfiguration(
        behavior: const NoStretchScrollBehavior(),

        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 245,
                        fit: BoxFit.cover,

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            width: double.infinity,
                            height: 245,
                            color: cream,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: orange,
                              ),
                            ),
                          );
                        },

                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder(height: 245);
                        },
                      )
                    : _imagePlaceholder(height: 245),
              ),

              const SizedBox(height: 25),

              Text(
                title,
                style: GoogleFonts.rubik(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: black,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),

                    child: imageProfile.isNotEmpty
                        ? Image.network(
                            imageProfile,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return _profilePlaceholder();
                            },
                          )
                        : _profilePlaceholder(),
                  ),

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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: black,
                          ),
                        ),

                        if (date.isNotEmpty) const SizedBox(height: 3),

                        if (date.isNotEmpty)
                          Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 23),

              const Divider(color: border, thickness: 1),

              const SizedBox(height: 22),

              Text(
                content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.8,
                  color: black,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  IconButton(
                    onPressed: isLikeLoading ? null : _toggleLike,

                    icon: isLikeLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: orange,
                            ),
                          )
                        : Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: orange,
                            size: 23,
                          ),
                  ),

                  Text(
                    isLiked ? 'Disukai' : 'Suka',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: grey,
                    ),
                  ),

                  const SizedBox(width: 15),

                  IconButton(
                    onPressed: isSaveLoading ? null : _toggleSave,

                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: orange,
                      size: 23,
                    ),
                  ),

                  Text(
                    isSaved ? 'Disimpan' : 'Simpan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      color: cream,

      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: greyLight),
      ),
    );
  }

  Widget _profilePlaceholder() {
    return Container(
      width: 42,
      height: 42,
      color: const Color(0xFFFFF0E9),

      child: const Icon(Icons.person_outline_rounded, size: 21, color: orange),
    );
  }
}
