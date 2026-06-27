class WatchedItem {
  final int? id;
  final int userId;
  final String title;
  final String category; // 'Film' or 'Series'
  final String genre; // Comma-separated string
  final int? season;
  final int? episode;
  final String? synopsis;
  final double? rating;
  final String? review;
  final String? posterPath;
  final String? createdAt;
  final String status; // 'Sudah Nonton', 'Planning Nonton', 'Up Coming'

  const WatchedItem({
    this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.genre,
    this.season,
    this.episode,
    this.synopsis,
    this.rating,
    this.review,
    this.posterPath,
    this.createdAt,
    this.status = 'Sudah Nonton',
  });

  /// Create from SQLite row map.
  factory WatchedItem.fromMap(Map<String, dynamic> map) {
    return WatchedItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      genre: map['genre'] as String,
      season: map['season'] as int?,
      episode: map['episode'] as int?,
      synopsis: map['synopsis'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      review: map['review'] as String?,
      posterPath: map['poster_path'] as String?,
      createdAt: map['created_at'] as String?,
      status: map['status'] as String? ?? 'Sudah Nonton',
    );
  }

  /// Convert to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'genre': genre,
      'season': season,
      'episode': episode,
      'synopsis': synopsis,
      'rating': rating,
      'review': review,
      'poster_path': posterPath,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'status': status,
    };
  }

  /// Immutable copy with optional field overrides.
  WatchedItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? category,
    String? genre,
    int? season,
    int? episode,
    String? synopsis,
    double? rating,
    String? review,
    String? posterPath,
    String? createdAt,
    String? status,
  }) {
    return WatchedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      genre: genre ?? this.genre,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      synopsis: synopsis ?? this.synopsis,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      posterPath: posterPath ?? this.posterPath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
