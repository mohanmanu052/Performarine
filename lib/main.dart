import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/pages/home_page.dart';
import 'package:flutter_sqflite_example/pages/intro_screen.dart';
import 'package:flutter_sqflite_example/pages/splash_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.tealAccent,
      ),
      home: IntroScreen(),
    );
  }
}
