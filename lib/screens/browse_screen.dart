import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface1 = Color(0xFF121212);
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);
const Color kRating = Color(0xFFF5C518);

class BrowseScreen extends StatefulWidget {
  final List<Movie> movies;
  final String initialFilter;

  const BrowseScreen({
    Key? key,
    required this.movies,
    this.initialFilter = 'all',
  }) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late String selectedFilter;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  final List<Map<String, String>> filters = [
    {'id': 'all', 'label': 'All Titles'},
    {'id': 'movies', 'label': 'Movies'},
    {'id': 'series', 'label': 'Web Series'},
    {'id': 'top10', 'label': 'Top 10 Today'},
    {'id': 'bollywood', 'label': 'Bollywood'},
    {'id': 'hollywood', 'label': 'Hollywood (Dual Audio)'},
    {'id': 'south', 'label': 'South Hindi'},
    {'id': '1080p', 'label': '1080p Full HD'},
    {'id': '4k', 'label': '4K UHD'},
    {'id': 'action', 'label': 'Action & Thriller'},
    {'id': 'drama', 'label': 'Drama & Romance'},
    {'id': 'sci-fi', 'label': 'Sci-Fi & Fantasy'},
  ];

  List<Movie> get filteredMovies {
    List<Movie> list = widget.movies;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((m) => m.title.toLowerCase().contains(q) || m.genre.any((g) => g.toLowerCase().contains(q))).toList();
    }

    switch (selectedFilter) {
      case 'movies':
        return list.where((m) => m.type == 'movie').toList();
      case 'series':
        return list.where((m) => m.type == 'series' || m.genre.any((g) => g.toLowerCase().contains('web series') || g.toLowerCase().contains('series'))).toList();
      case 'top10':
        return list.where((m) => m.isTrending).take(10).toList();
      case 'bollywood':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('bollywood'))).toList();
      case 'hollywood':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('hollywood') || g.toLowerCase().contains('dual audio'))).toList();
      case 'south':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('south'))).toList();
      case '1080p':
        return list.where((m) => m.quality.toLowerCase().contains('1080p')).toList();
      case '4k':
        return list.where((m) => m.quality.toLowerCase().contains('4k') || m.quality.toLowerCase().contains('2160p')).toList();
      case 'action':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('action') || g.toLowerCase().contains('thriller'))).toList();
      case 'drama':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('drama') || g.toLowerCase().contains('romance'))).toList();
      case 'sci-fi':
        return list.where((m) => m.genre.any((g) => g.toLowerCase().contains('sci-fi') || g.toLowerCase().contains('fantasy'))).toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredMovies;

    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Browse Catalogue",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ── Search Field ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSurface2,
                hintText: "Search catalogue by title or actor...",
                hintStyle: const TextStyle(color: kInkMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: kAccent, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Horizontal Filter Chips ──
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = f['id'] == selectedFilter;
                return ChoiceChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => selectedFilter = f['id']!);
                  },
                  backgroundColor: kSurface2,
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: isSelected ? kAccent : Colors.white12),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Results Counter ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${results.length} Titles Found",
                  style: const TextStyle(color: kInkMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Grid of Titles ──
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_outlined, size: 54, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 12),
                        const Text("No titles match your filter", style: TextStyle(color: kInkMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final movie = results[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: movie.poster,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: kSurface2),
                                      errorWidget: (_, __, ___) => Container(
                                        color: kSurface2,
                                        child: const Icon(Icons.movie, color: Colors.white24),
                                      ),
                                    ),
                                  ),
                                  // Quality badge
                                  if (movie.quality.isNotEmpty)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.75),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.white24, width: 0.5),
                                        ),
                                        child: Text(
                                          movie.quality.contains('4K') ? '4K' : 'HD',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Rating
                                  if (movie.rating > 0)
                                    Positioned(
                                      bottom: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.75),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: kRating, size: 10),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${movie.rating}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
