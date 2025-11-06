// Lokasi File: lib/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
  // Fungsi ini akan dieksekusi saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    // Kita panggil fungsi pengecekan sesi
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Beri jeda 1 detik untuk simulasi loading
    await Future.delayed(const Duration(seconds: 1));

    // Ambil instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Cek flag 'isLoggedIn'
    // '?? false' artinya jika flag-nya null (belum ada), anggap false
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Pengecekan 'mounted' penting untuk menghindari error
    if (!mounted) return;

    // Navigasi berdasarkan status login
    if (isLoggedIn) {
      // Jika sudah login, lempar ke HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      ); 
    } else {
      // Jika belum login, lempar ke AuthPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan loading sederhana
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat data...'),
          ],
        ),
      ),
    );
  }
}