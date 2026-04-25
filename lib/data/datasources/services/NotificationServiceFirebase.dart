import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceFirebase {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init(BuildContext context) async {
    try {
      await _initLocalNotification();
      await _requestPermission();
      _listenForeground();
      _listenClick(context);
    } catch (e) {
      print("LỖI trong quá trình init Notification: $e");
    }
  }

  Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      print("FCM TOKEN: $token");
      return token;
    } catch (e) {
      print(" LỖI KHI LẤY TOKEN: $e");
      return null;
    }
  }

  Future<void> _initLocalNotification() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(settings);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      print(" Foreground: ${message.notification?.title}");

      _showNotification(message);
    });
  }

  void _listenClick(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final path = message.data['navigatePath'];

      if (path == "appointment") {
        Navigator.pushNamed(context, '/appointment');
      }
    });
  }

  void _showNotification(RemoteMessage message) {
    _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
