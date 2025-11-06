// Lokasi File: lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'koleksi_page.dart';
import 'pencarian_page.dart';
import 'profil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Variabel untuk menyimpan indeks tab yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai tab
  static const List<Widget> _pages = <Widget>[
    BerandaPage(),
    PencarianPage(),
    KoleksiPage(),
    ProfilPage(),
  ];

  // Fungsi untuk mengubah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman sesuai _selectedIndex
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Definisikan BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        // Daftar item/tombol di navigasi
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        // Pengaturan UI
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna tab aktif
        unselectedItemColor: Colors.grey, // Warna tab non-aktif
        onTap: _onItemTapped, // Fungsi yang dipanggil saat tab diklik
        type: BottomNavigationBarType.fixed, // Agar semua label tampil
      ),
    );
  }
}