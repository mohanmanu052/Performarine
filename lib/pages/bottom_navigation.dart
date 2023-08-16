import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/pages/coming_soon_screen.dart';
import 'package:performarine/pages/dashboard/dashboard.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:performarine/pages/reports_module/reports.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/common_buttons.dart';
import '../common_widgets/widgets/common_widgets.dart';
import '../common_widgets/widgets/location_permission_dialog.dart';
import '../main.dart';
import '../models/trip.dart';
import '../new_trip_analytics_screen.dart';
import '../provider/common_provider.dart';
import '../services/database_service.dart';
import 'add_vessel_new/add_new_vessel_screen.dart';
import 'custom_drawer.dart';
import 'package:performarine/pages/trips/Trips.dart';

class BottomNavigation extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isComingFromReset, isAppKilled;
  String token;
   BottomNavigation({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset,this.token = "", this.isAppKilled = false}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with SingleTickerProviderStateMixin{
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  var _bottomNavIndex = 0;
  bool isFloatBtnSelect = false, isBluetoothConnected = false, isStartButton = false, isLocationDialogBoxOpen = false;
  double progress = 0.9, lprSensorProgress = 1.0;
  String bluetoothName = '';

  late CommonProvider commonProvider;

  final iconList = [
    "assets/icons/Home.png",
    "assets/icons/reports.png",
    "assets/icons/trips.png",
    "assets/icons/profile.png",
  ];

  final selectList = [
    "assets/icons/Home_select.png",
    "assets/icons/reports_select.png",
    "assets/icons/trips_select.png",
    "assets/icons/profile_select.png",
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
    "Profile"
  ];


  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
    commonProvider = context.read<CommonProvider>();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _icons = [
      Image.asset(
        iconList[0],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset(
        iconList[1],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset('assets/icons/start_trip_icon.png',
        height: displayHeight(context) * 0.035,
        width: displayWidth(context) * 0.12,
      ),
      Image.asset(
        iconList[2],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset(
        iconList[3],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),

    ];
    List<Widget> selectedIcons = [
      Image.asset(
        selectList[0],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset(
        selectList[1],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset('assets/icons/start_trip_icon.png',
        height: displayHeight(context) * 0.035,
        width: displayWidth(context) * 0.12,
      ),
      Image.asset(
        selectList[2],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),
      Image.asset(
        selectList[3],
        width: displayWidth(context) * 0.06,
        height: displayHeight(context) * 0.035,
      ),

    ];
    commonProvider = context.watch<CommonProvider>();
    var screensList = [
      Dashboard(tripData: widget.tripData,tabIndex: widget.tabIndex,isComingFromReset: widget.isComingFromReset,isAppKilled: widget.isAppKilled,token: widget.token),
      ReportsModule(),
      StartTripRecordingScreen(),
      Trips(),
      ComingSoonScreen()
    ];

    return WillPopScope(
      onWillPop: () async {
        return Utils.onAppExitCallBack(context, scaffoldKey);
      },
      child: Scaffold(
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
                : _bottomNavIndex == 3 ? 'Trips' : 'Profile' ,
            fontWeight: FontWeight.w700,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.05,
            fontFamily: outfit
          ),
          actions: [
            Container(
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
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: displayHeight(context) * 0.1,
          child: ClipRRect(
           // borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: bottomNavColor,
              child: TabBar(
                padding: EdgeInsets.zero,
                indicatorWeight: 18,
                  labelPadding: EdgeInsets.zero,
                  onTap: (index) async{


                    if(index == 2){
                      if(mounted) {
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
                      }
                    }
                    else{
                      setState(() {
                        _bottomNavIndex = index;
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
                        _labels[i],
                        isSelected: i == _bottomNavIndex,
                      ),
                  ],
                  controller: _tabController),
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
  }


  Widget _tabItem(Widget child, String label, {bool isSelected = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 13),
      child: AnimatedContainer(
        width: displayWidth(context) * 0.13,
          height: displayHeight(context) * 0.1,
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
                                  'There is a trip in progress from another Vessel. Please end the trip and come back here',
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
            isLocationPermitted: isLocationPermitted,
            isBluetoothConnected: isBluetoothConnected,)));
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
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,)));
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
            isLocationPermitted: isLocationPermitted,
            isBluetoothConnected: isBluetoothConnected,)));
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
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,
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
                                color: bluetoothConnectBtnBackColor,
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


}
