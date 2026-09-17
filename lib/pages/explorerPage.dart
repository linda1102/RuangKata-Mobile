import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api.dart';

import '../widgets/navigation.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> posts = [];
  List<String> categories = [];

  String selectedCategory = 'Semua';
  String searchText = '';

  bool isLoading = true;

  static const Color orange = Color(0xFFE8784A);
  static const Color lightOrange = Color(0xFFFFEEE7);
  static const Color darkText = Color(0xFF252525);
  static const Color greyText = Color(0xFF77736D);
  static const Color cream = Color(0xFFF1EDE5);
  static const Color border = Color(0xFFE7E3DC);
  static const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments;

      if (arguments != null && arguments is String) {
        selectedCategory = arguments;
      }

      getData();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(Api.posts),
      );

      print('POST STATUS: ${response.statusCode}');
      print('POST RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> fetchedPosts =
            data['data']['posts'] ?? [];

        final Set<String> categorySet = {};

        for (final post in fetchedPosts) {
          final category =
              post['category']?.toString().trim() ?? '';

          if (category.isNotEmpty) {
            categorySet.add(category);
          }
        }

        final List<String> fetchedCategories = [
          'Semua',
          ...categorySet,
        ];

        String currentCategory = selectedCategory;

        final categoryExists = fetchedCategories.any(
          (category) =>
              category.toLowerCase().trim() ==
              currentCategory.toLowerCase().trim(),
        );

        if (!categoryExists) {
          currentCategory = 'Semua';
        } else {
          currentCategory = fetchedCategories.firstWhere(
            (category) =>
                category.toLowerCase().trim() ==
                currentCategory.toLowerCase().trim(),
          );
        }

        setState(() {
          posts = fetchedPosts;
          categories = fetchedCategories;
          selectedCategory = currentCategory;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('ERROR GET POSTS: $error');

      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredPosts {
    final search = searchText.trim().toLowerCase();
    final selected = selectedCategory.trim().toLowerCase();

    return posts.where((post) {
      final title =
          post['title']?.toString().toLowerCase() ?? '';

      final content =
          post['content']?.toString().toLowerCase() ?? '';

      final category =
          post['category']?.toString().trim().toLowerCase() ?? '';

      final categoryMatch =
          selectedCategory.toLowerCase() == 'semua' ||
          category == selected;

      final searchMatch =
          search.isEmpty ||
          title.contains(search) ||
          content.contains(search) ||
          category.contains(search);

      return categoryMatch && searchMatch;
    }).toList();
  }

  String getImageUrl(dynamic post) {
    final image =
        post['imageUrl'] ?? post['image_url'];

    return image?.toString() ?? '';
  }

  String getProfileImage(dynamic post) {
    final image =
        post['imageProfile'] ?? post['image_profile'];

    return image?.toString() ?? '';
  }

  void openArticle(dynamic post) {
    Navigator.pushNamed(
      context,
      '/ArticlesDetailPage',
      arguments: post,
    );
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.rubik(
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: searchController,
                        textInputAction:
                            TextInputAction.search,
                        style:
                            GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: darkText,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 21,
                            color: orange,
                          ),
                          hintText: 'Cari artikel...',
                          hintStyle:
                              GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color:
                                const Color(0xFFAAA6A1),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          suffixIcon:
                              searchText.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: greyText,
                                      ),
                                      onPressed: () {
                                        searchController
                                            .clear();
                                      },
                                    )
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Jelajahi Topik',
                      style: GoogleFonts.rubik(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      height: 40,
                      child: categories.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              scrollDirection:
                                  Axis.horizontal,
                              itemCount:
                                  categories.length,
                              itemBuilder:
                                  (context, index) {
                                final category =
                                    categories[index];

                                final isSelected =
                                    selectedCategory ==
                                        category;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    right: 8,
                                  ),
                                  child:
                                      GestureDetector(
                                    onTap: () {
                                      selectCategory(
                                        category,
                                      );
                                    },
                                    child:
                                        AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 17,
                                        vertical: 10,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: isSelected
                                            ? orange
                                            : cream,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          25,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style:
                                            GoogleFonts
                                                .plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: isSelected
                                              ? white
                                              : greyText,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Temukan Artikel',
                          style: GoogleFonts.rubik(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        Text(
                          '${filteredPosts.length} artikel',
                          style:
                              GoogleFonts
                                  .plusJakartaSans(
                            fontSize: 10,
                            color: greyText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 50,
                          ),
                          child:
                              CircularProgressIndicator(
                            color: orange,
                          ),
                        ),
                      )
                    else if (filteredPosts.isEmpty)
                      _emptyState()
                    else
                      ListView.builder(
                        itemCount:
                            filteredPosts.length,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemBuilder:
                            (context, index) {
                          final post =
                              filteredPosts[index];

                          return _articleCard(post);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          const CustomNavbar(
            currentIndex: 1,
          ),
        ],
      ),
    );
  }

  Widget _articleCard(dynamic post) {
    final String title =
        post['title']?.toString() ??
        'Tanpa Judul';

    final String category =
        post['category']?.toString().trim() ?? '';

    final String author =
        post['author']?.toString().trim().isNotEmpty == true
            ? post['author'].toString()
            : post['username']?.toString() ??
                'Anonymous';

    final String imageUrl =
        getImageUrl(post);

    final String profileImage =
        getProfileImage(post);

    return GestureDetector(
      onTap: () {
        openArticle(post);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w700,
                        color: orange,
                        letterSpacing: 0.5,
                      ),
                    ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
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
                        decoration:
                            const BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior:
                            Clip.antiAlias,
                        child:
                            profileImage.isNotEmpty
                                ? Image.network(
                                    profileImage,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return const Icon(
                                        Icons
                                            .person_outline_rounded,
                                        size: 13,
                                        color: orange,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons
                                        .person_outline_rounded,
                                    size: 13,
                                    color: orange,
                                  ),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          author,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              GoogleFonts
                                  .plusJakartaSans(
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w600,
                            color: greyText,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 17,
                        color: greyText,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(14),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 55,
        ),
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration:
                  BoxDecoration(
                color: lightOrange,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 30,
                color: orange,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Artikel tidak ditemukan',
              style:
                  GoogleFonts.rubik(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
                color: darkText,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              selectedCategory.toLowerCase() ==
                      'semua'
                  ? 'Coba gunakan kata kunci lain.'
                  : 'Tidak ada artikel dalam kategori ini.',
              textAlign:
                  TextAlign.center,
              style:
                  GoogleFonts
                      .plusJakartaSans(
                fontSize: 12,
                color: greyText,
              ),
            ),

            const SizedBox(height: 18),

            if (selectedCategory.toLowerCase() !=
                'semua')
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory =
                        'Semua';
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: orange,
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),
                  child: Text(
                    'Lihat Semua Artikel',
                    style:
                        GoogleFonts
                            .plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color: white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 105,
      height: 105,
      color: cream,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 25,
          color: greyText,
        ),
      ),
    );
  }
}