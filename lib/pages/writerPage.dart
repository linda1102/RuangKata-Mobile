import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:frontend/config/api.dart';

class WriterPage extends StatefulWidget {
  const WriterPage({super.key});

  @override
  State<WriterPage> createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  static const int currentUserId = 7;

  static const Color orange = Color(0xFFE8784A);
  static const Color cream = Color(0xFFF1EDE5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF252525);
  static const Color grey = Color(0xFF77736D);
  static const Color border = Color(0xFFE7E3DC);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  String? existingImageUrl;

  int? editingArticleId;
  bool isEditMode = false;
  bool _hasReadArguments = false;

  int categoryId = 1;
  bool isSaving = false;

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Teknologi', 'icon': Icons.computer_outlined},
    {'id': 2, 'name': 'Pendidikan', 'icon': Icons.school_outlined},
    {'id': 3, 'name': 'Kuliner', 'icon': Icons.restaurant},
    {'id': 4, 'name': 'Cerita', 'icon': Icons.auto_stories},
    {'id': 5, 'name': 'Opini', 'icon': Icons.forum},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasReadArguments) return;

    _hasReadArguments = true;
    loadArticleData();
  }

  void loadArticleData() {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    debugPrint('==============================');
    debugPrint('WRITER PAGE ARGUMENTS');
    debugPrint('TYPE: ${arguments.runtimeType}');
    debugPrint('DATA: $arguments');
    debugPrint('==============================');

    // Tidak ada arguments = membuat artikel baru.
    if (arguments == null) {
      setState(() {
        isEditMode = false;
        editingArticleId = null;
        existingImageUrl = null;
      });
      return;
    }

    // Ada Map = mode edit.
    if (arguments is Map) {
      final article = Map<String, dynamic>.from(arguments);

      final parsedId = int.tryParse(article['id']?.toString() ?? '');

      final parsedCategoryId = int.tryParse(
        article['categoryId']?.toString() ?? '',
      );

      final title = article['title']?.toString() ?? '';

      final content = article['content']?.toString() ?? '';

      final imageUrl = article['imageUrl']?.toString();

      setState(() {
        isEditMode = true;
        editingArticleId = parsedId;

        titleController.text = title;
        contentController.text = content;

        if (parsedCategoryId != null) {
          categoryId = parsedCategoryId;
        }

        existingImageUrl = imageUrl != null && imageUrl.isNotEmpty
            ? imageUrl
            : null;
      });

      debugPrint('==============================');
      debugPrint('EDIT ARTICLE LOADED');
      debugPrint('ID: $editingArticleId');
      debugPrint('CATEGORY ID: $categoryId');
      debugPrint('TITLE: $title');
      debugPrint('IMAGE URL: $existingImageUrl');
      debugPrint('==============================');

      return;
    }

    debugPrint('WRITER PAGE: arguments tidak valid');
  }

  // =========================
  // PILIH FOTO
  // =========================

  Future<void> pickImage() async {
    if (isSaving) return;

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (!await file.exists()) {
        showMessage('Foto tidak ditemukan');
        return;
      }

      setState(() {
        selectedImage = file;
      });

      debugPrint('==============================');
      debugPrint('FOTO DIPILIH');
      debugPrint('PATH: ${file.path}');
      debugPrint('EXTENSION: ${path.extension(file.path)}');
      debugPrint('SIZE: ${await file.length()} bytes');
      debugPrint('==============================');
    } catch (e) {
      debugPrint('ERROR PICK IMAGE: $e');

      if (!mounted) return;

      showMessage('Gagal memilih foto');
    }
  }

  void removeSelectedImage() {
    if (isSaving) return;

    setState(() {
      selectedImage = null;
    });
  }

  // =========================
  // MIME TYPE FOTO
  // =========================

  MediaType? getImageContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');

      case '.png':
        return MediaType('image', 'png');

      case '.webp':
        return MediaType('image', 'webp');

      case '.gif':
        return MediaType('image', 'gif');

      default:
        return null;
    }
  }

  // =========================
  // SAVE ARTICLE
  // =========================

  Future<void> saveArticle(String status) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      showMessage('Judul belum diisi');
      return;
    }

    if (content.isEmpty) {
      showMessage('Isi artikel belum diisi');
      return;
    }

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final bool isEditing = isEditMode && editingArticleId != null;

      final String url = isEditing
          ? '${Api.posts}/$editingArticleId'
          : Api.posts;

      final request = http.MultipartRequest(
        isEditing ? 'PUT' : 'POST',
        Uri.parse(url),
      );

      // =========================
      // FIELD ARTIKEL
      // =========================

      request.fields.addAll({
        'categoryId': categoryId.toString(),
        'title': title,
        'content': content,
        'authorId': currentUserId.toString(),
        'status': status,
      });

      // =========================
      // FOTO
      // =========================

      if (selectedImage != null) {
        final imagePath = selectedImage!.path;
        final contentType = getImageContentType(imagePath);

        debugPrint('==============================');
        debugPrint('UPLOAD IMAGE');
        debugPrint('IMAGE PATH: $imagePath');
        debugPrint('CONTENT TYPE: $contentType');
        debugPrint('==============================');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: contentType,
          ),
        );
      }

      debugPrint('==============================');
      debugPrint('SAVE ARTICLE');
      debugPrint('METHOD: ${request.method}');
      debugPrint('URL: $url');
      debugPrint('FIELDS: ${request.fields}');
      debugPrint('FILES: ${request.files.map((e) => e.filename).toList()}');
      debugPrint('STATUS: $status');
      debugPrint('EDITING: $isEditing');
      debugPrint('ARTICLE ID: $editingArticleId');
      debugPrint('==============================');

      // =========================
      // KIRIM REQUEST
      // =========================

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('==============================');
      debugPrint('SERVER RESPONSE');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==============================');

      if (!mounted) return;

      // =========================
      // BERHASIL
      // =========================

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = status == 'draft'
            ? 'Artikel disimpan sebagai draft'
            : 'Artikel berhasil dipublikasikan';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.plusJakartaSans()),
          ),
        );

        Navigator.pop(context, true);
        return;
      }

      // =========================
      // ERROR SERVER
      // =========================

      String message = 'Gagal menyimpan artikel';

      try {
        final data = jsonDecode(response.body);

        if (data is Map) {
          if (data['message'] != null) {
            message = data['message'].toString();
          }

          if (data['error'] != null) {
            debugPrint('SERVER ERROR DETAIL: ${data['error']}');
          }
        }
      } catch (e) {
        debugPrint('ERROR PARSE RESPONSE: $e');
      }

      showMessage('$message (${response.statusCode})');
    } catch (e, stackTrace) {
      debugPrint('==============================');
      debugPrint('ERROR SAVE ARTICLE');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('==============================');

      if (!mounted) return;

      showMessage('Tidak dapat mengirim artikel ke server');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.plusJakartaSans())),
    );
  }

  // =========================
  // PLACEHOLDER
  // =========================

  Widget imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: orange,
            size: 27,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tambah foto',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih foto dari galeri',
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: grey),
        ),
      ],
    );
  }

  // =========================
  // IMAGE SECTION
  // =========================

  Widget imageSection() {
    Widget imageWidget;

    if (selectedImage != null) {
      imageWidget = Image.file(
        selectedImage!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return imagePlaceholder();
        },
      );
    } else if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        existingImageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return imagePlaceholder();
        },
      );
    } else {
      imageWidget = imagePlaceholder();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isSaving ? null : pickImage,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: imageWidget),

            if (selectedImage != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: isSaving ? null : removeSelectedImage,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: white, size: 19),
                  ),
                ),
              ),

            if (isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(
                    child: CircularProgressIndicator(color: orange),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TEXT FIELD
  // =========================

  Widget textField({
    required TextEditingController controller,
    required String hint,
    required double height,
    int maxLines = 1,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // =========================
  // BUTTON
  // =========================

  Widget actionButton({
    required String text,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? orange : white,
          foregroundColor: primary ? white : black,
          disabledBackgroundColor: primary ? orange.withOpacity(0.6) : white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: primary ? orange : border),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: black, size: 20),
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: Text(
          isEditMode ? 'Edit Article' : 'Create Article',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageSection(),

              const SizedBox(height: 24),

              Text(
                'Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: black,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: categoryId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: orange,
                    ),
                    dropdownColor: white,
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Row(
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              color: orange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category['name'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              categoryId = value;
                            });
                          },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Judul',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: black,
                ),
              ),

              const SizedBox(height: 8),

              textField(
                controller: titleController,
                hint: 'Tulis judul artikel...',
                height: 55,
              ),

              const SizedBox(height: 20),

              Text(
                'Isi Artikel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: black,
                ),
              ),

              const SizedBox(height: 8),

              textField(
                controller: contentController,
                hint: 'Tulis isi artikel...',
                height: 250,
                maxLines: 12,
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: actionButton(
                      text: 'Simpan Draft',
                      onPressed: () {
                        saveArticle('draft');
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: actionButton(
                      text: 'Publish',
                      primary: true,
                      onPressed: () {
                        saveArticle('published');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
