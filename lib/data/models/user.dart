class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? profilePhotoPath;
  final String? createdAt;

  const User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profilePhotoPath,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profilePhotoPath: map['profile_photo_path'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profile_photo_path': profilePhotoPath,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? profilePhotoPath,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
