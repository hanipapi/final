import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // Buat instance plugin
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 1. Fungsi Inisialisasi
  static Future<void> init() async {
    // Inisialisasi database timezone
    tz_data.initializeTimeZones();

    // --- Pengaturan untuk Android ---
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Gunakan ikon launcher default

    // --- Pengaturan untuk iOS ---
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // --- Gabungkan Pengaturan ---
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inisialisasi plugin
    await _plugin.initialize(settings);
  }

  // 2. Fungsi untuk tes notifikasi (kirim sekarang)
  static Future<void> showTestNotification() async {
    // Detail notifikasi untuk Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id_test',
      'Test Channel',
      channelDescription: 'Channel untuk tes notifikasi',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Detail notifikasi untuk iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Tampilkan notifikasi
    await _plugin.show(
      0, // ID notifikasi
      'Tes Notifikasi', // Judul
      'Jika Anda melihat ini, notifikasi berfungsi!', // Body
      details,
    );
  }

  // 3. Fungsi untuk menjadwalkan notifikasi harian
  static Future<void> scheduleDailyNotification() async {
    // Minta izin (wajib untuk Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Tentukan waktu (misal: jam 10 pagi)
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // Jam 10
      0,  // Menit 0
    );
    
    // Jika jam 10 pagi sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Detail notifikasi
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id_daily',
      'Daily Reminder Channel',
      channelDescription: 'Channel untuk pengingat harian',
      importance: Importance.high,
      priority: Priority.low,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Jadwalkan notifikas
  }
}