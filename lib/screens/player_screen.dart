import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/movie.dart';

class PremiumPlayerScreen extends StatefulWidget {
  final Movie movie;

  const PremiumPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<PremiumPlayerScreen> createState() => _PremiumPlayerScreenState();
}

class _PremiumPlayerScreenState extends State<PremiumPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  bool isLocked = false;
  bool showControls = true;
  String currentAudioLabel = "Default (Hindi/Main)";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    player = Player();
    controller = VideoController(player);

    String streamSource = widget.movie.videoUrl;
    if (widget.movie.audioTracks.isNotEmpty) {
      final defaultTrack = widget.movie.audioTracks.firstWhere(
        (t) => t.isDefault,
        orElse: () => widget.movie.audioTracks.first,
      );
      streamSource = defaultTrack.videoUrl.isNotEmpty ? defaultTrack.videoUrl : streamSource;
      currentAudioLabel = defaultTrack.label;
    }

    player.open(Media(streamSource));
  }

  @override
  void dispose() {
    player.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showAudioTrackSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final internalTracks = player.state.tracks.audio;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.audiotrack, color: Color(0xFFE11D48)),
                  SizedBox(width: 10),
                  Text(
                    "Select Audio Track",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (internalTracks.isNotEmpty) ...[
                const Text("Hardware MKV Audio Streams:", style: TextStyle(color: Colors.white60, fontSize: 13)),
                ...internalTracks.map((t) {
                  final isCurrent = player.state.track.audio == t;
                  final title = t.title ?? t.language ?? "Audio Stream ${t.id}";
                  return ListTile(
                    leading: Icon(
                      isCurrent ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCurrent ? const Color(0xFFE11D48) : Colors.white38,
                    ),
                    title: Text(title, style: TextStyle(color: isCurrent ? Colors.white : Colors.white70)),
                    onTap: () {
                      player.setAudioTrack(t);
                      setState(() {
                        currentAudioLabel = title;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ] else if (widget.movie.audioTracks.isNotEmpty) ...[
                const Text("Dual Audio Options:", style: TextStyle(color: Colors.white60, fontSize: 13)),
                ...widget.movie.audioTracks.map((track) {
                  final isSelected = track.label == currentAudioLabel;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFFE11D48) : Colors.white38,
                    ),
                    title: Text(track.label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                    onTap: () {
                      setState(() {
                        currentAudioLabel = track.label;
                      });
                      final pos = player.state.position;
                      player.open(Media(track.videoUrl)).then((_) {
                        player.seek(pos);
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Single Master Audio Track active.", style: TextStyle(color: Colors.white70)),
                )
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Video(
              controller: controller,
              controls: MaterialVideoControls,
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xCC1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.language, size: 18, color: Color(0xFFE50914)),
                    label: Text(
                      currentAudioLabel,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
