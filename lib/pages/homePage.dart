import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color orange = Color(0xFFDD6E42);
  static const Color blue = Color(0xFF4F6D7A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RuangKata",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Temukan cerita, ide, dan inspirasi.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: black,
                        ),
                      ),
                    ],
                  ),

                  // NOTIFICATION
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: white,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ================= SEARCH =================
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: blue.withOpacity(0.25),
                  ),
                ),
                child: TextField(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: black,
                  ),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search,
                      color: blue,
                    ),
                    hintText: "Cari artikel...",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ================= KATEGORI =================
              Text(
                "Kategori",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    categoryButton("Semua", true),
                    categoryButton("Pendidikan", false),
                    categoryButton("Inspirasi", false),
                    categoryButton("Lifestyle", false),
                    categoryButton("Teknologi", false),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= ARTIKEL TERBARU =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Artikel Terbaru",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),

                  Text(
                    "Lihat semua",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ARTIKEL 1
              articleCard(
                title: "Menemukan Makna di Balik Sebuah Cerita",
                category: "Inspirasi",
                author: "RuangKata",
              ),

              const SizedBox(height: 15),

              // ARTIKEL 2
              articleCard(
                title: "Belajar dari Hal-Hal Sederhana",
                category: "Pendidikan",
                author: "RuangKata",
              ),

              const SizedBox(height: 15),

              // ARTIKEL 3
              articleCard(
                title: "Kenapa Kita Perlu Terus Menulis?",
                category: "Lifestyle",
                author: "RuangKata",
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: orange,
        unselectedItemColor: blue,

        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Search",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: "Write",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: "Bookmarks",
          ),
        ],
      ),
    );
  }

  // ================= CATEGORY =================
  Widget categoryButton(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: active ? orange : white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? orange : blue.withOpacity(0.3),
        ),
      ),

      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: active ? white : blue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ================= ARTICLE CARD =================
  Widget articleCard({
    required String title,
    required String category,
    required String author,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: blue.withOpacity(0.15),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // GAMBAR
          Container(
            width: 100,
            height: 100,

            decoration: BoxDecoration(
              color: blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.image_outlined,
              size: 35,
              color: blue,
            ),
          ),

          const SizedBox(width: 14),

          // INFORMASI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: orange,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: black,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "oleh $author",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}