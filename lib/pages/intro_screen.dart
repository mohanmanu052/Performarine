import 'dart:async';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:performarine/analytics/file_manager.dart';
import 'package:performarine/analytics/location_callback_handler.dart';
import 'package:performarine/analytics/location_service_repository.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/authentication/reset_password.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/sync_data_cloud_to_mobile_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:uni_links/uni_links.dart';

import '../common_widgets/utils/constants.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool? isBtnVisible = false, isTripRunningCurrently = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initUniLinks();

    /*checkIfTripIsRunning();

    Future.delayed(Duration(seconds: 4), () {
      checkIfUserIsLoggedIn();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                        height: displayHeight(context) * 0.15,
                      ),
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

  /// To Check trip is running or not
  checkIfTripIsRunning() async {
    var pref = await Utils.initSharedPreferences();

    bool? isTripStarted = pref.getBool('trip_started');
    bool? isCalledFromNoti = pref.getBool('sp_key_called_from_noti');

    Utils.customPrint('INTRO START $isTripStarted');

    setState(() {
      isTripRunningCurrently = isTripStarted;
    });

    if (isTripRunningCurrently == null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isBtnVisible = true;
          });
        }
      });
    } else if (!isTripRunningCurrently!) {
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

          if (notificationAppLaunchDetails.notificationResponse!.id == 889) {
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

  /// To check user already log in or new user
  checkIfUserIsLoggedIn() async {
    var pref = await Utils.initSharedPreferences();

    bool? isUserLoggedIn = pref.getBool('isUserLoggedIn');
    bool? isTripStarted = pref.getBool('trip_started');
    bool? isCalledFromNoti = pref.getBool('sp_key_called_from_noti');
    bool? isFirstTimeUser = pref.getBool('isFirstTimeUser');

    Utils.customPrint('ISUSERLOGEDIN $isUserLoggedIn');
    Utils.customPrint('ISUSERLOGEDIN 1212 $isTripStarted');

    if (isTripStarted == null) {
      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            ModalRoute.withName(""));
      } else if (isUserLoggedIn) {
        if (isFirstTimeUser == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => SyncDataCloudToMobileScreen()),
              ModalRoute.withName(""));
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              ModalRoute.withName(""));
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            ModalRoute.withName(""));
      }
    }
    else if (isTripStarted) {
      Utils.customPrint('INTRO TRIP IS RUNNING $isTripStarted');

      flutterLocalNotificationsPlugin.cancel(1);

      final _isRunning = await BackgroundLocator();

      Utils.customPrint('INTRO TRIP IS RUNNING 1212 $_isRunning');

      List<String>? tripData = sharedPreferences!.getStringList('trip_data');

      reInitializeService();

      // final isRunning1 = await BackgroundLocator.isServiceRunning();
      //
      // StartTrip().startBGLocatorTrip(tripData[0], DateTime.now());
      //
      // final isRunning2 = await BackgroundLocator.isServiceRunning();


      //Utils.customPrint('INTRO TRIP IS RUNNING 11111 $isRunning1');

      StartTrip().startBGLocatorTrip(tripData![0], DateTime.now());

      final isRunning2 = await BackgroundLocator.isServiceRunning();

      Utils.customPrint('INTRO TRIP IS RUNNING 22222 $isRunning2');

      if (mounted) {
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
      }
    }
    else {
      /*if (isServiceRunning) {
        service.invoke("stopService");
         if (positionStream != null) {
          positionStream!.cancel();
        }
      }*/
      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
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

