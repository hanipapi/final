// Lokasi File: lib/pages/pencarian_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:project_akhir/services/unsplash_service.dart';

// 1. Ubah menjadi StatefulWidget
class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final UnsplashService _service = UnsplashService();
  final TextEditingController _searchController = TextEditingController();

  List<Photo> _photos = [];
  bool _isLoading = false;
  // bool untuk melacak apakah user sudah pernah mencari
  bool _hasSearched = false;

  // 2. Fungsi untuk memicu pencarian
  Future<void> _doSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) return; // Jangan cari jika kosong

    // Tutup keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true; // Tandai sudah pernah mencari
      _photos = []; // Kosongkan hasil sebelumnya
    });

    try {
      final results = await _service.searchPhotos(query, 1);
      setState(() {
        _photos = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Gagal melakukan pencarian. Cek koneksi Anda.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Foto')),
      body: Column(
        children: [
          // 3. Kolom (TextField) Pencarian
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ketik pencarian (cth: "nature", "cars")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _doSearch, // Panggil fungsi cari saat ikon ditekan
                ),
                border: const OutlineInputBorder(),
              ),
              // Panggil fungsi cari saat user tekan "Enter/Submit" di keyboard
              onSubmitted: (value) => _doSearch(),
            ),
          ),
          
          // 4. Tampilkan hasil (atau status)
          Expanded(
            child: _buildResultsBody(),
          ),
        ],
      ),
    );
  }

  // 5. Widget helper untuk menampilkan hasil
  Widget _buildResultsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Text('Silakan ketik sesuatu untuk memulai pencarian.'),
      );
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Text('Tidak ada hasil yang ditemukan.'),
      );
    }

    // 6. Tampilkan Grid (mirip BerandaPage)
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return InkWell(
          onTap: () {
            // 7. Arahkan ke Halaman Detail
            // Kita tidak perlu menunggu hasil 'pop' di sini
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailFotoPage(photo: photo),
              ),
            );
          },
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              photo.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}