// Lokasi File: lib/pages/toolkit_page.dart

import 'dart:async';
import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:dart_suncalc/suncalc.dart'; 
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
// [BARU] Import CurrencyService
import 'package:project_akhir/services/currency_service.dart';

class ToolkitPage extends StatefulWidget {
  const ToolkitPage({super.key});

  @override
  State<ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<ToolkitPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State LBS ---
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi...';
  String _sunriseTime = '...';
  String _goldenHourTime = '...';
  String _sunsetTime = '...';
  String _goldenHourDuskTime = '...';
  final DateFormat _timeFormat = DateFormat('HH:mm');

  // --- State Jam Dunia ---
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  // --- State Palet Warna ---
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Color> _paletteColors = [];
  bool _isLoadingPalette = false;

  // --- State Travel Budget (BARU) ---
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _budgetController = TextEditingController();
  Map<String, dynamic>? _exchangeRates;
  bool _isLoadingRates = true;
  String _selectedCurrency = 'USD'; // Mata uang tujuan
  String _conversionResult = '...';
  // Daftar negara populer untuk travel
  final Map<String, String> _travelCurrencies = {
    'USD': 'Amerika Serikat (Dollar)',
    'JPY': 'Jepang (Yen)',
    'EUR': 'Eropa (Euro)',
    'KRW': 'Korea Selatan (Won)',
    'SGD': 'Singapura (Dollar)',
    'MYR': 'Malaysia (Ringgit)',
    'THB': 'Thailand (Baht)',
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _initLocation(); 
    _loadExchangeRates(); // [BARU] Load kurs
  }

  @override
  void dispose() {
    _timer?.cancel();
    _budgetController.dispose();
    super.dispose();
  }

