import 'package:flutter/material.dart';
import '../../../../domain/models/movie.dart';
import '../../../core/app_theme.dart';
import '../../detail/views/detail_screen.dart';
import '../../player/views/player_screen.dart';

class BillboardHero extends StatelessWidget {
  final Movie? featuredMovie;

  const BillboardHero({super.key, required this.featuredMovie});

  @override
  Widget build(BuildContext context) {
    if (featuredMovie == null) {
      return Container(
        height: 420,
        color: AppTheme.surface,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.netflixRed),
        ),
      );
    }

    final movie = featuredMovie!;

    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          height: 420,
          width: double.infinity,
          child: Image.network(
            movie.backdrop.isNotEmpty ? movie.backdrop : movie.poster,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppTheme.surface),
          ),
        ),

        // Multi-Stop Netflix Dark Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.canvas.withOpacity(0.3),
                  AppTheme.canvas.withOpacity(0.85),
                  AppTheme.canvas,
                ],
                stops: const [0.0, 0.45, 0.85, 1.0],
              ),
            ),
          ),
        ),

        // Billboard Content
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Row: TOP 10 & Netflix Match Green Rating
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.netflixRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'TOP 10',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${((movie.rating.clamp(1.0, 10.0) / 10.0) * 100).toInt()}% Match',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.matchGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${movie.year} • ${movie.genre.isNotEmpty ? movie.genre.first : "Cinema"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // Synopsis Preview
              if (movie.synopsis.isNotEmpty)
                Text(
                  movie.synopsis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 14),

              // Action Buttons: Authentic Netflix Play & More Info
              Row(
                children: [
                  // Netflix Solid White Play Button
                  Expanded(
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
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Netflix Translucent Gray More Info Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'More Info',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.infoButtonBg,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
