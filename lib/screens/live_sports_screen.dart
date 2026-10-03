import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF222222);
const Color kInkMuted = Color(0xFF8A8F98);

class LiveSportsScreen extends StatefulWidget {
  final List<Movie> movies;

  const LiveSportsScreen({Key? key, required this.movies}) : super(key: key);

  @override
  State<LiveSportsScreen> createState() => _LiveSportsScreenState();
}

class _LiveSportsScreenState extends State<LiveSportsScreen> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadLiveChannels();
  }

  Future<void> _loadLiveChannels() async {
    final remote = await ApiService.fetchLiveChannels();
    if (mounted && remote.isNotEmpty) {
      setState(() {
        final customStreams = _liveItems.where((i) => i['categoryLabel'] == 'CUSTOM STREAM').toList();
        _liveItems.clear();
        _liveItems.addAll(customStreams);
        _liveItems.addAll(remote);
      });
    }
  }

  // ── Channels & Matches Data ──
  final List<Map<String, dynamic>> _liveItems = [
    // ═════════════════════════════════════════════════════════════
    //  FEATURED LIVE MATCH: INDIA vs WEST INDIES
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'India vs West Indies - Live Match',
      'category': 'cricket',
      'categoryLabel': '🔥 LIVE CRICKET SPECIAL',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
      'badge': 'LIVE 4K • 60 FPS',
      'status': 'IND vs WI Live Broadcast • Multi-Server (4K / 1080p / 720p Buffer-Free)',
      'isFeatured': true,
      'servers': [
        {
          'name': 'Server 1: 4K Ultra HD (60 FPS)',
          'quality': '4K UHD (High Bitrate)',
          'speed': 'Ultra Fast CDN',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
        {
          'name': 'Server 2: 1080p Full HD (Recommended)',
          'quality': '1080p (Zero Buffer)',
          'speed': 'Buffer-Free High Speed',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
        {
          'name': 'Server 3: 720p HD (Low Data Mode)',
          'quality': '720p (Smooth on 4G/5G)',
          'speed': 'Data Saver',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  STAR SPORTS & JIOHOTSTAR LIVE CHANNELS
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'Star Sports 1 Hindi HD',
      'category': 'cricket',
      'categoryLabel': 'STAR SPORTS NETWORK',
      'poster': 'https://images.unsplash.com/photo-1531415074868-036b10554f0a?w=1200&q=80',
      'badge': '1080p 50FPS',
      'status': 'Live Hindi Commentary • IND vs WI & International Cricket 24x7',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Star Sports Hindi 1080p Primary',
          'quality': '1080p HD',
          'speed': 'High Bitrate',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
        {
          'name': 'Star Sports Hindi 720p Backup',
          'quality': '720p Smooth',
          'speed': 'Low Latency',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
      ],
    },
    {
      'title': 'Star Sports 1 English HD',
      'category': 'cricket',
      'categoryLabel': 'STAR SPORTS NETWORK',
      'poster': 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=1200&q=80',
      'badge': 'LIVE HD',
      'status': 'Live English Commentary • Global Cricket Feed & Expert Analysis',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Star Sports English 1080p',
          'quality': '1080p HD',
          'speed': 'Primary Feed',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },
    {
      'title': 'Sports18 1 HD / JioHotstar Live',
      'category': 'cricket',
      'categoryLabel': 'JIOHOTSTAR / SPORTS18',
      'poster': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=1200&q=80',
      'badge': 'LIVE 4K / HD',
      'status': 'Official Digital Sports Feed • Multi-Angle Cricket Streaming',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Sports18 4K Ultra Stream',
          'quality': '4K UHD',
          'speed': 'Ultra High Speed',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
        {
          'name': 'Sports18 1080p Buffer-Free',
          'quality': '1080p HD',
          'speed': 'Fast CDN',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
      ],
    },
    {
      'title': 'DD Sports 1.0 HD (Doordarshan Official)',
      'category': 'cricket',
      'categoryLabel': 'FREE-TO-AIR CRICKET',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
      'badge': 'OFFICIAL FTA',
      'status': 'Direct National Satellite Feed • Zero Delay • All India Cricket',
      'isFeatured': false,
      'servers': [
        {
          'name': 'DD Sports Cloudfront HD',
          'quality': '1080p HD',
          'speed': 'Direct AWS CDN',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
        {
          'name': 'DD Sports Mumbai Edge',
          'quality': '1080p 60FPS',
          'speed': 'Direct Edge Server',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },
    {
      'title': 'Sky Sports Cricket HD',
      'category': 'cricket',
      'categoryLabel': 'INTERNATIONAL CRICKET',
      'poster': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=1200&q=80',
      'badge': '1080p 60FPS',
      'status': 'International Low-Latency Cricket Coverage',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Sky Sports Cricket Primary Feed',
          'quality': '1080p 60FPS',
          'speed': 'Low Latency',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  NEWS & ENTERTAINMENT
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'ABP News HD',
      'category': 'news',
      'categoryLabel': 'HINDI NEWS / 24X7',
      'poster': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'badge': 'LIVE',
      'status': 'Top Headlines • Breaking News & Analysis 24x7',
      'isFeatured': false,
      'servers': [
        {
          'name': 'ABP News Live Feed',
          'quality': '1080p HD',
          'speed': 'High Speed',
          'url': 'https://mumbai-edge.smartplaytv.in/ABPNews/index.m3u8',
        },
      ],
    },
    {
      'title': 'NDTV India HD',
      'category': 'news',
      'categoryLabel': 'NATIONAL NEWS',
      'poster': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
      'badge': 'LIVE',
      'status': 'Prime Time Analysis & Top National Stories',
      'isFeatured': false,
      'servers': [
        {
          'name': 'NDTV India Live Stream',
          'quality': '1080p HD',
          'speed': 'Direct Edge',
          'url': 'https://mumbai-edge.smartplaytv.in/NDTVIndia/index.m3u8',
        },
      ],
    },
    {
      'title': 'The Movie Club HD',
      'category': 'entertainment',
      'categoryLabel': '24/7 BLOCKBUSTER MOVIES',
      'poster': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'badge': 'LIVE CINEMA',
      'status': 'Non-Stop Indian Blockbusters & Action Films',
      'isFeatured': false,
      'servers': [
        {
          'name': 'The Movie Club Cinema Feed',
          'quality': '1080p HD',
          'speed': '24/7 Stream',
          'url': 'https://mumbai-edge.smartplaytv.in/TheMovieClub/index.m3u8',
        },
      ],
    },
  ];

  void _openStream(Map<String, dynamic> item, Map<String, String> server) {
    final liveMovie = Movie(
      id: 'live-${item['title'].hashCode}-${server['name'].hashCode}',
      title: '${item['title']} [${server['quality']}]',
      synopsis: '${item['status']}\nServer: ${server['name']} (${server['speed']})',
      poster: item['poster'] as String,
      backdrop: item['poster'] as String,
      videoUrl: server['url'] as String,
      downloadUrl: '',
      year: DateTime.now().year,
      duration: 'LIVE',
      quality: server['quality'] ?? '1080p Live',
      rating: 9.9,
      genre: ['Live Sports', 'Cricket', '4K HD'],
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

  void _showQualityModal(Map<String, dynamic> item) {
    final servers = (item['servers'] as List).cast<Map<String, String>>();
    if (servers.length == 1) {
      _openStream(item, servers.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(4)),
                    child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Select Playback Quality & Server (Zero Buffering):",
                style: TextStyle(color: kInkMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...servers.map((s) {
                final is4K = s['quality']!.contains('4K');
                final is1080 = s['quality']!.contains('1080p');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openStream(item, s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: is4K
                            ? kAccent.withOpacity(0.15)
                            : (is1080 ? Colors.white.withOpacity(0.08) : kSurface3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: is4K
                              ? kAccent
                              : (is1080 ? Colors.white30 : Colors.white12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            is4K ? Icons.four_k_rounded : Icons.hd_rounded,
                            color: is4K ? kAccent : Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name']!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${s['quality']} • ${s['speed']}",
                                  style: TextStyle(color: is4K ? kAccent : kInkMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showAddCustomStreamDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.live_tv_rounded, color: kAccent),
            SizedBox(width: 8),
            Text("Add Custom Stream", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Paste any live cricket or channel .m3u8 / stream URL to watch immediately:",
              style: TextStyle(color: kInkMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSurface3,
                hintText: "Stream Name (e.g. IND vs WI Special)",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSurface3,
                hintText: "https://.../stream.m3u8",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final url = urlController.text.trim();
              final title = titleController.text.trim().isNotEmpty
                  ? titleController.text.trim()
                  : "Custom Live Stream";
              if (url.isNotEmpty) {
                Navigator.pop(ctx);
                final customItem = {
                  'title': title,
                  'category': 'cricket',
                  'categoryLabel': 'CUSTOM STREAM',
                  'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
                  'badge': 'LIVE',
                  'status': 'User Added Custom Feed',
                  'isFeatured': false,
                  'servers': [
                    {
                      'name': title,
                      'quality': 'Direct HD',
                      'speed': 'Custom URL',
                      'url': url,
                    }
                  ],
                };
                setState(() {
                  _liveItems.insert(0, customItem);
                });
                _openStream(customItem, (customItem['servers'] as List).first as Map<String, String>);
              }
            },
            child: const Text("Watch Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _liveItems.where((item) {
      if (_selectedCategory == 'all') return true;
      return item['category'] == _selectedCategory;
    }).toList();

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
              "Live Cricket & Channels",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Add Custom Stream",
            icon: const Icon(Icons.add_link_rounded, color: Colors.white),
            onPressed: _showAddCustomStreamDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category Filters ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All Live', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('🏏 Cricket & Sports', 'cricket'),
                const SizedBox(width: 8),
                _buildFilterChip('📰 News', 'news'),
              ],
            ),
          ),

          // ── Stream Cards List ──
          Expanded(
            child: RefreshIndicator(
              color: kAccent,
              onRefresh: _loadLiveChannels,
              child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isFeatured = item['isFeatured'] == true;
                final servers = (item['servers'] as List).cast<Map<String, String>>();

                return GestureDetector(
                  onTap: () => _showQualityModal(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isFeatured ? kAccent.withOpacity(0.6) : Colors.white10,
                        width: isFeatured ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster Banner
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                              child: CachedNetworkImage(
                                imageUrl: item['poster'] as String,
                                height: isFeatured ? 190 : 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: kSurface3, height: isFeatured ? 190 : 150),
                                errorWidget: (_, __, ___) => Container(color: kSurface3, height: isFeatured ? 190 : 150),
                              ),
                            ),
                            // Dark gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(radius: 3, backgroundColor: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['badge'] as String,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Center Play Button
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30, width: 2),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Card Info & Quality Buttons
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (item['categoryLabel'] as String).toUpperCase(),
                                style: const TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['title'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['status'] as String,
                                style: const TextStyle(color: kInkMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 12),

                              // Quick Quality Chips row
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: servers.map((s) {
                                  final is4K = s['quality']!.contains('4K');
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => _openStream(item, s),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: is4K ? kAccent : kSurface3,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: is4K ? kAccent : Colors.white24, width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            size: 14,
                                            color: is4K ? Colors.white : kAccent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            s['quality']!,
                                            style: TextStyle(
                                              color: is4K ? Colors.white : Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
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
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kSurface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? kAccent : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kInkMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
