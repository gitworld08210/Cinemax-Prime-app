import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/movie.dart';

const Color kAccent = Color(0xFFE11D48);

class PremiumPlayerScreen extends StatefulWidget {
  final Movie movie;

  const PremiumPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<PremiumPlayerScreen> createState() => _PremiumPlayerScreenState();
}

class _PremiumPlayerScreenState extends State<PremiumPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  String currentAudioLabel = "Default Audio";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    String streamUrl = widget.movie.videoUrl;
    if (widget.movie.audioTracks.isNotEmpty) {
      final defaultTrack = widget.movie.audioTracks.firstWhere(
        (t) => t.isDefault,
        orElse: () => widget.movie.audioTracks.first,
      );
      streamUrl = defaultTrack.videoUrl.isNotEmpty ? defaultTrack.videoUrl : streamUrl;
      currentAudioLabel = defaultTrack.label;
    }

    _initializePlayer(streamUrl);
  }

  Future<void> _initializePlayer(String url, {Duration? startPosition}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final oldVideo = _videoPlayerController;
      final oldChewie = _chewieController;

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'User-Agent': 'CinemaxPrimePlayer/1.0'},
      );

      await _videoPlayerController!.initialize();

      if (startPosition != null) {
        await _videoPlayerController!.seekTo(startPosition);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        fullScreenByDefault: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: kAccent,
          handleColor: kAccent,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );

      oldChewie?.dispose();
      oldVideo?.dispose();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Playback Error: Unable to stream from server.";
      });
    }
  }

  void _switchAudio(AudioTrackInfo track) async {
    if (track.label == currentAudioLabel || track.videoUrl.isEmpty) return;
    final currentPos = _videoPlayerController?.value.position ?? Duration.zero;
    setState(() {
      currentAudioLabel = track.label;
    });
    await _initializePlayer(track.videoUrl, startPosition: currentPos);
  }

  void _showAudioTrackSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.audiotrack, color: kAccent),
                  SizedBox(width: 10),
                  Text(
                    "Select Audio Track",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (widget.movie.audioTracks.isNotEmpty) ...[
                ...widget.movie.audioTracks.map((track) {
                  final isSelected = track.label == currentAudioLabel;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? kAccent : Colors.white38,
                    ),
                    title: Text(track.label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchAudio(track);
                    },
                  );
                }),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Single Master Audio Track active (Original Dub).", style: TextStyle(color: Colors.white70)),
                )
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kAccent),
                  SizedBox(height: 16),
                  Text("Buffering Cinemax Stream...", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: kAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kAccent),
                    onPressed: () => _initializePlayer(widget.movie.videoUrl),
                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          else if (_chewieController != null)
            Center(
              child: Chewie(controller: _chewieController!),
            ),

          // Top Header Overlay
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.movie.audioTracks.isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xCC1A1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: const Icon(Icons.language, size: 16, color: kAccent),
                      label: Text(
                        currentAudioLabel,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _showAudioTrackSelector,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
