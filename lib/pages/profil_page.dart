// Lokasi File: lib/pages/profil_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/pages/auth_page.dart';
import 'package:project_akhir/pages/toolkit_page.dart';
import 'package:project_akhir/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State ---
  final AuthService _authService = AuthService();
  String _username = "Memuat...";
  String _email = "Memuat...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _username = user['username'];
        _email = user['email'];
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Akun Anda',
          style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // --- 1. Bagian Info User ---
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: lightGrey,
              child: Icon(Icons.person, size: 30, color: darkGrey),
            ),
            title: Text(
              _username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryBlack,
              ),
            ),
            subtitle: Text(
              _email,
              style: const TextStyle(color: darkGrey),
            ),
            trailing: const Icon(Icons.verified, size: 20, color: primaryGreen),
          ),
          
          // --- 2. Grup Toolkit ---
          _buildGroupHeader('Toolkit'),
          ListTile(
            leading: const Icon(Icons.construction_outlined, color: primaryBlack),
            title: const Text('Creative Toolkit'),
            subtitle: const Text('Kalkulator Golden Hour & Palet'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ToolkitPage()),
              );
            },
          ),
          
          // --- 3. Grup Kesan & Pesan (STATIS) ---
          _buildGroupHeader('Kesan & Pesan Developer'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Kesan:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Pengembangan aplikasi ini memberikan wawasan mendalam tentang integrasi API dan manajemen state di Flutter.",
                    style: TextStyle(color: darkGrey, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  Divider(height: 24),
                  Text(
                    "Pesan:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  // [TEKS YANG ANDA MINTA]
                  Text(
                    "Semoga aplikasi ini membantu anda dan terimakasih pak bagus sudah membimbing saya.",
                    style: TextStyle(color: darkGrey, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // --- 4. Tombol Logout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}