import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);
const Color kRating = Color(0xFFF5C518);

class SeriesScreen extends StatefulWidget {
  final List<Movie> movies;

  const SeriesScreen({Key? key, required this.movies}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String selectedFilter = 'all';

  List<Movie> get seriesList {
    final allSeries = widget.movies.where((m) =>
      m.type == 'series' || m.genre.any((g) => g.toLowerCase().contains('web series') || g.toLowerCase().contains('series'))
    ).toList();

    switch (selectedFilter) {
      case 'hindi':
        return allSeries.where((m) =>
          m.genre.any((g) => g.toLowerCase().contains('hindi') || g.toLowerCase().contains('bollywood'))
        ).toList();
      case 'hollywood':
        return allSeries.where((m) =>
          m.genre.any((g) => g.toLowerCase().contains('hollywood') || g.toLowerCase().contains('dual audio'))
        ).toList();
      case 'crime':
        return allSeries.where((m) =>
          m.genre.any((g) => g.toLowerCase().contains('crime') || g.toLowerCase().contains('thriller'))
        ).toList();
      default:
        return allSeries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = seriesList;

    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Web Series & Shows",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 42,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'All Web Series'),
                const SizedBox(width: 8),
                _buildFilterChip('hindi', 'Hindi & South Dubbed'),
                const SizedBox(width: 8),
                _buildFilterChip('hollywood', 'Hollywood (Dual Audio)'),
                const SizedBox(width: 8),
                _buildFilterChip('crime', 'Crime & Thriller'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tv_off_rounded, size: 54, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 12),
                        const Text("No web series in this category yet.", style: TextStyle(color: kInkMuted, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text("Use the Request tab to add your favourite series!", style: TextStyle(color: kAccent, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final show = list[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailScreen(movie: show)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: kSurface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                child: CachedNetworkImage(
                                  imageUrl: show.poster,
                                  width: 100,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: kSurface3),
                                  errorWidget: (_, __, ___) => Container(
                                    color: kSurface3,
                                    child: const Icon(Icons.tv, color: Colors.white24),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        show.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: kAccent.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "SERIES",
                                              style: TextStyle(color: kAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("${show.year}", style: const TextStyle(color: kInkMuted, fontSize: 12)),
                                          if (show.rating > 0) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.star, color: kRating, size: 12),
                                            const SizedBox(width: 2),
                                            Text("${show.rating}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        show.synopsis,
                                        style: const TextStyle(color: kInkMuted, fontSize: 12, height: 1.3),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = selectedFilter == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => selectedFilter = id);
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
  }
}
