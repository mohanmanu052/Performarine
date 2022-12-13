import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/splash_screen.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter SQFLite Example',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   // primarySwatch: Color(0xFF42B5BF),
      //   // accentColor: Colors.tealAccent,
      // ),
      home: IntroScreen(),
    );
  }
}
