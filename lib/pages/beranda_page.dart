// Lokasi File: lib/pages/beranda_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/services/unsplash_service.dart';

// 2. Ubah menjadi StatefulWidget
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // 3. Buat instance service
  final UnsplashService _unsplashService = UnsplashService();
  
  // 4. Buat variabel untuk menyimpan daftar foto
  List<Photo> _photos = [];
  bool _isLoading = true;
  int _currentPage = 1;

  // 5. Panggil fungsi untuk mengambil data saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  // 6. Fungsi untuk mengambil data dari service
  Future<void> _fetchPhotos() async {
    // Set loading jadi true (jika ini halaman pertama)
    if (_currentPage == 1) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Panggil service
      final newPhotos = await _unsplashService.getNewPhotos(_currentPage);
      
      // Tambahkan foto baru ke daftar
      setState(() {
        _isLoading = false;
        _photos.addAll(newPhotos);
        _currentPage++; // Siapkan untuk halaman selanjutnya
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Tampilkan error
      _showSnackBar('Gagal memuat foto. Cek koneksi Anda.', isError: true);
    }
  }
  
  // Fungsi helper untuk SnackBar
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
      appBar: AppBar(
        title: const Text('Beranda InstaGallery'),
      ),
      // 7. Tampilkan loading atau grid
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Saat ditarik (refresh), reset dan ambil data dari halaman 1
                setState(() {
                  _photos = [];
                  _currentPage = 1;
                });
                await _fetchPhotos();
              },
              // 8. Gunakan MasonryGridView
              child: MasonryGridView.count(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 2, // Tampilkan 2 kolom
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  
                  // [GANTI INI] Bungkus Card dengan InkWell
                  return InkWell(
                    onTap: () {
                      // [LOGIKA BARU] Navigasi ke Halaman Detail
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailFotoPage(photo: photo),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              photo.creatorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
    );
  }
}