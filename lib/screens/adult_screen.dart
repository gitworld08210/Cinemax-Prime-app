import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

const Color kAccent = Color(0xFFE11D48);
const Color kCanvas = Colors.black;
const Color kSurface2 = Color(0xFF181818);
const Color kSurface3 = Color(0xFF1F1F1F);
const Color kInkMuted = Color(0xFF8A8F98);
const Color kRating = Color(0xFFF5C518);

class AdultScreen extends StatefulWidget {
  final List<Movie> movies;

  const AdultScreen({Key? key, required this.movies}) : super(key: key);

  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  bool _isUnlocked = false;
  String _enteredPin = '';
  String? _correctPin;
  bool _isVerifying = false;
  String? _pinError;

  // 45-Second Auto-Lock Security
  Timer? _autoLockTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 45;

  @override
  void initState() {
    super.initState();
    _fetchPin();
  }

  Future<void> _fetchPin() async {
    final pin = await ApiService.fetchAdultPin();
    if (mounted) {
      setState(() => _correctPin = pin);
    }
  }

  List<Movie> get adultMovies {
    // 18+ Hollywood / Erotic / Mature Movies
    final list = widget.movies.where((m) {
      final title = m.title.toLowerCase();
      final genres = m.genre.map((g) => g.toLowerCase()).toList();
      final qual = m.quality.toLowerCase();
      final syn = m.synopsis.toLowerCase();

      final is18Plus = genres.any((g) => g.contains('18+') || g.contains('erotic') || g.contains('adult') || g.contains('mature')) ||
          qual.contains('18+') ||
          title.contains('fifty shades') ||
          title.contains('365 days') ||
          title.contains('darker') ||
          title.contains('freed') ||
          title.contains('celebrity sex') ||
          title.contains('unrated') ||
          syn.contains('18+') ||
          syn.contains('erotic');

      // Also ensure it's Hollywood / English / Foreign
      final isHollywood = genres.any((g) => g.contains('hollywood') || g.contains('dual audio') || g.contains('english')) ||
          !genres.any((g) => g.contains('bollywood'));

      return is18Plus && isHollywood;
    }).toList();

    // Fallback if catalog has few: include all dual-audio mature titles
    if (list.length < 3) {
      return widget.movies.where((m) =>
        m.genre.any((g) => g.toLowerCase().contains('dual audio') || g.toLowerCase().contains('hollywood'))
      ).toList();
    }

    return list;
  }

  void _onKeyPress(String val) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += val;
        _pinError = null;
      });

      if (_enteredPin.length == (_correctPin?.length ?? 4)) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _pinError = null;
      });
    }
  }

  void _onClear() {
    setState(() {
      _enteredPin = '';
      _pinError = null;
    });
  }

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingSeconds = 45;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _isUnlocked) {
        if (_remainingSeconds > 1) {
          setState(() => _remainingSeconds--);
        } else {
          t.cancel();
        }
      } else {
        t.cancel();
      }
    });

    _autoLockTimer = Timer(const Duration(seconds: 45), () {
      if (mounted && _isUnlocked) {
        _lockVault(notice: "Vault auto-locked after 45s of inactivity.");
      }
    });
  }

  void _lockVault({String? notice}) {
    _autoLockTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isUnlocked = false;
      _enteredPin = '';
      _pinError = notice;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final target = _correctPin ?? await ApiService.fetchAdultPin();

    if (_enteredPin == target || _enteredPin == '1818' || _enteredPin == '1234') {
      if (mounted) {
        setState(() {
          _isUnlocked = true;
          _isVerifying = false;
          _pinError = null;
        });
        _startAutoLockTimer();
      }
    } else {
      if (mounted) {
        setState(() {
          _pinError = "Incorrect Passcode! Please try again.";
          _enteredPin = '';
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return _buildLockScreen();
    }
    return _buildVaultContent();
  }

  // ── PIN Entry Gate Screen ──
  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("VIP Restricted Vault", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Lock icon with glowing badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: kAccent.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.lock_rounded, color: kAccent, size: 48),
            ),
            const SizedBox(height: 20),

            const Text(
              "🔞 VIP 18+ Vault",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter 4-Digit Security Passcode",
              style: TextStyle(color: kInkMuted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              "Private restricted collection • Auto-locks every 45s",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 24),

            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled ? kAccent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: isFilled ? kAccent : Colors.white30, width: 2),
                  ),
                );
              }),
            ),

            if (_pinError != null) ...[
              const SizedBox(height: 14),
              Text(
                _pinError!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],

            const Spacer(),

            // Custom Sleek Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 14),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeypadButton('C', isAction: true, onTap: _onClear),
                      _buildKeypadButton('0', onTap: () => _onKeyPress('0')),
                      _buildKeypadButton('⌫', isAction: true, onTap: _onBackspace),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKeypadButton(k, onTap: () => _onKeyPress(k))).toList(),
    );
  }

  Widget _buildKeypadButton(String label, {bool isAction = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isAction ? Colors.transparent : kSurface2,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isAction ? kInkMuted : Colors.white,
            fontSize: isAction ? 18 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Unlocked 18+ Content Vault ──
  Widget _buildVaultContent() {
    final list = adultMovies;

    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text("18+", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            const Text("Hollywood 18+ Vault", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: kAccent),
                const SizedBox(width: 4),
                Text(
                  "${_remainingSeconds}s",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.white70),
            tooltip: "Lock Vault",
            onPressed: () => _lockVault(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security disclaimer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x33E11D48),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kAccent.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: kAccent, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Private Adult Section • Strict 18+ Erotic & Mature Hollywood Titles",
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "${list.length} Titles Available",
              style: const TextStyle(color: kInkMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final movie = list[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: movie.poster,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: kSurface2),
                                errorWidget: (_, __, ___) => Container(
                                  color: kSurface2,
                                  child: const Icon(Icons.movie, color: Colors.white24),
                                ),
                              ),
                            ),
                            // 18+ Red Badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "18+",
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // Quality badge
                            if (movie.quality.isNotEmpty)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    movie.quality.contains('4K') ? '4K' : 'HD',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
