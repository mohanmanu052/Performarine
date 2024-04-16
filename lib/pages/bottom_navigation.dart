import 'dart:io';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/add_vessel_new/add_new_vessel_screen.dart';
import 'package:performarine/pages/auth/reset_password.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/dashboard/dashboard.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/reports_module/reports.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
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

import 'auth_new/sign_in_screen.dart';

class BottomNavigation extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isAppKilled;
  bool? isComingFromReset;
  String token;

  BottomNavigation(
      {Key? key,
      this.tripData = const [],
      this.tabIndex = 0,
      this.isComingFromReset = false,
      this.token = "",
      this.isAppKilled = false})
      : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}


class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  ScreenshotController screen_shot_controller = ScreenshotController();




  var _bottomNavIndex = 0;
  bool isFloatBtnSelect = false,
      isBluetoothConnected = false,
      isStartButton = false,
      isLocationDialogBoxOpen = false,
      isEndTripBtnClicked = false;
  double progress = 0.9, lprSensorProgress = 1.0;
  String bluetoothName = '';
  String? isLPRDeviceConnected;

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

  List<String> _labels = ["Home", "Reports", "Start Trip", "Trips", "Vessels"];

  late TabController _tabController;


  @override
  void didUpdateWidget(covariant BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    dynamic arg = Get.arguments;
    if (arg != null) {
      Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      bool isComingFrom = arguments?['isComingFromReset'] ?? false;
      String updatedToken = arguments?['token'] ?? "";

      setState(() {});
      bool? isTripStarted = sharedPreferences!.getBool('trip_started');
      Utils.customPrint("isComingFromReset: ${isComingFrom}");
      if (mounted) {
        if (isComingFrom != null && isComingFrom) {
          Future.delayed(Duration(microseconds: 500), () {
            Utils.customPrint(
                "XXXXXXXXX ${isThereCurrentDialogShowing(context)}");
            // if(isTripStarted ?? false){
            //  // showResetPasswordDialogBox(context);
            // } else{
            Get.to(ResetPassword(
              token: updatedToken,
              isCalledFrom: 'Dashboard',
            ));
            // }

            /*  if(!isThereCurrentDialogShowing(context))
            {
              WidgetsBinding.instance.addPostFrameCallback((duration)
              {
                print("RESET PASSWORD didUpdateWidget");
                showResetPasswordDialogBox(context,updatedToken);

              });
            } */
          });
        }
      }
      Utils.customPrint('HomeScreen did update');
    }
  }
  checkCurrentUser() {
    if(Get.arguments!=null){
    Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
    if (arguments != null) {
      if(arguments['isLoggedinUser']!=null&&arguments['isLoggedinUser']==false){
        Future.delayed(Duration(seconds: 1)).then((value) {showNotCurrentUserDailog(context);
        } );

        ;
      }}
//   if(arguments[])
// }
    }
  }
  signOut() async {
    var vesselDelete = await _databaseService.deleteDataFromVesselTable();
    var tripsDelete = await _databaseService.deleteDataFromTripTable();

    Utils.customPrint('DELETE $vesselDelete');
    Utils.customPrint('DELETE $tripsDelete');
    CustomLogger().logWithFile(Level.info, "DELETE $vesselDelete' -> $page");
    CustomLogger().logWithFile(Level.info, "DELETE $tripsDelete' -> $page");

    sharedPreferences!.clear();
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );

    googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen(calledFrom: 'sideMenu',)),
        ModalRoute.withName(""));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
