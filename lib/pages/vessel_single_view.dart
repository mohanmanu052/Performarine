import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/expansionCard.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/delegate/delegates_screen.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/widgets/log_level.dart';
import '../common_widgets/widgets/user_feed_back.dart';
import 'add_vessel_new/add_new_vessel_screen.dart';
import 'bottom_navigation.dart';
import 'feedback_report.dart';

class VesselSingleView extends StatefulWidget {
  CreateVessel? vessel;
  final bool? isCalledFromSuccessScreen, isCalledFromFleetScreen;
  final VoidCallback? isTripDeleted;

  VesselSingleView(
      {this.vessel,
      this.isCalledFromSuccessScreen = false,
      this.isTripDeleted,
      this.isCalledFromFleetScreen = false});

  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {
  List<CreateVessel>? vessel = [];

  final DatabaseService _databaseService = DatabaseService();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  Timer? notiTimer;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  DeviceInfo? deviceDetails;

  DateTime startDateTime = DateTime.now();
  SharedPreferences? pref;

  bool tripIsEnded = false;

  var uuid = Uuid();

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
      isVesselParticularExpanded = true,
      isVesselAnalyticsExpanded = false,
      isPropulsionDetails = true,
      anotherVesselEndTrip = false;

  late CommonProvider commonProvider;

  bool? gyroscopeAvailable,
      accelerometerAvailable,
      magnetometerAvailable,
      userAccelerometerAvailable;

  String totalDistance = '0',
      avgSpeed = '0',
      tripsCount = '0',
      totalDuration = "00:00:00",
      hullType = '-';

  @override
  void didUpdateWidget(covariant VesselSingleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("came to vessel single view screen.");
    getVesselAnalytics(widget.vessel!.id!);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    tripIsRunningOrNot();

    commonProvider = context.read<CommonProvider>();

    // Utils.customPrint('VESSEL Image ${widget.vessel!.displacement!.isEmpty}');

    checkSensorAvailabelOrNot();

    getVesselAnalytics(widget.vessel!.id!);

    getHullTypes();
  }

  /// To get hull types from secure storage
  getHullTypes() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? hullTypes = await storage.read(key: 'hullTypes');

    if (hullTypes != null) {
      Map<String, dynamic> mapOfHullTypes = jsonDecode(hullTypes);
      Utils.customPrint('HHHHH MAP: ${mapOfHullTypes}');
      mapOfHullTypes.forEach((key, value) {
        if (key == widget.vessel!.hullType.toString()) {
          hullType = value;
        }
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if(didPop)  return;
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
                fontFamily: outfit),
            leading: IconButton(
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
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async {
                    await SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);

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
          bottomSheet: Padding(
            padding: EdgeInsets.only(
              bottom: displayHeight(context) * 0.01,
            ),
            child: GestureDetector(
                onTap: () async {
                  final image = await controller.capture();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedbackReport(
                                imagePath: image.toString(),
                                uIntList: image,
                              )));
                },
                child: UserFeedback().getUserFeedback(context)),
          ),
          drawer: CustomDrawer(
            scaffoldKey: scaffoldKey,
          ),
          body: Stack(
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
                        isCalledFromVesselSingleView: true,
                        isCalledFromFleetScreen: widget.isCalledFromFleetScreen
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: Color(0xffECF3F9),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15))),
                        child: Column(
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0.0, left: 17, right: 17),
                                child: Column(
                                  children: [
                                    Theme(
                                        data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.black,
                                            ),
                                            dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                            collapsedIconColor: Colors.black,
                                            tilePadding: EdgeInsets.zero,
                                            childrenPadding: EdgeInsets.zero,
                                            iconColor: Colors.black,
                                            title: commonText(
                                                context: context,
                                                text: 'Delegate access',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.036,
                                                textAlign: TextAlign.start),
                                            children: [
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    commonText(
                                                        text: 'No Delegates',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        textSize: 16,
                                                        textColor:
                                                            delegateTextHeaderColor),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DelegatesScreen()));
                                                      },
                                                      child: commonText(
                                                          text:
                                                              'Manage Delegate Access',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          textSize: 11,
                                                          textColor: blueColor),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ])),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.black,
                                          ),
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        trailing: Container(
                                          width: displayWidth(context) * 0.12,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  var result =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddNewVesselPage(
                                                        isEdit: true,
                                                        createVessel:
                                                            widget.vessel,
                                                      ),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );

                                                  if (result != null) {
                                                    Utils.customPrint(
                                                        'RESULT 1 ${result[0]}');
                                                    Utils.customPrint(
                                                        'RESULT 1 ${result[1] as CreateVessel}');
                                                    setState(() {
                                                      widget.vessel = result[1]
                                                          as CreateVessel?;
                                                      isDataUpdated = result[0];
                                                    });
                                                  }
                                                },
                                                child: Image.asset(
                                                    'assets/icons/Edit.png',
                                                    width:
                                                        displayWidth(context) *
                                                            0.045,
                                                    color: Colors.black),
                                              ),
                                              !isPropulsionDetails
                                                  ? Icon(
                                                      Icons
                                                          .keyboard_arrow_down_outlined,
                                                      color: Colors.black,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .keyboard_arrow_up_outlined,
                                                      color: Colors.black,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        initiallyExpanded: true,
                                        onExpansionChanged: ((newState) {
                                          setState(() {
                                            isPropulsionDetails = newState;
                                          });

                                          Utils.customPrint(
                                              'EXPANSION CHANGE $isPropulsionDetails');
                                          CustomLogger().logWithFile(Level.info,
                                              "EXPANSION CHANGE $isPropulsionDetails -> $page");
                                        }),
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: EdgeInsets.zero,
                                        title: commonText(
                                            context: context,
                                            text: 'Vessel Dimensions',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.036,
                                            textAlign: TextAlign.start),
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/length.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.045,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.016),
                                                        Flexible(
                                                          child: commonText(
                                                            context: context,
                                                            text:
                                                                '${widget.vessel!.lengthOverall} $feet',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            textColor:
                                                                Colors.black,
                                                            textSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.034,
                                                            textAlign:
                                                                TextAlign.start,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: displayHeight(
                                                                context) *
                                                            0.006),
                                                    commonText(
                                                        context: context,
                                                        text: 'Length(LOA)',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: displayWidth(context) *
                                                      0.015),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/free_board.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.045,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.016),
                                                        Flexible(
                                                          child: commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.freeBoard} $feet',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.034,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: displayHeight(
                                                                context) *
                                                            0.006),
                                                    commonText(
                                                        context: context,
                                                        text: 'Freeboard',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: displayWidth(context) *
                                                      0.015),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                            'assets/icons/beam.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.048,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.016),
                                                        Flexible(
                                                          child: commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.beam} $feet',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.034,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: displayHeight(
                                                                context) *
                                                            0.006),
                                                    commonText(
                                                        context: context,
                                                        text: 'Beam',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: displayWidth(context) *
                                                      0.015),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        RotatedBox(
                                                          quarterTurns: 2,
                                                          child: Image.asset(
                                                              'assets/images/free_board.png',
                                                              width: displayWidth(
                                                                      context) *
                                                                  0.045,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.016),
                                                        Flexible(
                                                          child: commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.draft} $feet',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.034,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: displayHeight(
                                                                context) *
                                                            0.006),
                                                    commonText(
                                                        context: context,
                                                        text: 'Draft',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
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
                                          trailing: Container(
                                            width: displayWidth(context) * 0.12,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    var result =
                                                        await Navigator.of(
                                                                context)
                                                            .push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            AddNewVesselPage(
                                                          isEdit: true,
                                                          createVessel:
                                                              widget.vessel,
                                                        ),
                                                        fullscreenDialog: true,
                                                      ),
                                                    );

                                                    if (result != null) {
                                                      Utils.customPrint(
                                                          'RESULT 1 ${result[0]}');
                                                      Utils.customPrint(
                                                          'RESULT 1 ${result[1] as CreateVessel}');
                                                      setState(() {
                                                        widget.vessel = result[
                                                            1] as CreateVessel?;
                                                        isDataUpdated =
                                                            result[0];
                                                      });
                                                    }
                                                  },
                                                  child: Image.asset(
                                                      'assets/icons/Edit.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.045,
                                                      color: Colors.black),
                                                ),
                                                !isVesselParticularExpanded
                                                    ? Icon(
                                                        Icons
                                                            .keyboard_arrow_down_outlined,
                                                        color: Colors.black,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .keyboard_arrow_up_outlined,
                                                        color: Colors.black,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          onExpansionChanged: ((newState) {
                                            setState(() {
                                              isVesselParticularExpanded =
                                                  newState;
                                            });

                                            Utils.customPrint(
                                                'EXPANSION CHANGE $isVesselParticularExpanded');
                                            CustomLogger().logWithFile(
                                                Level.info,
                                                "EXPANSION CHANGE $isVesselParticularExpanded -> $page");
                                          }),
                                          tilePadding: EdgeInsets.zero,
                                          childrenPadding: EdgeInsets.zero,
                                          title: commonText(
                                              context: context,
                                              text: 'Propulsion Details',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.036,
                                              textAlign: TextAlign.start),
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          commonText(
                                                              context: context,
                                                              text: '130 $hp',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.04,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  'Diesel Engine\nPower',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.grey,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.024,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  '320 $kiloWattHour',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.04,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  'Electric Engine\nPower',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.grey,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.024,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          commonText(
                                                              context: context,
                                                              text: widget
                                                                      .vessel!
                                                                      .weight!
                                                                      .isEmpty
                                                                  ? '0 $pound'
                                                                  : '${widget.vessel!.weight} $pound',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.04,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  'Displacement',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.grey,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.024,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      displayHeight(context) *
                                                          0.012,
                                                ),
                                                Row(
                                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      //flex: 01,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          commonText(
                                                              context: context,
                                                              text: hullType,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.04,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: 'Hull Type',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.grey,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.024,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 02,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          widget.vessel!.mMSI! == ""
                                                              ? commonText(
                                                                  context:
                                                                      context,
                                                                  text: '-',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  textSize:
                                                                      displayWidth(context) *
                                                                          0.04,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start)
                                                              : commonText(
                                                                  context:
                                                                      context,
                                                                  text: widget
                                                                      .vessel!
                                                                      .mMSI,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.04,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: 'MMSI',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.grey,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.024,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
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
                              height: 8,
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
                                  collapsedIconColor: Colors.black,
                                  initiallyExpanded: true,
                                  onExpansionChanged: ((newState) {
                                    setState(() {
                                      isVesselAnalyticsExpanded = newState;
                                    });

                                    Utils.customPrint(
                                        'EXPANSION CHANGE $isVesselAnalyticsExpanded');
                                  }),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  title: commonText(
                                      context: context,
                                      text: 'VESSEL ANALYTICS',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.038,
                                      textAlign: TextAlign.start,
                                      fontFamily: poppins),
                                  children: [
                                    vesselAnalytics
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: blueColor,
                                            ),
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
                            widget.isCalledFromFleetScreen!
                            ? SizedBox(height: displayHeight(context) * 0.04,)
                            : Theme(
                              data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.black,
                                  ),
                                  dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                collapsedIconColor: Colors.black,
                                initiallyExpanded: true,
                                onExpansionChanged: ((newState) {
                                  Utils.customPrint('CURRENT STAT $newState');
                                }),
                                textColor: Colors.black,
                                iconColor: Colors.black,
                                title: commonText(
                                    context: context,
                                    text: 'TRIP HISTORY',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start,
                                    fontFamily: poppins),
                                children: [
                                  TripViewListing(
                                    scaffoldKey: scaffoldKey,
                                    vesselId: widget.vessel!.id,
                                    calledFrom: 'VesselSingleView',
                                    isTripDeleted: () async {
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
                                      commonProvider.getTripsByVesselId(
                                          widget.vessel!.id!);
                                      getVesselAnalytics(widget.vessel!.id!);
                                    },
                                  ),
                                  SizedBox(
                                    height: displayHeight(context) * 0.023,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                          ],
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
    );
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
}
