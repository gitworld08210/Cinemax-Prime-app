import 'package:flutter/material.dart';
import '../../../../domain/models/movie.dart';
import '../../../core/app_theme.dart';

import 'package:url_launcher/url_launcher.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final bool isBackupServer;

  const PlayerScreen({
    super.key,
    required this.movie,
    this.isBackupServer = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int _activeServer = 1;

  @override
  void initState() {
    super.initState();
    _activeServer = widget.isBackupServer ? 2 : 1;
  }

  String _getVideoUrl() {
    if (_activeServer == 1 && widget.movie.videoUrl.isNotEmpty) {
      return widget.movie.videoUrl;
    }
    if (_activeServer == 3 && widget.movie.downloadUrl.isNotEmpty) {
      return widget.movie.downloadUrl;
    }
    // Autoembed fallback
    final cleanId = widget.movie.id.replaceAll(RegExp(r'[^0-9]'), '');
    if (widget.movie.isSeries) {
      return 'https://autoembed.co/tv/tmdb/${cleanId.isNotEmpty ? cleanId : "1399"}/1/1';
    }
    return 'https://autoembed.co/movie/tmdb/${cleanId.isNotEmpty ? cleanId : "550"}';
  }

  Future<void> _launchStream(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open video stream: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamUrl = _getVideoUrl();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.movie.title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                '1080p HD',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video Theater Container
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _launchStream(streamUrl),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 60),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.movie.title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () => _launchStream(streamUrl),
                            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.black),
                            label: const Text(
                              'PLAY IN FULLSCREEN PLAYER',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Active Stream: Server $_activeServer',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              streamUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Server Switcher Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF141416),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _serverButton(1, 'Server 1 (Ultra HD)'),
                  _serverButton(2, 'Server 2 (AutoEmbed)'),
                  _serverButton(3, 'Server 3 (VIP Mirror)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serverButton(int serverId, String label) {
    final isActive = _activeServer == serverId;
    return GestureDetector(
      onTap: () => setState(() => _activeServer = serverId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
