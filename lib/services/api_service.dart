import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String catalogUrl = 'https://movie-bazar-iota.vercel.app/data/movies.json';
  static const String backupCatalogUrl = 'https://raw.githubusercontent.com/gitworld08210/Movie-bazar-/main/data/movies.json';
  static const String requestApiUrl = 'https://movie-bazar-iota.vercel.app/api/request';
  static const String supabaseUrl = 'https://nbnardbqkjouakkikxmr.supabase.co/rest/v1/movies?select=*&order=created_at.desc';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ibmFyZGJxa2pvdWFra2lreG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1NzU4NzIsImV4cCI6MjEwNjE1MTg3Mn0.YLpsdock3gBniqdc52SFnD6BcHFYzBaRXAEwUqNWQP0';
  static const String tmdbApiKey = '15d2ea6d0dc1d476efbca3eba2b9bbfb';

  static List<Movie>? _cachedMovies;

  static Future<List<Movie>> fetchMovies({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedMovies != null && _cachedMovies!.isNotEmpty) {
      return _cachedMovies!;
    }

    // 1. Direct from Supabase Live Database First (instant real-time updates)
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl&limit=1000'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        if (list.isNotEmpty) {
          _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
          return _cachedMovies!;
        }
      }
    } catch (_) {}

    // 2. Fallback to Vercel catalog cache
    try {
      final response = await http.get(Uri.parse(catalogUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
        return _cachedMovies!;
      }
    } catch (_) {}

    // 3. Fallback to GitHub raw
    try {
      final response = await http.get(Uri.parse(backupCatalogUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
        return _cachedMovies!;
      }
    } catch (_) {}

    return _cachedMovies ?? [];
  }

  /// Search TMDB for live titles (Movies & TV Shows)
  static Future<List<Map<String, dynamic>>> searchTmdb(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeComponent(query.trim());
      final url = 'https://api.themoviedb.org/3/search/multi?api_key=$tmdbApiKey&query=$encoded';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List results = data['results'] ?? [];
        return results
            .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .map<Map<String, dynamic>>((item) {
          final isTv = item['media_type'] == 'tv';
          final title = item['title'] ?? item['name'] ?? 'Untitled';
          final dateStr = item['release_date'] ?? item['first_air_date'] ?? '';
          final year = dateStr.isNotEmpty && dateStr.length >= 4 ? dateStr.substring(0, 4) : '';
          final posterPath = item['poster_path'];
          final posterUrl = posterPath != null
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800';
          final backdropPath = item['backdrop_path'];
          final backdropUrl = backdropPath != null
              ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
              : posterUrl;

          return {
            'id': item['id'],
            'title': title,
            'type': isTv ? 'series' : 'movie',
            'year': int.tryParse(year) ?? DateTime.now().year,
            'yearStr': year,
            'poster': posterUrl,
            'backdrop': backdropUrl,
            'overview': item['overview'] ?? '',
            'rating': item['vote_average'] != null ? (item['vote_average'] as num).toDouble() : 0.0,
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Submit a priority user request to Cinemax Priority Queue
  static Future<Map<String, dynamic>> submitPriorityRequest({
    required String title,
    int? tmdbId,
    String type = 'movie',
    int? year,
    String? poster,
    String? backdrop,
    String? synopsis,
  }) async {
    final payload = {
      'title': title,
      'tmdb_id': tmdbId,
      'type': type,
      'year': year ?? DateTime.now().year,
      'poster': poster ?? 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'backdrop': backdrop ?? poster ?? '',
      'synopsis': synopsis ?? 'Priority requested content: $title',
    };

    try {
      final response = await http.post(
        Uri.parse(requestApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    // Fallback direct to Supabase
    try {
      final reqId = 'req-${tmdbId ?? DateTime.now().millisecondsSinceEpoch}';
      final supaPayload = {
        'id': reqId,
        'title': title,
        'type': type,
        'year': year ?? DateTime.now().year,
        'duration': type == 'series' ? 'Series' : '2h 10m',
        'quality': 'PRIORITY_REQUEST',
        'badge': 'priority_request',
        'rating': 8.0,
        'maturity': 'U/A 16+',
        'video_url': tmdbId != null
            ? (type == 'series'
                ? 'https://vidsrc.me/embed/tv?tmdb=$tmdbId&season=1&episode=1'
                : 'https://vidsrc.me/embed/movie?tmdb=$tmdbId')
            : 'https://autoembed.co/movie/tmdb/337167',
        'download_url': '',
        'allow_download': false,
        'rights_confirmed': true,
        'poster': poster ?? 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        'backdrop': backdrop ?? poster ?? '',
        'genre': ['Requested Title', type == 'series' ? 'Web Series' : 'Bollywood'],
        'synopsis': synopsis ?? 'Requested title: $title',
      };

      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/movies'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: json.encode(supaPayload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Request submitted to Priority Engine!'};
      }
    } catch (_) {}

    return {'success': false, 'message': 'Failed to submit request.'};
  }

  /// Fetch the 18+ Vault PIN (Synced from Telegram Bot)
  static Future<String> fetchAdultPin() async {
    // 1. Try Render stream server /api/pin
    try {
      final res = await http.get(Uri.parse('https://ott-script-1.onrender.com/api/pin')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        final pin = data['pin']?.toString().trim();
        if (pin != null && pin.isNotEmpty) return pin;
      }
    } catch (_) {}

    // 2. Try Supabase config row
    try {
      final res = await http.get(
        Uri.parse('https://nbnardbqkjouakkikxmr.supabase.co/rest/v1/movies?id=eq.app-pin-18&select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = json.decode(utf8.decode(res.bodyBytes));
        if (list.isNotEmpty) {
          final pin = list[0]['title']?.toString().trim();
          if (pin != null && pin.isNotEmpty) return pin;
        }
      }
    } catch (_) {}

    return '1818'; // Default fallback PIN
  }

  /// Fetch real TV series seasons and episodes from TMDB
  static Future<List<Map<String, dynamic>>> fetchTvEpisodes(String title, {int season = 1}) async {
    final clean = title.replaceAll(RegExp(r'\s*\(?\d{4}\)?.*'), '').replaceAll(RegExp(r'(?i)season\s*\d+'), '').trim();
    try {
      final searchUrl = 'https://api.themoviedb.org/3/search/tv?api_key=$tmdbApiKey&query=${Uri.encodeComponent(clean)}';
      final sRes = await http.get(Uri.parse(searchUrl)).timeout(const Duration(seconds: 5));
      if (sRes.statusCode == 200) {
        final sData = json.decode(utf8.decode(sRes.bodyBytes));
        final results = sData['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final tvId = results[0]['id'];
          final epUrl = 'https://api.themoviedb.org/3/tv/$tvId/season/$season?api_key=$tmdbApiKey';
          final epRes = await http.get(Uri.parse(epUrl)).timeout(const Duration(seconds: 5));
          if (epRes.statusCode == 200) {
            final epData = json.decode(utf8.decode(epRes.bodyBytes));
            final eps = epData['episodes'] as List?;
            if (eps != null && eps.isNotEmpty) {
              return eps.map<Map<String, dynamic>>((e) {
                final stillPath = e['still_path'];
                return {
                  'episode_number': e['episode_number'] ?? 1,
                  'name': e['name'] ?? 'Episode ${e['episode_number']}',
                  'overview': e['overview'] ?? '',
                  'still': stillPath != null ? 'https://image.tmdb.org/t/p/w500$stillPath' : '',
                  'runtime': e['runtime'] != null ? '${e['runtime']}m' : '45m',
                };
              }).toList();
            }
          }
        }
      }
    } catch (_) {}

    // Fallback: Return 8 standard episodes
    return List.generate(8, (i) => {
      'episode_number': i + 1,
      'name': 'Episode ${i + 1}',
      'overview': 'Watch Episode ${i + 1} in Full HD on Cinemax Prime.',
      'still': '',
      'runtime': '45m',
    });
  }
}
