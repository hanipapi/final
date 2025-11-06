// Lokasi File: lib/pages/detail_foto_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/services/koleksi_service.dart';

class DetailFotoPage extends StatefulWidget {
  final Photo photo;
  const DetailFotoPage({super.key, required this.photo});

  @override
  State<DetailFotoPage> createState() => _DetailFotoPageState();
}

class _DetailFotoPageState extends State<DetailFotoPage> {
  final KoleksiService _koleksiService = KoleksiService();
  bool _sudahDisimpan = false;
  
  // [BARU] Variabel untuk melacak perubahan
  bool _apakahAdaPerubahan = false;

  @override
  void initState() {
    super.initState();
    _cekStatusFoto();
  }

  void _cekStatusFoto() async {
    bool status = await _koleksiService.cekApakahSudahDisimpan(widget.photo.id);
    setState(() {
      _sudahDisimpan = status;
    });
  }

  void _toggleSimpan() async {
    if (_sudahDisimpan) {
      await _koleksiService.hapusFoto(widget.photo.id);
      _showSnackBar('Foto dihapus dari koleksi', isError: true);
    } else {
      await _koleksiService.simpanFoto(widget.photo);
      _showSnackBar('Foto disimpan ke koleksi', isError: false);
    }
    
    // [BARU] Tandai bahwa telah terjadi perubahan
    setState(() {
      _apakahAdaPerubahan = true;
    });
    
    _cekStatusFoto();
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
    // [BARU] Gunakan PopScope untuk mengirim data saat 'Back'
    return PopScope(
      // Kirim nilai _apakahAdaPerubahan saat user menekan 'back'
      onPopInvoked: (didPop) {
         if (didPop) return;
         Navigator.of(context).pop(_apakahAdaPerubahan);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.photo.creatorName),
          // [BARU] Atur tombol back di AppBar agar mengirim data juga
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_apakahAdaPerubahan);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(widget.photo.imageUrl),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _toggleSimpan,
                  icon: Icon(_sudahDisimpan ? Icons.check : Icons.save),
                  label: Text(_sudahDisimpan ? 'Tersimpan' : 'Simpan ke Koleksi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sudahDisimpan ? Colors.grey : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Foto oleh: ${widget.photo.creatorName}',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}