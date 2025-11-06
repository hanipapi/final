// Lokasi File: lib/models/photo_model.dart

class Photo {
  final String id;
  final String imageUrl;
  final String creatorName;

  Photo({
    required this.id,
    required this.imageUrl,
    required this.creatorName,
  });

  // Constructor 1: Untuk membaca dari API Unsplash (Sudah ada)
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      imageUrl: json['urls']['regular'],
      creatorName: json['user']['name'],
    );
  }

  // [BARU] Constructor 2: Untuk membaca dari database Hive
  factory Photo.fromHiveMap(Map<dynamic, dynamic> map) {
    return Photo(
      id: map['id'],
      imageUrl: map['imageUrl'],
      creatorName: map['creatorName'],
    );
  }
}