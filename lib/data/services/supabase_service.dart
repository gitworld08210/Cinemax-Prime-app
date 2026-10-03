import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/movie.dart';

class SupabaseService {
  static const String _baseUrl = 'https://nbnardbqkjouakkikxmr.supabase.co/rest/v1/movies';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ibmFyZGJxa2pvdWFra2lreG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1NzU4NzIsImV4cCI6MjEwNjE1MTg3Mn0.YLpsdock3gBniqdc52SFnD6BcHFYzBaRXAEwUqNWQP0';

  final Map<String, String> _headers = {
    'apikey': _anonKey,
    'Authorization': 'Bearer $_anonKey',
    'Content-Type': 'application/json',
  };

  /// Fetch all active titles from Supabase (Up to 50 Lakh titles)
  Future<List<Movie>> fetchAllMovies({int limit = 5000000}) async {
    try {
      final uri = Uri.parse('$_baseUrl?select=*&order=created_at.desc&limit=$limit');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          return data.map((e) => Movie.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    // Fallback: Fetch directly from Render Cloud API
    try {
      final renderRes = await http.get(Uri.parse('https://ott-script-1.onrender.com/api/movies'));
      if (renderRes.statusCode == 200) {
        final json = jsonDecode(renderRes.body);
        if (json['data'] is List && (json['data'] as List).isNotEmpty) {
          return (json['data'] as List).map((e) => Movie.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Fetch trending movies
  Future<List<Movie>> fetchTrending({int limit = 5000000}) async {
    try {
      final uri = Uri.parse('$_baseUrl?select=*&order=rating.desc&limit=$limit');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          return data.map((e) => Movie.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    // Fallback: Fetch directly from Render Cloud API
    try {
      final renderRes = await http.get(Uri.parse('https://ott-script-1.onrender.com/api/movies'));
      if (renderRes.statusCode == 200) {
        final json = jsonDecode(renderRes.body);
        if (json['data'] is List && (json['data'] as List).isNotEmpty) {
          return (json['data'] as List).map((e) => Movie.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Fetch Bollywood titles
  Future<List<Movie>> fetchBollywood({int limit = 5000000}) async {
    try {
      final uri = Uri.parse('$_baseUrl?genre=cs.{Bollywood}&select=*&order=created_at.desc&limit=$limit');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Movie.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetch Web Series
  Future<List<Movie>> fetchWebSeries({int limit = 5000000}) async {
    try {
      final uri = Uri.parse('$_baseUrl?or=(type.eq.series,badge.eq.series)&select=*&order=created_at.desc&limit=$limit');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Movie.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Instant Search
  Future<List<Movie>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeComponent('%${query.trim()}%');
      final uri = Uri.parse('$_baseUrl?title=ilike.$encoded&select=*&limit=20');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Movie.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Submit user request (Dispatches to Render Cloud, Telegram Channel & Supabase)
  Future<bool> submitTitleRequest(String title, String type) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return false;

    bool anySuccess = false;

    // 1. Direct Dispatch to Render Streaming Engine API
    try {
      final renderUri = Uri.parse('https://ott-script-1.onrender.com/api/request');
      final renderRes = await http.post(
        renderUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': cleanTitle,
          'type': type,
          'year': DateTime.now().year,
        }),
      ).timeout(const Duration(seconds: 8));
      if (renderRes.statusCode >= 200 && renderRes.statusCode < 300) {
        anySuccess = true;
      }
    } catch (_) {}

    // 2. Direct Telegram Notification Dispatch
    try {
      const botToken = '8951731294:AAHN5rB2a7xIff0Z1LbLm9YX2bztlbnU958';
      const channelId = '-1004369294454';
      final tgUri = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      final tgText = '🔔 *New Priority Content Request (From App)!*\n'
          '🎬 *Title*: $cleanTitle\n'
          '📁 *Type*: ${type.toUpperCase()}\n'
          '⚡ *Status*: Queued for Cloud Pipe & Streaming';
      final tgRes = await http.post(
        tgUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': channelId,
          'text': tgText,
          'parse_mode': 'Markdown',
        }),
      ).timeout(const Duration(seconds: 8));
      if (tgRes.statusCode == 200) {
        anySuccess = true;
      }
    } catch (_) {}

    // 3. Supabase Record Insertion
    try {
      final reqId = 'req-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final payload = {
        'id': reqId,
        'title': cleanTitle,
        'type': type,
        'quality': 'PRIORITY_REQUEST',
        'badge': 'priority_request',
        'rights_confirmed': true,
        'allow_download': true,
        'rating': 4.8,
        'year': DateTime.now().year,
        'genre': [type == 'series' ? 'Web Series' : 'Bollywood', 'Requested'],
        'synopsis': 'High-priority title requested in 1080p Ultra HD.',
        'poster': 'https://image.tmdb.org/t/p/w780/lIBjLUAAw2bzeOHBJIKiZI4QDL0.jpg',
        'backdrop': 'https://image.tmdb.org/t/p/w1280/lIBjLUAAw2bzeOHBJIKiZI4QDL0.jpg',
        'video_url': 'https://autoembed.co/movie/tmdb/popular',
        'download_url': '',
      };

      final uri = Uri.parse(_baseUrl);
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        anySuccess = true;
      }
    } catch (_) {}

    return anySuccess;
  }
}
