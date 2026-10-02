import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface1 = Color(0xFF121212);
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);

class RequestScreen extends StatefulWidget {
  final List<Movie> existingMovies;

  const RequestScreen({Key? key, this.existingMovies = const []}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';
  final Set<int> _submittingIds = {};
  final Set<int> _submittedIds = {};

  void _onSearchChanged(String query) async {
    final clean = query.trim();
    if (clean == _lastQuery) return;
    _lastQuery = clean;

    if (clean.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await ApiService.searchTmdb(clean);
    if (mounted && _lastQuery == clean) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Movie? _findInCatalogue(String title, int? year) {
    final cleanTitle = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final m in widget.existingMovies) {
      final mClean = m.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (mClean.contains(cleanTitle) || cleanTitle.contains(mClean)) {
        return m;
      }
    }
    return null;
  }

  Future<void> _submitRequest(Map<String, dynamic> item) async {
    final tmdbId = item['id'] as int;
    setState(() => _submittingIds.add(tmdbId));

    final res = await ApiService.submitPriorityRequest(
      title: item['title'],
      tmdbId: tmdbId,
      type: item['type'] ?? 'movie',
      year: item['year'],
      poster: item['poster'],
      backdrop: item['backdrop'],
      synopsis: item['overview'],
    );

    if (mounted) {
      setState(() {
        _submittingIds.remove(tmdbId);
        _submittedIds.add(tmdbId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  res['message'] ?? 'Priority Request queued for download!',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text("REQUEST", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Priority Queue",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── 3-Step Explanation Banner (Matching Website) ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Can't find a Movie or Web Series?",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Search below and request any title! Our cloud delivery network automatically indexes and adds requested titles to Cinemax Prime in 4K/HD.",
                  style: TextStyle(fontSize: 12, color: kInkMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStepChip("1", "Search Title"),
                    const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white24),
                    _buildStepChip("2", "Request Title"),
                    const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white24),
                    _buildStepChip("3", "Cloud Ingest"),
                  ],
                ),
              ],
            ),
          ),

          // ── Search Input ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSurface3,
                hintText: "Search movie or series name (e.g. Stree 2, Pushpa)",
                hintStyle: const TextStyle(color: kInkMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: kAccent, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
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

          // ── Results or Empty State ──
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: kAccent))
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_rounded, size: 54, color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? "Type title name above to request"
                                  : "No matches found on TMDB",
                              style: const TextStyle(color: kInkMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final tmdbId = item['id'] as int;
                          final existing = _findInCatalogue(item['title'], item['year']);
                          final isSubmitting = _submittingIds.contains(tmdbId);
                          final isSubmitted = _submittedIds.contains(tmdbId);

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kSurface2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: existing != null ? const Color(0x3322C55E) : Colors.white10,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Poster Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                    imageUrl: item['poster'] ?? '',
                                    width: 55,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: kSurface3),
                                    errorWidget: (_, __, ___) => Container(
                                      color: kSurface3,
                                      child: const Icon(Icons.movie, color: Colors.white24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Title and Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white12,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              (item['type'] == 'series' ? 'Series' : 'Movie').toUpperCase(),
                                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${item['yearStr']}",
                                            style: const TextStyle(fontSize: 12, color: kInkMuted),
                                          ),
                                          if ((item['rating'] as double) > 0) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.star, color: Color(0xFFF5C518), size: 12),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${(item['rating'] as double).toStringAsFixed(1)}",
                                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (existing != null)
                                        const Text(
                                          "Already in catalogue!",
                                          style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.bold),
                                        )
                                      else if (isSubmitted)
                                        const Text(
                                          "✓ Queued for auto-download",
                                          style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Action Button
                                if (existing != null)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF22C55E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => DetailScreen(movie: existing)),
                                      );
                                    },
                                    child: const Text("Watch", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                else if (isSubmitted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text("Queued", style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  )
                                else
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    icon: isSubmitting
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Icon(Icons.bolt, size: 14),
                                    label: const Text("Request", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: isSubmitting ? null : () => _submitRequest(item),
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

  Widget _buildStepChip(String step, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: kAccent.withOpacity(0.2),
            child: Text(step, style: const TextStyle(fontSize: 10, color: kAccent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
