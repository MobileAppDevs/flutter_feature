// ignore_for_file: file_names

import 'dart:io';

import 'package:feature/feature/common_print/printlog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


/// msgController
class FirebaseMessagingCustom {
  static FirebaseMessaging? _instance;

  static Future<FirebaseMessaging?> getInstance() async {
    if (_instance == null) {
      // await setUpNotification();
      _instance = FirebaseMessaging.instance;
      Printlog.printLog("FirebaseMessaging init success:::::::");
      return _instance;
    }
    return _instance;
  }

  static Future<String?> getToken() async {
    return await _instance?.getToken();
  }

  // static Future<String?> getApnsToken() async {
  //   return await _instance?.getAPNSToken();
  // }

  static Future<bool?> isTest() async {
    return await _instance?.isSupported();
  }

  ///Mark - Notification
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', //id
      'High Importance Notifications', //title
      importance: Importance.high,
      playSound: true);

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setUpNotification() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    if (_instance != null) {
      await _instance!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    await notificationFuncCall();
  }

  static Future<void> notificationFuncCall() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    /// Request Permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Printlog.printLog('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Printlog.printLog('User granted provisional permission');
    } else {
      Printlog.printLog('User declined or has not accepted permission');
    }

    if (Platform.isIOS) {
      Printlog.printLog("Platform Apple");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AppleNotification? apple = message.notification?.apple;
        Printlog.printLog("tes...Notification");

        if (notification != null && apple != null) {                                                                                       
          Printlog.printLog("Notification value added in ctr....ios");
          // msgController.add(1);

          // await flutterLocalNotificationsPlugin.show(
          //     notification.hashCode,
          //     notification.title,
          //     notification.body,
          //     NotificationDetails(
          //       iOS: DarwinNotificationDetails(
          //           presentAlert: true,                                                                                                        
          //           // sound: true,
          //           subtitle: notification.title,
          //           // badgeNumber: 1,
          //           // presentBadge: true,
          //           presentSound: true),
          //     ));
        }
      });

      /// On Background :::
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Printlog.printLog("A new omMessageOpenedApp event was published!");
        RemoteNotification? notification = message.notification;
        // RemoteMessage? messageData = message;
        // AndroidNotification android = message.notification!.android!;
        if (notification != null) {
          routeNavigate(message: message);
          // routeValue: int.parse(messageData.data["route_id"].toString())
        }
      });
    } else if (Platform.isAndroid) {
      Printlog.printLog("Notification......Platform Android");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        Printlog.printLog("A new onMessage event was published!");

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          Printlog.printLog("Notification value added in ctr....android");
          // msgController.add(1);

          await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                  android: AndroidNotificationDetails(channel.id, channel.name,
                      // channel.description,
                      color: Colors.transparent,
                      playSound: true,
                      icon: "@mipmap/launcher_icon")));
        }
      });
    

      /// On Background :::
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Printlog.printLog("A new omMessageOpenedApp event was published!");
        RemoteNotification? notification = message.notification;
        // RemoteMessage messageData = message;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          routeNavigate(message: message);
          // routeValue: int.parse(messageData.data["route_id"].toString())
        }
      });
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (message.messageId != null) {
      // msgController.add(1);
      Printlog.printLog("Notification value added in ctr....Background");
    }
  }

  static Future routeNavigate({BuildContext? context, RemoteMessage? message}) async {
    try {
      Printlog.printLog("Route Navigation Call....${message?.data}");
      // Get.toNamed(Routes.DASHBOARD,arguments: const DashBoardScreen(navIndex: 3));
      handleNotificationType(message: message);
    } catch (e) {
      Printlog.printLog('on exception error .........$e');
    }
  }

   static _listenWhenAppIsInForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       Printlog.printLog("A new omMessageOpenedApp event was published!");
        RemoteNotification? notification = message.notification;
        // RemoteMessage messageData = message;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          routeNavigate(message: message);
          // routeValue: int.parse(messageData.data["route_id"].toString())
        }
      // });
    });
  }

// for navigation to screens
  static void handleNotificationType({RemoteMessage? message}) {
  }
   
}
