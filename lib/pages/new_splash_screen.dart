import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/jwt_utils.dart';
import 'package:performarine/pages/delegate/delegates_screen.dart';
import 'package:performarine/pages/fleet/manage_permissions_screen.dart';
import 'package:performarine/pages/fleet/my_fleet_screen.dart';
import 'package:performarine/pages/new_intro_screen.dart';
import '../common_widgets/widgets/log_level.dart';
import '../main.dart';
import 'auth/reset_password.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'bottom_navigation.dart';
import 'start_trip/trip_recording_screen.dart';
import 'sync_data_cloud_to_mobile_screen.dart';
import '../common_widgets/utils/utils.dart';
import '../analytics/location_callback_handler.dart';

class NewSplashScreen extends StatefulWidget {
  const NewSplashScreen({super.key});

  @override
  State<NewSplashScreen> createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends State<NewSplashScreen> {
  bool isBtnVisible = false,
      isTripRunningCurrently = false,
      locationAccuracy = false;
  StreamSubscription? _sub;
  String page = "Intro_screen";
        late AppLinks?  _appLinks;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initUniLinks();
  }

  /*@override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => NewIntroScreen()),
            ModalRoute.withName(""));
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: displayHeight(context),
        width: displayWidth(context),
        child: Stack(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/icons/background_img.png',
                  height: displayHeight(context),
                  width: displayWidth(context),
                  fit: BoxFit.cover,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: displayHeight(context) * 0.34,
                      width: displayWidth(context),
                      padding: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 70))
                      ]),
                    ))
              ],
            ),
            Positioned(
                top: displayHeight(context) * 0.3,
                right: 0,
                left: 0,
                child: Image.asset('assets/icons/app_icon.png',
                    width: displayWidth(context) * 0.2,
                    height: displayHeight(context) * 0.12))
          ],
        ),
      ),
    );
  }

  /// To Check trip is running or not
  checkIfTripIsRunning() async {
    var pref = await Utils.initSharedPreferences();

    bool? isTripStarted = pref.getBool('trip_started') ?? false;
    bool? isCalledFromNoti = pref.getBool('sp_key_called_from_noti');

    Utils.customPrint('INTRO START $isTripStarted');
    CustomLogger()
        .logWithFile(Level.info, "INTRO START $isTripStarted -> $page");
    CustomLogger()
        .logWithFile(Level.info, "INTRO START $isTripStarted -> $page");

    setState(() {
      isTripRunningCurrently = isTripStarted;
    });

    if (!isTripRunningCurrently!) {
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
      CustomLogger().logWithFile(
          Level.info, "NotificationAppLaunchDetails IS NULL -> $page");
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
        CustomLogger().logWithFile(
            Level.info, "NotificationAppLaunchDetails IS FALSE -> $page");

        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isBtnVisible = true;
            });
          }
        });
      } else {
        Utils.customPrint('NotificationAppLaunchDetails IS TRUE');
        CustomLogger().logWithFile(
            Level.info, "NotificationAppLaunchDetails IS TRUE -> $page");

        if (notificationAppLaunchDetails.notificationResponse!.id == 889 ||
            notificationAppLaunchDetails.notificationResponse!.id == 776 ||
            notificationAppLaunchDetails.notificationResponse!.id == 1) {
          List<String>? tripData =
          sharedPreferences!.getStringList('trip_data');

          /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TripAnalyticsScreen(
                      tripId: tripData![0],
                      vesselId: tripData[1],
                      isAppKilled: true,
                      tripIsRunningOrNot: isTripStarted)),
              ModalRoute.withName(""));*/

