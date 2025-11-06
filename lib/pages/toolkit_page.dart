// Lokasi File: lib/pages/toolkit_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:project_akhir/services/currency_service.dart';

class ToolkitPage extends StatefulWidget {
  const ToolkitPage({super.key});

  @override
  State<ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<ToolkitPage> {
  // --- STATE UNTUK JAM (dari Tahap 11) ---
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String _localTimezoneName = 'Memuat...';
  bool _isLoadingLocation = true;

  // --- [STATE BARU] UNTUK KONVERTER MATA UANG ---
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController(text: '1.0');
  
  // Daftar mata uang (sesuai brief + USD sebagai base)
  final List<String> _currencies = ['USD', 'IDR', 'EUR', 'JPY'];
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  
  bool _isLoadingRates = true;
  String _conversionResult = '...';
  // Map untuk menyimpan semua nilai tukar
  Map<String, dynamic>? _rates;

  @override
  void initState() {
    super.initState();
    // --- Init Jam (dari Tahap 11) ---
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _initLocation();

    // --- [BARU] Init Mata Uang ---
    _loadRates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  // --- FUNGSI JAM (dari Tahap 11, tidak berubah) ---
  Future<void> _initLocation() async {
    // ... (Fungsi ini tetap sama persis seperti Tahap 11) ...
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _localTimezoneName = 'Servis lokasi mati'; _isLoadingLocation = false; });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _localTimezoneName = 'Izin lokasi ditolak'; _isLoadingLocation = false; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _localTimezoneName = 'Izin lokasi ditolak permanen'; _isLoadingLocation = false; });
      return;
    }
    try {
      final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timezoneName = timezoneInfo.toString();
      setState(() { _localTimezoneName = timezoneName; _isLoadingLocation = false; });
    } catch (e) {
      setState(() { _localTimezoneName = 'Gagal deteksi LBS'; _isLoadingLocation = false; });
    }
  }

  Widget _buildClockCard(String title, String timezoneName) {
    // ... (Fungsi ini tetap sama persis seperti Tahap 11) ...
    String formattedTime;
    if (title == 'Waktu Lokal (LBS)' && _isLoadingLocation) { formattedTime = 'Mencari lokasi...'; } 
    else if (title == 'Waktu Lokal (LBS)' && !_isLoadingLocation && !timezoneName.contains('/')) { formattedTime = 'Error: $timezoneName'; }
    else {
      try {
        final location = tz.getLocation(timezoneName);
        final zonedTime = tz.TZDateTime.from(_currentTime, location);
        formattedTime = DateFormat('HH:mm:ss').format(zonedTime);
      } catch (e) { formattedTime = 'Error Zona Waktu'; }
    }
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(timezoneName.contains('/') ? timezoneName : '(LBS Error)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Text(formattedTime, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  // --- [FUNGSI BARU] UNTUK KONVERTER MATA UANG ---

  // 1. Ambil data dari API
  Future<void> _loadRates() async {
    final rates = await _currencyService.getLatestRates();
    if (rates != null) {
      setState(() {
        _rates = rates;
        _isLoadingRates = false;
        // Hitung konversi awal (1 USD ke IDR)
        _convert();
      });
    } else {
      setState(() {
        _isLoadingRates = false;
        _conversionResult = 'Gagal memuat nilai tukar.';
      });
    }
  }

  // 2. Logika perhitungan konversi
  void _convert() {
    if (_rates == null) return; // API belum siap

    // Ambil jumlah dari textfield
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _conversionResult = 'Jumlah tidak valid';
      });
      return;
    }

    // Ambil nilai tukar (semua based on USD)
    final double rateFrom = _rates![_fromCurrency].toDouble();
    final double rateTo = _rates![_toCurrency].toDouble();

    // Rumus konversi: (Amount / RateFrom) * RateTo
    // (Ubah dulu ke USD, baru ubah ke mata uang tujuan)
    final double result = (amount / rateFrom) * rateTo;

    // Format hasil
    setState(() {
      _conversionResult = '${result.toStringAsFixed(2)} $_toCurrency';
    });
  }

  // 3. Widget untuk UI Konverter
  Widget _buildCurrencyConverter() {
    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_rates == null) {
      return Center(
        child: Text(
          _conversionResult,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Tampilkan UI jika data siap
    return Column(
      children: [
        // Input Jumlah
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Jumlah',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _convert(), // Otomatis hitung saat diketik
        ),
        const SizedBox(height: 16),
        
        // Dropdown "From" dan "To"
        Row(
          children: [
            // Dropdown "From"
            Expanded(
              child: _buildCurrencyDropdown(
                value: _fromCurrency,
                onChanged: (newValue) {
                  setState(() {
                    _fromCurrency = newValue!;
                  });
                  _convert();
                },
              ),
            ),
            // Ikon panah
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward),
            ),
            // Dropdown "To"
            Expanded(
              child: _buildCurrencyDropdown(
                value: _toCurrency,
                onChanged: (newValue) {
                  setState(() {
                    _toCurrency = newValue!;
                  });
                  _convert();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Hasil Konversi
        Text(
          'Hasil Konversi:',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          _conversionResult,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper untuk membuat Dropdown
  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: _currencies.map((String currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  // --- [MODIFIKASI] build() UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creative Toolkit'),
      ),
      body: GestureDetector(
        // Tambahkan ini agar keyboard otomatis tutup saat klik di luar
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Bagian 1: Konversi Waktu (Tetap Sama) ---
            const Text(
              'Konverter Waktu Global',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildClockCard('Waktu Lokal (LBS)', _localTimezoneName),
            _buildClockCard('WIB', 'Asia/Jakarta'),
            _buildClockCard('WITA', 'Asia/Makassar'),
            _buildClockCard('WIT', 'Asia/Jayapura'),
            _buildClockCard('London', 'Europe/London'),
            
            const Divider(height: 40),
            
            // --- Bagian 2: Konversi Mata Uang [DIGANTI] ---
            const Text(
              'Konverter Mata Uang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Panggil widget konverter baru kita
                child: _buildCurrencyConverter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}