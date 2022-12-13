import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/pages/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroScreen(),
          ),
          ModalRoute.withName(""));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          child: Stack(
            children: [
              Image.asset(
                'assets/images/splash_bg_img.png',
                height: displayHeight(context),
                width: displayWidth(context),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: displayHeight(context) * 0.25,
                  width: displayWidth(context),
                  //padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.white,
                        blurRadius: 60,
                        spreadRadius: 60,
                        offset: const Offset(0, 10))
                  ]),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: displayHeight(context) * 0.1),
                        Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          //color: Colors.white,
                          height: displayHeight(context) * 0.15,
                        ),
                        //SizedBox(height: displayHeight(context) * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 30,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: displayHeight(context) * 0.25,
                    width: displayWidth(context),
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.65),
                          blurRadius: 40,
                          spreadRadius: 20,
                          offset: const Offset(0, 60))
                    ]),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
