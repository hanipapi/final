// Lokasi File: lib/services/koleksi_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KoleksiService {
  final Box _koleksiBox = Hive.box('koleksiBox');

  Future<String?> _getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUserEmail');
  }

  Future<List<dynamic>> _getUserCollection(String email) async {
    return _koleksiBox.get(email, defaultValue: []);
  }

  // --- Fungsi Simpan, Hapus, Cek (Tidak Berubah) ---

  Future<void> simpanFoto(Photo photo) async {
    final email = await _getCurrentUserEmail();
    if (email == null) return;
    List<dynamic> koleksi = await _getUserCollection(email);
    koleksi.add({
      'id': photo.id,
      'imageUrl': photo.imageUrl,
      'creatorName': photo.creatorName,
    });
    await _koleksiBox.put(email, koleksi);
  }

  Future<void> hapusFoto(String photoId) async {
    final email = await _getCurrentUserEmail();
    if (email == null) return;
    List<dynamic> koleksi = await _getUserCollection(email);
    koleksi.removeWhere((item) => item['id'] == photoId);
    await _koleksiBox.put(email, koleksi);
  }

  Future<bool> cekApakahSudahDisimpan(String photoId) async {
    final email = await _getCurrentUserEmail();
    if (email == null) return false;
    List<dynamic> koleksi = await _getUserCollection(email);
    return koleksi.any((item) => item['id'] == photoId);
  }

  // --- [FUNGSI BARU] ---
  
  // Fungsi untuk mengambil list koleksi yang sudah jadi List<Photo>
  Future<List<Photo>> getKoleksi() async {
    final email = await _getCurrentUserEmail();
    if (email == null) return []; // Kembalikan list kosong jika user tidak ada

    final List<dynamic> koleksiMaps = await _getUserCollection(email);
    
    // Ubah List<dynamic> (isinya Map) menjadi List<Photo>
    return koleksiMaps
        .map((map) => Photo.fromHiveMap(map))
        .toList()
        .reversed // Tampilkan yang terbaru disimpan di paling atas
        .toList();
  }
}