/*  checkIfUserIsLoggedInn() async {
    var pref = await Utils.initSharedPreferences();

    initUniLinks().then((value) {
      if (value == null || value.isEmpty) {
        bool? isUserLoggedIn = pref.getBool('isUserLoggedIn');
        bool? isFirstTimeUser = pref.getBool('isFirstTimeUser');

        if (isFirstTimeUser == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => NewSignInScreen(
                    calledFromNotification: true,
                  ) *//*LoginScreen*//*),
              ModalRoute.withName(""));
        } else if (isFirstTimeUser) {
          if (isUserLoggedIn == null) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewSignInScreen(calledFromNotification: true)),
                ModalRoute.withName(""));
          } else if (isUserLoggedIn != null && isUserLoggedIn) {
            String? userType = pref.getString('userType');

            if (commonProvider.globalLoginModel!.data == null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ErrorScreen()),
                  ModalRoute.withName(""));
            } else {
              if (userType != null) {
                if (userType == "hfl") {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardScreen()),
                      ModalRoute.withName(""));
                } else {
                  commonProvider.globalLoginModel!.data!.userHeight == null ||
                      commonProvider.globalLoginModel!.data!.userHeight! ==
                          '' ||
                      commonProvider.globalLoginModel!.data!.userHeight! ==
                          '0'
                      ? Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BmiCalculatorScreen()),
                      ModalRoute.withName(""))
                      : Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserConfigScreen()),
                      ModalRoute.withName(""));
                }
              } else {
                debugPrint(
                    'ORGID : ${commonProvider.globalLoginModel!.data!.orgId}');

                // commonProvider.globalLoginModel!.data!.userHeight == null ||
                //     commonProvider.globalLoginModel!.data!.userHeight! == '' ||
                //     commonProvider.globalLoginModel!.data!.userHeight! == '0'
                //     ? Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => BmiCalculatorScreen()),
                //     ModalRoute.withName(""))
                //     : Navigator.pushAndRemoveUntil(

                //     context,
                //     MaterialPageRoute(builder: (context) => UserConfigScreen()),
                //     ModalRoute.withName(""));

                if (commonProvider.globalLoginModel!.data?.userRole !=
                    'Doctor') {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserConfigScreen()),
                      ModalRoute.withName(""));
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserConfigScreen()),
                      ModalRoute.withName(""));
                }
              }
            }
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                ModalRoute.withName(""));
          }
        }
      }
      else {
        bool isUserLoggedIn = pref.getBool('isUserLoggedIn')!;
        bool isFirstTimeUser = pref.getBool('isFirstTimeUser')!;

        LoginModel loginModel =
        LoginModel.fromJson(jsonDecode(pref.getString('loginData')!));
        String userType = loginModel.data!.userRole!;

        if (isFirstTimeUser == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewSignInScreen(calledFromNotification: true)),
              ModalRoute.withName(""));
        } else if (isFirstTimeUser) {
          if (isUserLoggedIn == null) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewSignInScreen(calledFromNotification: true)),
                ModalRoute.withName(""));
          } else if (isUserLoggedIn != null && isUserLoggedIn) {
            if (value.contains('ShareMyProfile')) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InAppWebViewScreen(
                        webViewUrl: value,
                      )),
                  ModalRoute.withName(""));
            } else {
              if (userType == "hfl") {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                    ModalRoute.withName(""));
              } else {
                if (commonProvider.globalLoginModel!.data!.userHeight == null ||
                    commonProvider.globalLoginModel!.data!.userHeight! == '' ||
                    commonProvider.globalLoginModel!.data!.userHeight! == '0') {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BmiCalculatorScreen()),
                      ModalRoute.withName(""));
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserConfigScreen()),
                      ModalRoute.withName(""));
                }
              }
            }
          }
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewSignInScreen(calledFromNotification: true)),
              ModalRoute.withName(""));
        }
      }
    });
  }*/


  /// Reinitialized service after user killed app while trip is running
  reInitializeService() async {
    // print('RE-Initializing...');
    await BackgroundLocator.initialize();
    // String logStr = await FileManager.readLogFile();
    // print('RE-Initialization done');
    // final _isRunning = await BackgroundLocator.isServiceRunning();

    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 1,
            distanceFilter: 0,
            //client: bglas.LocationClient.android,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Trip is in progress',
                notificationMsg: '',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  Future<void> initUniLinks() async {
    Uri? initialLink;
    try {
      initialLink = await getInitialUri();
      debugPrint('UNI LINK: $initialLink');

      if(initialLink != null)
        {
          print('Deep link received: $initialLink');
          if(initialLink.queryParameters['verify'] != null){
            print("reset: ${initialLink.queryParameters['verify'].toString()}");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            print("isUserLoggedIn: $isUserLoggedIn");
            Map<String, dynamic> arguments = {
              "isComingFromReset": true,
              "token": initialLink.queryParameters['verify'].toString()
            };
            if(isUserLoggedIn != null)
            {
              if(isUserLoggedIn)
              {
                sharedPreferences!.setBool('reset_dialog_opened', false);
                Get.to(HomePage(isComingFromReset: true,token: initialLink.queryParameters['verify'].toString(),),arguments: arguments);

              }
            }
            else
            {
              Future.delayed(Duration(seconds: 2), (){
                Get.offAll(ResetPassword(token: initialLink!.queryParameters['verify'].toString(), isCalledFrom: "Main"));
              });
            }

          }
        }
      else
        {
          checkIfTripIsRunning();

          Future.delayed(Duration(seconds: 4), () {
            checkIfUserIsLoggedIn();
          });
        }

      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    try {
      _sub = uriLinkStream.listen((Uri? uri) async{

        /*setState(() {
          isComingFromUnilink = true;
        });*/

        print("URI: ${uri}");
        if (uri != null) {
          print('Deep link received: $uri');
          if(uri.queryParameters['verify'] != null){
            print("reset: ${uri.queryParameters['verify'].toString()}");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            print("isUserLoggedIn: $isUserLoggedIn");
            Map<String, dynamic> arguments = {
              "isComingFromReset": true,
              "token": uri.queryParameters['verify'].toString()
            };
            if(isUserLoggedIn != null)
            {
              if(isUserLoggedIn)
              {
                sharedPreferences!.setBool('reset_dialog_opened', false);
                Get.to(HomePage(isComingFromReset: true,token: uri.queryParameters['verify'].toString(),),arguments: arguments);

              }
            }
            else
            {
              Future.delayed(Duration(seconds: 2), (){
                Get.offAll(ResetPassword(token: initialLink!.queryParameters['verify'].toString(), isCalledFrom: "Main"));
              });
            }

          }
        }
        else
          {
            checkIfTripIsRunning();

            Future.delayed(Duration(seconds: 4), () {
              checkIfUserIsLoggedIn();
            });
          }
      }, onError: (err) {
        print('Error handling deep link: $err');
      });
    } on PlatformException {
      print("Exception while handling with uni links : ${PlatformException}");
    }
  }
}
