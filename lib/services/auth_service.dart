
import 'package:bcrypt/bcrypt.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class AuthService {
  final Box _userBox = Hive.box('userBox');

  bool registerUser(String username, String email, String password) {
    try {
      if (_userBox.containsKey(email)) {
        return false;
      }
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      _userBox.put(email, {
        'username': username,
        'email': email,
        'password': hashedPassword,
      });
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  //
  // 2. [FUNGSI BARU] Logika untuk Login User
  //
  Future<bool> loginUser(String email, String password) async {
    try {
      // 1. Cek apakah email ada di database Hive
      if (!_userBox.containsKey(email)) {
        return false; // Email tidak ditemukan
      }

      // 2. Ambil data user dari Hive
      final user = _userBox.get(email) as Map;
      final String hashedPassword = user['password'];

      // 3. Bandingkan password yang diinput dengan yang di Hive
      //    Ini adalah fungsi utama bcrypt untuk verifikasi
      bool passwordMatch = BCrypt.checkpw(password, hashedPassword);

      if (passwordMatch) {
        // 4. [PENTING] Jika password cocok, buat session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);       
         // Kita simpan juga email-nya, akan berguna untuk halaman profil
        await prefs.setString('currentUserEmail', email);
        
        return true; // Login berhasil
      } else {
        return false; // Password salah
      }
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  Future<Map<dynamic, dynamic>?> getCurrentUser() async {
    try {
      // 1. Ambil email dari session
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('currentUserEmail');

      if (email == null) {
        return null; // Tidak ada user yang login
      }

      // 2. Ambil data dari userBox berdasarkan email
      if (_userBox.containsKey(email)) {
        return _userBox.get(email) as Map<dynamic, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}