import 'package:flutter/material.dart';
import '../../../../domain/models/movie.dart';
import '../../../core/app_theme.dart';
import '../../player/views/player_screen.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final matchScore = ((movie.rating.clamp(1.0, 10.0) / 10.0) * 100).toInt();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: CustomScrollView(
        slivers: [
          // App Bar with Backdrop Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.canvas,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.backdrop.isNotEmpty ? movie.backdrop : movie.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.surface),
                  ),
                  // Multi-stop Netflix dark vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.canvas.withOpacity(0.5),
                          AppTheme.canvas,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Center Play Button (Netflix Solid White Circle)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 38),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Meta Info Badges: Match Green, Quality, Year
                  Row(
                    children: [
                      Text(
                        '$matchScore% Match',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.matchGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${movie.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF404040)),
                        ),
                        child: Text(
                          movie.quality,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        movie.isSeries ? 'TV Series' : 'Movie',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Genre Chips (Dark Pills)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: movie.genre.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Netflix Play Button (Solid White with Black Text)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                      label: const Text(
                        'Play',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Secondary Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie, isBackupServer: true)),
                            );
                          },
                          icon: const Icon(Icons.connected_tv_rounded, color: Colors.white, size: 18),
                          label: const Text(
                            'Backup Server',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.infoButtonBg,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to My List'),
                              backgroundColor: AppTheme.surfaceElevated,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF262626),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Starting fast download...'),
                              backgroundColor: AppTheme.surfaceElevated,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF262626),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Synopsis Header
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.synopsis.isNotEmpty
                        ? movie.synopsis
                        : 'Experience this title in ultra-clear 1080p stream with Dolby Atmos sound on Cinemax Prime.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Server Selector Card (Netflix Dark Surface)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.dns_rounded, color: AppTheme.netflixRed, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Available Streaming Sources',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildServerRow(context, 'Server 1 (Primary 1080p)', 'Cinemax Telegram Cloud Node', true),
                        const SizedBox(height: 8),
                        _buildServerRow(context, 'Server 2 (AutoEmbed HD)', 'Universal Multi-Source Player', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerRow(BuildContext context, String name, String subtitle, bool isPrimary) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie, isBackupServer: !isPrimary)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0x22E50914) : const Color(0xFF202020),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPrimary ? AppTheme.netflixRed : const Color(0xFF333333),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isPrimary ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
