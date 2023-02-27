import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lets_get_started_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';

import '../common_widgets/utils/constants.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool? isBtnVisible = false, isTripRunningCurrently = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfTripIsRunning();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //backgroundColor: const Color(0xff00575B),
        body: Stack(
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
                  child: isBtnVisible!
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Start your sea voyage with ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: displayWidth(context) * 0.035,
                                    fontFamily: inter,
                                    fontStyle: FontStyle.italic),
                              ),
                              SizedBox(height: displayHeight(context) * 0.005),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: commonText(
                                    context: context,
                                    text:
                                        'AI, data, and systems approach to electrification of vessels for improving the health of our oceans.',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white.withOpacity(0.8),
                                    textSize: displayWidth(context) * 0.03,
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(height: displayHeight(context) * 0.02),
                              GestureDetector(
                                onTap: () {
                                  checkIfUserIsLoggedIn();
                                },
                                child: Container(
                                  height: displayHeight(context) * 0.11,
                                  width: displayHeight(context) * 0.11,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 8)),
                                  child: Center(
                                    child: commonText(
                                        context: context,
                                        text: 'START',
                                        fontWeight: FontWeight.w600,
                                        textColor:
                                            Colors.white.withOpacity(0.8),
                                        textSize: displayWidth(context) * 0.04,
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                ))
          ],
        ),
      ),
    );
  }

  checkIfTripIsRunning() async {
    var pref = await Utils.initSharedPreferences();

    bool? isTripStarted = pref.getBool('trip_started');
    bool? isCalledFromNoti = pref.getBool('sp_key_called_from_noti');

    var service = FlutterBackgroundService();
    bool isServiceRunning = await service.isRunning();

    Utils.customPrint('IS SERVICE RUNNING:$isServiceRunning');

    Utils.customPrint('INTRO START $isTripStarted');

    setState(() {
      isTripRunningCurrently = isTripStarted;
    });

    if (isTripRunningCurrently == null) {
      if (isServiceRunning) {
        service.invoke("setAsBackground");
        if (positionStream != null) {
          positionStream!.cancel();
        }
        //var service2 = FlutterBackgroundService();
        bool isServiceRunning = await service.isRunning();

        Utils.customPrint('IS SERVICE RUNNING 222:$isServiceRunning');
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isBtnVisible = true;
          });
        }
      });
    } else if (!isTripRunningCurrently!) {
      if (isServiceRunning) {
        service.invoke("setAsBackground");
        if (positionStream != null) {
          positionStream!.cancel();
        }
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isBtnVisible = true;
          });
        }
      });
    } else {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails == null) {
        Utils.customPrint('NotificationAppLaunchDetails IS NULL');
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isBtnVisible = true;
            });
          }
        });
      } else {
        if (!notificationAppLaunchDetails.didNotificationLaunchApp) {
          Utils.customPrint('NotificationAppLaunchDetails IS FALSE');
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                isBtnVisible = true;
              });
            }
          });
        } else {
          Utils.customPrint('NotificationAppLaunchDetails IS TRUE');

          if (notificationAppLaunchDetails.notificationResponse!.id == 888) {
            List<String>? tripData =
                sharedPreferences!.getStringList('trip_data');

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => TripAnalyticsScreen(
                        tripId: tripData![0],
                        vesselId: tripData[1],
                        tripIsRunningOrNot: isTripStarted)),
                ModalRoute.withName(""));
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  isBtnVisible = true;
                });
              }
            });
          }
        }
      }
    }
  }

  checkIfUserIsLoggedIn() async {
    var pref = await Utils.initSharedPreferences();

    bool? isUserLoggedIn = pref.getBool('isUserLoggedIn');
    bool? isTripStarted = pref.getBool('trip_started');
    bool? isCalledFromNoti = pref.getBool('sp_key_called_from_noti');

    Utils.customPrint('ISUSERLOGEDIN $isUserLoggedIn');

    var service = FlutterBackgroundService();
    bool isServiceRunning = await service.isRunning();

    if (isTripStarted == null) {
      if (isServiceRunning) {
        service.invoke("stopService");
        if (positionStream != null) {
          positionStream!.cancel();
        }
      }

      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LetsGetStartedScreen()),
            ModalRoute.withName(""));
      } else if (isUserLoggedIn) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName(""));
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            ModalRoute.withName(""));
      }
    } else if (isTripStarted) {
      Utils.customPrint('INTRO TRIP IS RUNNING $isTripStarted');

      List<String>? tripData = sharedPreferences!.getStringList('trip_data');

      if (isCalledFromNoti == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(tripData: tripData ?? [])),
            ModalRoute.withName(""));
      } else if (!isCalledFromNoti) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(tripData: tripData ?? [])),
            ModalRoute.withName(""));
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => TripAnalyticsScreen(
                    tripId: tripData![0],
                    vesselId: tripData[1],
                    tripIsRunningOrNot: isTripStarted)),
            ModalRoute.withName(""));
      }
    } else {
      if (isServiceRunning) {
        service.invoke("stopService");
        if (positionStream != null) {
          positionStream!.cancel();
        }
      }
      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LetsGetStartedScreen()),
            ModalRoute.withName(""));
      } else if (isUserLoggedIn) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName(""));
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            ModalRoute.withName(""));
      }
    }
  }
}
