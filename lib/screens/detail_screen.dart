import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kRating = Color(0xFFF5C518);
const Color kInkMuted = Color(0xFF8A8F98);

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Map<String, dynamic>> _episodes = [];
  bool _loadingEpisodes = false;

  bool get isSeries =>
      widget.movie.type == 'series' ||
      widget.movie.genre.any((g) => g.toLowerCase().contains('series')) ||
      widget.movie.title.toLowerCase().contains('season') ||
      widget.movie.title.toLowerCase().contains('s0');

  @override
  void initState() {
    super.initState();
    if (isSeries) {
      _loadEpisodes();
    }
  }

  Future<void> _loadEpisodes() async {
    setState(() => _loadingEpisodes = true);
    try {
      final allMovies = await ApiService.fetchMovies();
      final cleanTitle = widget.movie.title
          .replaceAll(RegExp(r'\s*\(?\d{4}\)?.*'), '')
          .replaceAll(RegExp(r'(?i)season\s*\d+'), '')
          .trim().toLowerCase();

      final matchingEpisodes = allMovies.where((m) {
        final t = m.title.toLowerCase();
        return t.contains(cleanTitle) && m.videoUrl.isNotEmpty;
      }).toList();

      final tmdbEps = await ApiService.fetchTvEpisodes(widget.movie.title);
      List<Map<String, dynamic>> combined = [];

      if (matchingEpisodes.length > 1) {
        for (int i = 0; i < matchingEpisodes.length; i++) {
          final m = matchingEpisodes[i];
          final tmdbInfo = i < tmdbEps.length ? tmdbEps[i] : null;
          combined.add({
            'episode_number': i + 1,
            'name': tmdbInfo?['name'] ?? 'Episode ${i + 1}',
            'overview': tmdbInfo?['overview'] ?? m.synopsis,
            'still': (tmdbInfo?['still'] != null && tmdbInfo!['still'].toString().isNotEmpty)
                ? tmdbInfo['still']
                : m.backdrop,
            'runtime': tmdbInfo?['runtime'] ?? '45m',
            'video_url': m.videoUrl,
          });
        }
      } else {
        for (int i = 0; i < tmdbEps.length; i++) {
          final ep = Map<String, dynamic>.from(tmdbEps[i]);
          ep['video_url'] = widget.movie.videoUrl;
          combined.add(ep);
        }
      }

      if (mounted) {
        setState(() {
          _episodes = combined;
          _loadingEpisodes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingEpisodes = false);
    }
  }

  void _triggerDownload(String url) async {
    final cleanUrl = url.isNotEmpty ? url : widget.movie.downloadUrl;
    if (cleanUrl.isEmpty) return;

    final Uri uri = Uri.parse(cleanUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting high-speed download...'),
            backgroundColor: Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch download.')),
        );
      }
    }
  }

  // ── Language & Server Download Picker (Hollywood Dual Audio) ──
  void _showDownloadOptions() {
    final movie = widget.movie;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download, color: kAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Download Language",
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${movie.title} • ${movie.quality}",
                            style: const TextStyle(color: kInkMuted, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Multi-Audio Track options (Hindi, English, etc.)
                if (movie.audioTracks.isNotEmpty) ...[
                  ...movie.audioTracks.map((track) {
                    final isHindi = track.label.toLowerCase().contains('hindi') || track.lang == 'hi';
                    final downloadLink = track.videoUrl.isNotEmpty
                        ? (track.videoUrl.contains('/stream/')
                            ? track.videoUrl.replaceAll('/stream/', '/download/') + '?download=1'
                            : track.videoUrl)
                        : movie.downloadUrl;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isHindi ? kAccent.withOpacity(0.4) : Colors.white10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isHindi ? kAccent.withOpacity(0.2) : Colors.white10,
                          child: Icon(
                            isHindi ? Icons.translate : Icons.audiotrack,
                            color: isHindi ? kAccent : Colors.white70,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          track.label,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          "${movie.quality} • Fast Direct Download",
                          style: const TextStyle(color: kInkMuted, fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_downward, color: kAccent, size: 20),
                        onTap: () {
                          Navigator.pop(ctx);
                          _triggerDownload(downloadLink);
                        },
                      ),
                    );
                  }),
                ] else ...[
                  // Default Server 1 & Server 2 options
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.speed, color: kAccent, size: 20),
                      ),
                      title: const Text("Server 1 - High Speed Direct", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text("${movie.quality} • Full Speed Cloud CDN", style: const TextStyle(color: kInkMuted, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_downward, color: kAccent, size: 20),
                      onTap: () {
                        Navigator.pop(ctx);
                        _triggerDownload(movie.downloadUrl);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.cloud_download, color: Colors.white70, size: 20),
                      ),
                      title: const Text("Server 2 - Fast CDN Download", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text("${movie.quality} • Direct Media File", style: const TextStyle(color: kInkMuted, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_downward, color: Colors.white70, size: 20),
                      onTap: () {
                        Navigator.pop(ctx);
                        _triggerDownload(movie.videoUrl);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _playEpisode(Map<String, dynamic> ep) {
    final epNum = ep['episode_number'] ?? 1;
    final epTitle = "${widget.movie.title} • Ep $epNum: ${ep['name'] ?? ''}";
    final epVideoUrl = (ep['video_url'] != null && ep['video_url'].toString().isNotEmpty)
        ? ep['video_url'].toString()
        : widget.movie.videoUrl;

    final epMovie = Movie(
      id: "${widget.movie.id}-ep-$epNum",
      title: epTitle,
      type: 'series',
      year: widget.movie.year,
      duration: ep['runtime']?.toString() ?? widget.movie.duration,
      quality: widget.movie.quality,
      rating: widget.movie.rating,
      poster: (ep['still'] != null && ep['still'].toString().isNotEmpty) ? ep['still'].toString() : widget.movie.poster,
      backdrop: widget.movie.backdrop,
      videoUrl: epVideoUrl,
      downloadUrl: epVideoUrl,
      synopsis: (ep['overview'] != null && ep['overview'].toString().isNotEmpty) ? ep['overview'].toString() : widget.movie.synopsis,
      genre: widget.movie.genre,
      audioTracks: widget.movie.audioTracks,
      isFeatured: widget.movie.isFeatured,
      isTrending: widget.movie.isTrending,
      badge: "EP $epNum",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumPlayerScreen(movie: epMovie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

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
                      label: Text(isSeries ? 'Play Season 1' : 'Play Movie', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
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
                      label: Text(
                        movie.audioTracks.length > 1 ? 'Download (Select Audio)' : 'Download',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _showDownloadOptions,
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
                  const SizedBox(height: 24),

                  // ── Web Series Episodes Section ──
                  if (isSeries) ...[
                    const Divider(color: Colors.white12, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Episodes",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kSurface3,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text("Season 1", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_loadingEpisodes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: kAccent),
                        ),
                      )
                    else if (_episodes.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _episodes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final ep = _episodes[i];
                          final still = ep['still'] as String? ?? '';
                          final title = ep['name'] as String? ?? 'Episode ${i + 1}';
                          final num = ep['episode_number'] ?? (i + 1);
                          final overview = ep['overview'] as String? ?? '';
                          final runtime = ep['runtime'] as String? ?? '45m';

                          return Container(
                            decoration: BoxDecoration(
                              color: kSurface2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _playEpisode(ep),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            still.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: still,
                                                    width: 100,
                                                    height: 65,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, __) => Container(color: kSurface3, width: 100, height: 65),
                                                    errorWidget: (_, __, ___) => Container(color: kSurface3, width: 100, height: 65, child: const Icon(Icons.tv, color: Colors.white24)),
                                                  )
                                                : Container(
                                                    color: kSurface3,
                                                    width: 100,
                                                    height: 65,
                                                    child: const Icon(Icons.tv, color: Colors.white24),
                                                  ),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Episode Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "$num. $title",
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  runtime,
                                                  style: const TextStyle(color: kInkMuted, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              overview.isNotEmpty ? overview : "Watch full episode in HD on Cinemax Prime.",
                                              style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12, height: 1.3),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],

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
