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
      'title': 'DD Sports HD',
      'category': 'Live Sports & Cricket',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
      'badge': 'LIVE HD',
      'status': 'Live Sports • Cricket, National & International Games (1080p)',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
    },
    {
      'title': 'ABP News HD',
      'category': 'Hindi News / 24x7',
      'poster': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'badge': 'LIVE',
      'status': 'Top Headlines • Breaking News & Analysis 24x7',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/ABPNews/index.m3u8',
    },
    {
      'title': 'NDTV India HD',
      'category': 'National News',
      'poster': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
      'badge': 'LIVE',
      'status': 'Prime Time with Ravish & Top Stories (HD Stream)',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/NDTVIndia/index.m3u8',
    },
    {
      'title': 'DD National HD',
      'category': 'Special Events & Live Broadcast',
      'poster': 'https://images.unsplash.com/photo-1518173946687-a4c8a383392e?w=800',
      'badge': 'LIVE 1080p',
      'status': 'Live National Broadcast & Special Events',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/DDNational/index.m3u8',
    },
    {
      'title': 'The Movie Club HD',
      'category': '24/7 Blockbuster Movies',
      'poster': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'badge': 'LIVE CINEMA',
      'status': 'Non-Stop Indian Blockbusters & Action Films',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/TheMovieClub/index.m3u8',
    },
    {
      'title': 'Food Food TV',
      'category': 'Lifestyle & Food',
      'poster': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
      'badge': 'LIVE',
      'status': 'Master Chefs & Delicious Recipes 24x7',
      'streamUrl': 'https://mumbai-edge.smartplaytv.in/FoodFood/index.m3u8',
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
