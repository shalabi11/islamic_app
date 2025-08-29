// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:islamic_app/features/prayer_times/data/model/prayer_time_model.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init(Function(String?) onNotificationTapped) async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       // ✅ تحديد الدالة التي سيتم استدعاؤها عند الضغط
//       onDidReceiveNotificationResponse: (details) =>
//           onNotificationTapped(details.payload),
//     );
//     tz.initializeTimeZones();
//   }

//   Future<String?> _getSelectedAdhanPath(String prayerName) async {
//     final prefs = await SharedPreferences.getInstance();
//     final adhanId = prefs.getString('selected_adhan_id');
//     if (adhanId == null) return null;

//     final directory = await getApplicationDocumentsDirectory();
//     // تحديد المسار بناءً على اسم الصلاة
//     final type = prayerName == 'الفجر' ? 'adhan_fajr' : 'adhan';
//     final filePath = '${directory.path}/$adhanId-$type.mp3';

//     if (await File(filePath).exists()) {
//       return filePath;
//     }
//     // إذا لم يتم العثور على ملف الفجر، ابحث عن الملف العادي كبديل
//     if (prayerName == 'الفجر') {
//       final regularPath = '${directory.path}/$adhanId-adhan.mp3';
//       if (await File(regularPath).exists()) return regularPath;
//     }

//     return null;
//   }

//   Future<void> scheduleAdhanNotifications(PrayerTimeModel prayerTimes) async {
//     await _notificationsPlugin.cancelAll();
//     final now = DateTime.now();
//     final prayerMap = {
//       'الفجر': prayerTimes.fajr,
//       'الظهر': prayerTimes.dhuhr,
//       'العصر': prayerTimes.asr,
//       'المغرب': prayerTimes.maghrib,
//       'العشاء': prayerTimes.isha,
//     };

//     int notificationId = 0;
//     for (var prayer in prayerMap.entries) {
//       final timeParts = prayer.value.split(':');
//       final hour = int.parse(timeParts[0]);
//       final minute = int.parse(timeParts[1]);

//       final scheduledDate = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute,
//       );

//       if (scheduledDate.isAfter(DateTime.now())) {
//         _scheduleSingleNotification(
//           id: notificationId,
//           title: "حان الآن موعد أذان ${prayer.key}",
//           body: prayer.key == 'الفجر' ? "الصلاة خير من النوم" : "حي على الصلاة",
//           prayerName: prayer.key,
//           scheduledDate: scheduledDate,
//         );
//         notificationId++;
//       }
//     }
//   }
//   // In lib/core/services/notification_service.dart

//   // In lib/core/services/notification_service.dart

//   void _scheduleSingleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required String prayerName,
//     required tz.TZDateTime scheduledDate,
//   }) async {
//     final adhanPath = await _getSelectedAdhanPath(prayerName);

//     _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'adhan_channel_id',
//           'Adhan Notifications',
//           channelDescription: 'Channel for Adhan notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           sound: adhanPath != null
//               ? UriAndroidNotificationSound(adhanPath)
//               : null,
//           fullScreenIntent: true,
//           category: AndroidNotificationCategory.alarm,
//         ),
//       ),
//       payload: prayerName,
//       // Use the modern parameter for Android scheduling
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       // ❌ The parameter below has been removed, so we delete it.
//       // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:islamic_app/features/prayer_times/data/model/prayer_time_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../app_router.dart';
import '../../features/prayer_times/views/screens/adhan_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // لا حاجة لتمرير callback بعد الآن

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // هذه الدالة ستكون خارج الكلاس، في نفس الملف أو في main.dart
  static void onNotificationTapped(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null && AppRouter.navigatorKey.currentState != null) {
      AppRouter.navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => AdhanScreen(prayerName: payload),
        ),
      );
    }
  }

  Future<void> scheduleAdhanNotifications(PrayerTimeModel prayerTimes) async {
    await _notificationsPlugin.cancelAll();
    final now = DateTime.now();
    final prayerMap = {
      'الفجر': prayerTimes.fajr,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    int notificationId = 0;
    for (var prayer in prayerMap.entries) {
      final timeParts = prayer.value.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isAfter(DateTime.now())) {
        _scheduleSingleNotification(
          id: notificationId,
          title: "حان الآن موعد أذان ${prayer.key}",
          body: prayer.key == 'الفجر' ? "الصلاة خير من النوم" : "حي على الصلاة",
          prayerName: prayer.key,
          scheduledDate: scheduledDate,
        );
        notificationId++;
      }
    }
  }

  void _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required String prayerName,
    required tz.TZDateTime scheduledDate,
  }) {
    // تحديد اسم ملف الصوت بناءً على اسم الصلاة
    final soundName = prayerName == 'الفجر' ? 'adhan_fajr' : 'adhan_normal';

    _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'adhan_channel_id_v2',
          'Adhan Notifications',
          channelDescription: 'Channel for Adhan notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(
            soundName,
          ), // استخدام الصوت من assets
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      payload: prayerName,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
