import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class CategoryPills extends StatelessWidget {
  final String activeCategory;
  final Function(String) onSelectCategory;

  const CategoryPills({
    super.key,
    required this.activeCategory,
    required this.onSelectCategory,
  });

  static const List<Map<String, String>> categories = [
    {'id': 'all', 'label': 'All Titles'},
    {'id': 'movies', 'label': 'Movies'},
    {'id': 'series', 'label': 'TV Shows'},
    {'id': 'bollywood', 'label': 'Bollywood Hits'},
    {'id': 'hollywood', 'label': 'Hollywood'},
    {'id': 'south', 'label': 'South Dubbed'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat['id'] == activeCategory;

          return GestureDetector(
            onTap: () => onSelectCategory(cat['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.netflixRed : const Color(0xFF222222),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.netflixRed : const BorderSide(color: Color(0xFF333333)).color,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.netflixRed.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
