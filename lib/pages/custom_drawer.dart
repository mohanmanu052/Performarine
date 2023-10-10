import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel_new/add_new_vessel_screen.dart';
import 'package:performarine/pages/auth_new/change_password.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'package:performarine/pages/retired_vessels_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/sync_data_cloud_to_mobile_screen.dart';
import 'package:performarine/pages/web_navigation/privacy_and_policy_web_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

import '../common_widgets/widgets/log_level.dart';
import 'bottom_navigation.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Orientation? orientation;
  int? bottomNavIndex;
   CustomDrawer({Key? key, this.scaffoldKey,this.orientation,this.bottomNavIndex}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final DatabaseService _databaseService = DatabaseService();
  late double textSize,gmailTextSize,signOutText;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  String? currentVersion;
  late CommonProvider commonProvider;
  late List<CreateVessel> getVesselFuture;
  late List<Trip> getTrip;
  late DeviceInfoPlugin deviceDetails;
  bool isSync = false, isUploadStarted = false;
  String page = "Custom_drawer";
  String? chosenValue = "Info";
  bool uploadandSyncClicked=false;
  bool isSyncSignoutClicked=false, isSigningOut = false;


  @override
  void initState() {
    commonProvider = context.read<CommonProvider>();

    super.initState();

    deviceDetails = DeviceInfoPlugin();
    getVersion();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.portraitUp
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    textSize = widget.orientation == Orientation.portrait ? displayWidth(context) * 0.038 : displayWidth(context) * 0.02;
    gmailTextSize = widget.orientation == Orientation.portrait ? displayWidth(context) * 0.03 : displayWidth(context) * 0.015;
    signOutText = widget.orientation == Orientation.portrait ? displayWidth(context) * 0.04 : displayWidth(context) * 0.025;

    return 
    
    
    
     Drawer(
          backgroundColor: backgroundColor,
          child: Container(
            margin: widget.orientation == Orientation.portrait ? EdgeInsets.only(left: 30, right: 10.0, top: 10.0) : EdgeInsets.only(left: 10,right: 5,top: 5),
           // width: widget.orientation == Orientation.portrait ? 500 : 400,
            child: widget.orientation == Orientation.landscape
                ? SingleChildScrollView(
              child: Padding(
                padding:  EdgeInsets.only(left: displayWidth(context) * 0.02),
                child: Container(
                //  width: 400,
                  // height: displayHeight(context) *2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: displayHeight(context) * 0.05,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                Image.asset('assets/images/home.png', height: displayHeight(context) * 0.04,),

                                SizedBox(width: displayWidth(context) * 0.015,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    commonText(
                                        context: context,
                                        text: 'Hey!',
                                        fontWeight: FontWeight.w700,
                                        textSize: textSize,
                                        textAlign: TextAlign.start),
                                    SizedBox(height: displayHeight(context) * 0.005,),
                                    Flexible(
                                      child: Text(
                                        "${commonProvider.loginModel!.userEmail}",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: gmailTextSize,
                                          fontFamily: poppins,
                                        ),
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                )
                               /* Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        text: "Hey ",
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: displayWidth(context) * 0.04,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                "${commonProvider.loginModel!.userEmail} !",
                                            style: TextStyle(
                                              color: Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: displayWidth(context) * 0.04,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.06,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*InkWell(
                                onTap: () {
                                  CustomLogger().logWithFile(Level.info, "User Navigating to Home page -> $page");
                                  Navigator.of(context).pop();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BottomNavigation(),
                                      ),
                                      ModalRoute.withName(""));


                                },
                                child: commonText(
                                    context: context,
                                    text: 'Dashboard',
                                    fontWeight: FontWeight.w500,
                                    textColor: blueColor,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),*/
                              InkWell(
                                onTap: ()async {
                                //  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                  await Future.delayed(Duration(milliseconds: 500), (){});

                                  CustomLogger().logWithFile(Level.info, "User Navigating to Home page -> $page");
                                  Navigator.of(context).pop();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BottomNavigation(),
                                      ),
                                      ModalRoute.withName(""));


                                },
                                child: commonText(
                                    context: context,
                                    text: 'My Vessels',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                              InkWell(
                                onTap: ()async {
                                 // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                  await Future.delayed(Duration(milliseconds: 500), (){});

                                  CustomLogger().logWithFile(Level.info, "User Navigating to Add New Vessel Screen -> $page");
                                  Navigator.of(context).pop();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                             AddNewVesselPage(bottomNavIndex: widget.bottomNavIndex,)),
                                  );
                                },
                                child: commonText(
                                    context: context,
                                    text: 'Create Vessels',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                              InkWell(
                                onTap: ()async {
                                 // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                  await Future.delayed(Duration(milliseconds: 500), (){});
                                  CustomLogger().logWithFile(Level.info, "User Navigating to Retired Vessel Screen -> $page");
                                  Navigator.of(context).pop();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                             RetiredVesselsScreen(bottomNavIndex: widget.bottomNavIndex,)),
                                  );
                                },
                                child: commonText(
                                    context: context,
                                    text: 'Retired Vessels',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                           /*   InkWell(
                                onTap: () {
                                  CustomLogger().logWithFile(Level.info, "User Navigating to Search and Filter -> $page");
                                  Navigator.of(context).pop();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportsModule()),
                                  );
                                },
                                child: commonText(
                                    context: context,
                                    text: 'Reports',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ), */
                              InkWell(
                                onTap: () async {

                                 // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                  await Future.delayed(Duration(milliseconds: 500), (){});

                                  bool? isTripStarted =
                                      sharedPreferences!.getBool('trip_started');

                                  var tripSyncDetails =
                                      await _databaseService.tripSyncDetails();
                                  var vesselsSyncDetails =
                                      await _databaseService.vesselsSyncDetails();

                                  Utils.customPrint(
                                      "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                                  CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails-> $page");

                                  if (isTripStarted != null) {
                                    if (isTripStarted) {

                                      if(commonProvider.bottomNavIndex != 1){
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp
                                        ]);
                                      }else{
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.landscapeLeft,
                                          DeviceOrientation.landscapeRight,
                                          DeviceOrientation.portraitDown,
                                          DeviceOrientation.portraitUp
                                        ]);
                                      }

                                      Navigator.of(context).pop();
                                      Utils.showSnackBar(context,
                                          scaffoldKey: widget.scaffoldKey,
                                          message:
                                              'Please end the trip which is already running');
                                    } else {
                                      CustomLogger().logWithFile(Level.info, "User navigating to Sync Data Cloud to mobile screen-> $page");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                 SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex,)),
                                      );
                                    }
                                  } else {
                                    if (vesselsSyncDetails || tripSyncDetails) {
                                      showDialogBoxToUploadData(
                                          context, widget.scaffoldKey!, false,widget.orientation??Orientation.portrait);
                                    } else {
                                      Navigator.of(context).pop();
                                      CustomLogger().logWithFile(Level.info, "User navigating to Sync Data Cloud to mobile screen-> $page");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                 SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex,)),
                                      );
                                    }
                                  }
                                },
                                child: commonText(
                                    context: context,
                                    text: 'Sync from Cloud',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                              ),
                           /*   DropdownButton<String>(
                                focusColor:Colors.transparent,
                                value: chosenValue,
                                //elevation: 5,
                                style: TextStyle(color: Colors.white),
                                iconEnabledColor:Colors.black54,
                                items: <String>[
                                  'Info',
                                  'Debug',
                                  'Warning',
                                  'Error',
                                  'Verbose',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: commonText(
                                        context: context,
                                        text: value,
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.black54,
                                        textSize: textSize,
                                        textAlign: TextAlign.start)
                                  );
                                }).toList(),
                                hint: commonText(
                                    context: context,
                                    text: chosenValue,
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),

                                onChanged: (String? value) {
                                  setState(() {
                                    chosenValue = value;
                                    if(chosenValue == "Info"){
                                      logLevel = "info";
                                    } else if(chosenValue == "Debug"){
                                      logLevel = "debug";
                                    } else if(chosenValue == "Warning"){
                                      logLevel = "warning";
                                    } else if(chosenValue == "Error"){
                                      logLevel = "error";
                                    } else if(chosenValue == "Verbose"){
                                      logLevel = "verbose";
                                    }
                                  });
                                },
                              ), */
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: displayHeight(context) * 0.2),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                         commonProvider.loginModel!.loginType == "regular" ?   InkWell(
                              onTap: ()async {

                              //  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                await Future.delayed(Duration(milliseconds: 500), (){});

                                bool? isTripStarted =
                                sharedPreferences!.getBool('trip_started');

                                var tripSyncDetails =
                                    await _databaseService.tripSyncDetails();
                                var vesselsSyncDetails =
                                    await _databaseService.vesselsSyncDetails();

                                Utils.customPrint(
                                    "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                                CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails-> $page");

                                if (isTripStarted != null) {
                                  if (isTripStarted) {
                                    Navigator.of(context).pop();
                                    showEndTripDialogBox(context, );
                                  } else {
                                    if (vesselsSyncDetails || tripSyncDetails) {
                                      CustomLogger().logWithFile(Level.warning, "showDialogBoxToUploadData pop up for user confirmation-> $page");
                                      showDialogBoxToUploadData(context, widget.scaffoldKey!, true,widget.orientation??Orientation.portrait);
                                    } else {
                                      CustomLogger().logWithFile(Level.info, "User Navigating to change password screen-> $page");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChangePassword(bottomNavIndex: widget.bottomNavIndex,)),
                                      );
                                    }
                                  }
                                } else {
                                  if (vesselsSyncDetails || tripSyncDetails) {
                                    CustomLogger().logWithFile(Level.warning, "showDialogBoxToUploadData pop up for user confirmation-> $page");
                                    showDialogBoxToUploadData(context, widget.scaffoldKey!, true,widget.orientation??Orientation.portrait);
                                  } else {
                                    CustomLogger().logWithFile(Level.info, "User Navigating to change password screen-> $page");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChangePassword(bottomNavIndex: widget.bottomNavIndex,)),
                                    );
                                  }
                                }
                              },
                              child: commonText(
                                  context: context,
                                  text: 'Change Password',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.black54,
                                  textSize: textSize,
                                  textAlign: TextAlign.start),
                            ) : Container(),
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                            InkWell(
                              onTap: ()async {
                               // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                await Future.delayed(Duration(milliseconds: 500), (){});

                                CustomLogger().logWithFile(Level.info, "User Navigating to Terms and Conditions screen-> $page");
                                Navigator.of(context).pop();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CustomWebView(url:'https://${Urls.terms}', isPaccore: false,bottomNavIndex: widget.bottomNavIndex,)),
                                );
                              },
                              child: commonText(
                                  context: context,
                                  text: 'Terms & Conditions',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.black54,
                                  textSize: textSize,
                                  textAlign: TextAlign.start),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                            InkWell(
                              onTap: ()async {
                               // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                await Future.delayed(Duration(milliseconds: 500), (){});

                                CustomLogger().logWithFile(Level.info, "User Navigating to Privacy and Policy screen-> $page");
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CustomWebView(url: 'https://${Urls.privacy}',isPaccore: false,bottomNavIndex: widget.bottomNavIndex,)),
                                );
                              },
                              child: commonText(
                                  context: context,
                                  text: 'Privacy Policy',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.black54,
                                  textSize: textSize,
                                  textAlign: TextAlign.start),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                            InkWell(
                              onTap: () async {
                                //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                await Future.delayed(Duration(milliseconds: 500), (){});

                                bool? isTripStarted =
                                    sharedPreferences!.getBool('trip_started');

                                var tripSyncDetails =
                                    await _databaseService.tripSyncDetails();
                                var vesselsSyncDetails =
                                    await _databaseService.vesselsSyncDetails();

                                Utils.customPrint(
                                    "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                                CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails -> $page");

                                if (isTripStarted != null) {
                                  if (isTripStarted) {
                                    Navigator.of(context).pop();

                                    CustomLogger().logWithFile(Level.warning, "show End trip dialog box for user confirmation -> $page");

                                    showEndTripDialogBox(context);
                                  } else {
                                    if (vesselsSyncDetails || tripSyncDetails) {
                                      showDialogBox(context, widget.scaffoldKey!,widget.orientation??Orientation.portrait);
                                    } else {
                                      signOut();
                                    }
                                  }
                                } else {
                                  if (vesselsSyncDetails || tripSyncDetails) {
                                    showDialogBox(context, scaffoldKey,widget.orientation??Orientation.portrait);
                                  } else {
                                    signOut();
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  commonText(
                                      context: context,
                                      text: 'Sign Out',
                                      fontWeight: FontWeight.w400,
                                      textColor: Colors.black54,
                                      textSize: signOutText,
                                      textAlign: TextAlign.start),
                                  //Icon(Icons.logout, color: Colors.black54),
                                ],
                              ),
                            ),
                            SizedBox(height: displayHeight(context) * 0.02,),
                            commonText(
                                text: 'Version $currentVersion',
                                context: context,
                                textSize: textSize,
                                textColor: Colors.black54,
                                fontWeight: FontWeight.w400),

                          /*  Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                commonText(
                                    text: 'Powered by ',
                                    context: context,
                                    textSize: textSize,
                                    textColor: Colors.grey,
                                    fontWeight: FontWeight.w400),
                                TextButton(
                                  onPressed: ()async {
                                   // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                    await Future.delayed(Duration(milliseconds: 500), (){});

                                    Navigator.of(context).pop();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CustomWebView(url:'https://www.paccore.com/', isPaccore: true)),
                                    );
                                  },
                                  child: Text('paccore.com',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: textSize,
                                          color: blueColor,
                                          fontWeight: FontWeight.w500)),
                                )
                              ],
                            ),*/

                          ],
                        ),
                      ),
                      SizedBox(height: displayHeight(context) * 0.05)
                    ],
                  ),
                ),
              ),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.05,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            Image.asset('assets/images/home.png', height: displayHeight(context) * 0.04,),

                            SizedBox(width: displayWidth(context) * 0.015,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                commonText(
                                    context: context,
                                    text: 'Hey!',
                                    fontWeight: FontWeight.w700,
                                    textSize: textSize,
                                    textAlign: TextAlign.start),
                                SizedBox(height: displayHeight(context) * 0.005,),
                                Flexible(
                                  child: Text(
                                    "${commonProvider.loginModel!.userEmail}",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: displayWidth(context) * 0.03,
                                      fontFamily: poppins,
                                    ),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            )
                            /* Expanded(
                              child: RichText(
                                text: TextSpan(
                                    text: "Hey ",
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: displayWidth(context) * 0.04,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            "${commonProvider.loginModel!.userEmail} !",
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: displayWidth(context) * 0.04,
                                        ),
                                      )
                                    ]),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.06,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*InkWell(
                            onTap: () {
                              CustomLogger().logWithFile(Level.info, "User Navigating to Home page -> $page");
                              Navigator.of(context).pop();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BottomNavigation(),
                                  ),
                                  ModalRoute.withName(""));


                            },
                            child: commonText(
                                context: context,
                                text: 'Dashboard',
                                fontWeight: FontWeight.w500,
                                textColor: blueColor,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),*/
                          InkWell(
                            onTap: () {
                              CustomLogger().logWithFile(Level.info, "User Navigating to Home page -> $page");
                              Navigator.of(context).pop();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BottomNavigation(),
                                  ),
                                  ModalRoute.withName(""));


                            },
                            child: commonText(
                                context: context,
                                text: 'My Vessels',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),
                          InkWell(
                            onTap: ()async {
                            //  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                              await Future.delayed(Duration(milliseconds: 500), (){});
                              CustomLogger().logWithFile(Level.info, "User Navigating to Add New Vessel Screen -> $page");
                              Navigator.of(context).pop();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                       
                                        AddNewVesselPage(bottomNavIndex: widget.bottomNavIndex,)),
                              );
                            },
                            child: commonText(
                                context: context,
                                text: 'Create Vessels',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),
                          InkWell(
                            onTap: () {
                            //  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                              CustomLogger().logWithFile(Level.info, "User Navigating to Retired Vessel Screen -> $page");
                              Navigator.of(context).pop();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                     RetiredVesselsScreen(bottomNavIndex: widget.bottomNavIndex,)),
                              );
                            },
                            child: commonText(
                                context: context,
                                text: 'Retired Vessels',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),
                          /*   InkWell(
                            onTap: () {
                              CustomLogger().logWithFile(Level.info, "User Navigating to Search and Filter -> $page");
                              Navigator.of(context).pop();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReportsModule()),
                              );
                            },
                            child: commonText(
                                context: context,
                                text: 'Reports',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ), */
                          InkWell(
                            onTap: () async {
                             // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                              bool? isTripStarted =
                              sharedPreferences!.getBool('trip_started');

                              var tripSyncDetails =
                              await _databaseService.tripSyncDetails();
                              var vesselsSyncDetails =
                              await _databaseService.vesselsSyncDetails();

                              Utils.customPrint(
                                  "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                              CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails-> $page");

                              if (isTripStarted != null) {
                                if (isTripStarted) {
                                  Navigator.of(context).pop();
                                  Utils.showSnackBar(context,
                                      scaffoldKey: widget.scaffoldKey,
                                      message:
                                      'Please end the trip which is already running');
                                } else {
                                  CustomLogger().logWithFile(Level.info, "User navigating to Sync Data Cloud to mobile screen-> $page");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                         SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex,)),
                                  );
                                }
                              } else {
                                if (vesselsSyncDetails || tripSyncDetails) {
                                  showDialogBoxToUploadData(
                                      context, widget.scaffoldKey!, false,widget.orientation??Orientation.portrait);
                                } else {
                                  Navigator.of(context).pop();
                                  CustomLogger().logWithFile(Level.info, "User navigating to Sync Data Cloud to mobile screen-> $page");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                         SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex)),
                                  );
                                }
                              }
                            },
                            child: commonText(
                                context: context,
                                text: 'Sync from Cloud',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),
                          ),
                          /*   DropdownButton<String>(
                            focusColor:Colors.transparent,
                            value: chosenValue,
                            //elevation: 5,
                            style: TextStyle(color: Colors.white),
                            iconEnabledColor:Colors.black54,
                            items: <String>[
                              'Info',
                              'Debug',
                              'Warning',
                              'Error',
                              'Verbose',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: commonText(
                                    context: context,
                                    text: value,
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black54,
                                    textSize: textSize,
                                    textAlign: TextAlign.start)
                              );
                            }).toList(),
                            hint: commonText(
                                context: context,
                                text: chosenValue,
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black54,
                                textSize: textSize,
                                textAlign: TextAlign.start),

                            onChanged: (String? value) {
                              setState(() {
                                chosenValue = value;
                                if(chosenValue == "Info"){
                                  logLevel = "info";
                                } else if(chosenValue == "Debug"){
                                  logLevel = "debug";
                                } else if(chosenValue == "Warning"){
                                  logLevel = "warning";
                                } else if(chosenValue == "Error"){
                                  logLevel = "error";
                                } else if(chosenValue == "Verbose"){
                                  logLevel = "verbose";
                                }
                              });
                            },
                          ), */
                          SizedBox(
                            height: displayHeight(context) * 0.02,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      commonProvider.loginModel!.loginType == "regular" ?   InkWell(
                        onTap: ()async {
                         // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                          bool? isTripStarted =
                          sharedPreferences!.getBool('trip_started');

                          var tripSyncDetails =
                          await _databaseService.tripSyncDetails();
                          var vesselsSyncDetails =
                          await _databaseService.vesselsSyncDetails();

                          Utils.customPrint(
                              "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                          CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails-> $page");

                          if (isTripStarted != null) {
                            if (isTripStarted) {
                              Navigator.of(context).pop();
                              showEndTripDialogBox(context, );
                            } else {
                              if (vesselsSyncDetails || tripSyncDetails) {
                                CustomLogger().logWithFile(Level.warning, "showDialogBoxToUploadData pop up for user confirmation-> $page");
                                showDialogBoxToUploadData(context, widget.scaffoldKey!, true,widget.orientation??Orientation.portrait);
                              } else {
                                CustomLogger().logWithFile(Level.info, "User Navigating to change password screen-> $page");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChangePassword(bottomNavIndex:widget.bottomNavIndex ,)),
                                );
                              }
                            }
                          } else {
                            if (vesselsSyncDetails || tripSyncDetails) {
                              CustomLogger().logWithFile(Level.warning, "showDialogBoxToUploadData pop up for user confirmation-> $page");
                              showDialogBoxToUploadData(context, widget.scaffoldKey!, true,widget.orientation??Orientation.portrait);
                            } else {
                              CustomLogger().logWithFile(Level.info, "User Navigating to change password screen-> $page");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePassword(bottomNavIndex:widget.bottomNavIndex )),
                              );
                            }
                          }
                        },
                        child: commonText(
                            context: context,
                            text: 'Change Password',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ) : Container(),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          CustomLogger().logWithFile(Level.info, "User Navigating to Terms and Conditions screen-> $page");
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomWebView(url:'https://${Urls.terms}', isPaccore: false,bottomNavIndex: widget.bottomNavIndex,)),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Terms & Conditions',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          CustomLogger().logWithFile(Level.info, "User Navigating to Privacy and Policy screen-> $page");
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomWebView(url: 'https://${Urls.privacy}',isPaccore: false,bottomNavIndex: widget.bottomNavIndex,)),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Privacy Policy',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () async {
                         // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                          bool? isTripStarted =
                          sharedPreferences!.getBool('trip_started');

                          var tripSyncDetails =
                          await _databaseService.tripSyncDetails();
                          var vesselsSyncDetails =
                          await _databaseService.vesselsSyncDetails();

                          Utils.customPrint(
                              "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");
                          CustomLogger().logWithFile(Level.info, "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails -> $page");

                          if (isTripStarted != null) {
                            if (isTripStarted) {
                              Navigator.of(context).pop();

                              CustomLogger().logWithFile(Level.warning, "show End trip dialog box for user confirmation -> $page");

                              showEndTripDialogBox(context);
                            } else {
                              if (vesselsSyncDetails || tripSyncDetails) {
                                showDialogBox(context, widget.scaffoldKey!,widget.orientation??Orientation.portrait);
                              } else {
                                signOut();
                              }
                            }
                          } else {
                            if (vesselsSyncDetails || tripSyncDetails) {
                              showDialogBox(context, scaffoldKey,widget.orientation??Orientation.portrait);
                            } else {
                              signOut();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            commonText(
                                context: context,
                                text: 'Sign Out',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
                            //Icon(Icons.logout, color: Colors.black54),
                          ],
                        ),
                      ),
                      SizedBox(height: displayHeight(context) * 0.02,),
                      commonText(
                          text: 'Version $currentVersion',
                          context: context,
                          textSize: displayWidth(context) * 0.03,
                          textColor: Colors.black54,
                          fontWeight: FontWeight.w400),

                    /*  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          commonText(
                              text: 'Powered by ',
                              context: context,
                              textSize: displayWidth(context) * 0.03,
                              textColor: Colors.grey,
                              fontWeight: FontWeight.w400),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustomWebView(url:'https://www.paccore.com/', isPaccore: true)),
                              );
                            },
                            child: Text('paccore.com',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: displayWidth(context) * 0.035,
                                    color: blueColor,
                                    fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),*/

                    ],
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.05)
              ],
            ),
          ));
        
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = Platform.isAndroid ? packageInfo.version : '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  /// Normal Sign out without uploading data
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

  showDialogBox(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,Orientation orientation) {
    isSigningOut = false;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return 
          
          OrientationBuilder(
            builder: (context,orientation) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Container(
                      height:orientation==Orientation.portrait? displayHeight(context) * 0.42:displayHeight(context) * 0.75,
                      width:orientation==Orientation.portrait? MediaQuery.of(context).size.width:MediaQuery.of(context).size.width/2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 15, bottom: 15),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: displayHeight(context) * 0.02,
                                ),
                                Center(
                                  child: Image.asset('assets/icons/export_img.png',
                                  //height: displayHeight(context) * 0.2,
                                    width:orientation==Orientation.portrait? displayWidth(context) * 0.18:displayWidth(context) * 0.10),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Column(
                                    children: [
                                      commonText(
                                          context: context,
                                          text:
                                              'There are some vessel & trips data not sync with cloud, do you want to proceed further?',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.038:displayWidth(context) * 0.020,
                                          textAlign: TextAlign.center,
                                      fontFamily: inter),
                                      SizedBox(
                                        height:orientation==Orientation.portrait? displayHeight(context) * 0.015:10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: commonText(
                                            context: context,
                                            text:
                                                'Click Sync & Sign Out for not loosing local data which is not uploaded',
                                            fontWeight: FontWeight.w400,
                                            textColor: Colors.grey,
                                            textSize: orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.015,
                                            textAlign: TextAlign.center,
                                            fontFamily: inter),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: 
                                      isSigningOut
                                          ?
                                           Container(
                                              height:orientation==Orientation.portrait? displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                          child: Center(child: CircularProgressIndicator(color: blueColor,)))
                                          : 
                                          Center(
                                        child:
                                         CommonButtons.getAcceptButton(
                                            'Sync & Sign Out',
                                            context,
                                            blueColor, () async {
                                          bool internet =
                                          await Utils().check(scaffoldKey);

                                          if (internet) {
                                            setDialogState(() {
                                              isSyncSignoutClicked=true;
                                              isSigningOut = true;
                                            });

                                            syncAndSignOut(false, context, setDialogState);
                                          }
                                        },
                                         orientation==Orientation.portrait?   displayWidth(context) / 1.6:displayWidth(context) / 3,
                                       orientation==    Orientation.portrait?      displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                            primaryColor,
                                            Colors.white,
                                         orientation==    Orientation.portrait?      displayHeight(context) * 0.018:displayHeight(context) * 0.030,
                                            blueColor,
                                            '',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          ),
                                      child: Center(
                                        child: CommonButtons.getAcceptButton(
                                            'Sign Out', context,  Colors.transparent,
                                            () async {

if(!isSyncSignoutClicked){
                                          Navigator.of(context).pop();

                                          signOut();

}else{

}


                                              
                                        },
                                         orientation==Orientation.portrait?   displayWidth(context) / 1.6:displayWidth(context) / 3,
                                       orientation==    Orientation.portrait?      displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                            primaryColor,
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : blueColor,
                                         orientation==    Orientation.portrait?      displayHeight(context) * 0.015:displayHeight(context) * 0.028,
                                            Colors.transparent,
                                            '',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 0,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,),
                                child: Center(
                                  child: isUploadStarted
                                      ? SizedBox()
                                      : IconButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      icon:  Icon(Icons.close_rounded, color: buttonBGColor)),
                                ),
                              ),
                            )
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
        
    //     .then((value) {
    //   if(commonProvider.bottomNavIndex != 1){
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.portraitUp
    //     ]);
    //   }else{
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.landscapeLeft,
    //       DeviceOrientation.landscapeRight,
    //       DeviceOrientation.portraitDown,
    //       DeviceOrientation.portraitUp
    //     ]);
    //   }
    // });
  }

  ///To fetch data from cloud (Database)
  showDialogBoxToUploadData(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey, bool isChangePassword,Orientation orientation) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogBoxContext) {
          return OrientationBuilder(
            builder: (context,orientation) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Container(
                      height:orientation==Orientation.portrait? displayHeight(context) * 0.42:displayHeight(context) * 0.80,
                      width:orientation==Orientation.portrait? MediaQuery.of(context).size.width:MediaQuery.of(context).size.width/2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 5, bottom: 15),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: displayHeight(context) * 0.02,
                                ),
                                Center(
                                  child: Image.asset('assets/icons/export_img.png',
                                    //height: displayHeight(context) * 0.2,
                                    width:orientation==Orientation.portrait? displayWidth(context) * 0.18:displayWidth(context) * 0.10),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Column(
                                    children: [
                                      commonText(
                                          context: context,
                                          text:
                                          'There are some vessel & trips data not sync with cloud, do you want to proceed further?',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.038:displayWidth(context) * 0.018,
                                          textAlign: TextAlign.center,
                                          fontFamily: inter),
                                      SizedBox(
                                        height:orientation==Orientation.portrait? displayHeight(context) * 0.015:displayHeight(context) * 0.030,
                                      ),
                                      isChangePassword
                                          ? Padding(
                                            padding: EdgeInsets.only(
                                                left:orientation==Orientation.portrait? displayWidth(context) * 0.06:0,
                                            ),
                                            child: Center(
                                              child: commonText(
                                              context: context,
                                              text:
                                              'Click Upload & Change Password for not loosing local data which is not uploaded',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.grey,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.015,
                                              textAlign:orientation==Orientation.portrait? TextAlign.start:TextAlign.center),
                                            ),
                                          )
                                          : commonText(
                                          context: context,
                                          text:
                                          'Click Upload & Sync for not loosing local data which is not uploaded',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.012,
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: Center(
                                        child: isUploadStarted
                                            ? 
                                            Center(
                                          child: SizedBox(
                                              height:orientation==Orientation.portrait? displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                              child: Center(
                                                  child:
                                                  CircularProgressIndicator(
                                                    color: blueColor,
                                                  ))),
                                        )
                                            : CommonButtons.getAcceptButton(
                                            isChangePassword
                                                ? 'Upload & Change Password'
                                                : 'Upload & Sync',
                                            context,
                                            blueColor, () async {
                                          //  Navigator.of(context).pop();

                                          bool internet =
                                          await Utils().check(scaffoldKey);
                                          setState(() {
                                            isSync = true;
                                          });
                                          if (internet) {
                                            if (mounted) {
                                              setDialogState(() {
                                                isUploadStarted = true;
                                              });
                                            }
                                            syncAndSignOut(isChangePassword, context, setDialogState);
                                          }
                                        },
                                          orientation==    Orientation.portrait?   displayWidth(context) / 1.6:displayWidth(context) / 3,
                                       orientation==    Orientation.portrait?      displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                            primaryColor,
                                            Colors.white,
                                         orientation==    Orientation.portrait?      displayHeight(context) * 0.018:displayHeight(context) * 0.030,
                                            blueColor,
                                            '',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: CommonButtons.getAcceptButton(
                                            isChangePassword
                                                ? 'Skip & Change Password'
                                                : 'Skip & Sync', context, Colors.transparent,
                                                () {
                                              if(isChangePassword)
                                              {

                                                if(!isSync){
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ChangePassword(isChange: true,bottomNavIndex: widget.bottomNavIndex,)),
                                                );

                                              }else{

                                              }
                                              
                                              
                                              }else
                                              {
                                                if(!isUploadStarted){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                       SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex,)),
                                                );

                                                }
                                                else{

                                                }
                                              }

                                            },
                                          orientation==    Orientation.portrait?   displayWidth(context) / 1.6:displayWidth(context) / 3,
                                       orientation==    Orientation.portrait?      displayHeight(context) * 0.055:displayHeight(context) * 0.085,
                                            Colors.transparent,
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                                ? Colors.white
                                                : blueColor,
                                   orientation==    Orientation.portrait?         displayHeight(context) * 0.015:displayHeight(context) * 0.028,
                                            Colors.transparent,
                                            '',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 0,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,),
                                child: Center(
                                  child: isUploadStarted
                                      ? SizedBox()
                                      : IconButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      icon:  Icon(Icons.close_rounded, color: buttonBGColor)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          );
        }).then((value) {
      if(commonProvider.bottomNavIndex != 1){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp
        ]);
      }else{
        // SystemChrome.setPreferredOrientations([
        //   DeviceOrientation.landscapeLeft,
        //   DeviceOrientation.landscapeRight,
        //   DeviceOrientation.portraitDown,
        //   DeviceOrientation.portraitUp
        // ]);
      }
    });
  }

  /// If user have trip which is not uploaded then to sync data and sign out
  syncAndSignOut(bool isChangePassword, BuildContext context, StateSetter setDialogState) async {
    bool vesselErrorOccurred = false;
    bool tripErrorOccurred = false;

    var vesselsSyncDetails = await _databaseService.vesselsSyncDetails();
    var tripSyncDetails = await _databaseService.tripSyncDetails();

    getVesselFuture = await _databaseService.syncAndSignOutVesselList().catchError((onError) {
      setDialogState(() {
        isSigningOut = false;
        isUploadStarted = false;
     });
    });
    getTrip = await _databaseService.trips();

    Utils.customPrint("VESSEL SYNC TRIP ${getTrip.length}");
    Utils.customPrint("VESSEL SYNC TRIP $vesselsSyncDetails");
    Utils.customPrint("VESSEL SYNC TRIP $tripSyncDetails");

    CustomLogger().logWithFile(Level.info, "VESSEL SYNC TRIP ${getTrip.length}' -> $page");
    CustomLogger().logWithFile(Level.info, "VESSEL SYNC TRIP $vesselsSyncDetails' -> $page");
    CustomLogger().logWithFile(Level.info, "VESSEL SYNC TRIP $tripSyncDetails' -> $page");


    if (vesselsSyncDetails) {
      for (int i = 0; i < getVesselFuture.length; i++) {
        var vesselSyncOrNot = getVesselFuture[i].isSync;
        CustomLogger().logWithFile(Level.info, "VESSEL SYNC TRIP DISPLACEMENT  ${getVesselFuture[i].displacement}");
        Utils.customPrint(
            "VESSEL SUCCESS MESSAGE ${getVesselFuture[i].imageURLs}");
        CustomLogger().logWithFile(Level.info, "VESSEL SUCCESS MESSAGE ${getVesselFuture[i].imageURLs}' -> $page");

        if (vesselSyncOrNot == 0) {
          if (getVesselFuture[i].imageURLs != null &&
              getVesselFuture[i].imageURLs!.isNotEmpty) {
            if (getVesselFuture[i].imageURLs!.startsWith("https")) {
              getVesselFuture[i].selectedImages = [];
            } else {
              getVesselFuture[i].selectedImages = [
                File(getVesselFuture[i].imageURLs!)
              ];
            }

            Utils.customPrint(
                'VESSEL Data ${File(getVesselFuture[i].imageURLs!)}');
            CustomLogger().logWithFile(Level.info, "VESSEL Data ${File(getVesselFuture[i].imageURLs!)}' -> $page");
          } else {
            getVesselFuture[i].selectedImages = [];
          }

          await commonProvider
              .addVessel(
                  context,
                  getVesselFuture[i],
                  commonProvider.loginModel!.userId!,
                  commonProvider.loginModel!.token!,
                  scaffoldKey,
                  calledFromSignOut: true)
              .then((value) async {
            if (value!.status!) {
              await _databaseService.updateIsSyncStatus(
                  1, getVesselFuture[i].id.toString());
            } else {
              setState(() {
                vesselErrorOccurred = true;
              });
            }
          }).catchError((error) {
            Utils.customPrint("ADD VESSEL ERROR $error");
            CustomLogger().logWithFile(Level.error, "ADD VESSEL ERROR $error' -> $page");
            setState(() {
              vesselErrorOccurred = true;
            });
          });
        } else {
          Utils.customPrint("VESSEL DATA NOT Uploaded");
          CustomLogger().logWithFile(Level.error, "VESSEL DATA NOT Uploaded -> $page");
        }
      }

      Utils.customPrint("VESSEL DATA Uploaded");
      CustomLogger().logWithFile(Level.info, "VESSEL DATA Uploaded -> $page");
    }
    if (tripSyncDetails) {
      for (int i = 0; i < getTrip.length; i++) {
        var tripSyncOrNot = getTrip[i].isSync;

        AndroidDeviceInfo? androidDeviceInfo;
        IosDeviceInfo? iosDeviceInfo;
        if (Platform.isAndroid) {
          androidDeviceInfo = await deviceDetails.androidInfo;
        } else {
          iosDeviceInfo = await deviceDetails.iosInfo;
        }

        Directory tripDir = await getApplicationDocumentsDirectory();

        var sensorInfo = await Utils().getSensorObjectWithAvailability();

        if (tripSyncOrNot == 0) {
          var queryParameters;
          queryParameters = {
            "id": getTrip[i].id,
            "load": getTrip[i].currentLoad,
            "sensorInfo": sensorInfo['sensorInfo'],
            "deviceInfo": {
              "deviceId": Platform.isAndroid ? androidDeviceInfo!.id : '',
              "model": Platform.isAndroid
                  ? androidDeviceInfo!.model
                  : iosDeviceInfo!.model,
              "version": Platform.isAndroid
                  ? androidDeviceInfo!.version.release
                  : iosDeviceInfo!.utsname.release,
              "make": Platform.isAndroid
                  ? androidDeviceInfo!.manufacturer
                  : iosDeviceInfo?.utsname.machine,
              "board": Platform.isAndroid
                  ? androidDeviceInfo!.board
                  : iosDeviceInfo!.utsname.machine,
              "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
            },
            "startPosition": getTrip[i].startPosition!.split(','),
            "endPosition": getTrip[i].endPosition!.split(','),
            "number_of_passengers": getTrip[i].numberOfPassengers,
            /*json.decode(tripData.endPosition!.toString()).cast<String>().toList()*/
            "vesselId": getTrip[i].vesselId,
            "filePath": Platform.isAndroid
                ? '/data/user/0/com.performarine.app/app_flutter/${getTrip[i].id}.zip'
                : '${tripDir.path}/${getTrip[i].id}.zip',
            "createdAt": getTrip[i].createdAt,
            "updatedAt": getTrip[i].updatedAt,
            "duration": getTrip[i].time,
            "distance": double.parse(getTrip[i].distance!),
            "speed": double.parse(getTrip[i].speed!),
            "avgSpeed": double.parse(getTrip[i].avgSpeed!),
            //"userID": commonProvider.loginModel!.userId!
          };

    Utils.customPrint('QQQQQQ: $queryParameters');
          CustomLogger().logWithFile(Level.info, "QQQQQQ: $queryParameters -> $page");

          await commonProvider
              .sendSensorInfo(
                  context,
                  commonProvider.loginModel!.token,
                  File(Platform.isAndroid
                      ? '/data/user/0/com.performarine.app/app_flutter/${getTrip[i].id}.zip'
                      : '${tripDir.path}/${getTrip[i].id}.zip'),
                  queryParameters,
                  getTrip[i].id!,
                  scaffoldKey,
                  calledFromSignOut: true)
              .then((value) async {
            if (value!.status!) {
              Utils.customPrint("TRIP SUCCESS MESSAGE ${value.message}");
              CustomLogger().logWithFile(Level.info, "TRIP SUCCESS MESSAGE ${value.message}  -> $page");

              await _databaseService.updateTripIsSyncStatus(
                  1, getTrip[i].id.toString());
            } else {
              Utils.customPrint("TRIP MESSAGE ${value.message}");
              CustomLogger().logWithFile(Level.info, "TRIP MESSAGE ${value.message}  -> $page");
              setState(() {
                tripErrorOccurred = true;
              });
            }
          }).catchError((onError) {

            Utils.customPrint('DIOOOOOOOOOOOOO');
            CustomLogger().logWithFile(Level.error, "DIOoooooo -> $page");

            setState(() {
              tripErrorOccurred = true;
            });
          });
        }
      }
    }

    Navigator.of(context).pop();
   // Navigator.of(context).pop();

    if (!vesselErrorOccurred && !tripErrorOccurred) {
      if (isSync == true) {
        setState(() {
          isUploadStarted = false;
        });

        if(isChangePassword)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangePassword(isChange: true,bottomNavIndex: widget.bottomNavIndex,)),
            );
          }
        else
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  SyncDataCloudToMobileScreen(bottomNavIndex: widget.bottomNavIndex,)),
            );
          }

      } else {
        signOut();
      }
      Utils.customPrint("ERROR WHILE SYNC AND SIGN OUT IF SIGN OUTT");
      CustomLogger().logWithFile(Level.error, "ERROR WHILE SYNC AND SIGN OUT IF SIGN OUTT -> $page");
    } else {
      Utils.showSnackBar(context,
          scaffoldKey: widget.scaffoldKey,
          message: 'Failed to sync data to cloud. Please try again.');

      Utils.customPrint("ERROR WHILE SYNC AND SIGN OUT ELSE");
      CustomLogger().logWithFile(Level.error, "ERROR WHILE SYNC AND SIGN OUT ELSE-> $page");
    }
  }

  showEndTripDialogBox(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return 
          
          
          
          OrientationBuilder(
            builder: (context, orientation) {
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
                          mainAxisAlignment:orientation==Orientation.portrait? MainAxisAlignment.spaceBetween:MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:orientation==Orientation.portrait? CrossAxisAlignment.start:CrossAxisAlignment.center,
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
                                      'Please end the trip which is already running',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize:orientation==Orientation.portrait? displayWidth(context) * 0.04:displayWidth(context) * 0.02,
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
                                            CustomLogger().logWithFile(Level.info, "Click on go to trip 1-> $page");


                                            List<String>? tripData =
                                            sharedPreferences!.getStringList('trip_data');
                                            bool? runningTrip = sharedPreferences!.getBool("trip_started");

                                            String tripId = '', vesselName = '';
                                            if (tripData != null) {
                                              tripId = tripData[0];
                                              vesselName = tripData[1];
                                            }

                                            Utils.customPrint("Click on GO TO TRIP 2");
                                            CustomLogger().logWithFile(Level.info, "Click on go to trip 2-> $page");


                                            Navigator.of(dialogContext).pop();

                                            Navigator.push(
                                              dialogContext,
                                              MaterialPageRoute(builder: (context) => TripRecordingScreen(
                                                tripId: tripId,
                                                vesselId: tripData![1],
                                                tripIsRunningOrNot: runningTrip,)),
                                            );

                                            Utils.customPrint("Click on GO TO TRIP 3");
                                            CustomLogger().logWithFile(Level.info, "Click on go to trip 3-> $page");

                                          },
                                   orientation==Orientation.portrait?   displayWidth(context) * 0.65:displayWidth(context) * 0.25,
                                    orientation==Orientation.portrait?  displayHeight(context) * 0.054:displayHeight(context) * 0.090,
                                          primaryColor,
                                          Colors.white,
                               orientation==    Orientation.portrait?    displayHeight(context) * 0.02:displayHeight(context) * 0.03,
                                          blueColor,
                                          '',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Center(
                                    child: CommonButtons.getAcceptButton(
                                        'Cancel', context, Colors.transparent, () {
                                      Navigator.of(dialogContext).pop();
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
        }).then((value) {
      if(commonProvider.bottomNavIndex != 1){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp
        ]);
      }else{
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp
        ]);
      }
    });
  }
}
