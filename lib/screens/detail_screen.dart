import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import 'player_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kSurface2 = Color(0xFF181818);
const Color kRating = Color(0xFFF5C518);
const Color kInkMuted = Color(0xFF8A8F98);

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({Key? key, required this.movie}) : super(key: key);

  void _launchDownload(BuildContext context) async {
    final Uri url = Uri.parse(movie.downloadUrl.isNotEmpty ? movie.downloadUrl : movie.videoUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch download.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── Backdrop with vignette ──
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.backdrop.isNotEmpty ? movie.backdrop : movie.poster,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x80000000), Colors.black],
                        stops: [0.25, 0.65, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),

                  // Meta row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Quality badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(4)),
                        child: Text(movie.quality, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      // Year
                      Text('${movie.year}', style: const TextStyle(color: kInkMuted, fontSize: 14)),
                      // Duration
                      Text(movie.duration, style: const TextStyle(color: kInkMuted, fontSize: 14)),
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: kRating, size: 16),
                          const SizedBox(width: 3),
                          Text('${movie.rating}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      // Dual Audio indicator
                      if (movie.audioTracks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: kAccent.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('🔊 Dual Audio', style: TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Play Button (big, full width) ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text('Play Movie', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPlayerScreen(movie: movie)));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Download Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.download, size: 22),
                      label: const Text('Download', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      onPressed: () => _launchDownload(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Synopsis ──
                  const Text('Synopsis', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    movie.synopsis,
                    style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // ── Genre chips ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genre.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(g, style: const TextStyle(color: kInkMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
