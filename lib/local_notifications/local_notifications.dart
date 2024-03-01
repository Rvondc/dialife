import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final BehaviorSubject<String> onClickNotification =
      BehaviorSubject<String>();

  /* EXAMPLE TO ADD IN A STATEFUL PAGE

    @override
    void initState() {
      listenToNotifications();
      super.initState();
    }

    //  to listen to any notification clicked or not
    listenToNotifications() {
      print("Listening to notification");
      LocalNotifications.onClickNotification.stream.listen((event) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AnotherPage(payload: event)));
      });
    }

  */

  // on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

  static Future<List<PendingNotificationRequest>> pendingNotifRequests() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Initialized the local notfication
  static Future init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/launcher_icon'); // <-- Notif Icon
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher'); // <-- Notif Icon

    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //         onDidReceiveLocalNotification: (id, title, body, payload) => null);
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsDarwin,
      // linux: initializationSettingsLinux,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }

  // SHOW SIMPLE NOTIFICATION
  static Future<int?> schedNotif({
    required String title,
    required String body,
    required String payload,
    required Duration delay,
    required int id,
  }) async {
    // await Future.delayed(delay);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel $id',
      'simple notfication',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    if (tz.TZDateTime.now(tz.local)
        .add(delay)
        .isBefore(tz.TZDateTime.now(tz.local))) {
      return null;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // debugPrint(delay.toString());
    // debugPrint(tz.TZDateTime.now(tz.local).add(delay).toString());

    // debugPrint(
    //     (await _flutterLocalNotificationsPlugin.pendingNotificationRequests())
    //         .first
    //         .body);

    // await _flutterLocalNotificationsPlugin.show(
    //   0,
    //   title,
    //   body,
    //   notificationDetails,
    //   payload: payload,
    // );

    return id;
  }

  // SHOW PERIODIC NOTIFICATION IN REGULAR INTERVAL
  // static Future showPeriodicNotification({
  //   required String title,
  //   required String body,
  //   required String payload,
  // }) async {
  //   AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //     'channel 1',
  //     'periodic notification',
  //     channelDescription: 'your channel description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //     vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
  //   );

  //   NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidNotificationDetails);

  //   await _flutterLocalNotificationsPlugin.periodicallyShow(
  //     1,
  //     title,
  //     body,
  //     RepeatInterval.everyMinute,
  //     notificationDetails,
  //   );
  // }

  //SHOW A SCHEDULED NOTIFICATION
  // static Future showScheduleNotification({
  //   required String title,
  //   required String body,
  //   required String payload,
  // }) async {
  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     2,
  //     title,
  //     body,
  //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'channel 2',
  //         'schedule notification',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         ticker: 'ticker',
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     payload: payload,
  //   );
  // }

  //CLOSE A SPECIFIC CHANNEL NOTIFICATION
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  //CANCEL ALL NOTIFICATIONS
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
