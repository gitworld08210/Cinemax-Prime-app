import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'main_navigation_screen.dart';
import 'browse_screen.dart';
import 'request_screen.dart';
import 'player_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface1 = Color(0xFF121212);
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);
const Color kRating = Color(0xFFF5C518);

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}

class HomeScreenContent extends StatefulWidget {
  final List<Movie> movies;
  final Future<void> Function() onRefresh;

  const HomeScreenContent({
    Key? key,
    required this.movies,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String activeFilter = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Exclude 18+ content from home screen
  List<Movie> get allMovies => widget.movies.where((m) => !m.isAdult).toList();

  // Filters matching exact website categories
  List<Movie> _filterByCategory(String cat) {
    switch (cat) {
      case 'movies':
        return allMovies.where((m) => m.type == 'movie').toList();
      case 'series':
        return allMovies.where((m) => m.type == 'series' || m.genre.any((g) => g.toLowerCase().contains('web series'))).toList();
      case 'bollywood':
        return allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('bollywood'))).toList();
      case 'hollywood':
        return allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('hollywood') || g.toLowerCase().contains('dual audio'))).toList();
      case 'south':
        return allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('south'))).toList();
      case 'top10':
        return allMovies.where((m) => m.isTrending).take(10).toList();
      case 'action':
        return allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('action') || g.toLowerCase().contains('thriller'))).toList();
      default:
        return allMovies;
    }
  }

  List<Movie> get displayMovies {
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      return allMovies.where((m) => m.title.toLowerCase().contains(q)).toList();
    }
    return _filterByCategory(activeFilter);
  }

  // Section helpers
  List<Movie> get recentlyAdded => allMovies.take(20).toList();
  List<Movie> get trendingNow => allMovies.where((m) => m.isTrending).toList();
  List<Movie> get bollywoodMovies => allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('bollywood'))).toList();
  List<Movie> get hollywoodMovies => allMovies.where((m) => m.genre.any((g) => g.toLowerCase().contains('hollywood') || g.toLowerCase().contains('dual audio'))).toList();
  List<Movie> get webSeries => allMovies.where((m) => m.type == 'series' || m.genre.any((g) => g.toLowerCase().contains('web series'))).toList();

  Movie? get heroMovie => allMovies.isNotEmpty ? allMovies.firstWhere((m) => m.isFeatured, orElse: () => allMovies.first) : null;

  void _openDetail(Movie movie) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)));
  }

  void _launchDownload(Movie movie) {
    if (movie.audioTracks.length > 1) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF141414),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.download, color: kAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Download Audio", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text("${movie.title} • ${movie.quality}", style: const TextStyle(color: kInkMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...movie.audioTracks.map((track) {
                    final isHindi = track.label.toLowerCase().contains('hindi') || track.lang == 'hi';
                    final downloadLink = track.videoUrl.isNotEmpty
                        ? (track.videoUrl.contains('/stream/')
                            ? track.videoUrl.replaceAll('/stream/', '/download/') + '?download=1'
                            : track.videoUrl)
                        : movie.downloadUrl;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isHindi ? kAccent.withOpacity(0.4) : Colors.white10),
                      ),
                      child: ListTile(
                        leading: Icon(isHindi ? Icons.translate : Icons.audiotrack, color: isHindi ? kAccent : Colors.white70),
                        title: Text(track.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text("${movie.quality} • Fast Direct Download", style: const TextStyle(color: kInkMuted, fontSize: 12)),
                        trailing: const Icon(Icons.arrow_downward, color: kAccent, size: 20),
                        onTap: () async {
                          Navigator.pop(ctx);
                          final uri = Uri.parse(downloadLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    } else {
      final uri = Uri.parse(movie.downloadUrl.isNotEmpty ? movie.downloadUrl : movie.videoUrl);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: allMovies.isEmpty
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : RefreshIndicator(
              color: kAccent,
              onRefresh: widget.onRefresh,
              child: CustomScrollView(
                slivers: [
                  // ── Navbar ──
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: kCanvas,
                    toolbarHeight: 56,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('CINEMAX', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: kAccent.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('PRIME', style: TextStyle(color: kAccent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _showSearchSheet,
                      ),
                    ],
                  ),

                  // ── Hero Billboard ──
                  if (heroMovie != null)
                    SliverToBoxAdapter(child: _buildHeroBillboard(heroMovie!)),

                  // ── Category Pill Bar (exact match) ──
                  SliverToBoxAdapter(child: _buildCategoryPillBar()),

                  // ── If search/filter active show grid ──
                  if (searchQuery.isNotEmpty || activeFilter != 'all') ...[
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildPosterCard(displayMovies[i]),
                          childCount: displayMovies.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.52,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 10,
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Recently Added (NEW) ──
                    if (recentlyAdded.isNotEmpty) _buildRow('Recently added', recentlyAdded, badge: 'NEW', filterKey: 'all', seeAllLabel: 'See all ›'),
                    // ── Trending Now ──
                    if (trendingNow.isNotEmpty) _buildRow('Trending Now', trendingNow, filterKey: 'top10', seeAllLabel: 'Explore All ›'),
                    // ── Bollywood & Indian Cinema ──
                    if (bollywoodMovies.isNotEmpty) _buildRow('Bollywood & Indian Cinema', bollywoodMovies, filterKey: 'bollywood', seeAllLabel: 'See More ›'),
                    // ── Hollywood & Global Cinema ──
                    if (hollywoodMovies.isNotEmpty) _buildRow('Hollywood & Global Cinema', hollywoodMovies, filterKey: 'hollywood', seeAllLabel: 'Browse ›'),
                    // ── Web Series ──
                    if (webSeries.isNotEmpty) _buildRow('Web Series', webSeries, filterKey: 'series', seeAllLabel: 'See all ›'),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Hero Billboard (matches website exactly)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroBillboard(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: Container(
        height: 460,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.backdrop.isNotEmpty ? movie.backdrop : movie.poster,
              fit: BoxFit.cover,
            ),
            // Vignette gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x80000000), Colors.black],
                  stops: [0.2, 0.65, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.15),
                      border: Border.all(color: kAccent.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: kAccent, size: 14),
                        SizedBox(width: 4),
                        Text('Featured', style: TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Meta row
                  Row(
                    children: [
                      Icon(Icons.star, color: kRating, size: 15),
                      const SizedBox(width: 3),
                      Text('${movie.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(width: 10),
                      Text('${movie.year}', style: const TextStyle(color: kInkMuted, fontSize: 13)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(3)),
                        child: Text(movie.quality, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Synopsis (2 lines)
                  Text(
                    movie.synopsis,
                    style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Play Movie
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: const Text('Play Movie', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PremiumPlayerScreen(movie: movie)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // Download
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () => _launchDownload(movie),
                        ),
                        const SizedBox(width: 8),
                        // Browse All
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Browse All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrowseScreen(movies: widget.movies),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Category Pill Bar (exact website match)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCategoryPillBar() {
    final categories = [
      {'key': 'all', 'label': 'All'},
      {'key': 'movies', 'label': 'Movies'},
      {'key': 'series', 'label': 'TV Shows'},
      {'key': 'bollywood', 'label': 'Bollywood Hits'},
      {'key': 'hollywood', 'label': 'Hollywood'},
      {'key': 'south', 'label': 'South Hindi Dubbed'},
      {'key': 'top10', 'label': 'Top 10 Today'},
      {'key': 'action', 'label': 'Action & Thriller'},
      {'key': 'request', 'label': '⚡ Request Title'},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isActive = activeFilter == cat['key'];
          return GestureDetector(
            onTap: () {
              if (cat['key'] == 'request') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RequestScreen(existingMovies: widget.movies)),
                );
                return;
              }
              setState(() {
                activeFilter = cat['key']!;
                searchQuery = '';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? kAccent : kSurface2,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: isActive ? kAccent : Colors.white.withOpacity(0.08)),
              ),
              alignment: Alignment.center,
              child: Text(
                cat['label']!,
                style: TextStyle(
                  color: isActive ? Colors.white : kInkMuted,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Carousel Row (matches website stream-section layout)
  // ═══════════════════════════════════════════════════════════════
  SliverToBoxAdapter _buildRow(String title, List<Movie> movies, {String? badge, String filterKey = 'all', String seeAllLabel = 'See all ›'}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrowseScreen(
                          movies: widget.movies,
                          initialFilter: filterKey,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Text(
                      seeAllLabel,
                      style: const TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 236,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: movies.length,
              itemBuilder: (ctx, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _buildPosterCard(movies[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Poster Card (matches website poster-card)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPosterCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: SizedBox(
        width: 125,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.poster,
                    width: 125,
                    height: 170,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: 125, height: 170, color: kSurface2),
                    errorWidget: (_, __, ___) => Container(
                      width: 125, height: 170, color: kSurface2,
                      child: const Icon(Icons.movie, color: Colors.white24, size: 40),
                    ),
                  ),
                  // Dual Audio badge
                  if (movie.audioTracks.isNotEmpty)
                    Positioned(
                      top: 6, left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(3)),
                        child: const Text('DUAL', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  // Series badge
                  if (movie.type == 'series')
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(3)),
                        child: const Text('SERIES', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  Positioned(
                    bottom: 6, left: 6,
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: kRating, size: 12),
                        const SizedBox(width: 2),
                        Text('${movie.rating}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: Text(
                movie.title,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Search Bottom Sheet
  // ═══════════════════════════════════════════════════════════════
  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search titles',
                  hintStyle: const TextStyle(color: kInkMuted),
                  prefixIcon: const Icon(Icons.search, color: kAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: kInkMuted),
                    onPressed: () {
                      _searchController.clear();
                      setState(() { searchQuery = ''; activeFilter = 'all'; });
                      Navigator.pop(ctx);
                    },
                  ),
                  filled: true,
                  fillColor: kSurface3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (val) {
                  setState(() { searchQuery = val.trim(); activeFilter = 'all'; });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
