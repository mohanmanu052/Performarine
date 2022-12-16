import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/splash_screen.dart';
import 'package:get/get.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
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
        title: 'Flutter SQFLite Example',
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
