// Lokasi File: lib/services/unsplash_service.dart

import 'package:dio/dio.dart';
import 'package:project_akhir/config.dart';
import 'package:project_akhir/models/photo_model.dart';

class UnsplashService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.unsplash.com/',
      headers: {
        'Authorization': 'Client-ID ${Config.unsplashAccessKey}',
      },
    ),
  );

  // --- Fungsi Get New Photos (Tetap sama) ---
  Future<List<Photo>> getNewPhotos(int page) async {
    try {
      final response = await _dio.get(
        '/photos',
        queryParameters: {
          'page': page,
          'per_page': 20,
          'order_by': 'latest',
        },
      );
      List<Photo> photos = (response.data as List)
          .map((item) => Photo.fromJson(item))
          .toList();
      return photos;
    } on DioException catch (e) {
      print('Error fetching photos: $e');
      throw Exception('Failed to load photos');
    }
  }

  // --- [FUNGSI BARU] ---
  // Fungsi untuk mencari foto berdasarkan query
  Future<List<Photo>> searchPhotos(String query, int page) async {
    try {
      // Panggil endpoint /search/photos 
      final response = await _dio.get(
        '/search/photos',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': 20,
        },
      );

      // PENTING: Hasil pencarian ada di dalam key 'results'
      List<Photo> photos = (response.data['results'] as List)
          .map((item) => Photo.fromJson(item))
          .toList();

      return photos;

    } on DioException catch (e) {
      print('Error searching photos: $e');
      throw Exception('Failed to search photos');
    }
  }
}