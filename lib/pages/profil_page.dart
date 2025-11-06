// Lokasi File: lib/pages/profil_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/pages/auth_page.dart';
import 'package:project_akhir/pages/toolkit_page.dart';
import 'package:project_akhir/services/auth_service.dart';
import 'package:project_akhir/services/saran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_akhir/services/notification_service.dart';


// 1. Ubah menjadi StatefulWidget
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // 2. Buat instance service
  final AuthService _authService = AuthService();
  final SaranService _saranService = SaranService();

  // 3. Variabel untuk data user dan controller
  String _username = "Memuat...";
  String _email = "Memuat...";
  final TextEditingController _saranController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 4. Panggil data user saat halaman dibuka
    _loadUserData();
  }

  // 5. Fungsi untuk mengambil data user
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _username = user['username'];
        _email = user['email'];
      });
    }
  }

  // 6. Fungsi untuk kirim saran
  Future<void> _kirimSaran() async {
    final saran = _saranController.text;
    if (saran.isEmpty) {
      _showSnackBar('Saran tidak boleh kosong.', isError: true);
      return;
    }

    // Tutup keyboard
    FocusScope.of(context).unfocus();

    try {
      await _saranService.simpanSaran(saran);
      _saranController.clear();
      _showSnackBar('Saran Anda telah terkirim. Terima kasih!', isError: false);
    } catch (e) {
      _showSnackBar('Gagal mengirim saran.', isError: true);
    }
  }

  // 7. Fungsi Logout (tetap sama)
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      // 8. Gunakan ListView agar bisa di-scroll
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- BAGIAN INFO USER ---
          const Icon(Icons.account_circle, size: 100, color: Colors.blue),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              _email,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          const Divider(height: 40),

          //
          // [BARU] Tombol untuk Toolkit
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ToolkitPage()),
              );
            },
            icon: const Icon(Icons.construction),
            label: const Text('Buka Creative Toolkit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          //notifikasi
          const Text(
            'Notifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          // Tombol Tes Cepat
          OutlinedButton(
            onPressed: () {
              NotificationService.showTestNotification();
            },
            child: const Text('Kirim Tes Notifikasi Sekarang'),
          ),
          const SizedBox(height: 10),
          // Tombol Jadwalkan Harian
          ElevatedButton(
            onPressed: () {
              NotificationService.scheduleDailyNotification();
              _showSnackBar('Notifikasi harian (10:00) diaktifkan!', isError: false);
            },
            child: const Text('Aktifkan Notifikasi Harian (10:00)'),
          ),

          const Divider(height: 40),

          // --- BAGIAN SARAN & KESAN --- 
          const Text(
            'Saran & Kesan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _saranController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tulis masukan Anda untuk aplikasi ini...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _kirimSaran,
            child: const Text('Kirim Saran'),
          ),

          const Divider(height: 40),

          // --- BAGIAN LOGOUT --- 
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}