import 'dart:async';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/splash_screen.dart';
import 'package:get/get.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

SharedPreferences? sharedPreferences;

void callbackDispatcher() async {
  /*Workmanager().executeTask((taskName, inputData) async {
    print('BACKGROUND TASK IS EXECUTING: $taskName');
    bool isLocationPermitted = await Permission.location.isGranted;

    */ /* Timer.periodic(Duration(seconds: 2), (timer) {
      print(
          'BACKGROUND TASK IS EXECUTING INSIDE TIMER: $taskName ${timer.tick}');
    });*/ /*

    */ /*if (isLocationPermitted) {
      /// TODO Further Process
      await getLocationData();

      /// SAVED Sensor data
      startSensorFunctionality(stateSetter);
    } else {
      await Utils.getLocationPermission(context, scaffoldKey);
      bool isLocationPermitted = await Permission.location.isGranted;

      if (isLocationPermitted) {
        /// TODO Further Process
        await getLocationData();

        /// SAVED Sensor data
        startSensorFunctionality(stateSetter);
      }
    }*/ /*

    return Future.value(true);
  });*/
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();
  //await initializeService();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommonProvider()),
      ],
      child: GetMaterialApp(
        title: 'Performarine',
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //   // primarySwatch: Color(0xFF42B5BF),
        //   // accentColor: Colors.tealAccent,
        // ),
        home: IntroScreen(),
      ),
    );
  }
}