print('the get arguments was----'+Get.arguments.toString());
    WidgetsBinding.instance.addObserver(this);
    checkCurrentUser();

    _tabController =
        TabController(vsync: this, length: 5, initialIndex: widget.tabIndex);
    _bottomNavIndex = widget.tabIndex;
    commonProvider = context.read<CommonProvider>();

    bool? isTripStarted = sharedPreferences!.getBool('trip_started');

    if (widget.isAppKilled!) {
      if (isTripStarted != null) {
        if (isTripStarted) {
          Future.delayed(Duration(microseconds: 500), () {
            showEndTripDialogBox(context);
          });
        }
      }
    }

    print("RESET PASSWORD 4 ${widget.isComingFromReset}");

    if (widget.isComingFromReset != null) {
      print("RESET PASSWORD 3");
      if (widget.isComingFromReset!) {
        Future.delayed(Duration(microseconds: 1000), () {
          print("RESET PASSWORD INIT ${isThereCurrentDialogShowing(context)}");
          // if(isTripStarted ?? false){
          //  // showResetPasswordDialogBox(context);
          // } else {
          Get.to(ResetPassword(
            token: widget.token,
            isCalledFrom: 'Dashboard',
          ));
          // }
          // if(!isThereCurrentDialogShowing(context)){
          //   widget.isComingFromReset = false;
          //   print("RESET PASSWORD 5 ${widget.isComingFromReset}");
          //   showResetPasswordDialogBox(context, widget.token);
          // }
        });
      }
    }

    getLPRData();
  }

  getLPRData() async
  {
    FlutterSecureStorage storage = FlutterSecureStorage();
     isLPRDeviceConnected = await storage.read(
        key: 'onStartTripLPRDeviceConnected'
    );

    debugPrint('IS LPR DEVICE CONNECTED OR NOT $isLPRDeviceConnected');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
if(_bottomNavIndex==1){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

}
  }




  void captureScreenShot() async {
    final image = await screen_shot_controller.capture();
    Utils.customPrint("Image is: ${image.toString()}");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FeedbackReport(
                  imagePath: image.toString(),
                  uIntList: image,
                )));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Utils.customPrint("APP STATE - app in resumed");
        dynamic arg = Get.arguments;
        if (arg != null) {
          Map<String, dynamic> arguments =
              Get.arguments as Map<String, dynamic>;
          bool isComingFrom = arguments?['isComingFromReset'] ?? false;
          String updatedToken = arguments?['token'] ?? "";

          if (mounted) {
            setState(() {});
          }
          Utils.customPrint("isComingFromReset: ${isComingFrom}");
          if (mounted) {
            if (isComingFrom != null && isComingFrom) {
              Future.delayed(Duration(microseconds: 500), () {
                Utils.customPrint(
                    "XXXXXXXXX ${isThereCurrentDialogShowing(context)}");
                bool? result;
                bool? isTripStarted;
                if (sharedPreferences != null) {
                  result = sharedPreferences!.getBool('reset_dialog_opened');
                  isTripStarted = sharedPreferences!.getBool('trip_started');
                }

                if (!isThereCurrentDialogShowing(context)) {
                  WidgetsBinding.instance.addPostFrameCallback((duration) {
                    if (isComingFrom != null) {
                      if (!isComingFrom) {
                        print("RESET PASSWORD LIFECYCLE");

                        // if(isTripStarted ?? false){
                        //   print("Trip runnnig status3: $isTripStarted");
                        //  //  showResetPasswordDialogBox(context);
                        // } else {
                        Get.to(ResetPassword(
                          token: widget.token,
                          isCalledFrom: 'Dashboard',
                        ));
                        // }
                      }
                    }
                  });
                  setState(() {});
                }
              });
            }
          }
          Utils.customPrint('HomeScreen did update');
        } else {
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
      Dashboard(
          tripData: widget.tripData,
          tabIndex: widget.tabIndex,
          isComingFromReset: false,
          isAppKilled: widget.isAppKilled,
          token: widget.token),
      ReportsModule(
        onScreenShotCaptureCallback: () {
          captureScreenShot();
        },
      ),
      StartTripRecordingScreen(),
      Trips(),
      VesselsScreen()
    ];

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop){
          if(didPop)  return;

          if(!isComingFromUnilinkMain || !widget.isComingFromReset!)
          {
            Utils.onAppExitCallBack(context, scaffoldKey);
          }
        },
        child: OrientationBuilder(
            key: UniqueKey(),
            builder: (ctx, orientation) {
              double iconHeight = orientation == Orientation.portrait
                  ? displayHeight(context) * 0.035
                  : displayHeight(context) * 0.060;
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
                Image.asset(
                  'assets/icons/start_trip_icon.png',
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
                Image.asset(
                  'assets/icons/start_trip_icon.png',
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

              return Screenshot(
                controller: screen_shot_controller,
                child: Scaffold(
                  backgroundColor: backgroundColor,
                  key: scaffoldKey,
                  resizeToAvoidBottomInset: false,
                  drawer: CustomDrawer(
                    bottomNavIndex:_bottomNavIndex ,
                    scaffoldKey: scaffoldKey,
                    orientation: orientation,
                  ),
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
                        text: _bottomNavIndex == 0
                            ? 'Dashboard'
                            : _bottomNavIndex == 1
                                ? 'Reports'
                                : _bottomNavIndex == 3
                                    ? 'Trips'
                                    : 'Vessels',
                        fontWeight: FontWeight.w700,
                        textColor: Colors.black87,
                        textSize: orientation == Orientation.portrait
                            ? displayWidth(context) * 0.05
                            : displayWidth(context) * 0.025,
                        fontFamily: outfit),
                    actions: [
                      _bottomNavIndex != 0
                          ? Container(
                              margin: EdgeInsets.only(right: 8),
                              child: IconButton(
                                onPressed: () async{
                                                   await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()),
                                      ModalRoute.withName(""));
                                },
                                icon: Image.asset(
                                    'assets/icons/performarine_appbar_icon.png'),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                    ],
                  ),
                  bottomNavigationBar: orientation == Orientation.portrait
                      ? Container(
                    height: orientation == Orientation.portrait
                        ? displayHeight(context) * 0.1
                        : displayHeight(context) * 0.17,
                    child: ClipRRect(
                      child: Container(
                        color: bottomNavColor,
                        child: Wrap(
                          children: [
                            TabBar(
                                padding: EdgeInsets.zero,
                                indicatorWeight: 16,
                                labelPadding: EdgeInsets.zero,
                                onTap: (index) async {
                                  if (index == 1) {
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.landscapeLeft,
                                      DeviceOrientation.landscapeRight,
                                    ]);
                                  } else {
                                    // SystemChrome.setPreferredOrientations([
                                    //   DeviceOrientation.portraitUp,
                                    // ]);
                                  }

                                  // await Future.delayed(Duration(milliseconds: 500), (){
                                  //   print('INDEXXXXX: $index');
                                  // });

                                  if (index == 2) {
                                    List<CreateVessel> localVesselList =
                                        await _databaseService.vessels();

                                    if (localVesselList.isEmpty) {
                                      addNewVesselDialogBox(context,orientation);
                                    } else {
                                      if (!commonProvider.onTripEndClicked) {
                                        if (mounted) {
                                          bool? isTripStarted =
                                              sharedPreferences!
                                                  .getBool('trip_started');

                                          if (isTripStarted != null) {
                                            if (isTripStarted) {
                                              List<String>? tripData =
                                                  sharedPreferences!
                                                      .getStringList(
                                                          'trip_data');
                                              Trip tripDetails =
                                                  await _databaseService
                                                      .getTrip(tripData![0]);

                                              if (isTripStarted) {
                                                showDialogBox(context,orientation);
                                                return;
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            StartTripRecordingScreen(
                                                              bottomNavIndex: _bottomNavIndex,
                                                              // isLocationPermitted: isLocationPermitted,
                                                              // isBluetoothConnected: isBluetoothConnected,
                                                              calledFrom:
                                                                  'bottom_nav',
                                                            )));
                                              }
                                            }
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StartTripRecordingScreen(
                                                          bottomNavIndex: _bottomNavIndex,
                                                          // isLocationPermitted: isLocationPermitted,
                                                          // isBluetoothConnected: isBluetoothConnected,
                                                          calledFrom:
                                                              'bottom_nav',
                                                        )));
                                          }
                                        }
                                      } else {
                                        Utils.showSnackBar(
                                          context,
                                          scaffoldKey: scaffoldKey,
                                          message:
                                              'Please wait. Another trip\'s process is still going on',
                                        );
                                      }
                                    }
                                  } else {
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
                                      i == _bottomNavIndex
                                          ? selectedIcons[i]
                                          : _icons[i],
                                      _labels[i],
                                      orientation,
                                      isSelected: i == _bottomNavIndex,
                                    ),
                                ],
                                controller: _tabController),
                          ],
                        ),
                      ),
                    ),
                  )
                  : SizedBox(),
                  body: screensList[_bottomNavIndex],
                ),
              );
            }));
  }

  Widget _tabItem(Widget child, String label, Orientation orientation,
      {bool isSelected = false}) {
    return Padding(
      padding:
          EdgeInsets.only(top: orientation == Orientation.portrait ? 13 : 0),
      child:

      AnimatedContainer(
          width: orientation == Orientation.portrait
              ? displayWidth(context) * 0.13
              : displayWidth(context) * 0.11,
          height: orientation == Orientation.portrait
              ? displayHeight(context) * 0.07
              : displayHeight(context) * 0.16,
          alignment: Alignment.center,
          duration: Duration(milliseconds: 0),
          decoration: !isSelected
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: blueColor,
                ),
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              child,
              commonText(
                  context: context,
                  text: label,
                  fontWeight: FontWeight.w500,
                  textColor: isSelected ? backgroundColor : Colors.black,
                  textSize:orientation==Orientation.portrait? displayWidth(context) * 0.022:displayWidth(context) * 0.018,
                  textAlign: TextAlign.center,
                  fontFamily: outfit),
            ],
          )),
    );
  }

  showDialogBox(BuildContext context,Orientation orientation) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return OrientationBuilder(
            builder: (context,orientation) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Container(
                      height:orientation==Orientation.portrait? displayHeight(context) * 0.45:displayHeight(context) * 0.60,
                      width:orientation==Orientation.portrait? MediaQuery.of(context).size.width:MediaQuery.of(context).size.width/2,
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
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.038:displayWidth(context) * 0.020,
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

                                        List<String>? tripData = sharedPreferences!
                                            .getStringList('trip_data');
                                        bool? runningTrip = sharedPreferences!
                                            .getBool("trip_started");

                                        String tripId = '', vesselName = '';
                                        if (tripData != null) {
                                          tripId = tripData[0];
                                          vesselName = tripData[1];
                                        }

                                        Utils.customPrint("Click on GO TO TRIP 2");
                                        if (mounted) {
                                          Navigator.of(dialogContext).pop();

                                          Navigator.push(
                                            dialogContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TripRecordingScreen(
                                                      bottomNavIndex: _bottomNavIndex,
                                                        tripId: tripId,
                                                        vesselId: tripData![1],
                                                        vesselName: tripData[2],
                                                        tripIsRunningOrNot:
                                                            runningTrip)),
                                          );
                                        }

                                        Utils.customPrint("Click on GO TO TRIP 3");
                                      },
                                       orientation==Orientation.portrait?   displayWidth(context) * 0.65:displayWidth(context) * 0.25,
                                        orientation==Orientation.portrait?  displayHeight(context) * 0.054:displayHeight(context) * 0.090,
                                          primaryColor,
                                          Colors.white,
                                   orientation==    Orientation.portrait?    displayHeight(context) * 0.02:displayHeight(context) * 0.03,
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
                                        'Ok go back', context, Colors.transparent,
                                        () {
                                      if (mounted) {
                                        //  Navigator.of(context).pop();
                                        Navigator.of(dialogContext,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                    },
                                      orientation==    Orientation.portrait?     displayWidth(context) * 0.65:displayWidth(context) * 0.80,
                                      orientation==    Orientation.portrait?  displayHeight(context) * 0.054:displayHeight(context) * 0.070,
                                        primaryColor,
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : blueColor,
                                   orientation==    Orientation.portrait?       displayHeight(context) * 0.018:displayHeight(context) * 0.025,
                                        Colors.white,
                                        '',
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:orientation==    Orientation.portrait?    displayHeight(context) * 0.01:0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          );
        });
  }

  showResetPasswordDialogBox(BuildContext context) {
    if (sharedPreferences != null) {
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
                                    'Continue', context, blueColor, () async {
                                  /*    Navigator.pop(dialogContext);

                                      if(sharedPreferences != null){
                                        sharedPreferences!.setBool('reset_dialog_opened', false);
                                      }
                                      // Get.reset();
                                      // Get.resetRootNavigator();

                                      var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ResetPassword(token: token, isCalledFrom:  "HomePage",)),); */
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
                              /*   SizedBox(height: 4,),
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
                              ), */
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
      if (sharedPreferences != null) {
        sharedPreferences!.setBool('reset_dialog_opened', false);
      }
    });
  }

  bool isThereCurrentDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;



  showNotCurrentUserDailog(BuildContext context){
    return showDialog(
        barrierDismissible: true,
        context: context,

        builder: (BuildContext dialogContext) {

          return
            Dialog(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
          ),

       child:     Container(
           height: displayHeight(context) * 0.28,

          // color: Colors.white60,
            padding: EdgeInsets.all(16),
            child:                         Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  commonText(
                      context: context,
                      text:
                      'You are not currently signed in with other account. Please sign in to continue.',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.center),



            SizedBox(
              height: displayHeight(context) * 0.014,
            ),
            Container(
              margin: EdgeInsets.only(
                top: 8.0,
              ),
              child: Column(
                children: [
                  Center(
                    child: CommonButtons.getAcceptButton(
                        'Signout', context, blueColor, () async {

signOut();
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
Navigator.pop(context);
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
]
            )
            )         ));
    });
  }

  showEndTripDialogBox(BuildContext context) {
    if (sharedPreferences != null) {
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }
            SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async {
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
                                    text: lastTimeUsedText,
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
                                    child: isEndTripBtnClicked
                                        ? Container(
                                            //  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            //   height: displayHeight(context) * 0.054,
                                            //width:  displayWidth(context) * 0.064,
                                            child: CircularProgressIndicator(
                                            color: blueColor,
                                          ))
                                        : CommonButtons.getAcceptButton(
                                            'End Trip',
                                            context,
                                            Colors.transparent, () async {
                                            setDialogState(() {
                                              isEndTripBtnClicked = true;
                                            });

                                            List<String>? tripData =
                                                sharedPreferences!
                                                    .getStringList('trip_data');

                                            String tripId = '';
                                            if (tripData != null) {
                                              tripId = tripData[0];
                                            }

                                            final currentTrip =
                                                await _databaseService
                                                    .getTrip(tripId);

                                            DateTime createdAtTime =
                                                DateTime.parse(
                                                    currentTrip.createdAt!);

                                            var durationTime = DateTime.now()
                                                .toUtc()
                                                .difference(createdAtTime);
                                            String tripDuration =
                                                Utils.calculateTripDuration(
                                                    ((durationTime
                                                                .inMilliseconds) /
                                                            1000)
                                                        .toInt());

                                            Utils.customPrint(
                                                "DURATION !!!!!! $tripDuration");

                                            bool isSmallTrip = Utils()
                                                .checkIfTripDurationIsGraterThan10Seconds(
                                                    tripDuration.split(":"));

                                            if (!isSmallTrip) {
                                              Navigator.pop(context);

                                              Utils().showDeleteTripDialog(
                                                  context, endTripBtnClick: () {
                                                EasyLoading.show(
                                                    status: 'Please wait...',
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .black);
                                                endTripMethod(setDialogState);
                                                Utils.customPrint(
                                                    "SMALL TRIPP IDDD ${tripId}");

                                                Utils.customPrint(
                                                    "SMALL TRIPP IDDD ${tripId}");

                                                Future.delayed(
                                                    Duration(seconds: 1), () {
                                                  if (!isSmallTrip) {
                                                    Utils.customPrint(
                                                        "SMALL TRIPP IDDD 11 ${tripId}");
                                                    DatabaseService()
                                                        .deleteTripFromDB(
                                                            tripId);
                                                  }
                                                });
                                              }, onCancelClick: () {
                                                endTripMethod(setDialogState);
                                              });
                                            } else {
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
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Continue Trip',
                                      context,
                                      Colors.transparent, () async
                                  {

                                    bool onStartTripLPRDeviceConnected = sharedPreferences!.getBool('onStartTripLPRDeviceConnected') ?? false;
                                                                            bool? runningTrip = sharedPreferences!
                                            .getBool("trip_started");


                                    if(onStartTripLPRDeviceConnected){
                                      List<BluetoothDevice> connectedDeviceList = FlutterBluePlus.connectedDevices;
                                      if(connectedDeviceList.isNotEmpty)
                                      {

                                        final _isRunning = await BackgroundLocator();

                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                        List<String>? tripData = sharedPreferences!
                                            .getStringList('trip_data');

                                        reInitializeService();

                                        await StartTrip().startBGLocatorTrip(
                                            tripData![0], DateTime.now(), true);

                                        final isRunning2 = await BackgroundLocator
                                            .isServiceRunning();

                                        Navigator.of(context).pop();


                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 22222 $isRunning2');

                                                                           
                                                                           Navigator.push(
                                            dialogContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TripRecordingScreen(
                                                      bottomNavIndex: _bottomNavIndex,
                                                        tripId: tripData[0],
                                                        vesselId: tripData![1],
                                                        vesselName: tripData[2],
                                                        tripIsRunningOrNot:
                                                            runningTrip)),
                                          );

                                                                                                                                                                      LPRDeviceHandler().setLPRDevice(connectedDeviceList.first);

                                      }
                                      else
                                      {
                                        final _isRunning = await BackgroundLocator();

                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                        List<String>? tripData = sharedPreferences!
                                            .getStringList('trip_data');

                                        reInitializeService();

                                        await StartTrip().startBGLocatorTrip(
                                            tripData![0], DateTime.now(), true);

                                        final isRunning2 = await BackgroundLocator
                                            .isServiceRunning();

                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                            
                                                                                                                     Navigator.of(context).pop();


                                                                                                                                               LPRDeviceHandler().showDeviceDisconnectedDialog(null,bottomNavIndex:_bottomNavIndex,isNavigateToMaps: true );




                                      }
                                    }
                                    else{
                                      final _isRunning =
                                      await BackgroundLocator();

                                      Utils.customPrint(
                                          'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                      List<String>? tripData = sharedPreferences!
                                          .getStringList('trip_data');

                                      reInitializeService();

                                      StartTrip().startBGLocatorTrip(
                                          tripData![0], DateTime.now(), true);

                                      final isRunning2 = await BackgroundLocator
                                          .isServiceRunning();

                                      Utils.customPrint(
                                          'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                                                                Navigator.of(context).pop();

                                                                                                                                                                 Navigator.push(
                                            dialogContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TripRecordingScreen(
                                                      bottomNavIndex: _bottomNavIndex,
                                                        tripId: tripData[0],
                                                        vesselId: tripData[1],
                                                        vesselName: tripData[2],
                                                        tripIsRunningOrNot:
                                                            runningTrip)));




                                      
                                    }
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
        }).then((value) {});
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

  endTripMethod(StateSetter setDialogState) async {
    Utils.customPrint("Set Dialog set ${setDialogState == null}");
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    String tripId = '';
    if (tripData != null) {
      tripId = tripData[0];
    }

    final currentTrip = await _databaseService.getTrip(tripId);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    var durationTime = DateTime.now().toUtc().difference(createdAtTime);
    String tripDuration = Utils.calculateTripDuration(
        ((durationTime.inMilliseconds) / 1000).toInt());

    Utils.customPrint(
        'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

    EndTrip().endTrip(
        context: context,
        scaffoldKey: scaffoldKey,
        duration: tripDuration,
        onEnded: () async {
          Future.delayed(Duration(seconds: 1), () {
            EasyLoading.dismiss();
                                                                                            Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: currentTrip.id,
                                                                                    //tripData: tripData,
                                                                                    vesselId: currentTrip.vesselId,
                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                  )));

            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (context) => BottomNavigation()),
            //     ModalRoute.withName(""));
            //Navigator.of(context).pop();
          });

          Utils.customPrint('TRIPPPPPP ENDEDDD:');
          setState(() {
            getVesselFuture = _databaseService.vessels();
          });
        });
  }

  addNewVesselDialogBox(BuildContext context,Orientation orientation) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return OrientationBuilder(
            builder: (context,orientation) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Container(
                      height:orientation==Orientation.portrait? displayHeight(context) * 0.45:displayHeight(context) * 0.60,
                      width:orientation==Orientation.portrait? MediaQuery.of(context).size.width:MediaQuery.of(context).size.width/2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 15, bottom: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: commonText(
                                  context: context,
                                  text:
                                      'No vessel available, Please add vessel to continue',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black87,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.038:displayWidth(context) * 0.020,
                                  textAlign: TextAlign.center),
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
                                          'Add Vessel', context, blueColor,
                                          () async {
                                        if (mounted) {
                                          //Navigator.of(context).pop();
                                          Navigator.of(dialogContext,
                                                  rootNavigator: true)
                                              .pop();

                                          Navigator.push(
                                              dialogContext,
                                              MaterialPageRoute(
                                                  builder: (dialogContext) =>
                                                      AddNewVesselPage(
                                                        calledFrom: 'bottomNav',
                                                        bottomNavIndex:_bottomNavIndex ,

                                                      )));
                                        }
                                      },
                                      orientation==    Orientation.portrait?     displayWidth(context) * 0.65:displayWidth(context) * 0.30,
                                      orientation==    Orientation.portrait?  displayHeight(context) * 0.054:displayHeight(context) * 0.080,
                                          primaryColor,
                                          Colors.white,
                                         orientation==    Orientation.portrait?  displayHeight(context) * 0.02:displayHeight(context) * 0.04,
                                          blueColor,
                                          '',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Center(
                                    child: CommonButtons.getAcceptButton(
                                        'Cancel', context, Colors.transparent, () {
                                      if (mounted) {
                                        // Navigator.of(context).pop();
                                        Navigator.of(dialogContext,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                    },
                                      orientation==    Orientation.portrait?     displayWidth(context) * 0.65:displayWidth(context) * 0.80,
                                      orientation==    Orientation.portrait?  displayHeight(context) * 0.054:displayHeight(context) * 0.070,
                                        primaryColor,
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : blueColor,
                                      orientation==    Orientation.portrait?   displayHeight(context) * 0.018:displayHeight(context) * 0.030,
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
            }
          );
        });
  }
}
