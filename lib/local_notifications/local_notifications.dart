import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

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

  // Initialized the local notfication
  static Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // <-- Notif Icon

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
  }

  // SHOW SIMPLE NOTIFICATION
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel 0',
      'simple notfication',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // SHOW PERIODIC NOTIFICATION IN REGULAR INTERVAL
  static Future showPeriodicNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel 1',
      'periodic notification',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
    );
  }

  //SHOW A SCHEDULED NOTIFICATION
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    tz.initializeTimeZones();
    // tz.TZDateTime.now(tz.local)
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel 2',
          'schedule notification',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker'
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  //CLOSE A SPECIFIC CHANNEL NOTIFICATION
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  //CANCEL ALL NOTIFICATIONS
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
