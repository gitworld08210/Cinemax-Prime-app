import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String catalogUrl = 'https://movie-bazar-iota.vercel.app/data/movies.json';
  static const String backupCatalogUrl = 'https://raw.githubusercontent.com/gitworld08210/Movie-bazar-/main/data/movies.json';
  static const String supabaseUrl = 'https://nbnardbqkjouakkikxmr.supabase.co/rest/v1/movies?select=*&order=created_at.desc';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ibmFyZGJxa2pvdWFra2lreG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1NzU4NzIsImV4cCI6MjEwNjE1MTg3Mn0.YLpsdock3gBniqdc52SFnD6BcHFYzBaRXAEwUqNWQP0';

  static List<Movie>? _cachedMovies;

  static Future<List<Movie>> fetchMovies({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedMovies != null && _cachedMovies!.isNotEmpty) {
      return _cachedMovies!;
    }

    // 1. Try Vercel / GitHub movies.json first
    try {
      final response = await http.get(Uri.parse(catalogUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
        return _cachedMovies!;
      }
    } catch (_) {}

    // 2. Fallback to GitHub raw
    try {
      final response = await http.get(Uri.parse(backupCatalogUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
        return _cachedMovies!;
      }
    } catch (_) {}

    // 3. Fallback to Supabase direct
    try {
      final response = await http.get(
        Uri.parse(supabaseUrl),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
        _cachedMovies = list.map((item) => Movie.fromJson(item)).toList();
        return _cachedMovies!;
      }
    } catch (_) {}

    return _cachedMovies ?? [];
  }
}
