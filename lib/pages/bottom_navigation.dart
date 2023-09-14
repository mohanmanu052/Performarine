import 'dart:io';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/old_ui/old_custom_drawer.dart';
import 'package:performarine/pages/auth/reset_password.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/dashboard/dashboard.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/reports/search_and_filters.dart';
import 'package:performarine/pages/reports_module/reports.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../analytics/location_callback_handler.dart';
import '../analytics/start_trip.dart';
import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/common_buttons.dart';
import '../common_widgets/widgets/common_widgets.dart';
import '../main.dart';
import '../models/trip.dart';
import '../models/vessel.dart';
import '../provider/common_provider.dart';
import '../services/database_service.dart';
import 'Vessels_screen.dart';
import 'package:performarine/pages/trips/Trips.dart';

class BottomNavigation extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isAppKilled;
  bool? isComingFromReset;
  String token;
   BottomNavigation({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset, this.token = "", this.isAppKilled = false}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
ScreenshotController screen_shot_controller=ScreenshotController();

  var _bottomNavIndex = 0;
  bool isFloatBtnSelect = false, isBluetoothConnected = false, isStartButton = false, isLocationDialogBoxOpen = false, isEndTripBtnClicked = false, locationAccuracy = false;
  double progress = 0.9, lprSensorProgress = 1.0;
  String bluetoothName = '';


  late CommonProvider commonProvider;
  late Future<List<CreateVessel>> getVesselFuture;



  final iconList = [
    "assets/icons/Home.png",
    "assets/icons/reports.png",
    "assets/icons/trips.png",
    "assets/icons/vessels.png",
  ];

  final selectList = [
    "assets/icons/Home_select.png",
    "assets/icons/reports_select.png",
    "assets/icons/trips_select.png",
    "assets/icons/vessel_select.png",
  ];

  final bottomTabNames = [
    "Home",
    "Reports",
    "Trips",
    "Vessels",
  ];

  List<String> _labels = [
    "Home",
    "Reports",
    "Start Trip",
    "Trips",
    "Vessels"
  ];


  late TabController _tabController;

  @override
  void didUpdateWidget(covariant BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    dynamic arg = Get.arguments;
    if(arg !=  null)
    {
      Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      bool isComingFrom = arguments?['isComingFromReset'] ?? false;
      String updatedToken = arguments?['token'] ?? "";

      setState(() {});

      Utils.customPrint("isComingFromReset: ${isComingFrom}");
      if(mounted){
        if(isComingFrom != null && isComingFrom )
        {
          Future.delayed(Duration(microseconds: 500), (){

            Utils.customPrint("XXXXXXXXX ${isThereCurrentDialogShowing(context)}");

            if(!isThereCurrentDialogShowing(context))
            {
              WidgetsBinding.instance.addPostFrameCallback((duration)
              {
                print("RESET PASSWORD didUpdateWidget");
                showResetPasswordDialogBox(context,updatedToken);

              });
            }
          });
        }
      }
      Utils.customPrint('HomeScreen did update');
    }
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(vsync: this, length: 5, initialIndex: widget.tabIndex);
    _bottomNavIndex = widget.tabIndex;
    commonProvider = context.read<CommonProvider>();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    bool? isTripStarted = sharedPreferences!.getBool('trip_started');

    if(widget.isAppKilled!)
    {
      if(isTripStarted != null)
      {
        if(isTripStarted)
        {
          Future.delayed(Duration(microseconds: 500), (){
            showEndTripDialogBox(context);
          });

        }
      }

    }

    print("RESET PASSWORD 4 ${widget.isComingFromReset}");

    if(widget.isComingFromReset != null)
    {
      print("RESET PASSWORD 3");
      if(widget.isComingFromReset!)
      {
        Future.delayed(Duration(microseconds: 500), (){
          print("RESET PASSWORD INIT ${isThereCurrentDialogShowing(context)}");
          if(!isThereCurrentDialogShowing(context)){
            widget.isComingFromReset = false;
            print("RESET PASSWORD 5 ${widget.isComingFromReset}");
            showResetPasswordDialogBox(context, widget.token);
          }

        });
      }
    }
  }

  void captureScreenShot()async{
        final image = await screen_shot_controller.capture();
      Utils.customPrint(
          "Image is: ${image.toString()}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FeedbackReport(
                    imagePath: image.toString(),
                    uIntList: image,
                  )));


  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Utils.customPrint("APP STATE - app in resumed");
        dynamic arg = Get.arguments;
        if(arg !=  null)
        {
          Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
          bool isComingFrom = arguments?['isComingFromReset'] ?? false;
         // bool isComingFrom = widget.isComingFromReset ?? false;
          String updatedToken = arguments?['token'] ?? "";

          if(mounted){
            setState(() {});
          }
          Utils.customPrint("isComingFromReset: ${isComingFrom}");
          if(mounted){
            if(isComingFrom != null && isComingFrom )
            {
              Future.delayed(Duration(microseconds: 500), (){
                Utils.customPrint("XXXXXXXXX ${isThereCurrentDialogShowing(context)}");
                bool? result;
                if(sharedPreferences != null){
                  result = sharedPreferences!.getBool('reset_dialog_opened');
                }

                if(!isThereCurrentDialogShowing(context))
                {
                  WidgetsBinding.instance.addPostFrameCallback((duration)
                  {
                    if(isComingFrom != null){
                      if(!isComingFrom){
                        print("RESET PASSWORD LIFECYCLE");
                        showResetPasswordDialogBox(context,updatedToken);
                      }
                    }
                  });
                  setState(() {});
                }
              });
            }
          }
          Utils.customPrint('HomeScreen did update');
        }
        else{
          print('NULLLLL');
        }
        break;
      case AppLifecycleState.inactive:
        Utils.customPrint("APP STATE - app in inactive");
        break;
      case AppLifecycleState.paused:
        Utils.customPrint("APP STATE - app in paused");
        break;
      case AppLifecycleState.detached:
        Utils.customPrint("APP STATE - app in detached");
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    var screensList = [
      Dashboard(tripData: widget.tripData,tabIndex: widget.tabIndex,isComingFromReset: false,isAppKilled: widget.isAppKilled,token: widget.token),
     ReportsModule(onScreenShotCaptureCallback: (){
      captureScreenShot();
     },),
     // SearchAndFilters(calledFrom:'HOME'),
     
      StartTripRecordingScreen(),
      Trips(),
      VesselsScreen()
    ];

    return WillPopScope(
      onWillPop: () async {
        return Utils.onAppExitCallBack(context, scaffoldKey);
      },
      child:
      
      OrientationBuilder(
        key: UniqueKey(),
        builder: (context, orientation) {
                double iconHeight=        orientation==Orientation.portrait? displayHeight(context) * 0.035:displayHeight(context) * 0.060;
                              List<Widget> _icons = [
      Image.asset(
        iconList[0],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset(
        iconList[1],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset('assets/icons/start_trip_icon.png',
        height: iconHeight,
        width: displayWidth(context) * 0.12,
      ),
      Image.asset(
        iconList[2],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset(
        iconList[3],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),

    ];
    List<Widget> selectedIcons = [
      Image.asset(
        selectList[0],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset(
        selectList[1],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset('assets/icons/start_trip_icon.png',
        height: iconHeight,
        width: displayWidth(context) * 0.12,
      ),
      Image.asset(
        selectList[2],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),
      Image.asset(
        selectList[3],
        width: displayWidth(context) * 0.06,
        height: iconHeight,
      ),

    ];



      return
       Screenshot(
        controller: screen_shot_controller,
         child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: CustomDrawer(scaffoldKey: scaffoldKey,),
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                scaffoldKey.currentState!.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/icons/menu.png',
                ),
              ),
            ),
            title: commonText(
              context: context,
              text: _bottomNavIndex == 0 ? 'Dashboard'
                  : _bottomNavIndex == 1
                  ? 'Reports'
                  : _bottomNavIndex == 3 ? 'Trips' : 'Vessels' ,
              fontWeight: FontWeight.w700,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.05,
              fontFamily: outfit
            ),
            actions: [
              _bottomNavIndex != 0 ?  Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavigation()),
                        ModalRoute.withName(""));
                  },
                  icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ) : Container(width: 0,height: 0,),
            ],
          ),
          bottomNavigationBar: Container(
                     height:
                     
                     orientation==Orientation.portrait? displayHeight(context) * 0.1:displayHeight(context) * 0.2,
       
            // height: Platform.isAndroid ? displayHeight(context) * 0.098 ?         orientation==Orientation.portrait? displayHeight(context) * 0.1:displayHeight(context) * 0.2,
       
            
            //  displayHeight(context) * 0.109,
            child: ClipRRect(
             // borderRadius: BorderRadius.circular(10.0),
              child: Container(
                color: bottomNavColor,
                child: Wrap(
                  children: [
                    TabBar(
                      padding: EdgeInsets.zero,
                      indicatorWeight: 16,
                        labelPadding: EdgeInsets.zero,
                        onTap: (index) async{
                        if(index == 1){
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                        } else{
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);
                        }

                          if(index == 2){

                           if(!commonProvider.onTripEndClicked)
                             {
                               if(mounted)
                               {
                                 bool? isTripStarted =
                                 sharedPreferences!.getBool('trip_started');

                                 if (isTripStarted != null) {
                                   if (isTripStarted) {
                                     List<String>? tripData = sharedPreferences!
                                         .getStringList('trip_data');
                                     Trip tripDetails = await _databaseService
                                         .getTrip(tripData![0]);

                                     if (isTripStarted) {
                                       showDialogBox(context);
                                       return;
                                     }
                                     else
                                     {
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
                                         // isLocationPermitted: isLocationPermitted,
                                         // isBluetoothConnected: isBluetoothConnected,
                                         calledFrom: 'bottom_nav',)));
                                     }

                                   }
                                 }
                                 else
                                 {
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
                                     // isLocationPermitted: isLocationPermitted,
                                     // isBluetoothConnected: isBluetoothConnected,
                                     calledFrom: 'bottom_nav',)));
                                 }
                               }
                             }
                           else
                             {
                               Utils.showSnackBar(
                                 context,
                                 scaffoldKey: scaffoldKey,
                                 message: 'Please wait. Another trip\'s process is still going on',
                               );
                             }

                            /*if(mounted) {
                              bool? isTripStarted =
                              sharedPreferences!.getBool('trip_started');

                              if (isTripStarted != null) {
                                if (isTripStarted) {
                                  List<String>? tripData = sharedPreferences!
                                      .getStringList('trip_data');
                                  Trip tripDetails = await _databaseService
                                      .getTrip(tripData![0]);

                                  if (isTripStarted) {
                                    showDialogBox(context);
                                    return;
                                  }
                                }
                              }

                              bool isLocationPermitted =
                              await Permission.locationAlways.isGranted;

                              if (isLocationPermitted) {
                                bool isNDPermDenied = await Permission
                                    .bluetoothConnect.isPermanentlyDenied;

                                if (isNDPermDenied) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return LocationPermissionCustomDialog(
                                          isLocationDialogBox: false,
                                          text: 'Allow nearby devices',
                                          subText:
                                          'Allow nearby devices to connect to the app',
                                          buttonText: 'OK',
                                          buttonOnTap: () async {
                                            Get.back();
                                          },
                                        );
                                      });
                                  return;
                                } else {
                                  if (Platform.isIOS) {
                                    dynamic isBluetoothEnable =

                                    Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                                      showBluetoothDialog(context);
                                    });

                                    if(isBluetoothEnable != null){
                                      if (isBluetoothEnable) {
                                        // vessel!.add(widget.vessel!);
                                        await locationPermissions();
                                      } else {
                                        showBluetoothDialog(context);
                                      }
                                    }

                                  } else {
                                    bool isNDPermittedOne = await Permission
                                        .bluetoothConnect.isGranted;

                                    if (isNDPermittedOne) {
                                      bool isBluetoothEnable =
                                      Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                                        showBluetoothDialog(context);
                                      });

                                      if (isBluetoothEnable) {
                                        // vessel!.add(widget.vessel!);
                                        await locationPermissions();
                                      } else {
                                        showBluetoothDialog(context);
                                      }
                                    } else {
                                      await Permission.bluetoothConnect.request();
                                      bool isNDPermitted = await Permission
                                          .bluetoothConnect.isGranted;
                                      if (isNDPermitted) {
                                        bool isBluetoothEnable =
                                        Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                                          showBluetoothDialog(context);
                                        });

                                        if (isBluetoothEnable) {
                                          // vessel!.add(widget.vessel!);
                                          await locationPermissions();
                                        } else {
                                          showBluetoothDialog(context);
                                        }
                                      } else {
                                        if (await Permission
                                            .bluetoothConnect.isDenied ||
                                            await Permission.bluetoothConnect
                                                .isPermanentlyDenied) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return LocationPermissionCustomDialog(
                                                  isLocationDialogBox: false,
                                                  text: 'Allow nearby devices',
                                                  subText:
                                                  'Allow nearby devices to connect to the app',
                                                  buttonText: 'OK',
                                                  buttonOnTap: () async {
                                                    Get.back();

                                                    await openAppSettings();
                                                  },
                                                );
                                              });
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              else {
                                /// WIU
                                bool isWIULocationPermitted =
                                await Permission.locationWhenInUse.isGranted;

                                if (!isWIULocationPermitted) {
                                  await Utils.getLocationPermission(
                                      context, scaffoldKey);

                                  if(Platform.isAndroid){
                                    if (!(await Permission.locationWhenInUse
                                        .shouldShowRequestRationale)) {
                                      Utils.customPrint(
                                          'XXXXX@@@ ${await Permission.locationWhenInUse.shouldShowRequestRationale}');

                                      if(await Permission.locationWhenInUse
                                          .isDenied || await Permission.locationWhenInUse
                                          .isPermanentlyDenied){
                                        await openAppSettings();
                                      }

                                      */
                            /*showDialog(
                                              context: scaffoldKey.currentContext!,
                                              builder: (BuildContext context) {
                                                isLocationDialogBoxOpen = true;
                                                return LocationPermissionCustomDialog(
                                                  isLocationDialogBox: true,
                                                  text:
                                                  'Always Allow Access to “Location”',
                                                  subText:
                                                  "To track your trip while you use other apps we need background access to your location",
                                                  buttonText: 'Ok',
                                                  buttonOnTap: () async {
                                                    Get.back();

                                                    await openAppSettings();
                                                  },
                                                );
                                              }).then((value) {
                                            isLocationDialogBoxOpen = false;
                                          });*/
                            /*
                                    }
                                  }
                                  else
                                  {
                                    await Permission.locationAlways.request();

                                    bool isGranted = await Permission.locationAlways.isGranted;

                                    if(!isGranted)
                                    {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message:
                                          'Location permissions are denied without permissions we are unable to start the trip');
                                    }
                                  }

                                }
                                else
                                {
                                  bool isLocationPermitted =
                                  await Permission.locationAlways.isGranted;
                                  if (isLocationPermitted) {
                                    bool isNDPermDenied = await Permission
                                        .bluetoothConnect.isPermanentlyDenied;

                                    if (isNDPermDenied) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return LocationPermissionCustomDialog(
                                              isLocationDialogBox: false,
                                              text: 'Allow nearby devices',
                                              subText:
                                              'Allow nearby devices to connect to the app',
                                              buttonText: 'OK',
                                              buttonOnTap: () async {
                                                Get.back();

                                                await openAppSettings();
                                              },
                                            );
                                          });
                                      return;
                                    } else {
                                      bool isNDPermitted = await Permission
                                          .bluetoothConnect.isGranted;

                                      if (isNDPermitted) {
                                        bool isBluetoothEnable =
                                        Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                                          showBluetoothDialog(context);
                                        });

                                        if (isBluetoothEnable) {
                                          // vessel!.add(widget.vessel!);
                                          await locationPermissions();
                                        } else {
                                          showBluetoothDialog(context);
                                        }
                                      } else {
                                        await Permission.bluetoothConnect.request();
                                        bool isNDPermitted = await Permission
                                            .bluetoothConnect.isGranted;
                                        if (isNDPermitted) {
                                          bool isBluetoothEnable =
                                          Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                                            showBluetoothDialog(context);
                                          });

                                          if (isBluetoothEnable) {
                                            // vessel!.add(widget.vessel!);
                                            await locationPermissions();
                                          } else {
                                            showBluetoothDialog(context);
                                          }
                                        }
                                      }
                                    }
                                  }
                                  else if(await Permission.locationAlways.isPermanentlyDenied)
                                  {
                                    if(Platform.isIOS)
                                    {
                                      Permission.locationAlways.request();

                                      PermissionStatus status = await Permission.locationAlways.request().catchError((onError){
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message: "Location permissions are denied without permissions we are unable to start the trip");

                                        Future.delayed(Duration(seconds: 3),
                                                () async {
                                              await openAppSettings();
                                            });
                                        return PermissionStatus.denied;
                                      });

                                      if(status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied)
                                      {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message: "Location permissions are denied without permissions we are unable to start the trip");

                                        Future.delayed(Duration(seconds: 3),
                                                () async {
                                              await openAppSettings();
                                            });
                                      }
                                    }else
                                    {
                                      if (!isLocationDialogBoxOpen) {
                                        Utils.customPrint("ELSE CONDITION");

                                        showDialog(
                                            context: scaffoldKey.currentContext!,
                                            builder: (BuildContext context) {
                                              isLocationDialogBoxOpen = true;
                                              return LocationPermissionCustomDialog(
                                                isLocationDialogBox: true,
                                                text:
                                                'Always Allow Access to “Location”',
                                                subText:
                                                "To track your trip while you use other apps we need background access to your location",
                                                buttonText: 'Ok',
                                                buttonOnTap: () async {
                                                  Get.back();

                                                  await openAppSettings();
                                                },
                                              );
                                            }).then((value) {
                                          isLocationDialogBoxOpen = false;
                                        });
                                      }
                                    }
                                  }
                                  else {
                                    if (Platform.isIOS) {
                                      await Permission.locationAlways.request();

                                      bool isLocationAlwaysPermitted =
                                      await Permission.locationAlways.isGranted;

                                      Utils.customPrint(
                                          'IOS PERMISSION GIVEN OUTSIDE');

                                      if (isLocationAlwaysPermitted) {
                                        Utils.customPrint('IOS PERMISSION GIVEN 1');

                                        // vessel!.add(widget.vessel!);
                                        await locationPermissions();
                                      } else {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                            'Location permissions are denied without permissions we are unable to start the trip');

                                        Future.delayed(Duration(seconds: 3),
                                                () async {
                                              await openAppSettings();
                                            });
                                      }
                                    } else {
                                      if (!isLocationDialogBoxOpen) {
                                        Utils.customPrint("ELSE CONDITION");

                                        showDialog(
                                            context: scaffoldKey.currentContext!,
                                            builder: (BuildContext context) {
                                              isLocationDialogBoxOpen = true;
                                              return LocationPermissionCustomDialog(
                                                isLocationDialogBox: true,
                                                text:
                                                'Always Allow Access to “Location”',
                                                subText:
                                                "To track your trip while you use other apps we need background access to your location",
                                                buttonText: 'Ok',
                                                buttonOnTap: () async {
                                                  Get.back();

                                                  await openAppSettings();
                                                },
                                              );
                                            }).then((value) {
                                          isLocationDialogBoxOpen = false;
                                        });
                                      }
                                    }
                                  }
                                }
                                // return;

                              }

                              setState(() {
                                print("START BTN CLICKED");
                                isFloatBtnSelect = true;
                                //_bottomNavIndex = 4;

                              });
                            }*/
                          }
                          else{
                            setState(() {
                              _bottomNavIndex = index;
                              commonProvider.bottomNavIndex = index;
                            });
                          }
                        },
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide.none,
                        ),
                        tabs: [
                          for (int i = 0; i <= iconList.length; i++)
                            _tabItem(
                              i == _bottomNavIndex ? selectedIcons[i] : _icons[i],
                              _labels[i],orientation,
                              isSelected: i == _bottomNavIndex,
                            ),
                        ],
                        controller: _tabController),
                  ],
                ),
              ),
            ),
          ),
            /*   bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            notchMargin: 5,
            height: displayHeight(context) * 0.075,
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              return GestureDetector(
                onTap: (){
                  isFloatBtnSelect = false;
                  if(index == 0){
                    setState(() {
                      _bottomNavIndex = 0;
                    });
                  }else if(index == 1){
                    setState(() {
                      _bottomNavIndex = 1;
                    });
                  }else if(index == 2){
                    setState(() {
                      _bottomNavIndex = 2;
                    });
                  }else if(index == 3){
                    setState(() {
                      _bottomNavIndex = 3;
                    });
                  }
                },
                child:  Padding(
                  padding: EdgeInsets.only(
                    top: displayWidth(context) * 0.021,
                    left: 15,
                    right: 15
                  ),
                  child: Stack(
                    children: [
                      index == _bottomNavIndex ? Container(
                        width: displayWidth(context) * 0.12,
                        height: displayHeight(context) * 0.1,
                        decoration: BoxDecoration(
                            color: index == _bottomNavIndex ?  Color(0xff2663DB) : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(displayWidth(context) * 0.06))
                        ),
                      ) : SizedBox(),
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: index != _bottomNavIndex ? AssetImage(iconList[index]) as ImageProvider : AssetImage(selectList[index]) as ImageProvider,
                              width: displayWidth(context) * 0.06,
                              height: displayHeight(context) * 0.035,
                            ),
       
                            commonText(
                              context: context,
                              text: bottomTabNames[index],
                              fontWeight: FontWeight.w600,
                              textColor: index == _bottomNavIndex ? Colors.white :  Colors.black87,
                              textSize: displayWidth(context) * 0.022,
                              fontFamily: reemKufi
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            backgroundColor: commonBackgroundColor,
            activeIndex: _bottomNavIndex,
            splashSpeedInMilliseconds: 300,
            notchSmoothness: NotchSmoothness.defaultEdge,
            gapLocation: GapLocation.center,
            leftCornerRadius: displayWidth(context) * 0.09,
            rightCornerRadius: displayWidth(context) * 0.09,
            onTap: (index) => setState(() => _bottomNavIndex = index),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: floatingBtnColor,
            tooltip: "Start Trip",
            foregroundColor: isFloatBtnSelect! ? floatingBtnColor : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the roundness
            ),
            onPressed: ()async {
       
              bool? isTripStarted =
              sharedPreferences!.getBool('trip_started');
       
              if (isTripStarted != null) {
                if (isTripStarted) {
                  List<String>? tripData = sharedPreferences!
                      .getStringList('trip_data');
                  Trip tripDetails = await _databaseService
                      .getTrip(tripData![0]);
       
                  if (isTripStarted) {
                    showDialogBox(context);
                    return;
                  }
                }
              }
       
              bool isLocationPermitted =
              await Permission.locationAlways.isGranted;
       
              if (isLocationPermitted) {
                bool isNDPermDenied = await Permission
                    .bluetoothConnect.isPermanentlyDenied;
       
                if (isNDPermDenied) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LocationPermissionCustomDialog(
                          isLocationDialogBox: false,
                          text: 'Allow nearby devices',
                          subText:
                          'Allow nearby devices to connect to the app',
                          buttonText: 'OK',
                          buttonOnTap: () async {
                            Get.back();
                          },
                        );
                      });
                  return;
                } else {
                  if (Platform.isIOS) {
                    dynamic isBluetoothEnable =
       
                    Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                      showBluetoothDialog(context);
                    });
       
                    if(isBluetoothEnable != null){
                      if (isBluetoothEnable) {
                        // vessel!.add(widget.vessel!);
                        await locationPermissions();
                      } else {
                        showBluetoothDialog(context);
                      }
                    }
       
                  } else {
                    bool isNDPermittedOne = await Permission
                        .bluetoothConnect.isGranted;
       
                    if (isNDPermittedOne) {
                      bool isBluetoothEnable =
                      Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                        showBluetoothDialog(context);
                      });
       
                      if (isBluetoothEnable) {
                        // vessel!.add(widget.vessel!);
                        await locationPermissions();
                      } else {
                        showBluetoothDialog(context);
                      }
                    } else {
                      await Permission.bluetoothConnect.request();
                      bool isNDPermitted = await Permission
                          .bluetoothConnect.isGranted;
                      if (isNDPermitted) {
                        bool isBluetoothEnable =
                        Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                          showBluetoothDialog(context);
                        });
       
                        if (isBluetoothEnable) {
                          // vessel!.add(widget.vessel!);
                          await locationPermissions();
                        } else {
                          showBluetoothDialog(context);
                        }
                      } else {
                        if (await Permission
                            .bluetoothConnect.isDenied ||
                            await Permission.bluetoothConnect
                                .isPermanentlyDenied) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return LocationPermissionCustomDialog(
                                  isLocationDialogBox: false,
                                  text: 'Allow nearby devices',
                                  subText:
                                  'Allow nearby devices to connect to the app',
                                  buttonText: 'OK',
                                  buttonOnTap: () async {
                                    Get.back();
       
                                    await openAppSettings();
                                  },
                                );
                              });
                        }
                      }
                    }
                  }
                }
              }
              else {
                /// WIU
                bool isWIULocationPermitted =
                await Permission.locationWhenInUse.isGranted;
       
                if (!isWIULocationPermitted) {
                  await Utils.getLocationPermission(
                      context, scaffoldKey);
       
                  if(Platform.isAndroid){
                    if (!(await Permission.locationWhenInUse
                        .shouldShowRequestRationale)) {
                      Utils.customPrint(
                          'XXXXX@@@ ${await Permission.locationWhenInUse.shouldShowRequestRationale}');
       
                      if(await Permission.locationWhenInUse
                          .isDenied || await Permission.locationWhenInUse
                          .isPermanentlyDenied){
                        await openAppSettings();
                      }
       
                      /*showDialog(
                                          context: scaffoldKey.currentContext!,
                                          builder: (BuildContext context) {
                                            isLocationDialogBoxOpen = true;
                                            return LocationPermissionCustomDialog(
                                              isLocationDialogBox: true,
                                              text:
                                              'Always Allow Access to “Location”',
                                              subText:
                                              "To track your trip while you use other apps we need background access to your location",
                                              buttonText: 'Ok',
                                              buttonOnTap: () async {
                                                Get.back();
       
                                                await openAppSettings();
                                              },
                                            );
                                          }).then((value) {
                                        isLocationDialogBoxOpen = false;
                                      });*/
                    }
                  }
                  else
                  {
                    await Permission.locationAlways.request();
       
                    bool isGranted = await Permission.locationAlways.isGranted;
       
                    if(!isGranted)
                    {
                      Utils.showSnackBar(context,
                          scaffoldKey: scaffoldKey,
                          message:
                          'Location permissions are denied without permissions we are unable to start the trip');
                    }
                  }
       
                }
                else
                {
                  bool isLocationPermitted =
                  await Permission.locationAlways.isGranted;
                  if (isLocationPermitted) {
                    bool isNDPermDenied = await Permission
                        .bluetoothConnect.isPermanentlyDenied;
       
                    if (isNDPermDenied) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LocationPermissionCustomDialog(
                              isLocationDialogBox: false,
                              text: 'Allow nearby devices',
                              subText:
                              'Allow nearby devices to connect to the app',
                              buttonText: 'OK',
                              buttonOnTap: () async {
                                Get.back();
       
                                await openAppSettings();
                              },
                            );
                          });
                      return;
                    } else {
                      bool isNDPermitted = await Permission
                          .bluetoothConnect.isGranted;
       
                      if (isNDPermitted) {
                        bool isBluetoothEnable =
                        Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                          showBluetoothDialog(context);
                        });
       
                        if (isBluetoothEnable) {
                          // vessel!.add(widget.vessel!);
                          await locationPermissions();
                        } else {
                          showBluetoothDialog(context);
                        }
                      } else {
                        await Permission.bluetoothConnect.request();
                        bool isNDPermitted = await Permission
                            .bluetoothConnect.isGranted;
                        if (isNDPermitted) {
                          bool isBluetoothEnable =
                          Platform.isAndroid ? await blueIsOn() : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey, (){
                            showBluetoothDialog(context);
                          });
       
                          if (isBluetoothEnable) {
                            // vessel!.add(widget.vessel!);
                            await locationPermissions();
                          } else {
                            showBluetoothDialog(context);
                          }
                        }
                      }
                    }
                  }
                  else if(await Permission.locationAlways.isPermanentlyDenied)
                  {
                    if(Platform.isIOS)
                    {
                      Permission.locationAlways.request();
       
                      PermissionStatus status = await Permission.locationAlways.request().catchError((onError){
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey,
                            message: "Location permissions are denied without permissions we are unable to start the trip");
       
                        Future.delayed(Duration(seconds: 3),
                                () async {
                              await openAppSettings();
                            });
                        return PermissionStatus.denied;
                      });
       
                      if(status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied)
                      {
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey,
                            message: "Location permissions are denied without permissions we are unable to start the trip");
       
                        Future.delayed(Duration(seconds: 3),
                                () async {
                              await openAppSettings();
                            });
                      }
                    }else
                    {
                      if (!isLocationDialogBoxOpen) {
                        Utils.customPrint("ELSE CONDITION");
       
                        showDialog(
                            context: scaffoldKey.currentContext!,
                            builder: (BuildContext context) {
                              isLocationDialogBoxOpen = true;
                              return LocationPermissionCustomDialog(
                                isLocationDialogBox: true,
                                text:
                                'Always Allow Access to “Location”',
                                subText:
                                "To track your trip while you use other apps we need background access to your location",
                                buttonText: 'Ok',
                                buttonOnTap: () async {
                                  Get.back();
       
                                  await openAppSettings();
                                },
                              );
                            }).then((value) {
                          isLocationDialogBoxOpen = false;
                        });
                      }
                    }
                  }
                  else {
                    if (Platform.isIOS) {
                      await Permission.locationAlways.request();
       
                      bool isLocationAlwaysPermitted =
                      await Permission.locationAlways.isGranted;
       
                      Utils.customPrint(
                          'IOS PERMISSION GIVEN OUTSIDE');
       
                      if (isLocationAlwaysPermitted) {
                        Utils.customPrint('IOS PERMISSION GIVEN 1');
       
                        // vessel!.add(widget.vessel!);
                        await locationPermissions();
                      } else {
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey,
                            message:
                            'Location permissions are denied without permissions we are unable to start the trip');
       
                        Future.delayed(Duration(seconds: 3),
                                () async {
                              await openAppSettings();
                            });
                      }
                    } else {
                      if (!isLocationDialogBoxOpen) {
                        Utils.customPrint("ELSE CONDITION");
       
                        showDialog(
                            context: scaffoldKey.currentContext!,
                            builder: (BuildContext context) {
                              isLocationDialogBoxOpen = true;
                              return LocationPermissionCustomDialog(
                                isLocationDialogBox: true,
                                text:
                                'Always Allow Access to “Location”',
                                subText:
                                "To track your trip while you use other apps we need background access to your location",
                                buttonText: 'Ok',
                                buttonOnTap: () async {
                                  Get.back();
       
                                  await openAppSettings();
                                },
                              );
                            }).then((value) {
                          isLocationDialogBoxOpen = false;
                        });
                      }
                    }
                  }
                }
                // return;
       
       
              }
       
              setState(() {
                print("START BTN CLICKED");
                isFloatBtnSelect = true;
                //_bottomNavIndex = 4;
       
              });
       
       
            },
          //  child: isFloatBtnSelect! ? Icon(Icons.play_circle_filled) : Icon(Icons.play_arrow),
            child: Image.asset('assets/icons/start_btn.png',
              height: displayHeight(context) * 0.052,
              width: displayWidth(context) * 0.12,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked, */
          body: screensList[_bottomNavIndex],
          
             ),
       );
        })
    );
  }

  Widget _tabItem(Widget child, String label,Orientation orientation, {bool isSelected = false}) {
    return Padding(
      padding: EdgeInsets.only(top:orientation==Orientation.portrait? 13:0),
      child: AnimatedContainer(
        width: displayWidth(context) * 0.13,
          height:orientation==Orientation.portrait? displayHeight(context) * 0.07:displayHeight(context) * 0.2,
          alignment: Alignment.center,
          duration: Duration(milliseconds: 0),
          decoration: !isSelected
              ? null
              : BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: blueColor,
          ),
          padding:  EdgeInsets.all(5),
          child: Column(
            children: [
              child,
              commonText(
                  context: context,
                  text: label,
                  fontWeight: FontWeight.w500,
                  textColor: isSelected ? backgroundColor : Colors.black,
                  textSize: displayWidth(context) * 0.022,
                  textAlign: TextAlign.center,
                fontFamily: outfit
              ),
            ],
          )),
    );
  }

  showDialogBox(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              //color: Color(0xfff2fffb),
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(context) * 0.1,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),

                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                  'There is a trip in progress. Please end the trip and come back here',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black87,
                                  textSize: displayWidth(context) * 0.038,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Go to trip', context, blueColor,
                                          () async {

                                        Utils.customPrint("Click on GO TO TRIP 1");

                                        List<String>? tripData =
                                        sharedPreferences!.getStringList('trip_data');
                                        bool? runningTrip = sharedPreferences!.getBool("trip_started");

                                        String tripId = '', vesselName = '';
                                        if (tripData != null) {
                                          tripId = tripData[0];
                                          vesselName = tripData[1];
                                        }

                                        Utils.customPrint("Click on GO TO TRIP 2");

                                        Navigator.of(dialogContext).pop();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TripRecordingScreen(
                                              tripId: tripId,
                                              vesselId: tripData![1],
                                              vesselName: tripData[2],
                                              tripIsRunningOrNot: runningTrip)),
                                        );

                                        Utils.customPrint("Click on GO TO TRIP 3");

                                      },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.02,
                                      blueColor,
                                      '',
                                      fontFamily: outfit,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Ok go back', context, Colors.transparent, () {
                                  Navigator.of(context).pop();
                                },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    primaryColor,
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.white,
                                    '',
                                    fontWeight: FontWeight.w500),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  /// Check location permission
  locationPermissions() async {
    if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name.toLowerCase().contains("lpr")) {
              Utils.customPrint('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        if (mounted) {
                          setState(() {
                            isBluetoothConnected = true;
                            progress = 1.0;
                            lprSensorProgress = 1.0;
                            isStartButton = true;
                          });
                        }
                      });
                    });
                  }
                });
              });

              bluetoothName = r.device.name;
              setState(() {
                isBluetoothConnected = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device
                  .disconnect()
                  .then((value) => Utils.customPrint("is device disconnected:"));
            }
          }
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
            calledFrom: 'bottom_nav',)));
      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            for (ScanResult r in results) {
              if (r.device.name.toLowerCase().contains("lpr")) {
                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          if (mounted) {
                            setState(() {
                              isBluetoothConnected = true;
                              progress = 1.0;
                              lprSensorProgress = 1.0;
                              isStartButton = true;
                            });
                          }
                        });
                      });
                    }
                  });
                });

                bluetoothName = r.device.name;
                setState(() {
                  isBluetoothConnected = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device
                    .disconnect()
                    .then((value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              calledFrom: 'bottom_nav')));
        }
      }
    } else {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name.toLowerCase().contains("lpr")) {
              Utils.customPrint('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        if (mounted) {
                          setState(() {
                            isBluetoothConnected = true;
                            progress = 1.0;
                            lprSensorProgress = 1.0;
                            isStartButton = true;
                          });
                        }
                      });
                    });
                  }
                });
              });

              bluetoothName = r.device.name;
              setState(() {
                isBluetoothConnected = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device
                  .disconnect()
                  .then((value) => Utils.customPrint("is device disconnected: "));
            }
          }
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
            calledFrom: 'bottom_nav')));
      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            for (ScanResult r in results) {
              if (r.device.name.toLowerCase().contains("lpr")) {
                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          if (mounted) {
                            setState(() {
                              isBluetoothConnected = true;
                              progress = 1.0;
                              lprSensorProgress = 1.0;
                              isStartButton = true;
                            });
                          }
                        });
                      });
                    }
                  });
                });

                bluetoothName = r.device.name;
                setState(() {
                  isBluetoothConnected = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device
                    .disconnect()
                    .then((value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              calledFrom: 'bottom_nav'
          )));
        }
      }
    }
  }

  Future<bool> blueIsOn() async
  {
    FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    final isOn = await _flutterBlue.isOn;
    if(isOn) return true;

    await Future.delayed(const Duration(seconds: 1));
    return await FlutterBluePlus.instance.isOn;
  }

  showBluetoothDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(builder: (ctx, setDialogState) {
              return Container(
                width: displayWidth(context),
                height: displayHeight(context) * 0.3,
                decoration: new BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "Turn Bluetooth On",
                        style: TextStyle(
                            color: blutoothDialogTitleColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "To connect with other devices we require\n you to enable the Bluetooth",
                        style: TextStyle(
                            color: blutoothDialogTxtColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: displayWidth(context) * 0.12,
                          left: 15,
                          right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Utils.customPrint("Tapped on cancel button");
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bluetoothCancelBtnBackColor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothCancelBtnTxtColor),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Utils.customPrint("Tapped on enable Bluetooth");
                              Navigator.pop(context);
                              enableBT();
                              //showBluetoothListDialog(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Enable Bluetooth",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothConnectBtncolor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  /// To enable Bluetooth
  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) async {
      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
        // vessel!.add(widget.vessel!);
        await locationPermissions();
        Utils.customPrint(" bluetooth state$value");
      } else {
        bool isNearByDevicePermitted =
        await Permission.bluetoothConnect.isGranted;
        if (!isNearByDevicePermitted) {
          await Permission.bluetoothConnect.request();
        }
        else{
          await Permission.bluetooth.request();
        }
      }
    }).catchError((e) {
      Utils.customPrint("ENABLE BT$e");
    });
  }

  showResetPasswordDialogBox(BuildContext context,String token) {
    if(sharedPreferences != null){
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.4,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              child: Image.asset(
                                'assets/icons/lock.png',
                                height: displayHeight(context) * 0.15,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),

                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                  'If you are already logged in, click Continue to reset password.',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Continue', context, blueColor,
                                        () async {
                                      Navigator.pop(dialogContext);

                                      if(sharedPreferences != null){
                                        sharedPreferences!.setBool('reset_dialog_opened', false);
                                      }
                                      // Get.reset();
                                      // Get.resetRootNavigator();

                                      var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ResetPassword(token: token, isCalledFrom:  "HomePage",)),);
                                    },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    primaryColor,
                                    Colors.white,
                                    displayHeight(context) * 0.018,
                                    blueColor,
                                    '',
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4,),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Cancel', context, Colors.transparent,
                                        () async {
                                          if(sharedPreferences != null){
                                            sharedPreferences!.setBool('reset_dialog_opened', false);
                                          }
                                      Navigator.pop(dialogContext);
                                    },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    Colors.transparent,
                                    blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.transparent,
                                    '',
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) {
      if(sharedPreferences != null){
        sharedPreferences!.setBool('reset_dialog_opened', false);
      }
    });
  }

  bool isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;

  showEndTripDialogBox(BuildContext context) {
    if(sharedPreferences != null){
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: ()async{
              return false;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(
                builder: (ctx, setDialogState) {
                  return Container(
                    height: displayHeight(context) * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 15, bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),

                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                child: Image.asset(
                                  'assets/images/boat.gif',
                                  height: displayHeight(context) * 0.1,
                                  width: displayWidth(context),
                                  fit: BoxFit.contain,
                                ),
                              )),

                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Column(
                              children: [
                                commonText(
                                    context: context,
                                    text:
                                    'Last time you used performarine. there was a trip in progress. do you want to end the trip or continue?',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.04,
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.012,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                                                          height: displayHeight(context) * 0.054,
                                      // width:  displayWidth(context) * 0.064,

                                  child: Center(
                                    child: 
                                    isEndTripBtnClicked
                                        ?
                                        
                                        
                                         Container(
                                      //  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      //   height: displayHeight(context) * 0.054,
                                       //width:  displayWidth(context) * 0.064,
                                        child: CircularProgressIndicator(color: blueColor,
                                        
                                        ))
                                        : CommonButtons.getAcceptButton(
                                        'End Trip', context, Colors.transparent,
                                            () async {
                                          setDialogState(() {
                                            isEndTripBtnClicked = true;
                                          });
                                
                                          List<String>? tripData = sharedPreferences!
                                              .getStringList('trip_data');
                                
                                          String tripId = '';
                                          if (tripData != null) {
                                            tripId = tripData[0];
                                          }
                                
                                          final currentTrip =
                                          await _databaseService.getTrip(tripId);
                                
                                          DateTime createdAtTime =
                                          DateTime.parse(currentTrip.createdAt!);
                                
                                          var durationTime = DateTime.now()
                                              .toUtc()
                                              .difference(createdAtTime);
                                          String tripDuration =
                                          Utils.calculateTripDuration(
                                              ((durationTime.inMilliseconds) / 1000)
                                                  .toInt());
                                
                                          Utils.customPrint("DURATION !!!!!! $tripDuration");
                                
                                          bool isSmallTrip =  Utils().checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));
                                
                                          if(!isSmallTrip)
                                          {
                                            Navigator.pop(context);
                                
                                            Utils().showDeleteTripDialog(context, endTripBtnClick: (){
                                              EasyLoading.show(
                                                  status: 'Please wait...',
                                                  maskType: EasyLoadingMaskType.black);
                                              endTripMethod(setDialogState);
                                              Utils.customPrint("SMALL TRIPP IDDD ${tripId}");
                                
                                              Utils.customPrint("SMALL TRIPP IDDD ${tripId}");
                                
                                              Future.delayed(Duration(seconds: 1), (){
                                                if(!isSmallTrip)
                                                {
                                                  Utils.customPrint("SMALL TRIPP IDDD 11 ${tripId}");
                                                  DatabaseService().deleteTripFromDB(tripId);
                                                }
                                              });
                                            }, onCancelClick: (){
                                              endTripMethod(setDialogState);
                                            }
                                            );
                                          }
                                          else
                                          {
                                            endTripMethod(setDialogState);
                                          }
                                
                                        },
                                        displayWidth(context) * 0.65,
                                        displayHeight(context) * 0.054,
                                        primaryColor,
                                        Colors.white,
                                        displayHeight(context) * 0.02,
                                        endTripBtnColor,
                                        '',
                                        fontWeight: FontWeight.w700),
                                   ),
                                ),
                                SizedBox(height: 10,),
                                Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Continue Trip', context, Colors.transparent,
                                          () async {
                                        final _isRunning = await BackgroundLocator();

                                        Utils.customPrint('INTRO TRIP IS RUNNING 1212 $_isRunning');

                                        List<String>? tripData = sharedPreferences!.getStringList('trip_data');

                                        reInitializeService();

                                        StartTrip().startBGLocatorTrip(tripData![0], DateTime.now(), true);


                                        final isRunning2 = await BackgroundLocator.isServiceRunning();

                                        Utils.customPrint('INTRO TRIP IS RUNNING 22222 $isRunning2');
                                        Navigator.of(context).pop();
                                      },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      Colors.transparent,
                                      blueColor,
                                      displayHeight(context) * 0.018,
                                      Colors.transparent,
                                      '',
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.01,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).then((value) {

    });
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

  endTripMethod(StateSetter setDialogState)async
  {

    Utils.customPrint("Set Dialog set ${setDialogState == null}");
    List<String>? tripData = sharedPreferences!
        .getStringList('trip_data');

    String tripId = '';
    if (tripData != null) {
      tripId = tripData[0];
    }

    final currentTrip =
    await _databaseService.getTrip(tripId);

    DateTime createdAtTime =
    DateTime.parse(currentTrip.createdAt!);

    var durationTime = DateTime.now()
        .toUtc()
        .difference(createdAtTime);
    String tripDuration =
    Utils.calculateTripDuration(
        ((durationTime.inMilliseconds) / 1000)
            .toInt());

    Utils.customPrint(
        'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

    EndTrip().endTrip(
        context: context,
        scaffoldKey: scaffoldKey,
        duration: tripDuration,
        onEnded: () async {

          Future.delayed(Duration(seconds: 1), (){

            EasyLoading.dismiss();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigation()),
                ModalRoute.withName(""));
            //Navigator.of(context).pop();
          });

          Utils.customPrint('TRIPPPPPP ENDEDDD:');
          setState(() {
            getVesselFuture = _databaseService.vessels();
          });
        });
  }
}