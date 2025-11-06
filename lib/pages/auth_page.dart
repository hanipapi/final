// Lokasi File: lib/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/services/auth_service.dart';
// 1. [BARU] Import halaman Home
import 'main_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  // 2. [UBAH] Fungsi ini sekarang 'async' lagi
  void _handleAuthAction() async { 
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isLoginMode) {
      // --- LOGIKA LOGIN (INI BAGIAN BARUNYA) ---
      if (email.isEmpty || password.isEmpty) {
        _showSnackBar('Email dan Password harus diisi', isError: true);
        return;
      }

      // 3. Panggil loginUser (pakai 'await' karena ini Future)
      bool success = await _authService.loginUser(email, password);

      if (success) {
        // 4. Jika sukses, Pindah ke HomePage
        //    Kita gunakan 'pushReplacement' agar user tidak bisa 'back'
        //    ke halaman login setelah berhasil login.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // 5. Jika gagal, tampilkan error
        _showSnackBar('Login Gagal. Cek kembali email dan password Anda.', isError: true);
      }

    } else {
      // --- LOGIKA REGISTER (Ini tetap sama) ---
      final username = _usernameController.text;
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        _showSnackBar('Semua kolom harus diisi', isError: true);
        return;
      }
      
      // (Perhatikan, 'registerUser' tidak pakai 'await' karena dia sinkron)
      bool success = _authService.registerUser(username, email, password);

      if (success) {
        _showSnackBar('Registrasi berhasil! Silakan login.', isError: false);
        _toggleMode();
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        _showSnackBar('Registrasi gagal. Email mungkin sudah terdaftar.', isError: true);
      }
    }
  }

  // (Fungsi SnackBar tetap sama)
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  //
  // --- Bagian UI (Tidak ada yang berubah) ---
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Daftar Akun Baru'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang di InstaGallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _isLoginMode
                    ? 'Silakan login untuk melanjutkan'
                    : 'Buat akun baru Anda',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),
              if (!_isLoginMode)
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              if (!_isLoginMode) const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleAuthAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoginMode ? 'Login' : 'Daftar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLoginMode
                      ? 'Belum punya akun? Daftar di sini'
                      : 'Sudah punya akun? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}