import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/bill_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotif.initialize(initSettings);

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotif.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // ===========================================================================
  // MODE PRODUKSI: SCHEDULING H-1 JAM 08:00 PAGI (Steril & Akurat)
  // ===========================================================================
  Future<void> scheduleBillReminder(BillModel bill) async {
    if (bill.isPaid) return;

    final today = DateTime.now();

    // KELUARKAN DARI MODE TESTING: Setel alarm asli H-1 sebelum jatuh tempo jam 8 subuh
    final reminderDate = bill.dueDate.subtract(const Duration(days: 1));
    final scheduledDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      8, 0, 0, // Jam 8 pagi teng rill
    );

    // Antisipasi jika tanggal pengingat ternyata sudah lewat dari hari ini
    if (scheduledDateTime.isBefore(today)) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tagihin_reminders_channel',
      'Pengingat Tagihan',
      channelDescription:
          'Saluran khusus untuk notifikasi jatuh tempo Tagih.In',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);
    final uID = bill.id.hashCode;

    await _localNotif.zonedSchedule(
      uID,
      'Tagihan Besok Jatuh Tempo! ⚠️',
      'Jangan lupa bayar "${bill.title}" besok sebesar Rp ${bill.amount.toInt()}. Jaga skor kedisiplinanmu!',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(String billId) async {
    await _localNotif.cancel(billId.hashCode);
  }
}
