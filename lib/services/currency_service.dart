// Lokasi File: lib/services/currency_service.dart

import 'package:dio/dio.dart';
import 'package:project_akhir/config.dart';

class CurrencyService {
  final Dio _dio = Dio();
  final String _apiKey = Config.exchangeRateApiKey;
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6/';

  // Fungsi untuk mengambil nilai tukar terbaru (base: USD)
  Future<Map<String, dynamic>?> getLatestRates() async {
    try {
      final response = await _dio.get('$_baseUrl$_apiKey/latest/USD');
      
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        // Kita hanya butuh bagian 'conversion_rates'
        return response.data['conversion_rates'];
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching rates: $e');
      return null;
    }
  }
}