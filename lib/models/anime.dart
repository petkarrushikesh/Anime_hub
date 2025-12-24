class Anime {
  final int malId;
  final String title;
  final String? imageUrl;
  final String? trailerUrl;
  final String? synopsis;
  final double? score;
  final int? year;
  final List<String> genres;
  final String? type;
  final String? status;
  final String? aired;
  final int? episodes;

  Anime({
    required this.malId,
    required this.title,
    this.imageUrl,
    this.trailerUrl,
    this.synopsis,
    this.score,
    this.year,
    required this.genres,
    this.type,
    this.status,
    this.aired,
    this.episodes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    List<String> genreList = [];
    if (json['genres'] != null) {
      genreList = (json['genres'] as List)
          .map((genre) => genre['name'].toString())
          .toList();
    }

    String? trailerUrl;
    if (json['trailer'] != null && json['trailer']['url'] != null) {
      trailerUrl = json['trailer']['url'];
    } else if (json['trailer'] != null &&
        json['trailer']['youtube_id'] != null) {
      trailerUrl = 'https://www.youtube.com/watch?v=-G9BqkgZXRA=${json['trailer']['watch?v=-G9BqkgZXRA=']}';
    }

    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      imageUrl: json['images']?['jpg']?['large_image_url'] ??
          json['images']?['jpg']?['image_url'],
      trailerUrl: trailerUrl,
      synopsis: json['synopsis'],
      score: json['score']?.toDouble(),
      year: json['year'],
      genres: genreList,
      type: json['type'],
      status: json['status'],
      aired: json['aired']?['string'],
      episodes: json['episodes'],
    );
  }

  String get genresString => genres.join(', ');

  String get scoreString => score != null ? score!.toStringAsFixed(1) : 'N/A';

  String get yearString => year?.toString() ?? 'N/A';
}