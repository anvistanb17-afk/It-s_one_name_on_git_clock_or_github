import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Простой пакет для тестовых уведомлений
class TestNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Инициализация (вызови в main())
  static Future<void> initialize() async {
    // Настройки для Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  /// Показать тестовое уведомление
  static Future<void> showTestNotification({
    String title = 'Тест',
    String body = 'Это тестовое уведомление!',
    int id = 0,
  }) async {
    // Запрашиваем разрешения
    await _requestPermissions();

    // Настройки для Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Тестовые уведомления',
      channelDescription: 'Канал для тестовых уведомлений',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    // Настройки для iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Показать уведомление с задержкой
  static Future<void> showScheduledNotification({
    String title = 'Тест',
    String body = 'Отложенное уведомление!',
    int delaySeconds = 5,
    int id = 0,
  }) async {
    await _requestPermissions();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel_scheduled',
      'Отложенные уведомления',
      channelDescription: 'Канал для отложенных уведомлений',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = DateTime.now().add(Duration(seconds: delaySeconds));

    await _plugin.schedule(id, title, body, scheduledTime, details);
  }

  /// Отменить все уведомления
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Запросить разрешения
  static Future<void> _requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}
