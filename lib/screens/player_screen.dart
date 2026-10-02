import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/movie.dart';

const Color kAccent = Color(0xFFE11D48);

class PremiumPlayerScreen extends StatefulWidget {
  final Movie movie;

  const PremiumPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<PremiumPlayerScreen> createState() => _PremiumPlayerScreenState();
}

class _PremiumPlayerScreenState extends State<PremiumPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideTimer;
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
      final oldController = _controller;

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'User-Agent': 'CinemaxPrimePlayer/1.0'},
      );

      await _controller!.initialize();

      if (startPosition != null) {
        await _controller!.seekTo(startPosition);
      }

      await _controller!.play();
      oldController?.dispose();

      _controller!.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() {
        _isLoading = false;
      });
      _startHideTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Playback Error: Unable to stream from server.";
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _seekBy(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    _controller!.seekTo(target);
    _startHideTimer();
  }

  void _switchAudio(AudioTrackInfo track) async {
    if (track.label == currentAudioLabel || track.videoUrl.isEmpty) return;
    final currentPos = _controller?.value.position ?? Duration.zero;
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0
        ? "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}"
        : "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
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
    final hasVideo = _controller != null && _controller!.value.isInitialized;
    final position = hasVideo ? _controller!.value.position : Duration.zero;
    final duration = hasVideo ? _controller!.value.duration : Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Frame
            if (hasVideo)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),

            // Loading state
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
              ),

            // Error state
            if (_errorMessage != null)
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
              ),

            // Netflix Controls Overlay
            if (_showControls && !_isLoading && _errorMessage == null)
              Container(
                color: Colors.black45,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                      // Center Controls: Rewind 10s | Play/Pause | Forward 10s
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 42,
                            icon: const Icon(Icons.replay_10, color: Colors.white),
                            onPressed: () => _seekBy(-10),
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            iconSize: 64,
                            icon: Icon(
                              _controller?.value.isPlaying == true ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_controller?.value.isPlaying == true) {
                                _controller?.pause();
                              } else {
                                _controller?.play();
                              }
                              _startHideTimer();
                            },
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            iconSize: 42,
                            icon: const Icon(Icons.forward_10, color: Colors.white),
                            onPressed: () => _seekBy(10),
                          ),
                        ],
                      ),

                      // Bottom Scrubber Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: kAccent,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: kAccent,
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: (duration.inMilliseconds > 0)
                                      ? position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble()
                                      : 0.0,
                                  max: (duration.inMilliseconds > 0)
                                      ? duration.inMilliseconds.toDouble()
                                      : 1.0,
                                  onChanged: (val) {
                                    _controller?.seekTo(Duration(milliseconds: val.toInt()));
                                    _startHideTimer();
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
