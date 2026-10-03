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
        return data.map((e) => Movie.fromJson(e)).toList();
      }
    } catch (e) {
      // Return empty list on failure, no crash
    }
    return [];
  }

  /// Fetch trending movies
  Future<List<Movie>> fetchTrending({int limit = 5000000}) async {
    try {
      final uri = Uri.parse('$_baseUrl?select=*&order=rating.desc&limit=$limit');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Movie.fromJson(e)).toList();
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

  /// Submit user request
  Future<bool> submitTitleRequest(String title, String type) async {
    try {
      final reqId = 'req-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final payload = {
        'id': reqId,
        'title': title.trim(),
        'type': type,
        'quality': 'PRIORITY_REQUEST',
        'badge': 'priority_request',
        'rights_confirmed': true,
        'allow_download': true,
        'rating': 4.8,
        'year': DateTime.now().year,
        'genre': [type == 'series' ? 'Web Series' : 'Bollywood', 'Requested'],
        'synopsis': 'High-priority title requested in 1080p Ultra HD.',
        'poster': 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=780&auto=format&fit=crop',
        'backdrop': 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1280&auto=format&fit=crop',
        'video_url': 'https://autoembed.co/movie/tmdb/popular',
        'download_url': '',
      };

      final uri = Uri.parse(_baseUrl);
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
