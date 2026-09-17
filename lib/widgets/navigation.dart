import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
  });

  static const Color orange = Color(0xFFE8784A);
  static const Color grey = Color(0xFF9A938E);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _navItem(
              context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
            ),
          ),

          Expanded(
            child: _navItem(
              context,
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Explorer',
              index: 1,
            ),
          ),

          Expanded(
            child: _addButton(context),
          ),

          Expanded(
            child: _navItem(
              context,
              icon: Icons.edit_note_outlined,
              activeIcon: Icons.edit_note,
              label: 'Artikel',
              index: 3,
            ),
          ),

          Expanded(
            child: _navItem(
              context,
              icon: Icons.library_add_outlined,
              activeIcon: Icons.library_add,
              label: 'Library',
              index: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        if (index == 0) {
          Navigator.pushReplacementNamed(
            context,
            '/HomePage',
          );
        }

        if (index == 1) {
          Navigator.pushReplacementNamed(
            context,
            '/ExplorerPage',
          );
        }

        if (index == 3) {
          Navigator.pushReplacementNamed(
            context,
            '/ArticlesPage',
          );
        }

        if (index == 4) {
          Navigator.pushReplacementNamed(
            context,
            '/LibraryPage',
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 22,
            color: isSelected ? orange : grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? orange : grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/WriterPage',
        );
      },
      child: Transform.translate(
        offset: const Offset(0, -15),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}