  // --- Fungsi LBS ---
  Future<void> _initLocation() async {
    // ... (Kode sama seperti sebelumnya) ...
    bool serviceEnabled;
    LocationPermission permission;

    setState(() { _isLoadingLocation = true; });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _locationStatus = 'Servis lokasi mati'; _isLoadingLocation = false; });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _locationStatus = 'Izin lokasi ditolak'; _isLoadingLocation = false; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _locationStatus = 'Izin ditolak permanen'; _isLoadingLocation = false; });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      
      var times = SunCalc.getTimes(
        DateTime.now(), 
        lat: position.latitude, 
        lng: position.longitude
      );
      
      setState(() {
        _sunriseTime = _timeFormat.format(times.sunrise!.toLocal());
        _goldenHourTime = _timeFormat.format(times.goldenHourEnd!.toLocal());
        _sunsetTime = _timeFormat.format(times.sunset!.toLocal());
        _goldenHourDuskTime = _timeFormat.format(times.goldenHour!.toLocal());
        _locationStatus = 'Lokasi Ditemukan';
        _isLoadingLocation = false;
      });

    } catch (e) {
      setState(() { _locationStatus = 'Gagal kalkulasi data LBS'; _isLoadingLocation = false; });
    }
  }

  // --- Fungsi Palet Warna ---
  Future<void> _pickImageAndExtractPalette() async {
    // ... (Kode sama seperti sebelumnya) ...
    setState(() { _isLoadingPalette = true; _imageFile = null; _paletteColors = []; });
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      setState(() { _isLoadingPalette = false; });
      return; 
    }
    
    final File file = File(image.path);
    
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      FileImage(file),
      size: const Size(200, 200), 
      maximumColorCount: 6, 
    );
    
    setState(() {
      _imageFile = file;
      _paletteColors = palette.colors.toList();
      _isLoadingPalette = false;
    });
  }

  // --- [FUNGSI BARU] Travel Budget ---
  Future<void> _loadExchangeRates() async {
    final rates = await _currencyService.getLatestRates();
    if (mounted) {
      setState(() {
        _exchangeRates = rates;
        _isLoadingRates = false;
      });
    }
  }

  void _calculateBudget() {
    if (_exchangeRates == null || _budgetController.text.isEmpty) return;

    double idrAmount = double.tryParse(_budgetController.text) ?? 0;
    // Rumus: IDR * Rate Mata Uang Tujuan
    // (Karena API kita base-nya IDR, jadi tinggal dikalikan)
    double rate = _exchangeRates![_selectedCurrency].toDouble();
    double result = idrAmount * rate;

    setState(() {
      // Format hasil uang
      final formatCurrency = NumberFormat.simpleCurrency(name: _selectedCurrency);
      _conversionResult = formatCurrency.format(result);
    });
  }

  String _getTimeForLocation(String locationName) {
    try {
      final location = tz.getLocation(locationName);
      final zonedTime = tz.TZDateTime.from(_currentTime, location);
      return DateFormat('HH:mm:ss').format(zonedTime);
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creative Toolkit', style: TextStyle(color: primaryBlack)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlack),
      ),
      // Tambahkan GestureDetector agar keyboard menutup saat tap luar
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Bagian 1: Golden Hour ---
            _buildGroupHeader('Fotografi & Cahaya'),
            Card(
              elevation: 0,
              color: lightGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalkulator Golden Hour',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingLocation ? _locationStatus : 'Berhasil: Data LBS Lokasi Anda',
                      style: TextStyle(color: _isLoadingLocation ? Colors.orange[700] : primaryGreen),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeInfo(Icons.wb_sunny_outlined, 'Sunrise', _sunriseTime, primaryGreen),
                        _buildTimeInfo(Icons.wb_sunny, 'Golden Hour', _goldenHourTime, primaryGreen),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeInfo(Icons.dark_mode_outlined, 'Sunset', _sunsetTime, darkGrey),
                        _buildTimeInfo(Icons.dark_mode, 'Blue Hour', _goldenHourDuskTime, darkGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Bagian 2: Travel Budget (BARU) ---
            _buildGroupHeader('Travel Budget Estimator'),
            Card(
              elevation: 0,
              color: lightGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rencana Liburan?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                    ),
                    const Text(
                      'Estimasi nilai uangmu di negara tujuan.',
                      style: TextStyle(fontSize: 12, color: darkGrey),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoadingRates)
                      const Center(child: CircularProgressIndicator(color: primaryGreen))
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Input Rupiah
                          TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Budget (IDR)',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) => _calculateBudget(),
                          ),
                          const SizedBox(height: 12),
                          
                          // Dropdown Negara
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCurrency,
                                isExpanded: true,
                                items: _travelCurrencies.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCurrency = value!;
                                    _calculateBudget();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Hasil Konversi
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text('Estimasi di lokasi:', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(
                                  _conversionResult,
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // --- Bagian 3: Jam Dunia ---
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: lightGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text(
                      'Zona Waktu Live',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: [
                        _buildWorldClockItem('WIB', 'Asia/Jakarta'),
                        _buildWorldClockItem('WITA', 'Asia/Makassar'),
                        _buildWorldClockItem('WIT', 'Asia/Jayapura'),
                        _buildWorldClockItem('London', 'Europe/London'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // --- Bagian 4: Palet Warna ---
            _buildGroupHeader('Inspirasi Warna'),
            Card(
              elevation: 0,
              color: lightGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ekstraktor Palet Warna',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoadingPalette)
                      const Center(child: CircularProgressIndicator(color: primaryGreen)),
                    
                    if (_imageFile != null && _paletteColors.isNotEmpty)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _paletteColors.map((color) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black26, width: 0.5)
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      
                    if (_imageFile == null && !_isLoadingPalette)
                      const Center(child: Text('Pilih gambar untuk melihat palet warnanya.', style: TextStyle(color: darkGrey))),

                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _pickImageAndExtractPalette,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(_imageFile == null ? 'Pilih Gambar' : 'Pilih Gambar Lain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlack,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper UI Jam LBS
  Widget _buildTimeInfo(IconData icon, String label, String time, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: darkGrey, fontSize: 12)),
        Text(
          _isLoadingLocation ? '--:--' : time,
          style: const TextStyle(color: primaryBlack, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper UI Jam Dunia
  Widget _buildWorldClockItem(String label, String timezone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkGrey, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(
          _getTimeForLocation(timezone),
          style: const TextStyle(color: primaryBlack, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 16.0, bottom: 8.0),
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