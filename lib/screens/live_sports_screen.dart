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

  // ── Default Pure Indian TV Channels & Matches ──
  final List<Map<String, dynamic>> _liveItems = [
    // ═════════════════════════════════════════════════════════════
    //  FEATURED LIVE MATCH: INDIA vs WEST INDIES
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'India vs West Indies - Live Match',
      'category': 'sports',
      'categoryLabel': '🔥 LIVE CRICKET SPECIAL',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/320px-Flag_of_India.svg.png',
      'badge': 'LIVE 4K',
      'status': 'IND vs WI Live Broadcast • 4K & 1080p Buffer-Free Multi-CDN',
      'isFeatured': true,
      'servers': [
        {
          'name': 'Server 1: 4K Ultra HD (60 FPS)',
          'quality': '4K UHD (High Bitrate)',
          'speed': 'Ultra Fast CDN',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
        {
          'name': 'Server 2: 1080p Full HD',
          'quality': '1080p (Zero Buffer)',
          'speed': 'Buffer-Free High Speed',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
        {
          'name': 'Server 3: 720p HD',
          'quality': '720p (Data Saver)',
          'speed': '4G/5G Fast',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  SPORTS CHANNELS (INDIA)
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'Star Sports 1 Hindi HD',
      'category': 'sports',
      'categoryLabel': 'STAR SPORTS NETWORK',
      'poster': 'https://images.unsplash.com/photo-1531415074868-036b10554f0a?w=1200&q=80',
      'logo': 'https://i.imgur.com/E5jjKHI.png',
      'badge': '1080p HD',
      'status': 'Live Hindi Commentary • IND vs WI & Indian Cricket 24x7',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Star Sports Hindi 1080p',
          'quality': '1080p HD',
          'speed': 'High Bitrate',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
        {
          'name': 'Star Sports Hindi 720p',
          'quality': '720p Smooth',
          'speed': 'Low Latency',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
      ],
    },
    {
      'title': 'Star Sports 2 HD',
      'category': 'sports',
      'categoryLabel': 'STAR SPORTS NETWORK',
      'poster': 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=1200&q=80',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_STAR_SPORTS_2/images/LOGO_HD/image.png',
      'badge': 'LIVE HD',
      'status': 'Live Cricket & World Sports Broadcast',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Star Sports 2 Primary',
          'quality': '720p HD',
          'speed': 'Fast CDN',
          'url': 'http://tvsen5.aynascope.net/cXPB2LKkErN9/index.m3u8',
        },
      ],
    },
    {
      'title': 'Sports18 1 HD',
      'category': 'sports',
      'categoryLabel': 'JIOHOTSTAR / SPORTS18',
      'poster': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Sports18_1_logo.png/320px-Sports18_1_logo.png',
      'badge': '1080p 60FPS',
      'status': 'Official JioCinema & Sports18 Cricket Feed',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Sports18 1080p Primary',
          'quality': '1080p HD',
          'speed': 'Buffer-Free',
          'url': 'https://d35j504z0x2vu2.cloudfront.net/v1/manifest/0bc8e838797fedf411861f880083333244e04e08/dd-sports/0d75a6c1-a010-4100-b601-38379c94c7b8/2.m3u8',
        },
        {
          'name': 'Sports18 720p',
          'quality': '720p Smooth',
          'speed': 'Direct Edge',
          'url': 'https://mumbai-edge.smartplaytv.in/DDSportsHD/index.m3u8',
        },
      ],
    },
    {
      'title': 'DD Sports 1.0 HD',
      'category': 'sports',
      'categoryLabel': 'FREE-TO-AIR CRICKET',
      'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/DD_Sports_logo.png/320px-DD_Sports_logo.png',
      'badge': 'OFFICIAL FTA',
      'status': 'Direct Doordarshan National Satellite Live Feed',
      'isFeatured': false,
      'servers': [
        {
          'name': 'DD Sports AWS Cloudfront',
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
      'title': 'Sony Sports Ten 5',
      'category': 'sports',
      'categoryLabel': 'SONY SPORTS NETWORK',
      'poster': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=1200&q=80',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_SONY_SPORTS_TEN_5/images/LOGO_HD/image.png',
      'badge': '1080p HD',
      'status': 'Live Football, Tennis & International Sports',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Sony Ten 5 Cloudplay',
          'quality': '1080p HD',
          'speed': 'High Speed',
          'url': 'https://cloudplay-sonyliv.pages.dev/ten5.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  HINDI NEWS CHANNELS (INDIA)
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'Aaj Tak HD',
      'category': 'news',
      'categoryLabel': 'HINDI NEWS 24X7',
      'poster': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_AAJ_TAK/images/LOGO_HD/image.png',
      'badge': '1080p HD',
      'status': "India's No. 1 Hindi News Channel • Sabse Tez 24x7",
      'isFeatured': false,
      'servers': [
        {
          'name': 'Aaj Tak HD Official Master',
          'quality': '1080p HD',
          'speed': 'Official Live Stream',
          'url': 'https://feeds.intoday.in/aajtak/api/aajtakhd/master.m3u8',
        },
      ],
    },
    {
      'title': 'ABP News',
      'category': 'news',
      'categoryLabel': 'HINDI NEWS 24X7',
      'poster': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
      'logo': 'https://dtil.tmsimg.com/assets/s158138_ld_h15_aa.png?lock=720x540',
      'badge': '1080p HD',
      'status': 'Top Breaking Headlines & National Debate 24x7',
      'isFeatured': false,
      'servers': [
        {
          'name': 'ABP News AWS Cloudfront',
          'quality': '1080p HD',
          'speed': 'High Bitrate',
          'url': 'https://d1rc86nwwc9fag.cloudfront.net/vglive-sk-472500/abpnews/master.m3u8',
        },
      ],
    },
    {
      'title': 'NDTV India',
      'category': 'news',
      'categoryLabel': 'NATIONAL NEWS',
      'poster': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/NDTV_India_logo.png/320px-NDTV_India_logo.png',
      'badge': 'LIVE',
      'status': 'Prime Time Analysis & Objective Journalism',
      'isFeatured': false,
      'servers': [
        {
          'name': 'NDTV India Live Edge',
          'quality': '1080p HD',
          'speed': 'Direct Edge',
          'url': 'https://mumbai-edge.smartplaytv.in/NDTVIndia/index.m3u8',
        },
      ],
    },
    {
      'title': 'India TV',
      'category': 'news',
      'categoryLabel': 'HINDI NEWS 24X7',
      'poster': 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/India_TV_logo.png/320px-India_TV_logo.png',
      'badge': 'LIVE',
      'status': 'Aap Ki Adalat & Top National News',
      'isFeatured': false,
      'servers': [
        {
          'name': 'India TV Official Feed',
          'quality': '1080p HD',
          'speed': 'Official Live Stream',
          'url': 'https://livetv.indiatvnews.com/itv/itvlive/index.m3u8',
        },
      ],
    },
    {
      'title': 'Zee News',
      'category': 'news',
      'categoryLabel': 'HINDI NEWS 24X7',
      'poster': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Zee_News_logo.svg/320px-Zee_News_logo.svg.png',
      'badge': 'LIVE',
      'status': 'DNA Analysis & Non-Stop Indian Headlines',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Zee News Akamai CDN',
          'quality': '1080p HD',
          'speed': 'Akamai CDN',
          'url': 'https://zeenews.akamaized.net/live/smil:zeenewshindi.smil/master.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  ENTERTAINMENT & MOVIES (INDIA)
    // ═════════════════════════════════════════════════════════════
    {
      'title': 'Zee Cinema',
      'category': 'movies',
      'categoryLabel': 'BOLLYWOOD MOVIES',
      'poster': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_ZEE_CINEMA/images/LOGO_HD/LOGO_HD_image.png',
      'badge': 'HD MOVIES',
      'status': 'Non-Stop Blockbuster Hindi Cinema & Superhits',
      'isFeatured': false,
      'servers': [
        {
          'name': 'Zee Cinema Cloudfront',
          'quality': '720p HD',
          'speed': 'AWS CDN',
          'url': 'https://d1g8wgjurz8via.cloudfront.net/bpk-tv/NGCHD/default/NGCHD.m3u8',
        },
      ],
    },
    {
      'title': 'DD National HD',
      'category': 'movies',
      'categoryLabel': 'NATIONAL BROADCAST',
      'poster': 'https://images.unsplash.com/photo-1518173946687-a4c8a383392e?w=800',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/DD_National_logo.png/320px-DD_National_logo.png',
      'badge': 'LIVE 1080p',
      'status': 'Doordarshan National Official Broadcast',
      'isFeatured': false,
      'servers': [
        {
          'name': 'DD National Edge Feed',
          'quality': '1080p HD',
          'speed': 'Direct Feed',
          'url': 'https://mumbai-edge.smartplaytv.in/DDNational/index.m3u8',
        },
      ],
    },

    // ═════════════════════════════════════════════════════════════
    //  MUSIC (INDIA)
    // ═════════════════════════════════════════════════════════════
    {
      'title': '9XM',
      'category': 'music',
      'categoryLabel': 'BOLLYWOOD MUSIC',
      'poster': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_9XM/images/LOGO_HD/image.png',
      'badge': '1080p MUSIC',
      'status': "India's Best Bollywood & Punjabi Music 24x7",
      'isFeatured': false,
      'servers': [
        {
          'name': '9XM Master Playback',
          'quality': '1080p HD',
          'speed': 'Direct CDN',
          'url': 'https://9xjio.wiseplayout.com/9XM/master.m3u8',
        },
      ],
    },
    {
      'title': '9X Jalwa',
      'category': 'music',
      'categoryLabel': 'RETRO HITS MUSIC',
      'poster': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'logo': 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_9X_JALWA/images/LOGO_HD/image.png',
      'badge': '1080p MUSIC',
      'status': 'Evergreen Bollywood Classics & Melodies',
      'isFeatured': false,
      'servers': [
        {
          'name': '9X Jalwa Live Stream',
          'quality': '1080p HD',
          'speed': 'High Speed',
          'url': 'https://wiselp.wiseplayout.com/9X_Jalwa/master.m3u8',
        },
      ],
    },
  ];

  List<Map<String, String>> _parseServers(dynamic raw) {
    if (raw is List) {
      return raw.map((s) {
        if (s is Map) {
          return s.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        }
        return <String, String>{};
      }).toList();
    }
    return [];
  }

  void _openStream(Map<String, dynamic> item, Map<String, String> server) {
    final title = item['title']?.toString() ?? 'Live Stream';
    final serverName = server['name'] ?? 'Live Server';
    final quality = server['quality'] ?? '1080p Live';
    final speed = server['speed'] ?? 'High Speed';
    final poster = item['poster']?.toString() ?? '';
    final videoUrl = server['url'] ?? '';
    final status = item['status']?.toString() ?? '';

    final liveMovie = Movie(
      id: 'live-${title.hashCode}-${serverName.hashCode}',
      title: '$title [$quality]',
      synopsis: '$status\nServer: $serverName ($speed)',
      poster: poster,
      backdrop: poster,
      videoUrl: videoUrl,
      downloadUrl: '',
      year: DateTime.now().year,
      duration: 'LIVE',
      quality: quality,
      rating: 9.9,
      genre: ['Live Sports', 'Indian TV', 'HD'],
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
    final servers = _parseServers(item['servers']);
    if (servers.isEmpty) return;
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
              "Paste any live cricket or Indian channel .m3u8 URL to watch immediately:",
              style: TextStyle(color: kInkMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: kSurface3,
                hintText: "Channel Name (e.g. Star Sports 1 Hindi)",
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
                  : "Custom Indian Stream";
              if (url.isNotEmpty) {
                Navigator.pop(ctx);
                final customItem = {
                  'title': title,
                  'category': 'sports',
                  'categoryLabel': 'CUSTOM STREAM',
                  'poster': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
                  'logo': 'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/320px-Flag_of_India.svg.png',
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
                _openStream(customItem, _parseServers(customItem['servers']).first);
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
              "Live Indian TV & Cricket",
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
          // ═══════════════════════════════════════════════════════════
          //  CIRCULAR CHANNELS BAR (Tapping any circle opens that channel!)
          // ═══════════════════════════════════════════════════════════
          Container(
            height: 104,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F0F),
              border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _liveItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final ch = _liveItems[index];
                final logoUrl = ch['logo']?.toString() ?? ch['poster']?.toString() ?? '';
                final title = ch['title']?.toString() ?? '';
                final shortName = _getShortName(title);

                return GestureDetector(
                  onTap: () => _showQualityModal(ch),
                  child: SizedBox(
                    width: 66,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular Logo with Glowing Live Ring
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE11D48), Color(0xFFFB7185), Color(0xFFE11D48)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccent.withOpacity(0.35),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(2.5),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.black,
                                  child: CachedNetworkImage(
                                    imageUrl: logoUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => Container(color: kSurface2),
                                    errorWidget: (_, __, ___) => Container(
                                      color: kSurface2,
                                      child: const Icon(Icons.tv_rounded, color: Colors.white54, size: 24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tiny LIVE badge on bottom
                            Positioned(
                              bottom: -2,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  child: const Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Channel Name
                        Text(
                          shortName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Category Filters ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Indian TV', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🏏 Sports & Cricket', 'sports'),
                  const SizedBox(width: 8),
                  _buildFilterChip('📰 Hindi News', 'news'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🎬 Movies', 'movies'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🎵 Music', 'music'),
                ],
              ),
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
                  final servers = _parseServers(item['servers']);

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
                              // Channel Logo inside banner (Top Right)
                              if (item['logo'] != null && (item['logo'] as String).isNotEmpty)
                                Positioned(
                                  top: 10,
                                  right: 12,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.7),
                                      border: Border.all(color: Colors.white30, width: 1),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: item['logo'] as String,
                                        fit: BoxFit.contain,
                                        errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white, size: 16),
                                      ),
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

  String _getShortName(String title) {
    if (title.contains('India vs West Indies')) return 'IND vs WI';
    if (title.contains('Star Sports 1 Hindi')) return 'Star Sports 1';
    if (title.contains('Star Sports 2')) return 'Star Sports 2';
    if (title.contains('Sports18')) return 'Sports18';
    if (title.contains('DD Sports')) return 'DD Sports';
    if (title.contains('Sony Sports')) return 'Sony Sports';
    if (title.contains('Aaj Tak')) return 'Aaj Tak';
    if (title.contains('ABP News')) return 'ABP News';
    if (title.contains('NDTV')) return 'NDTV';
    if (title.contains('India TV')) return 'India TV';
    if (title.contains('Zee News')) return 'Zee News';
    if (title.contains('Zee Cinema')) return 'Zee Cinema';
    if (title.contains('DD National')) return 'DD National';
    if (title.contains('9XM')) return '9XM';
    if (title.contains('9X Jalwa')) return '9X Jalwa';
    return title.split(' ').take(2).join(' ');
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
