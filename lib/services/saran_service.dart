// Lokasi File: lib/services/saran_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaranService {
  final Box _saranBox = Hive.box('saranBox');

  // Fungsi untuk menyimpan saran
  Future<void> simpanSaran(String saran) async {
    // 1. Ambil email user yang sedang login
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUserEmail');
    if (email == null) return; // Tidak ada user

    // 2. Ambil list saran yang sudah ada untuk user ini
    // Jika belum ada, buat list baru
    List<dynamic> daftarSaran = _saranBox.get(email, defaultValue: []);

    // 3. Tambahkan saran baru ke list
    daftarSaran.add({
      'saran': saran,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 4. Simpan kembali list yang sudah diupdate ke Hive
    await _saranBox.put(email, daftarSaran);
  }
}