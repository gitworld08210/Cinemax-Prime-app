class Movie {
  final String id;
  final String title;
  final String type;
  final String synopsis;
  final String poster;
  final String backdrop;
  final int year;
  final double rating;
  final List<String> genre;
  final String videoUrl;
  final String downloadUrl;
  final String quality;
  final String badge;

  const Movie({
    required this.id,
    required this.title,
    required this.type,
    required this.synopsis,
    required this.poster,
    required this.backdrop,
    required this.year,
    required this.rating,
    required this.genre,
    required this.videoUrl,
    required this.downloadUrl,
    required this.quality,
    required this.badge,
  });

  bool get isSeries => type.toLowerCase() == 'series' || badge.toLowerCase() == 'series';

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genre'] is List) {
      parsedGenres = (json['genre'] as List).map((e) => e.toString()).toList();
    } else if (json['genre'] is String) {
      parsedGenres = (json['genre'] as String).split(',').map((e) => e.trim()).toList();
    }
    if (parsedGenres.isEmpty) {
      parsedGenres = ['Cinema', 'Popular'];
    }

    double parsedRating = 4.5;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else {
        parsedRating = double.tryParse(json['rating'].toString()) ?? 4.5;
      }
    }

    int parsedYear = 2024;
    if (json['year'] != null) {
      if (json['year'] is int) {
        parsedYear = json['year'] as int;
      } else {
        parsedYear = int.tryParse(json['year'].toString()) ?? 2024;
      }
    }

    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      type: json['type']?.toString() ?? 'movie',
      synopsis: json['synopsis']?.toString() ?? '',
      poster: json['poster']?.toString() ?? 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=780&auto=format&fit=crop',
      backdrop: json['backdrop']?.toString() ?? 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1280&auto=format&fit=crop',
      year: parsedYear,
      rating: parsedRating,
      genre: parsedGenres,
      videoUrl: json['video_url']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
      quality: json['quality']?.toString() ?? '1080p Ultra HD',
      badge: json['badge']?.toString() ?? '',
    );
  }
}
