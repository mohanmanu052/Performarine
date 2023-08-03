import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../models/device_model.dart';
import '../lpr_bluetooth_list.dart';
import '../trip_analytics.dart';


class StartTripRecordingScreen extends StatefulWidget {
  final bool? isLocationPermitted;
  final bool? isBluetoothConnected;
  const StartTripRecordingScreen({super.key, this.isLocationPermitted, this.isBluetoothConnected});

  @override
  State<StartTripRecordingScreen> createState() => _StartTripRecordingScreenState();
}

class _StartTripRecordingScreenState extends State<StartTripRecordingScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<VesselDropdownItem> vesselData = [];

  VesselDropdownItem? selectedValue;

  String selectedVesselWeight = 'Select Current Load', getTripId = '';

  int valueHolder = 1;

  bool? isGpsOn, isLPRConnected, isBleOn;
  bool addingDataToDB = false, isServiceRunning = false, isLocationDialogBoxOpen = false, isStartButton = false;

  final controller = ScreenshotController();

  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;

  late Future<List<CreateVessel>> vesselList;

  String? selectedVesselName, vesselId;

  Timer? notiTimer;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  DeviceInfo? deviceDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();

    getVesselAndTripsData();
  }

  @override
  Widget build(BuildContext context) {

    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: commonBackgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: commonBackgroundColor,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/icons/menu.png',
              ),
            ),
          ),
          title: Container(
            child: commonText(
              context: context,
              text: 'Start Trip Recording',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.045,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/images/home.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
            child: Column(
              children: [

                Container(
                  height: displayHeight(context) * 0.4,
                  width: displayWidth(context),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: FlutterMap(
                        options: MapOptions(
                         center: LatLng(56.704173, 11.543808),
                          minZoom: 12,
                          maxZoom: 14,
                          bounds: LatLngBounds(
                             LatLng(56.7378, 11.6644),
                             LatLng(56.6877, 11.5089),
                          ),
                        ),
                        children: [
                          TileLayer(
                            tileProvider: AssetTileProvider(),
                            maxZoom: 14,
                            urlTemplate: 'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: displayWidth(context),
                  height: displayHeight(context) * 0.75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    color: Color(0xffECF3F9)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonText(
                              context: context,
                              text: 'Pre Departure Checklist',
                              fontWeight: FontWeight.w600,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.04,
                            ),

                            SizedBox(height: displayHeight(context) * 0.01,),

                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<
                                  VesselDropdownItem>(
                                autovalidateMode: AutovalidateMode
                                    .onUserInteraction,
                                dropdownColor:
                                Theme.of(context).brightness ==
                                    Brightness.dark
                                    ? "Select Vessel" ==
                                    'User SubRole'
                                    ? Colors.white
                                    : Colors.transparent
                                    : Colors.white,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1.5, color: Colors.transparent),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1.5, color: Colors.transparent),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.red.shade300.withOpacity(0.7)),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  errorStyle: TextStyle(
                                      fontFamily: inter,
                                      fontSize: displayWidth(context) * 0.025),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.red.shade300.withOpacity(0.7)),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  fillColor: Color(0xffE6E9F0),
                                  filled: true,
                                  hintText: "Select your vessel",
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .brightness ==
                                          Brightness.dark
                                          ? "Select Vessel" ==
                                          'User SubRole'
                                          ? Colors.black54
                                          : Colors.white
                                          : Colors.black54,
                                      fontSize:
                                      displayWidth(context) *
                                          0.034,
                                      fontFamily: inter,
                                      fontWeight: FontWeight.w500),
                                ),
                                isExpanded: true,
                                isDense: true,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Select Vessel';
                                  }
                                  return null;
                                },
                                icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Theme.of(context)
                                        .brightness ==
                                        Brightness.dark
                                        ? "Select Vessel" ==
                                        'User SubRole'
                                        ? Colors.black
                                        : Colors.white
                                        : Colors.black),
                                value: selectedValue,
                                items: vesselData.map((item) {
                                  return DropdownMenuItem<
                                      VesselDropdownItem>(
                                    value: item,
                                    child: Text(
                                      item.name!,
                                      style: TextStyle(
                                          fontSize: displayWidth(
                                              context) *
                                              0.0346,
                                          color: Theme.of(context)
                                              .brightness ==
                                              Brightness.dark
                                              ? "Select Vessel" ==
                                              'User SubRole'
                                              ? Colors.black
                                              : Colors.white
                                              : Colors.black,
                                          fontWeight:
                                          FontWeight.w500),
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (item) {
                                  Utils.customPrint("id is: ${item?.id} ");
                                  CustomLogger().logWithFile(Level.info, "id is: ${item?.id}-> $page");

                                  selectedValue = item;
                                  vesselId = item!.id;
                                  selectedVesselName = item.name;

                                },
                              ),
                            ),

                            SizedBox(height: displayHeight(context) * 0.02,),

                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<dynamic>(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1.5, color: Colors.transparent),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1.5, color: Colors.transparent),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.red.shade300.withOpacity(0.7)),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  errorStyle: TextStyle(
                                      fontFamily: inter,
                                      fontSize: displayWidth(context) * 0.025),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.red.shade300.withOpacity(0.7)),
                                      borderRadius: BorderRadius.all(Radius.circular(8))),
                                  fillColor: Color(0xffE6E9F0),
                                  filled: true,
                                ),
                                value: null,
                                isDense: true,
                                icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Theme.of(context)
                                        .brightness ==
                                        Brightness.dark
                                        ? "Select Vessel" ==
                                        'User SubRole'
                                        ? Colors.black
                                        : Colors.white
                                        : Colors.black),
                                hint: commonText(
                                    context: context,
                                    text:
                                    selectedVesselWeight,
                                    fontWeight:
                                    FontWeight.w500,
                                    textColor: Colors.black54,
                                    textSize: displayWidth(
                                        context) *
                                        0.032,
                                    textAlign:
                                    TextAlign.start),
                                //  Text(
                                //     '${selectedVesselWeight}'),
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                      value: '1',
                                      child: Text('Empty')),
                                  DropdownMenuItem(
                                      value: '2',
                                      child: Text('Half')),
                                  DropdownMenuItem(
                                      value: '3',
                                      child: Text('Full')),
                                  DropdownMenuItem(
                                      value: '4',
                                      child:
                                      Text('Variable')),
                                ],
                                onChanged: (weightValue) {
                                  setState(() {
                                    if (int.parse(
                                        weightValue) ==
                                        1) {
                                      selectedVesselWeight =
                                      'Empty';
                                    } else if (int.parse(
                                        weightValue) ==
                                        2) {
                                      selectedVesselWeight =
                                      'Half';
                                    } else if (int.parse(
                                        weightValue) ==
                                        3) {
                                      selectedVesselWeight =
                                      'Full';
                                    } else {
                                      selectedVesselWeight =
                                      'Variable';
                                    }
                                  });
                                },
                              ),
                            ),

                            SizedBox(height: displayHeight(context) * 0.03,),

                            commonText(
                              context: context,
                              text: 'Number of Passengers',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.038,
                            ),

                            Slider(
                                value: valueHolder.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 10,
                                activeColor: Color(0xff2663DB),
                                inactiveColor: Colors.grey,
                                label: '${valueHolder.round()}',
                                onChanged: (double newValue) {
                                  setState(() {
                                    valueHolder = newValue.round();
                                  });
                                },
                                semanticFormatterCallback: (double newValue) {
                                  return '${newValue.round()}';
                                }
                            ),

                            SizedBox(height: displayHeight(context) * 0.03,),

                            commonText(
                              context: context,
                              text: 'Sensor Information',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.038,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset('assets/icons/location.png',
                                            height: displayHeight(context) * 0.04,
                                            width: displayWidth(context) * 0.07,),

                                          SizedBox(width: displayWidth(context) * 0.04,),

                                          commonText(
                                            context: context,
                                            text: 'GPS Signal',
                                            fontWeight: FontWeight.w400,
                                            textColor: Colors.black45,
                                            textSize: displayWidth(context) * 0.036,
                                          ),
                                        ],
                                      ),
                                      commonText(
                                        context: context,
                                        text: widget.isLocationPermitted! ? 'OK' : 'No Connected',
                                        fontWeight: FontWeight.w500,
                                        textColor: widget.isLocationPermitted! ? Colors.green : Colors.grey,
                                        textSize: displayWidth(context) * 0.03,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: displayHeight(context) * 0.007,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset('assets/icons/lpr.png',
                                            height: displayHeight(context) * 0.04,
                                            width: displayWidth(context) * 0.07,),

                                          SizedBox(width: displayWidth(context) * 0.04,),

                                          commonText(
                                            context: context,
                                            text: 'LPR',
                                            fontWeight: FontWeight.w400,
                                            textColor: Colors.black45,
                                            textSize: displayWidth(context) * 0.036,
                                          ),
                                        ],
                                      ),

                                      commonText(
                                        context: context,
                                        text: widget.isBluetoothConnected! ? 'Connected' : 'Disconnected',
                                        fontWeight: FontWeight.w500,
                                        textColor: widget.isBluetoothConnected! ? Colors.green : Colors.red,
                                        textSize: displayWidth(context) * 0.03,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: displayHeight(context) * 0.007,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset('assets/icons/ble.png',
                                            height: displayHeight(context) * 0.04,
                                            width: displayWidth(context) * 0.06,),

                                          SizedBox(width: displayWidth(context) * 0.04,),

                                          commonText(
                                            context: context,
                                            text: 'Wireless NMEA',
                                            fontWeight: FontWeight.w400,
                                            textColor: Colors.black45,
                                            textSize: displayWidth(context) * 0.036,
                                          ),
                                        ],
                                      ),

                                      commonText(
                                        context: context,
                                        text: 'Not Configured',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.amber,
                                        textSize: displayWidth(context) * 0.03,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: displayHeight(context) * 0.03,),

                            addingDataToDB
                                ? Center(
                                child: CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        circularProgressColor)))
                                : InkWell(
                              onTap: ()async
                              {
                                Utils.customPrint(
                                    'SELECTED VESSEL WEIGHT $selectedVesselWeight');
                                if (selectedVesselWeight ==
                                    'Select Current Load') {
                                  Utils.customPrint(
                                      'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    behavior:
                                    SnackBarBehavior.floating,
                                    content: Text(
                                        "Please select current load"),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.blue,
                                  ));
                                  return;
                                }

                                if (selectedValue ==
                                    null) {
                                  Utils.customPrint(
                                      'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    behavior:
                                    SnackBarBehavior.floating,
                                    content: Text(
                                        "Please select vessel"),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.blue,
                                  ));
                                  return;
                                }

                                bool isLocationPermitted =
                                await Permission
                                    .location.isGranted;

                                if (isLocationPermitted) {

                                  if (Platform.isAndroid) {
                                    final androidInfo =
                                    await DeviceInfoPlugin()
                                        .androidInfo;

                                    if (androidInfo.version.sdkInt <
                                        29) {
                                      var isStoragePermitted =
                                      await Permission
                                          .storage.status;
                                      if (isStoragePermitted
                                          .isGranted) {
                                        bool
                                        isNotificationPermitted =
                                        await Permission
                                            .notification
                                            .isGranted;

                                        if (isNotificationPermitted) {
                                          startWritingDataToDB(
                                              context);
                                        } else {
                                          await Utils
                                              .getNotificationPermission(
                                              context);
                                          bool
                                          isNotificationPermitted =
                                          await Permission
                                              .notification
                                              .isGranted;
                                          if (isNotificationPermitted) {
                                            startWritingDataToDB(
                                                context);
                                          }
                                        }
                                      } else {
                                        await Utils
                                            .getStoragePermission(
                                            context);
                                        final androidInfo =
                                        await DeviceInfoPlugin()
                                            .androidInfo;

                                        var isStoragePermitted =
                                        await Permission
                                            .storage.status;

                                        if (isStoragePermitted
                                            .isGranted) {
                                          bool
                                          isNotificationPermitted =
                                          await Permission
                                              .notification
                                              .isGranted;

                                          if (isNotificationPermitted) {
                                            startWritingDataToDB(
                                                context);
                                          } else {
                                            await Utils
                                                .getNotificationPermission(
                                                context);
                                            bool
                                            isNotificationPermitted =
                                            await Permission
                                                .notification
                                                .isGranted;
                                            if (isNotificationPermitted) {
                                              startWritingDataToDB(
                                                  context);
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      bool isNotificationPermitted =
                                      await Permission
                                          .notification
                                          .isGranted;

                                      if (isNotificationPermitted) {
                                        startWritingDataToDB(
                                            context);
                                      } else {
                                        await Utils
                                            .getNotificationPermission(
                                            context);
                                        bool
                                        isNotificationPermitted =
                                        await Permission
                                            .notification
                                            .isGranted;
                                        if (isNotificationPermitted) {
                                          startWritingDataToDB(
                                              context);
                                        }
                                      }
                                    }
                                  }
                                  else {
                                    bool isNotificationPermitted =
                                    await Permission
                                        .notification.isGranted;

                                    if (isNotificationPermitted) {
                                      startWritingDataToDB(
                                          context);
                                    } else {
                                      await Utils
                                          .getNotificationPermission(
                                          context);
                                      bool isNotificationPermitted =
                                      await Permission
                                          .notification
                                          .isGranted;
                                      if (isNotificationPermitted) {
                                        startWritingDataToDB(
                                            context);
                                      }
                                    }
                                  }
                                }
                                else {
                                  await Utils.getLocationPermission(
                                      context, scaffoldKey);
                                  bool isLocationPermitted =
                                  await Permission
                                      .location.isGranted;

                                  if (isLocationPermitted) {
                                    // service.startService();

                                    if (Platform.isAndroid) {
                                      final androidInfo =
                                      await DeviceInfoPlugin()
                                          .androidInfo;

                                      if (androidInfo
                                          .version.sdkInt <
                                          29) {
                                        var isStoragePermitted =
                                        await Permission
                                            .storage.status;
                                        if (isStoragePermitted
                                            .isGranted) {
                                          bool
                                          isNotificationPermitted =
                                          await Permission
                                              .notification
                                              .isGranted;

                                          if (isNotificationPermitted) {
                                            startWritingDataToDB(
                                                context);
                                          } else {
                                            await Utils
                                                .getNotificationPermission(
                                                context);
                                            bool
                                            isNotificationPermitted =
                                            await Permission
                                                .notification
                                                .isGranted;
                                            if (isNotificationPermitted) {
                                              startWritingDataToDB(
                                                  context);
                                            }
                                          }
                                        } else {
                                          await Utils
                                              .getStoragePermission(
                                              context);
                                          final androidInfo =
                                          await DeviceInfoPlugin()
                                              .androidInfo;

                                          var isStoragePermitted =
                                          await Permission
                                              .storage.status;

                                          if (isStoragePermitted
                                              .isGranted) {
                                            bool
                                            isNotificationPermitted =
                                            await Permission
                                                .notification
                                                .isGranted;

                                            if (isNotificationPermitted) {
                                              startWritingDataToDB(
                                                  context);
                                            } else {
                                              await Utils
                                                  .getNotificationPermission(
                                                  context);
                                              bool
                                              isNotificationPermitted =
                                              await Permission
                                                  .notification
                                                  .isGranted;
                                              if (isNotificationPermitted) {
                                                startWritingDataToDB(
                                                    context);
                                              }
                                            }
                                          }
                                        }
                                      } else {
                                        bool
                                        isNotificationPermitted =
                                        await Permission
                                            .notification
                                            .isGranted;

                                        if (isNotificationPermitted) {
                                          startWritingDataToDB(
                                              context);
                                        } else {
                                          await Utils
                                              .getNotificationPermission(
                                              context);
                                          bool
                                          isNotificationPermitted =
                                          await Permission
                                              .notification
                                              .isGranted;
                                          if (isNotificationPermitted) {
                                            startWritingDataToDB(
                                                context);
                                          }
                                        }
                                      }
                                    } else {
                                      bool isNotificationPermitted =
                                      await Permission
                                          .notification
                                          .isGranted;

                                      if (isNotificationPermitted) {
                                        startWritingDataToDB(
                                            context);
                                      } else {
                                        await Utils
                                            .getNotificationPermission(
                                            context);
                                        bool
                                        isNotificationPermitted =
                                        await Permission
                                            .notification
                                            .isGranted;
                                        if (isNotificationPermitted) {
                                          startWritingDataToDB(
                                            context,);
                                        }
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xff2663DB)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/icons/start_btn.png',
                                        height: displayHeight(context) * 0.055,
                                        width: displayWidth(context) * 0.12,
                                      ),
                                      SizedBox(width: displayWidth(context) * 0.01,),
                                      commonText(
                                        context: context,
                                        text: 'Start Trip',
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.white,
                                        textSize: displayWidth(context) * 0.042,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top : displayWidth(context) * 0.01,
                              bottom : displayWidth(context) * 0.01,
                            ),
                            child: GestureDetector(
                                onTap: ()async{
                                  final image = await controller.capture();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                                    imagePath: image.toString(),
                                    uIntList: image,)));
                                },
                                child: UserFeedback().getUserFeedback(context)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  //To get all vessels
  getVesselAndTripsData() async {
    try {
      bool check = await Utils().check(scaffoldKey);
      if (check) {
        commonProvider
            .getUserConfigData(context, commonProvider.loginModel!.userId!,
            commonProvider.loginModel!.token!, scaffoldKey)
            .then((value) {

          Utils.customPrint("value is: ${value!.status}");
          CustomLogger().logWithFile(Level.info, "value is: ${value.status} -> $page");

          if (value != null) {
            Utils.customPrint("value 1 is: ${value.status}");

            Utils.customPrint("value of get user config by id: ${value.vessels}");
            CustomLogger().logWithFile(Level.info, "value of get user config by id: ${value.vessels} -> $page");

            vesselData = List<VesselDropdownItem>.from(value.vessels!.map(
                    (vessel) => VesselDropdownItem(id: vessel.id, name: vessel.name)));

            Utils.customPrint("vesselData: ${vesselData.length}");
            CustomLogger().logWithFile(Level.info, "vesselData: ${vesselData.length} -> $page");

          } else {
          }
        }).catchError((e) {
        });
      } else {

      }
    } catch (e) {


      Utils.customPrint("Error while fetching data from getUserConfigById: $e");
      CustomLogger().logWithFile(Level.error, "Error while fetching data from getUserConfigById: $e -> $page");

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

  /// To enable Bluetooth
  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) async {
      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
       /* vessel!.add(widget.vessel!);
        await locationPermissions(widget.vessel!.vesselSize!,
            widget.vessel!.name!, widget.vessel!.id!);*/
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

  /// It will save data to local database when trip is start
  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = selectedVesselName;
    final currentLoad = selectedVesselWeight;

    ReceivePort port = ReceivePort();
    String? latitude, longitude;
    port.listen((dynamic data) async {
      LocationDto? locationDto =
      data != null ? LocationDto.fromJson(data) : null;
      if (locationDto != null) {
        latitude = locationDto.latitude.toString();
        longitude = locationDto.longitude.toString();
      }
      ;
    });
    await fetchDeviceData();

    try {
      await _databaseService.insertTrip(Trip(
          id: getTripId,
          vesselId: vesselId,
          vesselName: selectedVesselName,
          currentLoad: currentLoad,
          filePath: file,
          isSync: 0,
          tripStatus: 0,
          createdAt: Utils.getCurrentTZDateTime(),
          updatedAt: Utils.getCurrentTZDateTime(),
          startPosition: [latitude, longitude].join(","),
          endPosition: [latitude, longitude].join(","),
          deviceInfo: deviceDetails!.toJson().toString()));
    } on Exception catch (e) {
      Utils.customPrint('ON SAVE EXE: $e');
    }
    return;
  }

  /// It will start trip and called startBGLocatorTrip function from StartTrip.dart file
  startWritingDataToDB(
      BuildContext bottomSheetContext) async {
    Utils.customPrint('ISSSSS XXXXXXX: $isServiceRunning');

    setState(() {
      addingDataToDB = true;
    });

    getTripId = ObjectId().toString();

    flutterLocalNotificationsPlugin
        .show(
      776,
      '',
      'Trip is in progress',
      NotificationDetails(
          android: AndroidNotificationDetails(
              'performarine_trip_$getTripId', '$getTripId',
              channelDescription: 'Description',
              importance: Importance.max,
              priority: Priority.high),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            subtitle: '',
          )),
    )
        .catchError((onError) {
      Utils.customPrint('IOS NOTI ERROR: $onError');
    });


    await onSave('', bottomSheetContext, true);

    if(sharedPreferences == null){
      sharedPreferences = await SharedPreferences.getInstance();
    }

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data', [
      getTripId,
      vesselId!,
      selectedVesselName!,
      selectedVesselWeight
    ]);

    await initPlatformStateBGL();

   //await tripIsRunningOrNot();

    addingDataToDB = false;
    isStartButton = false;

    bool? runningTrip = sharedPreferences!.getBool("trip_started");

    if (runningTrip!) {
      List<String>? tripData = sharedPreferences!.getStringList('trip_data');
      final tripDetails = await _databaseService.getTrip(tripData![0]);

      var result = Navigator.pushReplacement(
        scaffoldKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => TripRecordingScreen(
              tripId: tripDetails.id,
                vesselId: tripData[1],
                tripIsRunningOrNot: runningTrip
            )),
      );

      if (result != null) {
        Utils.customPrint('VESSEL SINGLE VIEW RESULT $result');
      }
    }
    return;
  }

  /// It will initialize background_locator_2
  Future<void> initPlatformStateBGL() async {
    Utils.customPrint('Initializing...');
    await BackgroundLocator.initialize();
    Utils.customPrint('Initialization done');

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
                notificationTitle: '',
                notificationMsg: 'Trip is in progress',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)))
        .then((value) async {
      StartTrip().startBGLocatorTrip(getTripId, DateTime.now());

      notiTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
        var activeNotifications = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

        if (activeNotifications != null && activeNotifications.isNotEmpty) {
          if (activeNotifications[0].channelId == 'app.yukams/locator_plugin' || activeNotifications[0].channelId == 'performarine_trip_$getTripId-3') {
            Utils.customPrint("CHANNEL ID MATCH");
            Utils.customPrint("CHANNEL ID MATCH: ${activeNotifications[0].id}");

            await flutterLocalNotificationsPlugin.cancel(776);

            if (notiTimer != null) {
              notiTimer!.cancel();
            }
          }
        }
      });
    });
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
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
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
                                      'Go to trip', context, buttonBGColor,
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
                                      displayHeight(context) * 0.015,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Ok go back', context, buttonBGColor, () {
                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey,
                                      displayHeight(context) * 0.015,
                                      Colors.white,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
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

  /// To get device details
  fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo;
    }
  }

  /// To fetch device data
  fetchDeviceData() async {
    await fetchDeviceInfo();

    deviceDetails = Platform.isAndroid
        ? DeviceInfo(
        board: androidDeviceInfo?.board,
        deviceId: androidDeviceInfo?.id,
        deviceType: androidDeviceInfo?.type,
        make: androidDeviceInfo?.manufacturer,
        model: androidDeviceInfo?.model,
        version: androidDeviceInfo?.version.release)
        : DeviceInfo(
        board: iosDeviceInfo?.utsname.machine,
        deviceId: '',
        deviceType: iosDeviceInfo?.utsname.machine,
        make: iosDeviceInfo?.utsname.machine,
        model: iosDeviceInfo?.model,
        version: iosDeviceInfo?.utsname.release);
    Utils.customPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }


  /*showBluetoothListDialog(BuildContext context, StateSetter stateSetter) {
    stateSetter(() {
      progress = 0.9;
      lprSensorProgress = 0.0;
      isStartButton = false;
    });

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
                  height: displayHeight(context) * 0.5,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          "Available Devices",
                          style: TextStyle(
                              color: blutoothDialogTitleColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Tap to connect with LPR Devices to\n track Trip details",
                          style: TextStyle(
                              color: blutoothDialogTxtColor,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Implement listView for bluetooth devices
                      Expanded(
                        child: isRefreshList == true
                            ? Container(
                            width: displayWidth(context),
                            height: displayHeight(context) * 0.28,
                            child: LPRBluetoothList(
                              dialogContext: dialogContext,
                              setDialogSet: setDialogState,
                              onSelected: (value) {
                                if (mounted) {
                                  stateSetter(() {
                                    bluetoothName = value;
                                  });
                                }
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  stateSetter(() {
                                    isBluetoothConnected = value;
                                  });
                                }
                              },
                            ))
                            : Container(
                            width: displayWidth(context),
                            height: displayHeight(context) * 0.28,
                            child: LPRBluetoothList(
                              dialogContext: dialogContext,
                              setDialogSet: setDialogState,
                              onSelected: (value) {
                                if (mounted) {
                                  stateSetter(() {
                                    bluetoothName = value;
                                  });
                                }
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  stateSetter(() {
                                    isBluetoothConnected = value;
                                  });
                                }
                              },
                            )),
                      ),

                      Container(
                        width: displayWidth(context),
                        margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // FlutterBluePlus.instance.

                                Navigator.pop(context);
                                stateSetter(() {
                                  progress = 0.9;
                                  lprSensorProgress = 0.0;
                                  isStartButton = true;
                                  bluetoothName = '';
                                });
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
                              onTap: () {
                                Utils.customPrint("Tapped on scan button");

                                if (mounted) {
                                  setDialogState(() {
                                    isScanningBluetooth = true;
                                  });
                                }

                                FlutterBluePlus.instance.startScan(
                                    timeout: const Duration(seconds: 2));

                                if (mounted) {
                                  Future.delayed(Duration(seconds: 2), () {
                                    setDialogState(() {
                                      isScanningBluetooth = false;
                                    });
                                  });
                                }

                                if (mounted) {
                                  stateSetter(() {
                                    isRefreshList = true;
                                    progress = 0.9;
                                    lprSensorProgress = 0.0;
                                    isStartButton = false;
                                    bluetoothName = '';
                                  });
                                }
                              },
                              child: isScanningBluetooth
                                  ? Center(
                                child: Container(
                                    width: displayWidth(context) * 0.34,
                                    child: Center(
                                        child:
                                        CircularProgressIndicator())),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                  color: bluetoothConnectBtnBackColor,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                height: displayWidth(context) * 0.12,
                                width: displayWidth(context) * 0.34,
                                // color: HexColor(AppColors.introButtonColor),
                                child: Center(
                                  child: Text(
                                    "Scan",
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
              }));
        }).then((value) {
      Utils.customPrint('DIALOG VALUE $value');

      if (bluetoothName != '') {
        stateSetter(() {
          progress = 1.0;
          lprSensorProgress = 1.0;
          isStartButton = true;
          isBluetoothConnected = true;
        });
      } else {
        stateSetter(() {
          isBluetoothConnected = false;
        });
      }
    });
  }*/
}

class VesselDropdownItem {
  final String? id;
  final String? name;

  VesselDropdownItem({this.id, this.name});
}
