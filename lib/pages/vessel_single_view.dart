import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/analytics/location_callback_handler.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/expansionCard.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../common_widgets/widgets/log_level.dart';
import '../common_widgets/widgets/user_feed_back.dart';
import '../new_trip_analytics_screen.dart';
import 'add_vessel_new/add_new_vessel_screen.dart';
import 'bottom_navigation.dart';
import 'feedback_report.dart';

class VesselSingleView extends StatefulWidget {
  CreateVessel? vessel;
  final bool? isCalledFromSuccessScreen;

  VesselSingleView({this.vessel, this.isCalledFromSuccessScreen = false});
  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {
  List<CreateVessel>? vessel = [];

  final DatabaseService _databaseService = DatabaseService();

  GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  Timer? notiTimer, locationTimer;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  DeviceInfo? deviceDetails;

  DateTime startDateTime = DateTime.now();
  SharedPreferences? pref;

  bool isStartButton = false,
      isEndTripButton = false,
      isZipFileCreate = false,
      isSensorDataUploaded = false,
      addingDataToDB = false,
      isLocationDialogBoxOpen = false,
      tripIsEnded = false,
      isServiceRunning = false,
      isBluetoothDialog = false,
      isBluetoothConnected = false,
      isRefreshList = false,
      isScanningBluetooth = false;

  String fileName = '', getTripId = '', selectedVesselWeight = 'Select Current Load', bluetoothName = '';
  int fileIndex = 1;
  String? latitude, longitude;
  var uuid = Uuid();

  double progress = 0.9,
      deviceProgress = 1.0,
      sensorProgress = 1.0,
      accSensorProgress = 1.0,
      lprSensorProgress = 1.0,
      uaccSensorProgress = 1.0,
      gyroSensorProgress = 1.0,
      magnSensorProgress = 1.0;

  double progressBegin = 0.0,
      deviceProgressBegin = 0.0,
      sensorProgressBegin = 0.0,
      accSensorProgressBegin = 0.0,
      uaccSensorProgressBegin = 0.0,
      gyroSensorProgressBegin = 0.0,
      magnSensorProgressBegin = 0.0,
      lprSensorProgressBegin = 0.0;

  List<String> sensorDataTable = ['ACC', 'UACC', 'GYRO', 'MAGN'];

  final controller = ScreenshotController();
  final controller1 = ScreenshotController();

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

  /// To delete vessel and add into retired vessel list
  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  /// TO delete trip from vessel
  Future<void> _onDeleteTripsByVesselID(String vesselId) async {
    await _databaseService.deleteTripBasedOnVesselId(vesselId);
    setState(() {});
  }

  bool isBottomSheetOpened = false,
      isDataUpdated = false,
      tripIsRunning = false,
      isCheckingPermission = false,
      isTripEndedOrNot = false,
      vesselAnalytics = false,
      isVesselParticularExpanded = false,
      anotherVesselEndTrip = false;

  late CommonProvider commonProvider;

  bool? gyroscopeAvailable,
      accelerometerAvailable,
      magnetometerAvailable,
      userAccelerometerAvailable;

  String totalDistance = '0',
      avgSpeed = '0',
      tripsCount = '0',
      totalDuration = "00:00:00";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tripIsRunningOrNot();

    commonProvider = context.read<CommonProvider>();

    Utils.customPrint('VESSEL Image ${isTripEndedOrNot}');

    checkSensorAvailabelOrNot();

    getVesselAnalytics(widget.vessel!.id!);
  }

  /// To get running trip details
  getRunningTripDetails() async {
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');
    Trip tripDetails = await _databaseService.getTrip(tripData![0]);
    if (tripIsRunning)
      Utils.customPrint('VESSEL SINGLE VIEW TRIP ID ${tripDetails.id}');

    if (tripIsRunning) {
      if (tripDetails.vesselId != widget.vessel!.id) {
        setState(() {
          tripIsRunning = false;
        });
      }
    }
  }

