import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'common_utils/system_utils.dart';
import 'don_cueva_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StreamingSharedPreferences sharedPreferences =
      await StreamingSharedPreferences.instance;
  SystemUtils().changeSystemBarColor();
  SystemUtils().setOrientation();
  SystemUtils().hideSystemUiOverlay();

  AwesomeNotifications().initialize(null, // icon for your app notification

      [
        NotificationChannel(
            channelKey: 'key1',
            channelName: 'Proto Coders Point',
            channelDescription: "Notification example",
            defaultColor: const Color(0XFF9050DD),
            ledColor: Colors.white,
            playSound: true,
            enableLights: true,
            importance: NotificationImportance.High,
            enableVibration: true)
      ]);

  runApp(
    MyApp(
      sharedPreferences: sharedPreferences,
    ),
  );
}

class MyApp extends StatefulWidget {
  final StreamingSharedPreferences? sharedPreferences;

  const MyApp({this.sharedPreferences});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return DonCuevaApp(
      sharedPreferences: widget.sharedPreferences,
    );
  }
}
