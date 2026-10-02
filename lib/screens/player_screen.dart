import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';

const Color kAccent = Color(0xFFE11D48);

enum PlayerFitMode { contain, cover, fill }

class PremiumPlayerScreen extends StatefulWidget {
  final Movie movie;

  const PremiumPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<PremiumPlayerScreen> createState() => _PremiumPlayerScreenState();
}

class _PremiumPlayerScreenState extends State<PremiumPlayerScreen> with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  bool _isLocked = false;
  Timer? _hideTimer;

  // OTT features
  PlayerFitMode _fitMode = PlayerFitMode.contain;
  double _playbackSpeed = 1.0;
  String currentAudioLabel = "Default Audio";
  int _activeServer = 1;

  // Double tap ripple animation
  String? _rippleText;
  bool _rippleIsForward = true;
  Timer? _rippleTimer;

  // Track user scrubbing
  bool _isScrubbing = false;
  double _scrubValue = 0.0;

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

  @override
  void dispose() {
    _hideTimer?.cancel();
    _rippleTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializePlayer(String url, {Duration? startPosition}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final oldController = _controller;

      // Handle video URL
      final uri = Uri.parse(url.trim());
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 CinemaxPlayer/2.0',
          'Accept': '*/*',
        },
      );

      await _controller!.initialize();

      if (startPosition != null && startPosition > Duration.zero) {
        await _controller!.seekTo(startPosition);
      }

      await _controller!.setPlaybackSpeed(_playbackSpeed);
      await _controller!.play();
      oldController?.dispose();

      _controller!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startHideTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Playback Error: Unable to stream from server ($e).";
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted && !_isScrubbing) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls && !_isLocked) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) return;
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  // ── Rock-Solid Seek Handling (Never Resets to 0) ──
  void _seekBy(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final duration = _controller!.value.duration;
    if (duration <= Duration.zero) return;

    final current = _controller!.value.position;
    int targetMs = current.inMilliseconds + (seconds * 1000);
    if (targetMs < 0) targetMs = 0;
    if (targetMs > duration.inMilliseconds) targetMs = duration.inMilliseconds;

    _controller!.seekTo(Duration(milliseconds: targetMs));

    // Show visual ripple
    _showRipple(seconds > 0 ? "+${seconds}s" : "${seconds}s", seconds > 0);
    _startHideTimer();
  }

  void _showRipple(String text, bool isForward) {
    _rippleTimer?.cancel();
    setState(() {
      _rippleText = text;
      _rippleIsForward = isForward;
    });
    _rippleTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _rippleText = null;
        });
      }
    });
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
                    "Audio & Languages",
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
                    subtitle: Text(track.lang.toUpperCase(), style: const TextStyle(color: Colors.white30, fontSize: 11)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchAudio(track);
                    },
                  );
                }),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Master Multi-Audio / Stereo Stream active.", style: TextStyle(color: Colors.white70)),
                )
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
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
                  Icon(Icons.speed, color: kAccent),
                  SizedBox(width: 10),
                  Text(
                    "Playback Speed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: speeds.map((s) {
                  final isSelected = _playbackSpeed == s;
                  return ChoiceChip(
                    label: Text("${s}x"),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _playbackSpeed = s);
                        _controller?.setPlaybackSpeed(s);
                        Navigator.pop(ctx);
                      }
                    },
                    backgroundColor: const Color(0xFF222222),
                    selectedColor: kAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cycleFitMode() {
    setState(() {
      if (_fitMode == PlayerFitMode.contain) {
        _fitMode = PlayerFitMode.cover;
      } else if (_fitMode == PlayerFitMode.cover) {
        _fitMode = PlayerFitMode.fill;
      } else {
        _fitMode = PlayerFitMode.contain;
      }
    });
    final label = _fitMode == PlayerFitMode.contain
        ? "Aspect Ratio: Fit"
        : (_fitMode == PlayerFitMode.cover ? "Aspect Ratio: Zoom / Fill" : "Aspect Ratio: Stretch 16:9");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _triggerDownload() async {
    final dlUrl = widget.movie.downloadUrl.isNotEmpty ? widget.movie.downloadUrl : widget.movie.videoUrl;
    if (dlUrl.isNotEmpty) {
      final uri = Uri.parse(dlUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0
        ? "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}"
        : "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = _controller != null && _controller!.value.isInitialized;
    final position = hasVideo ? _controller!.value.position : Duration.zero;
    final duration = hasVideo ? _controller!.value.duration : Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video Layer with Dynamic Aspect Ratio ──
          if (hasVideo)
            Center(
              child: _fitMode == PlayerFitMode.fill
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  : _fitMode == PlayerFitMode.cover
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
            ),

          // ── Gesture Detection Layer (Double-Tap Seek Left/Right & Tap Center) ──
          Positioned.fill(
            child: Row(
              children: [
                // Left 40% (Double tap rewinds 10s)
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    onDoubleTap: () => _seekBy(-10),
                  ),
                ),
                // Center 20% (Single tap toggles controls)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                  ),
                ),
                // Right 40% (Double tap forwards 10s)
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    onDoubleTap: () => _seekBy(10),
                  ),
                ),
              ],
            ),
          ),

          // ── Double Tap Animated Feedback Ripple ──
          if (_rippleText != null)
            Align(
              alignment: _rippleIsForward ? const Alignment(0.65, 0.0) : const Alignment(-0.65, 0.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _rippleIsForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                      color: kAccent,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _rippleText!,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // ── Loading state ──
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

          // ── Error state ──
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xE6141414),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: kAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text("Retry Stream"),
                          onPressed: () => _initializePlayer(widget.movie.videoUrl),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text("Download Offline"),
                          onPressed: _triggerDownload,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── Screen Locked Indicator (Floating Unlock Pill) ──
          if (_isLocked)
            Positioned(
              top: 24,
              left: 24,
              child: SafeArea(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.lock, color: kAccent, size: 18),
                  label: const Text("Screen Locked (Tap to Unlock)", style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _isLocked = false;
                      _showControls = true;
                    });
                    _startHideTimer();
                  },
                ),
              ),
            ),

          // ── Netflix HUD Overlays ──
          if (_showControls && !_isLoading && _errorMessage == null && !_isLocked)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xD9000000),
                  ],
                  stops: [0.0, 0.25, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── TOPBAR ──
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.movie.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.movie.quality.isNotEmpty)
                                  Text(
                                    widget.movie.quality,
                                    style: const TextStyle(color: Color(0xFF8A8F98), fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          // Aspect Ratio Button
                          IconButton(
                            icon: const Icon(Icons.aspect_ratio, color: Colors.white70, size: 20),
                            tooltip: "Aspect Ratio",
                            onPressed: _cycleFitMode,
                          ),
                          // Speed Button
                          IconButton(
                            icon: const Icon(Icons.speed, color: Colors.white70, size: 20),
                            tooltip: "Playback Speed",
                            onPressed: _showSpeedSelector,
                          ),
                          // Audio Track Button
                          if (widget.movie.audioTracks.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.audiotrack, color: kAccent, size: 20),
                              tooltip: "Audio Tracks",
                              onPressed: _showAudioTrackSelector,
                            ),
                          // Download Button
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.white70, size: 20),
                            tooltip: "Download to Device",
                            onPressed: _triggerDownload,
                          ),
                          // Screen Lock Button
                          IconButton(
                            icon: const Icon(Icons.lock_open, color: Colors.white70, size: 20),
                            tooltip: "Lock Screen",
                            onPressed: () {
                              setState(() {
                                _isLocked = true;
                                _showControls = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── CENTER CONTROLS ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Rewind 10s
                        IconButton(
                          iconSize: 44,
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () => _seekBy(-10),
                        ),
                        const SizedBox(width: 36),
                        // Big Play / Pause
                        GestureDetector(
                          onTap: () {
                            if (_controller?.value.isPlaying == true) {
                              _controller?.pause();
                            } else {
                              _controller?.play();
                            }
                            _startHideTimer();
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 2),
                            ),
                            child: Icon(
                              _controller?.value.isPlaying == true ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),
                        // Forward 10s
                        IconButton(
                          iconSize: 44,
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () => _seekBy(10),
                        ),
                      ],
                    ),

                    // ── BOTTOMBAR ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scrubber & Times
                          Row(
                            children: [
                              Text(
                                _formatDuration(_isScrubbing ? Duration(milliseconds: _scrubValue.toInt()) : position),
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
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
                                    value: _isScrubbing
                                        ? _scrubValue
                                        : ((duration.inMilliseconds > 0)
                                            ? position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble()
                                            : 0.0),
                                    max: (duration.inMilliseconds > 0)
                                        ? duration.inMilliseconds.toDouble()
                                        : 1.0,
                                    onChangeStart: (val) {
                                      _hideTimer?.cancel();
                                      setState(() {
                                        _isScrubbing = true;
                                        _scrubValue = val;
                                      });
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        _scrubValue = val;
                                      });
                                    },
                                    onChangeEnd: (val) {
                                      _controller?.seekTo(Duration(milliseconds: val.toInt()));
                                      setState(() {
                                        _isScrubbing = false;
                                      });
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
                        ],
                      ),
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