  /// Check sensor is available or not
  checkSensorAvailabelOrNot() async {
    gyroscopeAvailable =
    await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
    await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
    await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);
  }

  /// Check trip is running or not
  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      Utils.customPrint('Trip is Running VESSEL VESSEL $tripIsRunning');

      if (tripIsRunning) {
        getRunningTripDetails();
      }

      if (!tripIsRunning) {
        setState(() {
          isTripEndedOrNot = false;
        });
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigation(),
              ),
              ModalRoute.withName(""));

          return false;
        } else {
          Navigator.of(context).pop(true);
          return false;
        }
      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: backgroundColor,
            title: commonText(
              context: context,
              text: 'Vessel Details',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.045,
            ),
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
            /*leading: IconButton(
              onPressed: () async {
                await tripIsRunningOrNot();

                if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavigation(),
                      ),
                      ModalRoute.withName(""));
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),*/
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
                  icon: Image.asset('assets/images/home.png'),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
          drawer: CustomDrawer(),
          body: Container(
            color: Colors.white,
            //margin: EdgeInsets.only(bottom: 4),
            child: Stack(
              children: [
                SizedBox(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ExpansionCard(
                            scaffoldKey,
                            widget.vessel,
                                (value) async {
                              var result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddNewVesselPage(
                                    isEdit: true,
                                    createVessel: widget.vessel,
                                  ),
                                  fullscreenDialog: true,
                                ),
                              );

                              if (result != null) {
                                Utils.customPrint('RESULT 1 ${result[0]}');
                                Utils.customPrint(
                                    'RESULT 1 ${result[1] as CreateVessel}');
                                setState(() {
                                  widget.vessel = result[1] as CreateVessel?;
                                  isDataUpdated = result[0];
                                });
                              }
                            },
                                (value) {},
                                (value) {
                              _onDeleteTripsByVesselID(value.id!);
                              _onVesselDelete(value);
                            },
                            false,
                        isCalledFromVesselSingleView: true,),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Color(0xffECF3F9),
                            borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))
                          ),
                          child: Column(
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 0.0, left: 17, right: 17),
                                  child: Column(
                                    children: [

                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.black,
                                            ),
                                            dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          initiallyExpanded: true,
                                          onExpansionChanged: ((newState) {}),
                                          tilePadding: EdgeInsets.zero,
                                          childrenPadding: EdgeInsets.zero,
                                          title: commonText(
                                              context: context,
                                              text: 'Vessel Dimensions',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.036,
                                              textAlign: TextAlign.start),
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset('assets/images/length.png',
                                                              width: displayWidth(context) * 0.045,
                                                              color: Colors.black),
                                                          SizedBox(
                                                              width: displayWidth(context) * 0.016),
                                                          Flexible(
                                                            child: commonText(
                                                              context: context,
                                                              text:
                                                              '${widget.vessel!.lengthOverall} ft',
                                                              fontWeight: FontWeight.w500,
                                                              textColor: Colors.black,
                                                              textSize:
                                                              displayWidth(context) * 0.034,
                                                              textAlign: TextAlign.start,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: displayHeight(context) * 0.006),

                                                      commonText(
                                                          context: context,
                                                          text: 'Length(LOA)',
                                                          fontWeight: FontWeight.w500,
                                                          textColor: Colors.grey,
                                                          textSize: displayWidth(context) * 0.024,
                                                          textAlign: TextAlign.start),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: displayWidth(context) * 0.015),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                              'assets/images/free_board.png',
                                                              width: displayWidth(context) * 0.045,
                                                              color: Colors.black),
                                                          SizedBox(
                                                              width: displayWidth(context) * 0.016),
                                                          Flexible(
                                                            child: commonText(
                                                                context: context,
                                                                text:
                                                                '${widget.vessel!.freeBoard} ft',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.034,
                                                                textAlign: TextAlign.start),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: displayHeight(context) * 0.006),
                                                      commonText(
                                                          context: context,
                                                          text: 'Freeboard',
                                                          fontWeight: FontWeight.w500,
                                                          textColor: Colors.grey,
                                                          textSize: displayWidth(context) * 0.024,
                                                          textAlign: TextAlign.start),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: displayWidth(context) * 0.015),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                              'assets/images/free_board.png',
                                                              width: displayWidth(context) * 0.045,
                                                              color: Colors.black),
                                                          SizedBox(
                                                              width: displayWidth(context) * 0.016),
                                                          Flexible(
                                                            child: commonText(
                                                                context: context,
                                                                text: '${widget.vessel!.beam} ft',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.034,
                                                                textAlign: TextAlign.start),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: displayHeight(context) * 0.006),
                                                      commonText(
                                                          context: context,
                                                          text: 'Beam',
                                                          fontWeight: FontWeight.w500,
                                                          textColor: Colors.grey,
                                                          textSize: displayWidth(context) * 0.024,
                                                          textAlign: TextAlign.start),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: displayWidth(context) * 0.015),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          RotatedBox(
                                                            quarterTurns: 2,
                                                            child: Image.asset(
                                                                'assets/images/free_board.png',
                                                                width: displayWidth(context) * 0.045,
                                                                color: Colors.black),
                                                          ),
                                                          SizedBox(
                                                              width: displayWidth(context) * 0.016),
                                                          Flexible(
                                                            child: commonText(
                                                                context: context,
                                                                text: '${widget.vessel!.draft} ft',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.034,
                                                                textAlign: TextAlign.start),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: displayHeight(context) * 0.006),
                                                      commonText(
                                                          context: context,
                                                          text: 'Draft',
                                                          fontWeight: FontWeight.w500,
                                                          textColor: Colors.grey,
                                                          textSize: displayWidth(context) * 0.024,
                                                          textAlign: TextAlign.start),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: displayHeight(context) * 0.01,
                                      ),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.black,
                                            ),
                                            dividerColor: Colors.transparent),
                                        child: Container(
                                          child: ExpansionTile(
                                            initiallyExpanded: true,
                                            onExpansionChanged: ((newState) {
                                              setState(() {
                                                isVesselParticularExpanded = newState;
                                              });

                                              Utils.customPrint(
                                                  'EXPANSION CHANGE $isVesselParticularExpanded');
                                              CustomLogger().logWithFile(Level.info, "EXPANSION CHANGE $isVesselParticularExpanded -> $page");
                                            }),
                                            tilePadding: EdgeInsets.zero,
                                            childrenPadding: EdgeInsets.zero,
                                            title: commonText(
                                                context: context,
                                                text: 'Propulsion Details',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize: displayWidth(context) * 0.036,
                                                textAlign: TextAlign.start),
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            commonText(
                                                                context: context,
                                                                text:
                                                                '${widget.vessel!.capacity}cc',
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.04,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'Capacity' ,
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            commonText(
                                                                context: context,
                                                                text: widget.vessel!.builtYear
                                                                    .toString(),
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.04,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'Built',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            widget.vessel!.regNumber! == ""
                                                                ? commonText(
                                                                context: context,
                                                                text: '-',
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) *
                                                                    0.04,
                                                                textAlign: TextAlign.start)
                                                                : commonText(
                                                                context: context,
                                                                text: widget.vessel!.regNumber,
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) *
                                                                    0.048,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'Registration Number',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                                    child: const Divider(
                                                      color: Colors.grey,
                                                      thickness: 1,
                                                      indent: 1,
                                                      endIndent: 2,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            commonText(
                                                                context: context,
                                                                text:
                                                                '${widget.vessel!.weight} Lbs',
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.04,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'Weight',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            commonText(
                                                                context: context,
                                                                text:
                                                                '${widget.vessel!.vesselSize} hp',
                                                                fontWeight: FontWeight.w600,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) * 0.042,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'Size (hp)',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            widget.vessel!.mMSI! == ""
                                                                ? commonText(
                                                                context: context,
                                                                text: '-',
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) *
                                                                    0.04,
                                                                textAlign: TextAlign.start)
                                                                : commonText(
                                                                context: context,
                                                                text: widget.vessel!.mMSI,
                                                                fontWeight: FontWeight.w700,
                                                                textColor: Colors.black,
                                                                textSize:
                                                                displayWidth(context) *
                                                                    0.04,
                                                                textAlign: TextAlign.start),
                                                            commonText(
                                                                context: context,
                                                                text: 'MMSI',
                                                                fontWeight: FontWeight.w500,
                                                                textColor: Colors.grey,
                                                                textSize:
                                                                displayWidth(context) * 0.024,
                                                                textAlign: TextAlign.start),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: displayHeight(context) * 0.01,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.black,
                                    ),
                                    dividerColor: Colors.transparent),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: ExpansionTile(
                                    initiallyExpanded: true,
                                    onExpansionChanged: ((newState) {
                                      setState(() {
                                        isVesselParticularExpanded = newState;
                                      });

                                      Utils.customPrint(
                                          'EXPANSION CHANGE $isVesselParticularExpanded');
                                    }),
                                    tilePadding: EdgeInsets.zero,
                                    childrenPadding: EdgeInsets.zero,
                                    title: commonText(
                                        context: context,
                                        text: 'VESSEL ANALYTICS',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.038,
                                        textAlign: TextAlign.start),
                                    children: [
                                      vesselAnalytics
                                          ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      )
                                          : vesselSingleViewVesselAnalytics(
                                          context,
                                          totalDuration,
                                          totalDistance,
                                          tripsCount,
                                          avgSpeed),
                                    ],
                                  ),
                                ),
                              ),

                              Theme(
                                data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.black,
                                    ),
                                    dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  onExpansionChanged: ((newState) {
                                    Utils.customPrint('CURRENT STAT $newState');
                                  }),
                                  textColor: Colors.black,
                                  iconColor: Colors.black,
                                  title: commonText(
                                      context: context,
                                      text: 'Trip History',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.038,
                                      textAlign: TextAlign.start),
                                  children: [
                                    TripViewListing(
                                      scaffoldKey: scaffoldKey,
                                      vesselId: widget.vessel!.id,
                                      calledFrom: 'VesselSingleView',
                                      isTripDeleted: ()async{
                                        setState(() {
                                          getVesselAnalytics(widget.vessel!.id!);
                                        });
                                      },
                                      onTripEnded: () async {
                                        Utils.customPrint('SINGLE VIEW TRIP END');
                                        await tripIsRunningOrNot();
                                        setState(() {
                                          tripIsEnded = true;
                                        });
                                        commonProvider.getTripsByVesselId(widget.vessel!.id!);
                                        getVesselAnalytics(widget.vessel!.id!);
                                      },
                                    ),
                                    SizedBox(height: displayHeight(context) * 0.02,),
                                    /*Padding(
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
                                    ),*/
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.05,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: displayHeight(context) * 0.08,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    color: Color(0xffECF3F9),
                    margin: EdgeInsets.only(left: 10, right: 10, top: 8),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        children: [
                          tripIsRunning
                              ? isTripEndedOrNot
                              ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    circularProgressColor),
                              ))
                              : CommonButtons.getRichTextActionButton(
                              icon: Image.asset('assets/icons/end_btn.png',
                                height: displayHeight(context) * 0.055,
                                width: displayWidth(context) * 0.12,
                              ),
                              title: 'End Trip',
                              context: context,
                              fontSize: displayWidth(context) * 0.042,
                              textColor: Colors.white,
                              buttonPrimaryColor: endTripBtnColor,
                              borderColor: endTripBtnColor,
                              width: displayWidth(context),
                              onTap: () async {

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
                                  Utils().showDeleteTripDialog(context,
                                      endTripBtnClick: (){
                                        endTripMethod();
                                        Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

                                        Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

                                        Future.delayed(Duration(seconds: 1), (){
                                          if(!isSmallTrip)
                                          {
                                            Utils.customPrint("SMALL TRIPP IDDD 11 ${tripId}");
                                            DatabaseService().deleteTripFromDB(tripId);
                                          }
                                        });
                                      },
                                      onCancelClick: (){
                                        Navigator.of(context).pop();
                                      }
                                  );
                                }
                                else
                                {
                                  Utils().showEndTripDialog(context, () async
                                  {
                                    endTripMethod();
                                  }, () {
                                    Navigator.of(context).pop();
                                  });
                                }


                              })
                              : CommonButtons.getRichTextActionButton(
                                icon: Image.asset('assets/icons/start_btn.png',
                                  height: displayHeight(context) * 0.055,
                                  width: displayWidth(context) * 0.12,
                                ),
                              title: 'Start Trip',
                              context: context,
                              fontSize: displayWidth(context) * 0.042,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              width: displayWidth(context),
                              onTap: () async {
                                bool? isTripStarted =
                                sharedPreferences!.getBool('trip_started');

                                if (isTripStarted != null) {
                                  if (isTripStarted) {
                                    List<String>? tripData = sharedPreferences!
                                        .getStringList('trip_data');
                                    Trip tripDetails = await _databaseService
                                        .getTrip(tripData![0]);

                                    if (tripDetails.vesselId != widget.vessel!.id) {
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
                                          vessel!.add(widget.vessel!);
                                          await locationPermissions(
                                              widget.vessel!.vesselSize!,
                                              widget.vessel!.name!,
                                              widget.vessel!.id!);
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
                                          vessel!.add(widget.vessel!);
                                          await locationPermissions(
                                              widget.vessel!.vesselSize!,
                                              widget.vessel!.name!,
                                              widget.vessel!.id!);
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
                                            vessel!.add(widget.vessel!);
                                            await locationPermissions(
                                                widget.vessel!.vesselSize!,
                                                widget.vessel!.name!,
                                                widget.vessel!.id!);
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
                                            vessel!.add(widget.vessel!);
                                            await locationPermissions(
                                                widget.vessel!.vesselSize!,
                                                widget.vessel!.name!,
                                                widget.vessel!.id!);
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
                                              vessel!.add(widget.vessel!);
                                              await locationPermissions(
                                                  widget.vessel!.vesselSize!,
                                                  widget.vessel!.name!,
                                                  widget.vessel!.id!);
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

                                          vessel!.add(widget.vessel!);
                                          await locationPermissions(
                                              widget.vessel!.vesselSize!,
                                              widget.vessel!.name!,
                                              widget.vessel!.id!);
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
                              }),

                          Padding(
                            padding: EdgeInsets.only(
                              top : displayWidth(context) * 0.008,
                              bottom : displayWidth(context) * 0.005,
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
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> blueIsOn() async
  {
    FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    final isOn = await _flutterBlue.isOn;
    if(isOn) return true;

    await Future.delayed(const Duration(seconds: 1));
    return await FlutterBluePlus.instance.isOn;
  }

  /// Check location permission
  locationPermissions(dynamic size, String vesselName, String weight) async {
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

        Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(isLocationPermitted: isLocationPermitted, isBluetoothConnected: isBluetoothConnected)));
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(isLocationPermitted: isLocationPermitted, isBluetoothConnected: isBluetoothConnected)));
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(isLocationPermitted: isLocationPermitted, isBluetoothConnected: isBluetoothConnected)));
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(isLocationPermitted: isLocationPermitted, isBluetoothConnected: isBluetoothConnected)));
        }
      }
    }
  }

  getBottomSheet(BuildContext context, dynamic size, String vesselName,
      String weight, bool isLocationPermission) async {
    isStartButton = false;
    isEndTripButton = false;
    isSensorDataUploaded = false;
    isZipFileCreate = false;
    addingDataToDB = false;
    selectedVesselWeight = 'Select Current Load';
    isBottomSheetOpened = true;
    isBluetoothConnected = false;
    progress = 0.9;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            if (!addingDataToDB) {
              Navigator.pop(context);
              return false;
            } else {
              return false;
            }
          },
          child: Screenshot(
            controller: controller1,
            child: Scaffold(
              backgroundColor: Colors.transparent.withOpacity(0.0),
              extendBody: false,
              key: _modelScaffoldKey,
              resizeToAvoidBottomInset: true,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: StatefulBuilder(builder:
                    (BuildContext bottomSheetContext, StateSetter stateSetter) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: displayWidth(context) * 0.01,
                                  ),
                                  TweenAnimationBuilder(
                                    duration: const Duration(seconds: 3),
                                    tween: Tween(
                                        begin: progressBegin, end: progress),
                                    builder: (context, double value, _) {
                                      return SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: value,
                                              backgroundColor:
                                              Colors.grey.shade200,
                                              strokeWidth: 3,
                                              color: Colors.green,
                                            ),
                                            Center(
                                              child: buildProgress(value, 60),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      Utils.customPrint('END');
                                      stateSetter(() {
                                        isStartButton = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: displayWidth(context) * 0.08),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        commonText(
                                            context: context,
                                            text: 'Fetching your device details',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                            displayWidth(context) * 0.032,
                                            textAlign: TextAlign.start),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        TweenAnimationBuilder(
                                            duration: const Duration(seconds: 3),
                                            tween: Tween(
                                                begin: deviceProgressBegin,
                                                end: deviceProgress),
                                            builder: (context, double value, _) {
                                              return SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      color:
                                                      circularProgressColor,
                                                      value: value,
                                                      backgroundColor:
                                                      Colors.grey.shade200,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                      const AlwaysStoppedAnimation(
                                                          Colors.green),
                                                    ),
                                                    Center(
                                                      child: subTitleProgress(
                                                          value,
                                                          displayWidth(context) *
                                                              0.035),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: displayWidth(context) * 0.08),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            commonText(
                                                context: context,
                                                text: isLocationPermission
                                                    ? 'Location permission granted'
                                                    : 'Location permission is required',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                displayWidth(context) * 0.032,
                                                textAlign: TextAlign.start),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            !isLocationPermission
                                                ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red,
                                                        width: 2),
                                                    shape: BoxShape.circle),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                                : TweenAnimationBuilder(
                                                duration: const Duration(
                                                    seconds: 3),
                                                tween: Tween(
                                                    begin:
                                                    sensorProgressBegin,
                                                    end: sensorProgress),
                                                builder: (context,
                                                    double value, _) {
                                                  return SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        CircularProgressIndicator(
                                                          color:
                                                          circularProgressColor,
                                                          value: value,
                                                          backgroundColor:
                                                          Colors.grey
                                                              .shade200,
                                                          strokeWidth: 2,
                                                          valueColor:
                                                          const AlwaysStoppedAnimation(
                                                              Colors
                                                                  .green),
                                                        ),
                                                        Center(
                                                          child: subTitleProgress(
                                                              value,
                                                              displayWidth(
                                                                  context) *
                                                                  0.035),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                        isLocationPermission
                                            ? SizedBox()
                                            : commonText(
                                            context: context,
                                            text: 'Permission Denied!',
                                            fontWeight: FontWeight.w400,
                                            textColor: Colors.red,
                                            textSize:
                                            displayWidth(context) * 0.028,
                                            textAlign: TextAlign.start),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: displayWidth(context) * 0.08),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            commonText(
                                                context: context,
                                                text: 'Connecting with LPR',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                displayWidth(context) * 0.032,
                                                textAlign: TextAlign.start),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            TweenAnimationBuilder(
                                                duration:
                                                const Duration(seconds: 3),
                                                tween: Tween(
                                                    begin: lprSensorProgressBegin,
                                                    end: lprSensorProgress),
                                                builder:
                                                    (context, double value, _) {
                                                  return isBluetoothConnected
                                                      ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        CircularProgressIndicator(
                                                          color:
                                                          circularProgressColor,
                                                          value: value,
                                                          backgroundColor:
                                                          Colors.grey
                                                              .shade200,
                                                          strokeWidth: 2,
                                                          valueColor:
                                                          const AlwaysStoppedAnimation(
                                                              Colors
                                                                  .green),
                                                        ),
                                                        Center(
                                                          child: subTitleProgress(
                                                              value,
                                                              displayWidth(
                                                                  context) *
                                                                  0.035),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                      : SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Container(
                                                      alignment:
                                                      Alignment.center,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .red,
                                                              width: 2),
                                                          shape: BoxShape
                                                              .circle),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                        isBluetoothConnected
                                            ? Row(
                                          children: [
                                            commonText(
                                                context: context,
                                                text: 'Connected with ',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.green,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            commonText(
                                                context: context,
                                                text: bluetoothName,
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.green,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        )
                                            : InkWell(
                                          onTap: () async {
                                            showBluetoothListDialog(
                                                context, stateSetter);
                                          },
                                          child: commonText(
                                              context: context,
                                              text:
                                              'Tap to connect LPR manually',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                              displayWidth(context) *
                                                  0.028,
                                              textAlign: TextAlign.start),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: displayWidth(context) * 0.08),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        commonText(
                                            context: context,
                                            text: 'Connecting with sensors',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                            displayWidth(context) * 0.032,
                                            textAlign: TextAlign.start),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        TweenAnimationBuilder(
                                            duration: const Duration(seconds: 3),
                                            tween: Tween(
                                                begin: accSensorProgressBegin,
                                                end: accSensorProgress),
                                            builder: (context, double value, _) {
                                              return SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      color:
                                                      circularProgressColor,
                                                      value: value,
                                                      backgroundColor:
                                                      Colors.grey.shade200,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                      const AlwaysStoppedAnimation(
                                                          Colors.green),
                                                    ),
                                                    Center(
                                                      child: subTitleProgress(
                                                          value,
                                                          displayWidth(context) *
                                                              0.035),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  isZipFileCreate
                                      ? InkWell(
                                    onTap: () async {
                                      File copiedFile =
                                      File('${ourDirectory!.path}.zip');

                                      Directory directory;

                                      if (Platform.isAndroid) {
                                        directory = Directory(
                                            "storage/emulated/0/Download/${widget.vessel!.id}.zip");
                                      } else {
                                        directory =
                                        await getApplicationDocumentsDirectory();
                                      }

                                      copiedFile.copy(directory.path);

                                      Utils.customPrint(
                                          'DOES FILE EXIST: ${copiedFile.existsSync()}');
                                      if (copiedFile.existsSync()) {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                            'File downloaded successfully');
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        commonText(
                                            context: context,
                                            text: 'Download File',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                            displayWidth(context) *
                                                0.038,
                                            textAlign: TextAlign.start),
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Icon(
                                              Icons.file_download_outlined),
                                        )
                                      ],
                                    ),
                                  )
                                      : SizedBox(),
                                  SizedBox(
                                    height: displayWidth(context) * 0.03,
                                  ),
                                  StatefulBuilder(
                                    builder: (context, StateSetter stateSetter) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Container(
                                              height: displayHeight(context) >=
                                                  680
                                                  ? displayHeight(context) * 0.056
                                                  : displayHeight(context) * 0.07,
                                              alignment: Alignment.centerLeft,
                                              color: Color(0xFFECF3F9),
                                              child: InputDecorator(
                                                decoration: const InputDecoration(
                                                  enabledBorder: InputBorder.none,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              0.0))),
                                                  contentPadding: EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 5,
                                                      bottom: 5),
                                                ),
                                                child: commonText(
                                                    context: context,
                                                    text: vesselName,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.black54,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.032,
                                                    textAlign: TextAlign.start),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20, top: 10),
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: displayHeight(context) >=
                                                  680
                                                  ? displayHeight(context) * 0.056
                                                  : displayHeight(context) * 0.07,
                                              color: Color(0xFFECF3F9),
                                              child: InputDecorator(
                                                decoration: const InputDecoration(
                                                  enabledBorder: InputBorder.none,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              0.0))),
                                                  contentPadding: EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 10,
                                                      bottom: 10),
                                                ),
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<dynamic>(
                                                    value: null,
                                                    isDense: true,
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
                                                      stateSetter(() {
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
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              //height: 50,
                              width: displayWidth(context),
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 17,
                                    right: 17,
                                    bottom:
                                    isStartButton || isEndTripButton ? 0 : 2),
                                child: isStartButton
                                    ? addingDataToDB
                                    ? Center(
                                    child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            circularProgressColor)))
                                    : CommonButtons.getActionButton(
                                    title: 'Start',
                                    context: context,
                                    fontSize:
                                    displayWidth(context) * 0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor: buttonBGColor,
                                    borderColor: buttonBGColor,
                                    width: displayWidth(context),
                                    onTap: () async {
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
                                        stateSetter(() {
                                          isLocationPermission = true;
                                        });

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
                                                    bottomSheetContext,
                                                    stateSetter);
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
                                                      bottomSheetContext,
                                                      stateSetter);
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
                                                      bottomSheetContext,
                                                      stateSetter);
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
                                                        bottomSheetContext,
                                                        stateSetter);
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
                                                  bottomSheetContext,
                                                  stateSetter);
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
                                                    bottomSheetContext,
                                                    stateSetter);
                                              }
                                            }
                                          }
                                        } else {
                                          bool isNotificationPermitted =
                                          await Permission
                                              .notification.isGranted;

                                          if (isNotificationPermitted) {
                                            startWritingDataToDB(
                                                bottomSheetContext,
                                                stateSetter);
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
                                                  bottomSheetContext,
                                                  stateSetter);
                                            }
                                          }
                                        }
                                      } else {
                                        await Utils.getLocationPermission(
                                            context, scaffoldKey);
                                        bool isLocationPermitted =
                                        await Permission
                                            .location.isGranted;

                                        if (isLocationPermitted) {
                                          stateSetter(() {
                                            isLocationPermission = true;
                                          });
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
                                                      bottomSheetContext,
                                                      stateSetter);
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
                                                        bottomSheetContext,
                                                        stateSetter);
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
                                                        bottomSheetContext,
                                                        stateSetter);
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
                                                          bottomSheetContext,
                                                          stateSetter);
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
                                                    bottomSheetContext,
                                                    stateSetter);
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
                                                      bottomSheetContext,
                                                      stateSetter);
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
                                                  bottomSheetContext,
                                                  stateSetter);
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
                                                    bottomSheetContext,
                                                    stateSetter);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    })
                                    : Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: CommonButtons.getActionButton(
                                      title: 'Cancel',
                                      context: context,
                                      fontSize:
                                      displayWidth(context) * 0.042,
                                      textColor: Colors.white,
                                      buttonPrimaryColor: buttonBGColor,
                                      borderColor: buttonBGColor,
                                      width: displayWidth(context),
                                      onTap: () {
                                        Get.back();
                                      }),
                                ),
                              ),
                            ),

                            /*Padding(
                              padding: EdgeInsets.only(
                                top : displayWidth(context) * 0.01,
                              ),
                              child: GestureDetector(
                                  onTap: ()async{
                                    final image = await controller1.capture();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                                      imagePath: image.toString(),
                                      uIntList: image,)));
                                  },
                                  child: UserFeedback().getUserFeedback(context)
                              ),
                            ),
*/
                            SizedBox(
                              height: displayWidth(context) * 0.02,
                            )

                          ],
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: addingDataToDB
                              ? SizedBox()
                              : Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor),
                            child: IconButton(
                                onPressed: () async {
                                  isBottomSheetOpened = false;
                                  await tripIsRunningOrNot();
                                  setState(() {
                                    widget.vessel!.id = widget.vessel!.id;
                                  });

                                  stateSetter(() {
                                    addingDataToDB = false;
                                  });

                                  Navigator.of(bottomSheetContext).pop();
                                },
                                icon: Icon(Icons.close_rounded,
                                    color: buttonBGColor)),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
      elevation: 4,
      enableDrag: false,
    ).then((value) async {
      await tripIsRunningOrNot();
      Utils.customPrint('BACK PRESSED');
      isBottomSheetOpened = false;

      addingDataToDB = false;
      isStartButton = false;
      isEndTripButton = true;

      if (tripIsRunning) {
        List<String>? tripData = sharedPreferences!.getStringList('trip_data');
        final tripDetails = await _databaseService.getTrip(tripData![0]);

        var result = Navigator.pushReplacement(
          scaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => NewTripAnalyticsScreen(
                tripId: tripDetails.id,
                vesselId: widget.vessel!.id,
                tripIsRunningOrNot: tripIsRunning,
              )),
        );

        if (result != null) {
          Utils.customPrint('VESSEL SINGLE VIEW RESULT $result');
        }
      }
    });
  }

  /// To enable Bluetooth
  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) async {
      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
        vessel!.add(widget.vessel!);
        await locationPermissions(widget.vessel!.vesselSize!,
            widget.vessel!.name!, widget.vessel!.id!);
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

  buildProgress(double progress, double size) {
    return commonText(
        context: context,
        text: '${(progress * 100).toStringAsFixed(0)} %',
        fontWeight: FontWeight.w500,
        textColor: Colors.black,
        textSize: displayWidth(context) * 0.038,
        textAlign: TextAlign.start);
  }

  subTitleProgress(double progress, double size) {
    if (progress == 1) {
      return Icon(
        Icons.done,
        color: Colors.green,
        size: size,
      );
    }
  }

  /// It will save data to local database when trip is start
  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = widget.vessel!.name;
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
          vesselId: widget.vessel!.id,
          vesselName: vesselName,
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
      BuildContext bottomSheetContext, StateSetter stateSetter) async {
    Utils.customPrint('ISSSSS XXXXXXX: $isServiceRunning');

    stateSetter(() {
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

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data', [
      getTripId,
      widget.vessel!.id!,
      widget.vessel!.name!,
      selectedVesselWeight
    ]);

    await initPlatformStateBGL();


    await tripIsRunningOrNot();

    Navigator.pop(bottomSheetContext);
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
                                      displayHeight(context) * 0.02,
                                      blueColor,
                                      '',
                                      fontWeight: FontWeight.w700),
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
                                      'Ok Go Back', context, Colors.transparent, () {
                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : blueColor,
                                      displayHeight(context) * 0.015,
                                      Colors.white,
                                      '',
                                      fontWeight: FontWeight.w700),
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

  showBluetoothListDialog(BuildContext context, StateSetter stateSetter) {
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
  }

  /// To get all the data of vessel (trip count, avg trip speed etc)
  void getVesselAnalytics(String vesselId) async {
    if (!tripIsRunning) {
      setState(() {
        vesselAnalytics = true;
      });
    }
    List<String> analyticsData =
    await _databaseService.getVesselAnalytics(vesselId);

    setState(() {
      totalDistance = analyticsData[0];
      avgSpeed = analyticsData[1];
      tripsCount = analyticsData[2];
      totalDuration = analyticsData[3];
      vesselAnalytics = false;
    });

    Utils.customPrint('VESSEl ANA $vesselAnalytics');
  }

  endTripMethod() async{


    setState(() {
      isTripEndedOrNot = true;
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

    Navigator.of(context).pop();

    Utils.customPrint(
        'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

    EndTrip().endTrip(
        context: context,
        scaffoldKey: scaffoldKey,
        duration: tripDuration,
        onEnded: () async {
          Utils.customPrint('TRIPPPPPP ENDEDDD:');
          setState(() {
            isEndTripButton = false;
            tripIsEnded = true;
            commonProvider.getTripsByVesselId(
                widget.vessel!.id);
            // isZipFileCreate = true;
          });
          await tripIsRunningOrNot();
          getVesselAnalytics(widget.vessel!.id!);
        });
  }
}