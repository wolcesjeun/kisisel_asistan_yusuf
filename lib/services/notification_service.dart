import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/hatirlatici.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında yapılacak işlemler
      },
    );
  }

  Future<bool> izinIste() async {
    if (Platform.isIOS) {
      final alert = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return alert ?? false;
    } else if (Platform.isAndroid) {
      // Android 13 ve üzeri için bildirim izni
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
      return true; // Android 13'ten düşük sürümler için varsayılan olarak true
    }
    return false;
  }

  Future<void> planlaHatirlatici({
    required int id,
    required String baslik,
    required String aciklama,
    required DateTime tarih,
    required HatirlaticiTekrar tekrar,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'hatirlaticilar_kanali',
      'Hatırlatıcılar',
      channelDescription: 'Hatırlatıcı bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (tekrar != HatirlaticiTekrar.birKez) {
      RepeatInterval interval;
      switch (tekrar) {
        case HatirlaticiTekrar.gunluk:
          interval = RepeatInterval.daily;
          break;
        case HatirlaticiTekrar.haftalik:
          interval = RepeatInterval.weekly;
          break;
        case HatirlaticiTekrar.aylik:
          interval = RepeatInterval.daily;
          break;
        default:
          interval = RepeatInterval.daily;
      }

      await _notifications.periodicallyShow(
        id,
        baslik,
        aciklama,
        interval,
        details,
      );
    } else {
      var bildirimTarihi = tz.TZDateTime.from(tarih, tz.local);
      
      // Eğer seçilen tarih geçmişte kaldıysa, bir sonraki dakikaya ayarla
      if (bildirimTarihi.isBefore(tz.TZDateTime.now(tz.local))) {
        bildirimTarihi = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
      }

      await _notifications.zonedSchedule(
        id,
        baslik,
        aciklama,
        bildirimTarihi,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> iptalHatirlatici(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> tumHatirlaticilariIptalEt() async {
    await _notifications.cancelAll();
  }
} 