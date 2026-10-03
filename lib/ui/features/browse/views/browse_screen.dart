import 'package:flutter/material.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../domain/models/movie.dart';
import '../../../core/app_theme.dart';
import '../../home/widgets/movie_card.dart';

class BrowseScreen extends StatefulWidget {
  final String initialFilter;
  final bool isSearchFocused;

  const BrowseScreen({
    super.key,
    this.initialFilter = 'all',
    this.isSearchFocused = false,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadMovies();

    if (widget.isSearchFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    final movies = await _supabase.fetchAllMovies(limit: 100);
    if (mounted) {
      setState(() {
        _allMovies = movies;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<Movie> temp = List.from(_allMovies);

    // Apply Tab Filter
    if (_selectedFilter == 'movies') {
      temp = temp.where((m) => !m.isSeries).toList();
    } else if (_selectedFilter == 'series') {
      temp = temp.where((m) => m.isSeries).toList();
    } else if (_selectedFilter == 'bollywood') {
      temp = temp.where((m) => m.genre.any((g) => g.toLowerCase().contains('bollywood') || g.toLowerCase().contains('hindi'))).toList();
    } else if (_selectedFilter == 'trending') {
      temp.sort((a, b) => b.rating.compareTo(a.rating));
    }

    // Apply Search Query
    if (query.isNotEmpty) {
      temp = temp.where((m) => m.title.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _filteredMovies = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text(
          'Browse Titles',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Input Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.canvas,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (_) => _applyFilters(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search movies, web series, genres...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF242424),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF333333)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF333333)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.netflixRed, width: 1.5),
                ),
              ),
            ),
          ),

          // Netflix Pill Filter Bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppTheme.canvas,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Movies', 'movies'),
                _buildFilterChip('TV Shows', 'series'),
                _buildFilterChip('Bollywood', 'bollywood'),
                _buildFilterChip('Top Rated', 'trending'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderSubtle),

          // Grid Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed))
                : _filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie_filter_outlined, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No titles matching "${_searchController.text}"'
                                  : 'No titles found in this category',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(movie: _filteredMovies[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = _selectedFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.netflixRed,
        backgroundColor: const Color(0xFF222222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.netflixRed : const BorderSide(color: Color(0xFF333333)).color,
        ),
        onSelected: (val) {
          setState(() {
            _selectedFilter = id;
            _applyFilters();
          });
        },
      ),
    );
  }
}
