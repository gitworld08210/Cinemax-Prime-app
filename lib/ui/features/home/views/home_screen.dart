import 'package:flutter/material.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../domain/models/movie.dart';
import '../../../core/app_theme.dart';
import '../../browse/views/browse_screen.dart';
import '../widgets/billboard_hero.dart';
import '../widgets/category_pills.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/request_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabase = SupabaseService();
  bool _isLoading = true;
  String _activeCategory = 'all';

  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _bollywoodMovies = [];
  List<Movie> _seriesMovies = [];
  Movie? _featuredMovie;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final all = await _supabase.fetchAllMovies(limit: 5000000);
      final trending = await _supabase.fetchTrending(limit: 5000000);
      final bollywood = await _supabase.fetchBollywood(limit: 5000000);
      final series = await _supabase.fetchWebSeries(limit: 5000000);

      if (mounted) {
        setState(() {
          _allMovies = all;
          _trendingMovies = trending.isNotEmpty ? trending : all.take(10).toList();
          _bollywoodMovies = bollywood;
          _seriesMovies = series;
          _featuredMovie = all.isNotEmpty ? all.first : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _activeCategory = category);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowseScreen(initialFilter: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'CINEMAX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppTheme.netflixRed,
                letterSpacing: 0.5,
                fontSize: 22,
                fontFamily: 'Bebas Neue',
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'PRIME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Request Title Button (Netflix Pill)
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const RequestDialog(),
              );
            },
            icon: const Text('⚡', style: TextStyle(fontSize: 13)),
            label: const Text(
              'Request',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0x33E50914),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: AppTheme.netflixRed, width: 1),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Search Button
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseScreen(isSearchFocused: true)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.netflixRed,
              backgroundColor: AppTheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Billboard Hero Section
                    BillboardHero(featuredMovie: _featuredMovie),
                    const SizedBox(height: 14),

                    // Netflix Category Filter Pills
                    CategoryPills(
                      activeCategory: _activeCategory,
                      onSelectCategory: _onCategorySelected,
                    ),
                    const SizedBox(height: 20),

                    // Trending Now
                    MovieCarousel(
                      title: 'Trending Now',
                      emoji: '🔥',
                      movies: _trendingMovies,
                      onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'trending')),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Bollywood Hits
                    if (_bollywoodMovies.isNotEmpty) ...[
                      MovieCarousel(
                        title: 'Bollywood & Indian Cinema',
                        emoji: '🇮🇳',
                        movies: _bollywoodMovies,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'bollywood')),
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Web Series
                    if (_seriesMovies.isNotEmpty) ...[
                      MovieCarousel(
                        title: 'Web Series & TV Shows',
                        emoji: '📺',
                        movies: _seriesMovies,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'series')),
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Recently Added
                    MovieCarousel(
                      title: 'Recently Added to Cinemax',
                      emoji: '✨',
                      movies: _allMovies,
                      onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'all')),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF121212),
          indicatorColor: const Color(0x33E50914),
          selectedIndex: 0,
          height: 60,
          onDestinationSelected: (idx) {
            if (idx == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'all')),
              );
            } else if (idx == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseScreen(initialFilter: 'series')),
              );
            } else if (idx == 3) {
              showDialog(
                context: context,
                builder: (_) => const RequestDialog(),
              );
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.netflixRed),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.netflixRed),
              label: 'Browse',
            ),
            NavigationDestination(
              icon: Icon(Icons.tv_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.tv_rounded, color: AppTheme.netflixRed),
              label: 'Series',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.bolt_rounded, color: AppTheme.netflixRed),
              label: 'Request',
            ),
          ],
        ),
      ),
    );
  }
}
