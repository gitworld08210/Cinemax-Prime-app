import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'player_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);

class LiveSportsScreen extends StatelessWidget {
  final List<Movie> movies;

  const LiveSportsScreen({Key? key, required this.movies}) : super(key: key);

  final List<Map<String, String>> liveChannels = const [
    {
      'title': 'Star Sports 1 Hindi HD',
      'category': 'Cricket / IPL 2027',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
      'badge': 'LIVE',
      'status': 'India vs Australia • 2nd ODI (Live in 1080p 60FPS)',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
    {
      'title': 'Sony Ten 1 HD',
      'category': 'Football / Champions League',
      'poster': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800',
      'badge': 'LIVE',
      'status': 'Real Madrid vs Man City • Matchday 4',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
    {
      'title': 'Star Sports Select HD',
      'category': 'Premier League / Football',
      'poster': 'https://images.unsplash.com/photo-1489944445391-11dd35574549?w=800',
      'badge': 'LIVE',
      'status': 'Arsenal vs Chelsea • Super Sunday',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
    {
      'title': 'WWE Network Live',
      'category': 'Combat Sports / Wrestling',
      'poster': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=800',
      'badge': 'LIVE',
      'status': 'Friday Night SmackDown (HD Stream)',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
    {
      'title': 'JioCinema Sports 4K',
      'category': 'Cricket / T20 League',
      'poster': 'https://images.unsplash.com/photo-1531415074868-036b107e775a?w=800',
      'badge': 'LIVE',
      'status': 'Multi-Cam Ultra HD Stream',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
  ];

  void _openLiveStream(BuildContext context, Map<String, String> channel) {
    final liveMovie = Movie(
      id: 'live-${channel['title']!.hashCode}',
      title: channel['title']!,
      synopsis: channel['status']!,
      poster: channel['poster']!,
      backdrop: channel['poster']!,
      videoUrl: channel['streamUrl']!,
      downloadUrl: '',
      year: DateTime.now().year,
      duration: 'LIVE',
      quality: '1080p 60FPS Live',
      rating: 9.5,
      genre: ['Live Sports', 'Cricket', 'HD'],
      type: 'live',
      badge: 'LIVE',
      isFeatured: true,
      isTrending: true,
      audioTracks: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PremiumPlayerScreen(movie: liveMovie)),
    );
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
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Live Sports & Channels",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: liveChannels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final ch = liveChannels[index];
          return GestureDetector(
            onTap: () => _openLiveStream(context, ch),
            child: Container(
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: ch['poster']!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: kSurface3, height: 160),
                          errorWidget: (_, __, ___) => Container(color: kSurface3, height: 160),
                        ),
                      ),
                      // Dark gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),
                      ),
                      // LIVE Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: Colors.white),
                              SizedBox(width: 4),
                              Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                      // Play circle in center
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(ch['category']!.toUpperCase(), style: const TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ch['title']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ch['status']!,
                          style: const TextStyle(color: kInkMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
