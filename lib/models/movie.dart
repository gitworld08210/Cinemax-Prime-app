class AudioTrackInfo {
  final String lang;
  final String label;
  final String videoUrl;
  final bool isDefault;

  AudioTrackInfo({
    required this.lang,
    required this.label,
    required this.videoUrl,
    this.isDefault = false,
  });

  factory AudioTrackInfo.fromJson(Map<String, dynamic> json) {
    return AudioTrackInfo(
      lang: json['lang'] ?? 'hi',
      label: json['label'] ?? 'Hindi',
      videoUrl: json['video_url'] ?? '',
      isDefault: json['default'] ?? false,
    );
  }
}

class Movie {
  final String id;
  final String title;
  final String type; // 'movie' or 'series'
  final int year;
  final String duration;
  final String quality;
  final double rating;
  final String poster;
  final String backdrop;
  final String videoUrl;
  final String downloadUrl;
  final String synopsis;
  final List<String> genre;
  final List<AudioTrackInfo> audioTracks;
  final bool isFeatured;
  final bool isTrending;
  final String badge;

  Movie({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
    required this.duration,
    required this.quality,
    required this.rating,
    required this.poster,
    required this.backdrop,
    required this.videoUrl,
    required this.downloadUrl,
    required this.synopsis,
    required this.genre,
    required this.audioTracks,
    this.isFeatured = false,
    this.isTrending = false,
    this.badge = '',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenre = [];
    if (json['genre'] is List) {
      parsedGenre = (json['genre'] as List).map((g) => g.toString()).toList();
    } else if (json['genre'] is String) {
      parsedGenre = [json['genre']];
    }

    List<AudioTrackInfo> tracks = [];
    if (json['audio_tracks'] is List) {
      tracks = (json['audio_tracks'] as List)
          .map((t) => AudioTrackInfo.fromJson(t))
          .toList();
    }

    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      type: json['type'] ?? 'movie',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2024') ?? 2024,
      duration: json['duration'] ?? '1080p Full HD',
      quality: json['quality'] ?? '1080p Ultra HD',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 8.0,
      poster: json['poster'] ?? 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      backdrop: json['backdrop'] ?? json['poster'] ?? 'https://images.unsplash.com/photo-1518173946687-a4c8a383392e?w=1600',
      videoUrl: json['video_url'] ?? '',
      downloadUrl: json['download_url'] ?? json['video_url'] ?? '',
      synopsis: json['synopsis'] ?? 'Watch in crisp Full HD on Cinemax Prime.',
      genre: parsedGenre.isNotEmpty ? parsedGenre : ['Action', 'Drama'],
      audioTracks: tracks,
      isFeatured: json['is_featured'] ?? false,
      isTrending: json['is_trending'] ?? false,
      badge: json['badge']?.toString() ?? '',
    );
  }
}