          sharedPreferences!.setBool('key_lat_time_dialog_open', false);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TripRecordingScreen(
                      tripId: tripData![0],
                      vesselName: tripData[2],
                      vesselId: tripData[1],
                      isAppKilled: true,
                      calledFrom: 'notification',
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

    CustomLogger()
        .logWithFile(Level.info, "ISUSERLOGEDIN  $isUserLoggedIn -> $page");
    CustomLogger()
        .logWithFile(Level.info, "ISUSERLOGEDIN 1212 $isTripStarted -> $page");

    if (isTripStarted == null) {
      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NewIntroScreen()),
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
              MaterialPageRoute(
                  builder: (context) => BottomNavigation(isAppKilled: true)),
              ModalRoute.withName(""));
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NewIntroScreen()),
            ModalRoute.withName(""));
      }
    } else if (isTripStarted) {
      Utils.customPrint('INTRO TRIP IS RUNNING $isTripStarted');
      CustomLogger().logWithFile(
          Level.info, "INTRO TRIP IS RUNNING $isTripStarted -> $page");

      flutterLocalNotificationsPlugin.cancel(1);

      final _isRunning = await BackgroundLocator();

      Utils.customPrint('INTRO TRIP IS RUNNING 1212 $_isRunning');
      CustomLogger().logWithFile(
          Level.info, "INTRO TRIP IS RUNNING $_isRunning -> $page");

      List<String>? tripData = sharedPreferences!.getStringList('trip_data');

      if (mounted) {
        if (isCalledFromNoti == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigation(
                    tripData: tripData ?? [],
                    isAppKilled: true,
                  )),
              ModalRoute.withName(""));
        } else if (!isCalledFromNoti) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigation(
                      tripData: tripData ?? [], isAppKilled: true)),
              ModalRoute.withName(""));
        } else {
          /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TripAnalyticsScreen(
                      tripId: tripData![0],
                      vesselId: tripData[1],
                      tripIsRunningOrNot: isTripStarted)),
              ModalRoute.withName(""));*/

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TripRecordingScreen(
                      tripId: tripData![0],
                      vesselName: tripData[2],
                      vesselId: tripData[1],
                      calledFrom: 'notification',
                      tripIsRunningOrNot: isTripStarted)),
              ModalRoute.withName(""));
        }
      }
    } else {
      if (isUserLoggedIn == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NewIntroScreen()),
            ModalRoute.withName(""));
      } else if (isUserLoggedIn) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigation(isAppKilled: true)),
            ModalRoute.withName(""));
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NewIntroScreen()),
            ModalRoute.withName(""));
      }
    }
  }

  /// Reinitialized service after user killed app while trip is running
  reInitializeService() async {
    await BackgroundLocator.initialize();
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
        _appLinks = AppLinks();

    Uri? initialLink;
    try {
      // bool? isInitialUriHandled =
      //     sharedPreferences!.getBool('is_initial_uri_handled') ?? false;
      //
      // if (!isInitialUriHandled) {
        sharedPreferences!.setBool('is_initial_uri_handled', true);
        initialLink = await _appLinks?.getInitialLink();

        Utils.customPrint('UNI LINK: $initialLink');
        CustomLogger()
            .logWithFile(Level.info, "UNI LINK: $initialLink -> $page");

        if (initialLink != null) {
          Utils.customPrint('Deep link received: $initialLink');
          CustomLogger().logWithFile(
              Level.info, "Deep link received: $initialLink -> $page");
          if (initialLink.path=='/reset') {
            Utils.customPrint(
                "reset: ${initialLink.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "reset: ${initialLink.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn =
            await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": true,
              "token": initialLink.queryParameters['verify'].toString()
            };

            Utils.customPrint("ARGUMENTS: $arguments");

            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {
                isComingFromUnilinkMain = true;
                sharedPreferences!.setBool('reset_dialog_opened', false);
                Get.offAll(
                    BottomNavigation(
                        isComingFromReset: true,
                        token: initialLink.queryParameters['verify'].toString(),
                        isAppKilled: true),
                    arguments: arguments);
              }
            } else {
            //  Future.delayed(Duration(seconds: 2), () {
                isComingFromUnilinkMain = true;
                Get.offAll(ResetPassword(
                    token: initialLink.queryParameters['verify'].toString(),
                    isCalledFrom: "Main"));
            //  });
            }
          }
          else if (initialLink.path=='/fleetmember') {
            Utils.customPrint(
                "fleetmember: ${initialLink.queryParameters['fleetmember'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "fleetmember: ${initialLink.queryParameters['fleetmember'].toString()} -> $page");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": initialLink.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {

                isComingFromUnilinkMain = true;
        bool isSameUser=await        JwtUtils.getDecodedData(initialLink.queryParameters['verify'].toString());
                         String fleetId=JwtUtils.getFleetId(initialLink.queryParameters['verify'].toString());

if(isSameUser){
  Get.to(
      ManagePermissionsScreen(isComingFromUnilink:true,fleetId: fleetId,url: initialLink,),
      arguments: arguments);
}else{
  Map<String, dynamic> arguments = {
    "isComingFromReset": false,
    "token": initialLink.queryParameters['verify'].toString(),
    'isLoggedinUser':false
  };
  Get.offAll(
      BottomNavigation(
          isComingFromReset: false,
          isAppKilled: true),
      arguments: arguments);
}
                // sharedPreferences!.setBool('reset_dialog_opened', false);

              }
            } else {
              Future.delayed(Duration(seconds: 2), () {
                //isComingFromUnilinkMain = true;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const NewIntroScreen()),
                    ModalRoute.withName(""));
              });
            }
          }
          else if(initialLink.path=='/delegateaccess'){
                        Utils.customPrint(
                "delegate: ${initialLink.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "delegate: ${initialLink.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": initialLink.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {

                isComingFromUnilinkMain = true;
                bool isSameUser=await        JwtUtils.getDecodedData(initialLink.queryParameters['verify'].toString());
                String vesselId=JwtUtils.getVesselId(initialLink.queryParameters['verify'].toString());
                String? ownerId=JwtUtils.getOwnerId(initialLink.queryParameters['verify'].toString());
                if(isSameUser){
                  // Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>ManagePermissionsScreen(isComingFromUnilink:true,fleetId: fleetId,url: uri,),),
                  //     ModalRoute.withName('/')
                  //
                  // );
                  Get.to(
                      DelegatesScreen(isComingFromUnilink:true,vesselID: vesselId,uri: initialLink,
                      ownerId: ownerId,
                      
                      ),
                      arguments: arguments,

                  );
                }else{
                  Map<String, dynamic> arguments = {
                    "isComingFromReset": false,
                    "token": initialLink.queryParameters['verify'].toString(),
                    'isLoggedinUser':false
                  };
                  Get.offAll(
                      BottomNavigation(
                          isComingFromReset: false,
                          isAppKilled: true),
                      arguments: arguments);
                }
              }


            }}

        } else {
          checkIfTripIsRunning();
          Future.delayed(Duration(seconds: 1), () {
            checkIfUserIsLoggedIn();
          });
        }
      // }
      // else{
      //   checkIfTripIsRunning();
      //   Future.delayed(Duration(seconds: 4), () {
      //     checkIfUserIsLoggedIn();
      //   });
      // }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    try {
      _sub = _appLinks?.uriLinkStream.listen((Uri? uri) async {
        Utils.customPrint("URI: ${uri}");
        CustomLogger().logWithFile(Level.info, "URI: $uri-> $page");
        if (uri != null) {
          Utils.customPrint('Deep link received: $uri');
          CustomLogger().logWithFile(Level.info, "Deep link received-> $page");
          if (uri.path=='/reset') {
            Utils.customPrint(
                "reset: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "reset: ${uri.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn =
            await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn -> $page");
            Map<String, dynamic> arguments = {
              "isComingFromReset": true,
              "token": uri.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {
                sharedPreferences!.setBool('reset_dialog_opened', false);
                Get.offAll(
                    BottomNavigation(
                        isComingFromReset: true,
                        token: uri.queryParameters['verify'].toString(),
                        isAppKilled: true),
                    arguments: arguments);
              }
            } else {
              Get.to(ResetPassword(token: uri.queryParameters['verify'].toString(),isCalledFrom: "Main",));
              CustomLogger().logWithFile(Level.info, "User navigating to reset password screen -> $page ");
            }
          }
          else if (uri.path=='/fleetmember') {
            Utils.customPrint(
                "reset: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "reset: ${uri.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn =
            await sharedPreferences!.getBool('isUserLoggedIn');
            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn -> $page");
            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": uri.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {
                //sharedPreferences!.setBool('reset_dialog_opened', false);
                bool isSameUser=await        JwtUtils.getDecodedData(uri.queryParameters['verify'].toString());
                String fleetId=JwtUtils.getFleetId(uri.queryParameters['verify'].toString());
                if(isSameUser){
                  Get.to(
                      ManagePermissionsScreen(isComingFromUnilink:true,fleetId: fleetId,url: uri,),
                      arguments: arguments);
                }else{
                  Map<String, dynamic> arguments = {
                    "isComingFromReset": false,
                    "token": uri.queryParameters['verify'].toString(),
                    'isLoggedinUser':false
                  };
                  Get.offAll(
                      BottomNavigation(
                          isComingFromReset: false,
                          isAppKilled: true),
                      arguments: arguments);
                }
              }
            } else {
              Future.delayed(Duration(seconds: 2), ()
              {
                //isComingFromUnilinkMain = true;
Get.offAll( const SignInScreen());
                    
              });
            }
          }

          else if(uri.path=='/delegateaccess'){
                        Utils.customPrint(
                "delegate: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "delegate: ${uri.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": uri.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {

                isComingFromUnilinkMain = true;
                bool isSameUser=await        JwtUtils.getDecodedData(uri.queryParameters['verify'].toString());
                String vesselId=JwtUtils.getVesselId(uri.queryParameters['verify'].toString());
                String? ownerId=JwtUtils.getOwnerId(uri.queryParameters['verify'].toString());
                if(isSameUser){
                  Get.to(
                      DelegatesScreen(isComingFromUnilink:true,vesselID: vesselId,uri: uri,
                      ownerId: ownerId,
                      
                      ),
                      arguments: arguments,

                  );
                }else{
                  Map<String, dynamic> arguments = {
                    "isComingFromReset": false,
                    "token": uri.queryParameters['verify'].toString(),
                    'isLoggedinUser':false
                  };
                  Get.offAll(
                      BottomNavigation(
                          isComingFromReset: false,
                          isAppKilled: true),
                      arguments: arguments);
                }
              }
            } else {


              Future.delayed(Duration(seconds: 2), () {
                //isComingFromUnilinkMain = true;
                Get.offAll(
                    SignInScreen(),
                    );
              });
            }
          }




        } else {
          checkIfTripIsRunning();
          Future.delayed(Duration(seconds: 1), () {
            checkIfUserIsLoggedIn();
          });
        }
      }, onError: (err) {
        Utils.customPrint('Error handling deep link: $err');
        CustomLogger()
            .logWithFile(Level.error, "Error handling deep link -> $page");
      });
    } on PlatformException {
      Utils.customPrint(
          "Exception while handling with uni links : ${PlatformException}");
      CustomLogger().logWithFile(Level.error,
          "Exception while handling with uni links : ${PlatformException} -> $page");
    }
  }
}