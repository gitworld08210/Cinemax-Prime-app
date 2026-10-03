import 'package:flutter/material.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../core/app_theme.dart';

class RequestDialog extends StatefulWidget {
  const RequestDialog({super.key});

  @override
  State<RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabase = SupabaseService();
  String _selectedType = 'movie';
  bool _isLoading = false;
  String? _statusMessage;

  void _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final success = await _supabase.submitTitleRequest(title, _selectedType);

    setState(() {
      _isLoading = false;
      _statusMessage = success
          ? '🎉 Request received! Our cloud pipeline is fetching 1080p stream.'
          : '⚠️ Could not queue right now. Please try again.';
    });

    if (success) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.borderSubtle, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Request Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const Size(30, 30),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Cannot find your movie or TV show? Request it here for automatic 1080p cloud pipeline processing.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 16),

            // Type Selector (Netflix Pills)
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Movie')),
                    selected: _selectedType == 'movie',
                    selectedColor: AppTheme.netflixRed,
                    backgroundColor: const Color(0xFF242424),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _selectedType == 'movie' ? Colors.white : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(
                      color: _selectedType == 'movie' ? AppTheme.netflixRed : const BorderSide(color: Color(0xFF333333)).color,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = 'movie');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Web Series')),
                    selected: _selectedType == 'series',
                    selectedColor: AppTheme.netflixRed,
                    backgroundColor: const Color(0xFF242424),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _selectedType == 'series' ? Colors.white : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(
                      color: _selectedType == 'series' ? AppTheme.netflixRed : const BorderSide(color: Color(0xFF333333)).color,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = 'series');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input field
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter title (e.g. Inception, Mirzapur)...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF242424),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.netflixRed, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusMessage!.contains('🎉') ? AppTheme.matchGreen : AppTheme.netflixRed,
                  ),
                ),
              ),

            // Submit Button (Netflix Red)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.netflixRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
