// Lokasi File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir/pages/splash_page.dart';
import 'package:project_akhir/services/notification_service.dart';

// 1. [BARU] Import paket timezone
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. [BARU] Inisialisasi database zona waktu
  tz.initializeTimeZones(); 
  await NotificationService.init();
  
  // Inisialisasi Hive (sudah ada)
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Hive.openBox('koleksiBox');
  await Hive.openBox('saranBox');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Sederhana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}