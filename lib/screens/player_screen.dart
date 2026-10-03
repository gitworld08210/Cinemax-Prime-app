import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';

const Color kNetflixRed = Color(0xFFE50914);
const Color kInkMuted = Color(0xFF9E9E9E);

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

  // Double tap feedback
  String? _rippleText;
  bool _rippleIsForward = true;
  Timer? _rippleTimer;

  // Scrubbing state
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
    _controller?.removeListener(_onControllerUpdate);
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

      final uri = Uri.parse(url.trim());
      _controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) CinemaxPlayer/2.0',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );

      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Server took too long to respond");
        },
      );

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
          _errorMessage = "Playback Error: Unable to stream from cloud server ($e).";
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
    _hideTimer = Timer(const Duration(seconds: 3), () {
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

  // ── Netflix Fast Seek (+10s / -10s) ──
  Future<void> _seekBy(int seconds) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final duration = _controller!.value.duration;
    if (duration <= Duration.zero) return;

    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);

    _showRipple("${seconds > 0 ? '+' : ''}${seconds}s", seconds > 0);
    _startHideTimer();

    await _controller!.seekTo(clamped);
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.subtitles_outlined, color: kNetflixRed),
                    SizedBox(width: 10),
                    Text(
                      "Audio & Languages",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.movie.audioTracks.isNotEmpty) ...[
                  ...widget.movie.audioTracks.map((track) {
                    final isSelected = track.label == currentAudioLabel;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? kNetflixRed : Colors.white38,
                      ),
                      title: Text(track.label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(track.lang.toUpperCase(), style: const TextStyle(color: Colors.white30, fontSize: 11)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _switchAudio(track);
                      },
                    );
                  }),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Master Multi-Audio / Stereo Stream active.", style: TextStyle(color: Colors.white70)),
                  )
                ],
              ],
            ),
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.speed, color: kNetflixRed),
                    SizedBox(width: 10),
                    Text(
                      "Playback Speed",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      selectedColor: kNetflixRed,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
  }

  void _triggerDownload() {
    final dlUrl = widget.movie.downloadUrl.isNotEmpty ? widget.movie.downloadUrl : widget.movie.videoUrl;
    if (dlUrl.isNotEmpty) {
      final uri = Uri.parse(dlUrl);
      launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final remaining = (duration > position) ? duration - position : Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video Canvas Layer ──
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

          // ── Gesture Layer (Double tap seek, single tap toggle controls) ──
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    onDoubleTap: () => _seekBy(-10),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                  ),
                ),
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

          // ── Double Tap Animated Ripple ──
          if (_rippleText != null)
            Align(
              alignment: _rippleIsForward ? const Alignment(0.65, 0.0) : const Alignment(-0.65, 0.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _rippleIsForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                      color: kNetflixRed,
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

          // ── Buffering Indicator ──
          if (_isLoading || (hasVideo && _controller!.value.isBuffering))
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: const CircularProgressIndicator(color: kNetflixRed, strokeWidth: 3),
              ),
            ),

          // ── Error State ──
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
                    const Icon(Icons.error_outline, color: kNetflixRed, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: kNetflixRed),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Retry"),
                      onPressed: () => _initializePlayer(widget.movie.videoUrl),
                    ),
                  ],
                ),
              ),
            ),

          // ── Screen Lock Icon (Upper-Left Corner) ──
          if (_isLocked)
            Positioned(
              top: 20,
              left: 20,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() {
                        _isLocked = false;
                        _showControls = true;
                      });
                      _startHideTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ══════════════════════════════════════════════════════════
          //  Clean Netflix HUD
          // ══════════════════════════════════════════════════════════
          if (_showControls && !_isLoading && _errorMessage == null && !_isLocked)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xE6000000),
                  ],
                  stops: [0.0, 0.22, 0.65, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── TOPBAR: Clean & Minimalist ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.movie.title,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.movie.audioTracks.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.subtitles_outlined, color: Colors.white, size: 22),
                              tooltip: "Audio & Subtitles",
                              onPressed: _showAudioTrackSelector,
                            ),
                        ],
                      ),
                    ),

                    // ── CENTER CONTROLS: 10s Rewind | Play-Pause | 10s Forward ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 10s Rewind
                        IconButton(
                          iconSize: 46,
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () => _seekBy(-10),
                        ),
                        const SizedBox(width: 44),
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 2),
                            ),
                            child: Icon(
                              _controller?.value.isPlaying == true ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                        // 10s Forward
                        IconButton(
                          iconSize: 46,
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () => _seekBy(10),
                        ),
                      ],
                    ),

                    // ── BOTTOMBAR: Netflix Scrubber & Clean Action Row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scrubber & Times
                          Row(
                            children: [
                              Text(
                                _formatDuration(_isScrubbing ? Duration(milliseconds: _scrubValue.toInt()) : position),
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: kNetflixRed,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: kNetflixRed,
                                    trackHeight: 3.5,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
                                    onChangeEnd: (val) async {
                                      final target = Duration(milliseconds: val.toInt());
                                      await _controller?.seekTo(target);
                                      if (mounted) {
                                        setState(() {
                                          _isScrubbing = false;
                                        });
                                        _startHideTimer();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                "-${_formatDuration(remaining)}",
                                style: const TextStyle(color: kInkMuted, fontSize: 13),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Clean Bottom Action Row (Speed, Lock, Aspect, Download)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Speed
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.white70, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                icon: const Icon(Icons.speed, size: 18),
                                label: Text("Speed (${_playbackSpeed}X)", style: const TextStyle(fontSize: 12)),
                                onPressed: _showSpeedSelector,
                              ),
                              // Lock
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.white70, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                icon: const Icon(Icons.lock_outline, size: 18),
                                label: const Text("Lock", style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  setState(() {
                                    _isLocked = true;
                                    _showControls = false;
                                  });
                                },
                              ),
                              // Aspect Ratio
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.white70, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                icon: const Icon(Icons.aspect_ratio, size: 18),
                                label: Text(
                                  _fitMode == PlayerFitMode.contain ? "Fit" : (_fitMode == PlayerFitMode.cover ? "Fill" : "Stretch"),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: _cycleFitMode,
                              ),
                              // Download
                              IconButton(
                                icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white70, size: 20),
                                tooltip: "Download Offline",
                                onPressed: _triggerDownload,
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
