import 'dart:convert';

import 'package:badminton_management_1/notification/fcm_incoming_message.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// import 'package:u2u_dpn/repository/api_repository.dart';
// import 'package:u2u_dpn/widget/ultil.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  CHANNEL_ID, // id
  CHANNEL_NAME, // title
  description: CHANNEL_DESCRIPTION, // description
  importance: Importance.max,
  playSound: true,
  // sound:  RawResourceAndroidNotificationSound('alert')
);
const CHANNEL_ID = 'high_important_channel';
const CHANNEL_NAME = 'High Important Notification';
const CHANNEL_DESCRIPTION = 'This Channel is used for important notifications';

class FCMController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool isFlutterLocalNotificationsInitialized = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String firebaseTopicAll = 'general';
  String firebaseTopicUser = 'personal';

  Future<dynamic> initToState() async {
    await _checkPermission();
    await setupFlutterNotifications();
    String? fcmToken = await _firebaseMessaging.getToken();
    // fcmSubscribeToAPI(fcmToken ?? '');
    print('[FCM Firebase Token]  $fcmToken');
    await fcmSubscribeToTopic();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      _handleMessage(event, FcmMessageAction.showModal, FCMType.foreground);
    });

    ///give you the message on which users taps
    ///and it opened the app from terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    _handleMessage(
        initialMessage, FcmMessageAction.navigation, FCMType.terminated);

    /// when the app is in the background via a
    /// Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
      _handleMessage(event, FcmMessageAction.navigation, FCMType.background);

      //onclick when background
      // NotificationController controller = Get.put(NotificationController());

      // NotificationModel? model = await controller.readNotify(int.parse(event.data['notify_id']));

      // Get.to(() => DetailNotification(model!));
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onBackgroundMessage((RemoteMessage event) async {
      _handleMessage(event, FcmMessageAction.navigation, FCMType.background);
      // NotificationController controller = Get.put(NotificationController());

      // NotificationModel? model = await controller.readNotify(int.parse(event.data['notify_id']));

      // Get.to(() => DetailNotification(model!));
    });
  }

  Future _checkPermission() async {
    NotificationSettings settingsCurrent =
        await _firebaseMessaging.getNotificationSettings();

    if (settingsCurrent.authorizationStatus == AuthorizationStatus.authorized) {
      print('[FCM] - Permission Notification: User granted permission');
    } else if (settingsCurrent.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print(
          '[FCM] - Permission Notification: User granted provisional permission');
    } else {
      print(
          '[FCM] - Permission Notification: User declined or has not accepted permission');
      await _firebaseMessaging.requestPermission(
        alert: false,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> postTokenToServer(String token, String deviceInfo) async {
    final url = Uri.parse('http://api.davidbadminton.com');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'device': deviceInfo}),
    );

    if (response.statusCode == 200) {
      print('FCM Token sent successfully!');
    } else {
      print('Failed to send token: ${response.body}');
    }
  }

  Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return 'Device: ${androidInfo.model} (${androidInfo.brand})';
  }

  Future fcmSubscribeToAPI(String token) async {
    print(await getDeviceInfo());
    // await ApiRepository().postTokenFCM(token, await Utils().deviceInfo());
    await postTokenToServer(token, await getDeviceInfo());
  }

  Future<void> setupFlutterNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // if (notificationResponse.payload != null) {
        //   NotificationController controller = Get.put(NotificationController());

        //   NotificationModel? model = await controller.readNotify(int.parse(notificationResponse.payload.toString()));

        //   Get.to(() => DetailNotification(model!));
        // } else {
        //   switch (notificationResponse.notificationResponseType) {
        //     case NotificationResponseType.selectedNotification:
        //       Utils.debugPrint('NotificationResponseType: selectedNotification');

        //       Get.to(() => const NotificationScreen());
        //       break;
        //     case NotificationResponseType.selectedNotificationAction:
        //       Utils.debugPrint('NotificationResponseType: selectedNotificationAction');
        //       Get.to(() => const NotificationScreen());
        //       break;
        //   }
        // }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    fcmSubscribeToTopic();

    isFlutterLocalNotificationsInitialized = true;
  }

  fcmSubscribeToTopic() async {
    print('[FCM] firebaseTopicUser: $firebaseTopicUser');
    print('[FCM] firebaseTopicAll: $firebaseTopicAll');
    if (firebaseTopicUser != '' && firebaseTopicUser != 'nil') {
      await _firebaseMessaging.subscribeToTopic(firebaseTopicUser);
      print('[FCM] subscribeToTopic success: $firebaseTopicUser');
    }
    if (firebaseTopicAll != '' && firebaseTopicAll != 'nil') {
      await _firebaseMessaging.subscribeToTopic(firebaseTopicAll);
      print('[FCM] subscribeToTopic All success: $firebaseTopicAll');
    }
  }

  fcmUnsubscribeFromTopic() async {
    print('[FCM] firebaseTopicUser: $firebaseTopicUser');
    print('[FCM] firebaseTopicAll: $firebaseTopicAll');

    if (firebaseTopicUser != '' && firebaseTopicUser != 'nil') {
      await _firebaseMessaging.unsubscribeFromTopic(firebaseTopicUser);
      print('[FCM] UnsubscribeToTopic success: $firebaseTopicUser');
    }
    if (firebaseTopicAll != '' && firebaseTopicAll != 'nil') {
      await _firebaseMessaging.unsubscribeFromTopic(firebaseTopicAll);
      print('[FCM] UnsubscribeToTopic All success: $firebaseTopicAll');
    }
  }

  void showFlutterNotification(FcmIncomingMessage message) {
    if (message.notification != null) {
      String customTitle =
          message.data.oldTitle ?? message.notification!.title.toString();
      String customBody =
          message.data.oldContent ?? message.notification!.body.toString();
      try {
        var mapVariables = jsonDecode(message.data.variables!);
        if (mapVariables is Map) {
          Map<String, String> mapVariablesFor = {};
          mapVariables.forEach((key, value) {
            mapVariablesFor[key.toString()] = value.toString();
          });
          customTitle = customTitle.toString().trParams(mapVariablesFor);
          customBody = customBody.toString().trParams(mapVariablesFor);
        }
      } catch (_) {}
      flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        customTitle,
        customBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
          ),
          iOS: const DarwinNotificationDetails(presentSound: true),
        ),
        payload: message.data.notificationItemId,
      );
    }
  }

  _handleMessage(RemoteMessage? event, FcmMessageAction action, FCMType type) {
    if (event != null && event.notification != null) {
      final messageData = MessageData.fromJson(event.data,
          remoteNotification: event.notification);
      RemoteNotification remoteNotification = event.notification!;
      AndroidNotification? android = event.notification!.android;

      FcmIncomingMessage incoming = FcmIncomingMessage(
        data: messageData,
        action: action,
        // pushToRouteName: Utils().getRouteMessageFollowCategory(messageData),
        // arguments: Utils().getArgumentsMessageFollowCategory(messageData, remoteNotification),
        type: type,
        notification: remoteNotification,
        androidNotification: android,
      );

      print('REMOTE: ${remoteNotification.body}');

      showFlutterNotification(incoming);
    }
  }
}
