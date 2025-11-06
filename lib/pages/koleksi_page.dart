// Lokasi File: lib/pages/koleksi_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:project_akhir/services/koleksi_service.dart';

// 1. Ubah menjadi StatefulWidget
class KoleksiPage extends StatefulWidget {
  const KoleksiPage({super.key});

  @override
  State<KoleksiPage> createState() => _KoleksiPageState();
}

class _KoleksiPageState extends State<KoleksiPage> {
  final KoleksiService _koleksiService = KoleksiService();
  
  bool _isLoading = true;
  List<Photo> _koleksiFoto = [];

  @override
  void initState() {
    super.initState();
    // 2. Ambil data saat halaman pertama kali dibuka
    _loadKoleksi();
  }

  // 3. Buat fungsi untuk mengambil data
  Future<void> _loadKoleksi() async {
    setState(() {
      _isLoading = true;
    });
    
    final foto = await _koleksiService.getKoleksi();
    
    setState(() {
      _koleksiFoto = foto;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Saya')),
      body: _isLoading
          // 4. Tampilkan loading
          ? const Center(child: CircularProgressIndicator())
          // 5. Tampilkan pesan jika kosong
          : _koleksiFoto.isEmpty
              ? Center(
                  child: Text(
                    'Anda belum menyimpan foto apapun.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                )
              // 6. Tampilkan galeri jika ada data
              : RefreshIndicator(
                  onRefresh: _loadKoleksi, // Bisa pull-to-refresh
                  child: MasonryGridView.count(
                    padding: const EdgeInsets.all(8.0),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: _koleksiFoto.length,
                    itemBuilder: (context, index) {
                      final photo = _koleksiFoto[index];
                      return InkWell(
                        onTap: () async {
                          // 7. Navigasi ke Detail & tunggu hasilnya
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailFotoPage(photo: photo),
                            ),
                          );
                          
                          // 8. Jika hasilnya 'true', muat ulang koleksi
                          if (result == true && mounted) {
                            _loadKoleksi();
                          }
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(photo.imageUrl, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}