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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:geolocator/geolocator.dart' as geo;
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
import 'package:performarine/models/get_user_config_model.dart' as vs;
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/custom_drawer.dart';
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
import '../bottom_navigation.dart';
import '../lpr_bluetooth_list.dart';
import '../trip_analytics.dart';

class StartTripRecordingScreen extends StatefulWidget {
  //final bool? isLocationPermitted;
  //final bool? isBluetoothConnected;
  final String calledFrom;
  const StartTripRecordingScreen(
      {super.key,
        /*this.isLocationPermitted = false, this.isBluetoothConnected = false,*/ this.calledFrom =
      ''});

  @override
  State<StartTripRecordingScreen> createState() =>
      _StartTripRecordingScreenState();
}

class _StartTripRecordingScreenState extends State<StartTripRecordingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<VesselDropdownItem> vesselData = [];

  VesselDropdownItem? selectedValue;

  String selectedVesselWeight = 'Select Current Load',
      getTripId = '',
      bluetoothName = '';

  int valueHolder = 1, numberOfPassengers = 0, passengerValue = 0;

  bool? isGpsOn, isLPRConnected, isBleOn;
  bool addingDataToDB = false,
      isServiceRunning = false,
      isLocationDialogBoxOpen = false,
      isStartButton = false,
      isVesselDataLoading = false,
      isBluetoothPermitted = false,
      isLocationPermitted = false,
      isRefreshList = false,
      isScanningBluetooth = false,
      isSliderDisable = false,
      isCheck = false;

  final controller = ScreenshotController();

  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;

  String? selectedVesselName, vesselId, sliderCount = '10+';

  Timer? notiTimer;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  DeviceInfo? deviceDetails;
  late Future<List<CreateVessel>> vesselList;

  double progress = 0.9, lprSensorProgress = 1.0, sliderMinVal = 11;

  late AnimationController popupAnimationController;
  late TextEditingController textEditingController;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    //checkAllPermission(false);

    commonProvider = context.read<CommonProvider>();
    getVesselAndTripsData();

    checkTempPermissions();
    textEditingController = TextEditingController();

    popupAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        textEditingController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textEditingController.value.text.length);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    popupAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        checkTempPermissions();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: commonText(
              context: context,
              text: 'Start Trip Recording',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.045,
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavigation()),
                        ModalRoute.withName(""));
                  },
                  icon:
                  Image.asset('assets/icons/performarine_appbar_icon.png'),
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
                              urlTemplate:
                              'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isVesselDataLoading
                      ? Container(
                    height: displayHeight(context) * 0.1,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            circularProgressColor),
                      ),
                    ),
                  )
                      : Container(
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xffECF3F9)),
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
                                textSize: displayWidth(context) * 0.038,
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.008,
                              ),
                              DropdownButtonHideUnderline(
                                child:
                                DropdownButton2<VesselDropdownItem>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Vessel',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .brightness ==
                                            Brightness.dark
                                            ? "Select Vessel" ==
                                            'User SubRole'
                                            ? Colors.black54
                                            : Colors.white
                                            : Colors.black54,
                                        fontSize:
                                        displayWidth(context) * 0.032,
                                        fontFamily: outfit,
                                        fontWeight: FontWeight.w400),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: selectedValue,
                                  items: vesselData.map((item) {
                                    return DropdownMenuItem<
                                        VesselDropdownItem>(
                                      value: item,
                                      child: Text(
                                        item.name!,
                                        style: TextStyle(
                                            fontSize:
                                            displayWidth(context) *
                                                0.032,
                                            color: Theme.of(context)
                                                .brightness ==
                                                Brightness.dark
                                                ? "Select Vessel" ==
                                                'User SubRole'
                                                ? Colors.black
                                                : Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (item) {
                                    Utils.customPrint(
                                        "id is: ${item?.id} ");
                                    CustomLogger().logWithFile(Level.info,
                                        "id is: ${item?.id}-> $page");
                                    setState(() {
                                      selectedValue = item;
                                      vesselId = item!.id;
                                      selectedVesselName = item.name;
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: displayHeight(context) * 0.06,
                                    width: displayWidth(context) * 0.9,
                                    padding: EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                      color: Color(0xffE6E9F0),
                                    ),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                    iconSize:
                                    displayHeight(context) * 0.03,
                                    iconEnabledColor: Colors.black,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight:
                                    displayHeight(context) * 0.25,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      // color: backgroundColor,
                                    ),
                                    offset: const Offset(0, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(20),
                                      thickness: MaterialStateProperty
                                          .all<double>(6),
                                      thumbVisibility:
                                      MaterialStateProperty.all<bool>(
                                          true),
                                    ),
                                  ),
                                  menuItemStyleData:
                                  const MenuItemStyleData(
                                    padding: EdgeInsets.only(
                                        left: 14, right: 14),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                              commonText(
                                context: context,
                                text: 'Number of Passengers',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.034,
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.008,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Container(
                                          height: displayHeight(context) *
                                              0.06,
                                          width: !isSliderDisable
                                              ? displayWidth(context) *
                                              0.8
                                              : displayWidth(context) *
                                              0.5,
                                          child: FlutterSlider(
                                            values: [
                                              numberOfPassengers
                                                  .toDouble()
                                            ],
                                            max: sliderMinVal,
                                            min: 0,
                                            trackBar: FlutterSliderTrackBar(
                                                activeTrackBarHeight: 4.5,
                                                inactiveTrackBarHeight:
                                                4.5,
                                                activeTrackBar:
                                                BoxDecoration(
                                                    color: Color(
                                                        0xff2663DB))),
                                            tooltip: FlutterSliderTooltip(
                                                custom: (value) {
                                                  debugPrint("NUMBER OF PASS 1 $value");
                                                  String data = value.toInt().toString();
                                                  numberOfPassengers = value.toInt();

                                                  return Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical:
                                                        displayHeight(
                                                            context) *
                                                            0.02),
                                                    child: commonText(
                                                      context: context,
                                                      text:
                                                      numberOfPassengers ==
                                                          0
                                                          ? ''
                                                          : '$data',
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      textColor:
                                                      Colors.black,
                                                      textSize:
                                                      displayWidth(
                                                          context) *
                                                          0.028,
                                                    ),
                                                  );
                                                },
                                                alwaysShowTooltip: true,
                                                positionOffset:
                                                FlutterSliderTooltipPositionOffset(
                                                    top: -15)),
                                            handlerWidth: 15,
                                            handlerHeight: 15,
                                            onDragging: (int value,dynamic val,dynamic val1){
                                             val != 11 ? passengerValue = val.toInt() : val;
                                              print("On dragging: value: $value, val: $val, val1: $val1");
                                              if(val == 11 && sliderMinVal == 11){
                                                if(mounted){

                                                  setState(() {
                                                    isCheck = true;
                                                    isSliderDisable =
                                                    true;
                                                    popupAnimationController
                                                        .forward()
                                                        .then((value) =>
                                                        _focusNode
                                                            .requestFocus());
                                                  });
                                                }
                                              }
                                            },
                                            handler: FlutterSliderHandler(
                                                child: Container(
                                                  height: 15,
                                                  width: 15,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                      Color(0xff2663DB)),
                                                )),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: isSliderDisable
                                            ? displayWidth(context) * 0.5
                                            : displayWidth(context) * 0.8,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 5),
                                              child: commonText(
                                                context: context,
                                                text: '0',
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.028,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 0),
                                              child: commonText(
                                                context: context,
                                                text: sliderCount,
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.028,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  isSliderDisable
                                      ? textFieldPopUp()
                                      : Container(
                                    width: 0,
                                    height: 0,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.02,
                              ),
                              Container(
                                margin:
                                EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    commonText(
                                      context: context,
                                      text: 'Sensor Information',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize:
                                      displayWidth(context) * 0.034,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0, top: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/location.png',
                                                    height: displayHeight(
                                                        context) *
                                                        0.04,
                                                    width: displayWidth(
                                                        context) *
                                                        0.07,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(
                                                        context) *
                                                        0.04,
                                                  ),
                                                  commonText(
                                                    context: context,
                                                    text: 'GPS Signal',
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    textColor:
                                                    Colors.black45,
                                                    textSize:
                                                    displayWidth(
                                                        context) *
                                                        0.034,
                                                  ),
                                                ],
                                              ),
                                              commonText(
                                                context: context,
                                                text: isLocationPermitted
                                                    ? 'OK'
                                                    : 'No Connected',
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor:
                                                isLocationPermitted
                                                    ? Colors.green
                                                    : Colors.grey,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.03,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                            displayHeight(context) *
                                                0.007,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/lpr.png',
                                                    height: displayHeight(
                                                        context) *
                                                        0.04,
                                                    width: displayWidth(
                                                        context) *
                                                        0.07,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(
                                                        context) *
                                                        0.04,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      bool
                                                      isNDPermittedOne =
                                                      await Permission
                                                          .bluetoothConnect
                                                          .isGranted;

                                                      if (isNDPermittedOne) {
                                                        dynamic isBluetoothEnable = Platform
                                                            .isAndroid
                                                            ? await blueIsOn()
                                                            : await commonProvider
                                                            .checkIfBluetoothIsEnabled(
                                                            scaffoldKey,
                                                                () {
                                                              showBluetoothDialog(
                                                                  context);
                                                            });

                                                        if (isBluetoothEnable) {
                                                          showBluetoothListDialog(
                                                              context);
                                                        }
                                                        else{
                                                          Utils.showSnackBar(context, scaffoldKey: scaffoldKey, message: 'Bluetooth is disabled. Please enable.');
                                                        }
                                                      }
                                                      else{
                                                        Utils.showSnackBar(context, scaffoldKey: scaffoldKey, message: 'Bluetooth permission is needed.');
                                                      }
                                                    },
                                                    child: commonText(
                                                      context: context,
                                                      text: 'LPR',
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      textColor:
                                                      Colors.black45,
                                                      textSize:
                                                      displayWidth(
                                                          context) *
                                                          0.034,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              commonText(
                                                context: context,
                                                text: isBluetoothPermitted
                                                    ? 'Connected'
                                                    : 'Disconnected',
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor:
                                                isBluetoothPermitted
                                                    ? Colors.green
                                                    : Colors.red,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.03,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                            displayHeight(context) *
                                                0.007,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/ble.png',
                                                    height: displayHeight(
                                                        context) *
                                                        0.04,
                                                    width: displayWidth(
                                                        context) *
                                                        0.06,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(
                                                        context) *
                                                        0.04,
                                                  ),
                                                  commonText(
                                                    context: context,
                                                    text: 'Wireless NMEA',
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    textColor:
                                                    Colors.black45,
                                                    textSize:
                                                    displayWidth(
                                                        context) *
                                                        0.034,
                                                  ),
                                                ],
                                              ),
                                              commonText(
                                                context: context,
                                                text: 'Not Configured',
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor: Colors.amber,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.03,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.03,
                              ),
                              addingDataToDB
                                  ? Center(
                                  child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                          circularProgressColor)))
                                  : Container(
                                child: CommonButtons
                                    .getRichTextActionButton(
                                  icon: Image.asset(
                                    'assets/icons/start_btn.png',
                                    height: displayHeight(context) *
                                        0.055,
                                    width: displayWidth(context) *
                                        0.12,
                                  ),
                                  title: 'Start Trip',
                                  context: context,
                                  fontSize:
                                  displayWidth(context) * 0.042,
                                  textColor: Colors.white,
                                  buttonPrimaryColor: blueColor,
                                  borderColor: blueColor,
                                  width: displayWidth(context),
                                  onTap: () async {
                                    if (selectedValue == null) {
                                      Utils.customPrint(
                                          'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior
                                            .floating,
                                        content: Text(
                                            "Please select vessel"),
                                        duration:
                                        Duration(seconds: 1),
                                        backgroundColor:
                                        Colors.blue,
                                      ));
                                      return;
                                    }
                                    if (isCheck) {
                                      if (textEditingController
                                          .text.isEmpty) {
                                        ScaffoldMessenger.of(
                                            context)
                                            .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: Text(
                                              "Please enter Number of Passengers"),
                                          duration:
                                          Duration(seconds: 1),
                                          backgroundColor:
                                          Colors.blue,
                                        ));
                                        return;
                                      }

                                      if (int.parse(
                                          textEditingController
                                              .text) >
                                          11) {
                                        sliderMinVal = 999;
                                        sliderCount = '';
                                        isSliderDisable = false;
                                      } else {
                                        sliderMinVal = 11;
                                        sliderCount = '10+';
                                        isSliderDisable = false;
                                      }
                                    }

                                    Utils.customPrint(
                                        'SELECTED VESSEL WEIGHT $selectedVesselWeight');
                                    /*  if (selectedVesselWeight ==
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
                                      } */

                                    checkAllPermission(true);

                                    /*bool isLocationPermitted =
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
                                      }*/
                                  },
                                ),
                              ),
                              /* addingDataToDB
                                  ? Center(
                                  child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          circularProgressColor)))
                                  : InkWell(
                                onTap: ()async
                                {

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
                              ),*/
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: displayWidth(context) * 0.01,
                              bottom: displayWidth(context) * 0.01,
                            ),
                            child: GestureDetector(
                                onTap: () async {
                                  final image =
                                  await controller.capture();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FeedbackReport(
                                                imagePath:
                                                image.toString(),
                                                uIntList: image,
                                              )));
                                },
                                child: UserFeedback()
                                    .getUserFeedback(context)),
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
      ),
    );
  }

  Widget textFieldPopUp() {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: popupAnimationController,
          curve: Interval(0.0, 1.0, curve: Curves.elasticOut)),
      child: Center(
        child: Container(
          width: displayWidth(context) * 0.25,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Color(0xffE6E9F0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 12),
                      border: InputBorder.none),
                  controller: textEditingController,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(FocusNode());

                    // popupAnimationController.reset();
                  },
                  onEditingComplete: (){
                   // setState(() {
                      //textEditingController.text.isNotEmpty ? numberOfPassengers = int.parse(textEditingController.text) : numberOfPassengers = passengerValue;
                    if(textEditingController.text.isEmpty){
                      setState(() {
                        numberOfPassengers = passengerValue;
                        sliderMinVal = 11;
                        sliderCount = '10+';
                      });
                    }else if(int.parse(textEditingController.text) < 11){
                        numberOfPassengers = int.parse(textEditingController.text);
                        sliderMinVal = 11;
                      }else if(int.parse(textEditingController.text) < 1000){
                        numberOfPassengers = int.parse(textEditingController.text);

                        sliderMinVal = 999;
                        sliderCount = '';
                      }
                    //});
                  },
                  onChanged: (String value) {
                    print("value is: $value");
                    if (value.length == 3) {
                      setState(() {
                        numberOfPassengers =
                            int.parse(textEditingController.text);
                        sliderMinVal = 999;
                        sliderCount = '';
                      });
                      FocusScope.of(context).requestFocus(new FocusNode());
                    }
                  /*  else if(value.length == 2){
                         setState(() {
                           numberOfPassengers = int.parse(textEditingController.text);
                           sliderMinVal = 11;
                           sliderCount = '1';
                         });
                    }  */
                    else if(value.length == 0){
                      setState(() {
                         numberOfPassengers = passengerValue;
                       //sliderMinVal = 11;
                        sliderCount = '10+';
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: Container(
                  //width: displayWidth(context) * 0.01,
                  height: displayHeight(context) * 0.03,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(null),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      backgroundColor: MaterialStateProperty.all(blueColor),
                      textStyle: MaterialStateProperty.all(
                          TextStyle(color: Colors.blue)),
                      shape: MaterialStateProperty.all(
                          new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                    onPressed: () {
                      setState(() {
                        if (textEditingController.text.isEmpty) {
                          sliderMinVal = 11;
                          numberOfPassengers = passengerValue;
                          sliderCount = '10+';
                          isSliderDisable = false;
                          isCheck = false;
                        } else if(textEditingController.text.isNotEmpty && int.parse(textEditingController.text) > 11){

                          sliderMinVal = 999;
                          sliderCount = '';
                          isSliderDisable = false;
                          numberOfPassengers =
                              int.parse(textEditingController.text);
                        } else if (textEditingController.text.isNotEmpty &&
                            int.parse(textEditingController.text) < 11) {
                          sliderMinVal = 11;
                          sliderCount = '10+';
                          isSliderDisable = false;
                          numberOfPassengers =
                              int.parse(textEditingController.text);
                        }
                      });
                      FocusScope.of(context).requestFocus(new FocusNode());

                      kReleaseMode
                          ? null
                          : debugPrint(
                          'Number of passengers $numberOfPassengers');

                      // popupAnimationController.reset();
                    },
                    child: commonText(
                      context: context,
                      text: 'OK',
                      fontWeight: FontWeight.w500,
                      textColor: backgroundColor,
                      textSize: displayWidth(context) * 0.034,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  checkAllPermission(bool tripRecordingStarted) async {
    if (mounted) {
      bool? isTripStarted = sharedPreferences!.getBool('trip_started');

      if (isTripStarted != null) {
        if (isTripStarted) {
          List<String>? tripData =
          sharedPreferences!.getStringList('trip_data');
          Trip tripDetails = await _databaseService.getTrip(tripData![0]);

          if (isTripStarted) {
            showDialogBox(context);
            return;
          }
        }
      }

      bool isLocationPermitted = await Permission.locationAlways.isGranted;

      if (isLocationPermitted) {
        bool isNDPermDenied =
        await Permission.bluetoothConnect.isPermanentlyDenied;

        if (isNDPermDenied) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return LocationPermissionCustomDialog(
                  isLocationDialogBox: false,
                  text: 'Allow nearby devices',
                  subText: 'Allow nearby devices to connect to the app',
                  buttonText: 'OK',
                  buttonOnTap: () async {
                    Get.back();
                  },
                );
              });
          return;
        } else {
          if (Platform.isIOS) {
            dynamic isBluetoothEnable = Platform.isAndroid
                ? await blueIsOn()
                : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey,
                    () {
                  showBluetoothDialog(context);
                });

            if (isBluetoothEnable != null) {
              if (isBluetoothEnable) {
                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                showBluetoothDialog(context);
              }
            }
          } else {
            bool isNDPermittedOne = await Permission.bluetoothConnect.isGranted;

            if (isNDPermittedOne) {
              bool isBluetoothEnable = Platform.isAndroid
                  ? await blueIsOn()
                  : await commonProvider.checkIfBluetoothIsEnabled(scaffoldKey,
                      () {
                    showBluetoothDialog(context);
                  });

              if (isBluetoothEnable) {
                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                showBluetoothDialog(context);
              }
            } else {
              await Permission.bluetoothConnect.request();
              bool isNDPermitted = await Permission.bluetoothConnect.isGranted;
              if (isNDPermitted) {
                bool isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await commonProvider
                    .checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context);
                });

                if (isBluetoothEnable) {
                  // vessel!.add(widget.vessel!);
                  await locationPermissions(tripRecordingStarted);
                } else {
                  showBluetoothDialog(context);
                }
              } else {
                if (await Permission.bluetoothConnect.isDenied ||
                    await Permission.bluetoothConnect.isPermanentlyDenied) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LocationPermissionCustomDialog(
                          isLocationDialogBox: false,
                          text: 'Allow nearby devices',
                          subText: 'Allow nearby devices to connect to the app',
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
      } else {
        /// WIU
        bool isWIULocationPermitted =
        await Permission.locationWhenInUse.isGranted;

        if (!isWIULocationPermitted) {
          await Utils.getLocationPermission(context, scaffoldKey);

          if (Platform.isAndroid) {
            if (!(await Permission
                .locationWhenInUse.shouldShowRequestRationale)) {
              Utils.customPrint(
                  'XXXXX@@@ ${await Permission.locationWhenInUse.shouldShowRequestRationale}');

              if (await Permission.locationWhenInUse.isDenied ||
                  await Permission.locationWhenInUse.isPermanentlyDenied) {
                await openAppSettings();
              }

              showDialog(
                  context: scaffoldKey.currentContext!,
                  builder: (BuildContext context) {
                    isLocationDialogBoxOpen = true;
                    return LocationPermissionCustomDialog(
                      isLocationDialogBox: true,
                      text: 'Always Allow Access to “Location”',
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
          } else {
            await Permission.locationAlways.request();

            bool isGranted = await Permission.locationAlways.isGranted;

            if (!isGranted) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey,
                  message:
                  'Location permissions are denied without permissions we are unable to start the trip');
            }
          }
        } else {
          bool isLocationPermitted = await Permission.locationAlways.isGranted;
          if (isLocationPermitted) {
            bool isNDPermDenied =
            await Permission.bluetoothConnect.isPermanentlyDenied;

            if (isNDPermDenied) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LocationPermissionCustomDialog(
                      isLocationDialogBox: false,
                      text: 'Allow nearby devices',
                      subText: 'Allow nearby devices to connect to the app',
                      buttonText: 'OK',
                      buttonOnTap: () async {
                        Get.back();

                        await openAppSettings();
                      },
                    );
                  });
              return;
            } else {
              bool isNDPermitted = await Permission.bluetoothConnect.isGranted;

              if (isNDPermitted) {
                bool isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await commonProvider
                    .checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context);
                });

                if (isBluetoothEnable) {
                  // vessel!.add(widget.vessel!);
                  await locationPermissions(tripRecordingStarted);
                } else {
                  showBluetoothDialog(context);
                }
              } else {
                await Permission.bluetoothConnect.request();
                bool isNDPermitted =
                await Permission.bluetoothConnect.isGranted;
                if (isNDPermitted) {
                  bool isBluetoothEnable = Platform.isAndroid
                      ? await blueIsOn()
                      : await commonProvider
                      .checkIfBluetoothIsEnabled(scaffoldKey, () {
                    showBluetoothDialog(context);
                  });

                  if (isBluetoothEnable) {
                    // vessel!.add(widget.vessel!);
                    await locationPermissions(tripRecordingStarted);
                  } else {
                    showBluetoothDialog(context);
                  }
                }
              }
            }
          } else if (await Permission.locationAlways.isPermanentlyDenied) {
            if (Platform.isIOS) {
              Permission.locationAlways.request();

              PermissionStatus status = await Permission.locationAlways
                  .request()
                  .catchError((onError) {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    "Location permissions are denied without permissions we are unable to start the trip");

                Future.delayed(Duration(seconds: 3), () async {
                  await openAppSettings();
                });
                return PermissionStatus.denied;
              });

              if (status == PermissionStatus.denied ||
                  status == PermissionStatus.permanentlyDenied) {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    "Location permissions are denied without permissions we are unable to start the trip");

                Future.delayed(Duration(seconds: 3), () async {
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
                        text: 'Always Allow Access to “Location”',
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
          } else {
            if (Platform.isIOS) {
              await Permission.locationAlways.request();

              bool isLocationAlwaysPermitted =
              await Permission.locationAlways.isGranted;

              Utils.customPrint('IOS PERMISSION GIVEN OUTSIDE');

              if (isLocationAlwaysPermitted) {
                Utils.customPrint('IOS PERMISSION GIVEN 1');

                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    'Location permissions are denied without permissions we are unable to start the trip');

                Future.delayed(Duration(seconds: 3), () async {
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
                        text: 'Always Allow Access to “Location”',
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
    }
  }

  checkTempPermissions() async {
    this.isLocationPermitted = await Permission.locationAlways.isGranted;
    setState(() {});
  }

  //To get all vessels
  getVesselAndTripsData() async {
    setState(() {
      isVesselDataLoading = true;
    });

    List<CreateVessel> localVesselList =
    await _databaseService.vessels().catchError((onError) {
      setState(() {
        isVesselDataLoading = false;
      });
    });
    vesselData = List<VesselDropdownItem>.from(localVesselList
        .map((vessel) => VesselDropdownItem(id: vessel.id, name: vessel.name)));
    setState(() {
      isVesselDataLoading = false;
    });
    return;

    /*try {
      bool check = await Utils().check(scaffoldKey);
      if (check) {
        setState(() {
          isVesselDataLoading = false;
        });
        commonProvider
            .getUserConfigData(context, commonProvider.loginModel!.userId!,
            commonProvider.loginModel!.token!, scaffoldKey)
            .then((value) {

          Utils.customPrint("value is: ${value!.status}");
          CustomLogger().logWithFile(Level.info, "value is: ${value.status} -> $page");

          if (value != null) {
            setState(() {
              isVesselDataLoading = true;
            });
            Utils.customPrint("value 1 is: ${value.status}");

            Utils.customPrint("value of get user config by id: ${value.vessels}");
            CustomLogger().logWithFile(Level.info, "value of get user config by id: ${value.vessels} -> $page");


            Utils.customPrint("UNRETIRE VESSEL LEGNTH ${vesselData.length}");

            List<vs.Vessels> vesselListData = value.vessels!.where((element) => element.vesselStatus == 1).toList();

            vesselData = List<VesselDropdownItem>.from(vesselListData.map(
                    (vessel) => VesselDropdownItem(id: vessel.id, name: vessel.name)));

            Utils.customPrint("vesselData: ${vesselData.length}");
            CustomLogger().logWithFile(Level.info, "vesselData: ${vesselData.length} -> $page");

          } else {
            setState(() {
              isVesselDataLoading = true;
            });
          }
        }).catchError((e) {
          setState(() {
            isVesselDataLoading = true;
          });
        });
      } else {
        setState(() {
          isVesselDataLoading = true;
        });
      }
    } catch (e) {
      setState(() {
        isVesselDataLoading = true;
      });

      Utils.customPrint("Error while fetching data from getUserConfigById: $e");
      CustomLogger().logWithFile(Level.error, "Error while fetching data from getUserConfigById: $e -> $page");

    }*/
  }

  Future<bool> blueIsOn() async {
    FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    final isOn = await _flutterBlue.isOn;
    if (isOn) return true;

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
        } else {
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

    debugPrint("NUMBER OF PASS 4 $numberOfPassengers");

    try {
      await _databaseService.insertTrip(Trip(
          id: getTripId,
          vesselId: vesselId,
          vesselName: selectedVesselName,
          currentLoad: 'Empty',
          numberOfPassengers: numberOfPassengers,
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
  startWritingDataToDB(BuildContext bottomSheetContext) async {
    Utils.customPrint('ISSSSS XXXXXXX: $isServiceRunning');

    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LocationPermissionCustomDialog(
              isLocationDialogBox: false,
              text: 'Require GPS',
              subText: 'Please enable GPS.',
              buttonText: 'OK',
              buttonOnTap: () async {
                Get.back();

                // AppSettings.openAppSettings(type: AppSettingsType.location);
              },
            );
          });
      return;
    }

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

    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data',
        [getTripId, vesselId!, selectedVesselName!, selectedVesselWeight]);

    // if(!await loc.Location().serviceEnabled()){
    //   loc.Location().requestService();
    //
    //   // StreamSubscription<geo.ServiceStatus> serviceStatusStream = geo.Geolocator.getServiceStatusStream().listen(
    //   //         (geo.ServiceStatus status) {
    //   //       print(status);
    //   //       if(status == geo.ServiceStatus.disabled){
    //   //         loc.Location().requestService();
    //   //       }
    //   //     });
    // }
    // else{
    //   // StreamSubscription<geo.ServiceStatus> serviceStatusStream = geo.Geolocator.getServiceStatusStream().listen(
    //   //         (geo.ServiceStatus status) {
    //   //       print(status);
    //   //       if(status == geo.ServiceStatus.disabled){
    //   //         loc.Location().requestService();
    //   //       }
    //   //     });
    // }

    await initPlatformStateBGL();

    //await tripIsRunningOrNot();

    addingDataToDB = false;
    isStartButton = false;

    bool? runningTrip = sharedPreferences!.getBool("trip_started");

    if (runningTrip!) {
      List<String>? tripData = sharedPreferences!.getStringList('trip_data');
      final tripDetails = await _databaseService.getTrip(tripData![0]);

      print('CALLED FROM: ${widget.calledFrom}');

      var result = Navigator.pushReplacement(
        scaffoldKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => TripRecordingScreen(
                tripId: tripDetails.id,
                vesselName: tripDetails.vesselName,
                vesselId: tripData[1],
                tripIsRunningOrNot: runningTrip,
                calledFrom: widget.calledFrom)),
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
          if (activeNotifications[0].channelId == 'app.yukams/locator_plugin' ||
              activeNotifications[0].channelId ==
                  'performarine_trip_$getTripId-3') {
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

                                        Navigator.of(dialogContext).pop();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TripRecordingScreen(
                                                      tripId: tripId,
                                                      vesselId: tripData![1],
                                                      vesselName: tripData[2],
                                                      tripIsRunningOrNot:
                                                      runningTrip)),
                                        );

                                        Utils.customPrint("Click on GO TO TRIP 3");
                                      },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.2,
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
                                    'Ok go back', context, Colors.transparent,
                                        () {
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

  checkAndGetLPRList() {
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
                        isBluetoothPermitted = true;
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
            isBluetoothPermitted = true;
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
  }

  /// Check location permission
  locationPermissions(bool isTripRecordingStarted) async {
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
                            isBluetoothPermitted = true;
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
                isBluetoothPermitted = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device.disconnect().then(
                      (value) => Utils.customPrint("is device disconnected:"));
            }
          }
        });

        setState(() {
          this.isLocationPermitted = isLocationPermitted;
        });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

        /* Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
          isLocationPermitted: isLocationPermitted,
          isBluetoothConnected: isBluetoothConnected,
          calledFrom: 'bottom_nav',)));*/
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
                              isBluetoothPermitted = true;
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
                  isBluetoothPermitted = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device.disconnect().then(
                        (value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });

          setState(() {
            this.isLocationPermitted = isLocationPermitted;
          });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

          /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,
              calledFrom: 'bottom_nav')));*/
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
                            isBluetoothPermitted = true;
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
                isBluetoothPermitted = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device.disconnect().then(
                      (value) => Utils.customPrint("is device disconnected: "));
            }
          }
        });

        setState(() {
          this.isLocationPermitted = isLocationPermitted;
        });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

        /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
            isLocationPermitted: isLocationPermitted,
            isBluetoothConnected: isBluetoothConnected,
            calledFrom: 'bottom_nav')));*/
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
                              isBluetoothPermitted = true;
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
                  isBluetoothPermitted = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device.disconnect().then(
                        (value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });

          setState(() {
            this.isLocationPermitted = isLocationPermitted;
          });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

          /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,
              calledFrom: 'bottom_nav'
          )));*/
        }
      }
    }
  }

  showBluetoothListDialog(BuildContext context) {
    setState(() {
      progress = 0.9;
      lprSensorProgress = 0.0;
      isStartButton = false;
    });

    checkAndGetLPRList();

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
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  setState(() {
                                    isBluetoothPermitted = value;
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
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  setState(() {
                                    isBluetoothPermitted = value;
                                  });
                                }
                              },
                            )),
                      ),

                      Container(
                        width: displayWidth(context),
                        margin:
                        EdgeInsets.only(left: 15, right: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // FlutterBluePlus.instance.

                                Navigator.pop(context);
                                setState(() {
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
                                  setState(() {
                                    isScanningBluetooth = true;
                                  });
                                }

                                FlutterBluePlus.instance.startScan(
                                    timeout: const Duration(seconds: 2));

                                if (mounted) {
                                  Future.delayed(Duration(seconds: 2), () {
                                    setState(() {
                                      isScanningBluetooth = false;
                                    });
                                  });
                                }

                                if (mounted) {
                                  setState(() {
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
                                  color: blueColor,
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
        setState(() {
          progress = 1.0;
          lprSensorProgress = 1.0;
          isStartButton = true;
          isBluetoothPermitted = true;
        });
      } else {
        setState(() {
          isBluetoothPermitted = false;
        });
      }
    });
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