import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';

import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../main.dart';
import '../../models/vessel.dart';
import '../../services/database_service.dart';
import '../bottom_navigation.dart';

class MapScreen extends StatefulWidget {
  final bool? tripIsRunningOrNot;
  final String? vesselId, tripId, calledFrom;
  final bool isAppKilled;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BuildContext? context;

   MapScreen(
      {super.key,
      this.scaffoldKey,
      this.tripIsRunningOrNot,
      this.vesselId,
      this.tripId,
      this.isAppKilled = false,
      this.context,
      this.calledFrom = ''});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = ScreenshotController();

  String tripDistance = '0.00',
      tripDuration = '00:00:00',
      tripSpeed = '0.0',
      tripAvgSpeed = '0.0';

  Timer? durationTimer;

  final DatabaseService _databaseService = DatabaseService();

  bool tripIsRunning = false,
      isuploadTrip = false,
      isTripEnded = false,
      isEndTripBtnClicked = false,
      isDataUpdated = false,
      lastTimePopupBtnClicked = false,
      locationAccuracy = false;

  Trip? tripData;
  CreateVessel? vesselData;

  late CommonProvider commonProvider;
  // List<double>? _accelerometerValues;
  // List<double>? _userAccelerometerValues;
  // List<double>? _gyroscopeValues;
  // List<double>? _magnetometerValues;
String? lprTransperntServiceId;
String? lprTransperntServiceIdStatus;
String? lprUartTX;
String? lprUartTxStatus;
String? connectedBluetoothDeviceName;
String? lprStreamingData='No Lpr Streaming Data Found';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();

    Utils.customPrint("LATEST TRIP ID ${widget.tripId}");

    setState(() {
      tripIsRunning = widget.tripIsRunningOrNot!;
      getData();
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
      Wakelock.enable();
      if (widget.isAppKilled) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(Duration(milliseconds: 100), () {
            bool isOpened =
                sharedPreferences!.getBool("key_lat_time_dialog_open") ?? false;
            if (!isOpened) {
              showEndTripDialogBox(context);
            }
          });
        });
      }
    }
  }

  getRealTimeTripDetails() async {
    if (mounted) {
      setState(() {
        // getTripDetailsFromNoti = true;
      });
    }

    final currentTrip = await _databaseService.getTrip(widget.tripId!);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    WidgetsFlutterBinding.ensureInitialized();

    await sharedPreferences!.reload();

    durationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      Utils.customPrint(
          '##TDATA updated time delay from 1 sec to 400 MS by abhi');
      tripDistance = sharedPreferences!.getString('tripDistance') ?? "0";
      tripSpeed = sharedPreferences!.getString('tripSpeed') ?? "0.0";
      tripAvgSpeed = sharedPreferences!.getString('tripAvgSpeed') ?? "0.0";

      Utils.customPrint("TRIP ANALYTICS SPEED $tripSpeed");
      Utils.customPrint("TRIP ANALYTICS AVG SPEED $tripAvgSpeed");

      var durationTime = DateTime.now().toUtc().difference(createdAtTime);
      tripDuration = Utils.calculateTripDuration(
          ((durationTime.inMilliseconds) ~/ 1000).toInt());

      if (mounted) {
        setState(() {
          // getTripDetailsFromNoti = true;
        });
      }
    });
          LPRDeviceHandler().listenToDeviceConnectionState(
            callBackLprTanspernetserviecId: (String lprTransperntServiceId1,String lprUartTX1){
lprTransperntServiceId=lprTransperntServiceId1;
lprUartTX=lprUartTX1;

            },
            callBackconnectedDeviceName: (bluetoothDeviceName1) {
              connectedBluetoothDeviceName=bluetoothDeviceName1;
            },
            callBackLprTanspernetserviecIdStatus: (String status ){
lprTransperntServiceIdStatus=status;
            },

            callBackLprUartTxStatus: (status) {
              lprUartTxStatus=status;
            },
            callBackLprStreamingData: (lprSteamingData1) {
              
              lprStreamingData=lprSteamingData1;
            },
          );
        

  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    print('XXXX: ${widget.tripIsRunningOrNot}');
    return Screenshot(
      controller: controller,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mapLegend(),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                          center: LatLng(56.704173, 11.543808),
                          minZoom: 12,
                          maxZoom: 14,
                          bounds: LatLngBounds(
                            LatLng(56.7378, 11.6644),
                            LatLng(56.6877, 11.5089),
                          )),
                      children: [
                        TileLayer(
                          tileProvider: AssetTileProvider(),
                          maxZoom: 14,
                          urlTemplate:
                              'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 38),
                            height: displayHeight(context) * 0.12,
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 25, left: 25, right: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        commonText(
                                          context: context,
                                          text: 'Distance',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                        ),
                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        Text(
                                          tripDistance,
                                          style: TextStyle(
                                            fontSize:
                                                displayWidth(context) * 0.05,
                                            fontFamily: outfit,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),

                                        /*commonText(
                                          context: context,
                                          text: tripDistance,
                                          fontWeight: FontWeight.w700,
                                          textColor: Colors.black,
                                          textSize: displayWidth(context) * 0.05,
                                        ),
*/
                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        commonText(
                                          context: context,
                                          text: 'Nautical Miles',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.024,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        commonText(
                                          context: context,
                                          text: 'Speed',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                        ),
                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        Text(
                                          tripSpeed,
                                          style: TextStyle(
                                            fontSize:
                                                displayWidth(context) * 0.05,
                                            fontFamily: outfit,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),

                                        /*commonText(
                                          context: context,
                                          text: tripSpeed,
                                          fontWeight: FontWeight.w700,
                                          textColor: Colors.black,
                                          textSize: displayWidth(context) * 0.05,
                                        ),*/

                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        commonText(
                                          context: context,
                                          text: speedKnot,
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.024,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        commonText(
                                          context: context,
                                          text: 'Time',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                        ),
                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        Text(
                                          tripDuration,
                                          style: TextStyle(
                                            fontSize:
                                                displayWidth(context) * 0.05,
                                            fontFamily: outfit,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),

                                        /* commonText(
                                          context: context,
                                          text: tripDuration,
                                          fontWeight: FontWeight.w700,
                                          textColor: Colors.black,
                                          textSize: displayWidth(context) * 0.05,
                                        ),*/

                                        SizedBox(
                                          height:
                                              displayHeight(context) * 0.003,
                                        ),
                                        commonText(
                                          context: context,
                                          text: 'hh:mm:ss',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.024,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.002,
                          ),
                          Container(
                            color: backgroundColor,
                            width: displayWidth(context),
                            child: Column(
                              children: [
                                isTripEnded
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: displayHeight(context) * 0.03,
                                            bottom:
                                                displayHeight(context) * 0.04),
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  blueColor),
                                        )),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          top: displayHeight(context) * 0.03,
                                          bottom: displayHeight(context) * 0.04,
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child:
                                              CommonButtons
                                                  .getRichTextActionButton(
                                                      icon: Image.asset(
                                                        'assets/icons/end_btn.png',
                                                        height: displayHeight(
                                                                context) *
                                                            0.055,
                                                        width: displayWidth(
                                                                context) *
                                                            0.12,
                                                      ),
                                                      title: 'Stop Trip',
                                                      context: context,
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.042,
                                                      textColor: Colors.white,
                                                      buttonPrimaryColor:
                                                          endTripBtnColor,
                                                      borderColor:
                                                          endTripBtnColor,
                                                      width: displayWidth(
                                                              context) *
                                                          0.75,
                                                      onTap: () async {

                                                        await SystemChrome
                                                            .setPreferredOrientations([
                                                          DeviceOrientation
                                                              .portraitUp,
                                                        ]);

                                                        Utils.customPrint(
                                                            "END TRIP CURRENT TIME ${DateTime.now()}");

                                                        bool isSmallTrip = Utils()
                                                            .checkIfTripDurationIsGraterThan10Seconds(
                                                                tripDuration
                                                                    .split(
                                                                        ":"));

                                                        Utils.customPrint(
                                                            "SMALL TRIPP IDDD bool$isSmallTrip");

                                                        if (!isSmallTrip) {
                                                          Utils()
                                                              .showDeleteTripDialog(
                                                                  context,
                                                                  endTripBtnClick:
                                                                      () {
                                                          LPRDeviceHandler().isSelfDisconnected = true;
                                                            endTrip(
                                                                isTripDeleted:
                                                                    true);

                                                            Utils.customPrint(
                                                                "SMALL TRIPP IDDD ${tripData!.id!}");

                                                            int value = Platform
                                                                    .isAndroid
                                                                ? 1
                                                                : 0;

                                                            Future.delayed(
                                                                Duration(
                                                                    seconds:
                                                                        value),
                                                                () {
                                                              if (!isSmallTrip) {
                                                                Utils.customPrint(
                                                                    "SMALL TRIPP IDDD ${tripData!.id!}");
                                                                DatabaseService()
                                                                    .deleteTripFromDB(
                                                                        tripData!
                                                                            .id!);

                                                                if (widget
                                                                        .calledFrom ==
                                                                    'bottom_nav') {
                                                                  Navigator.pushAndRemoveUntil(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  BottomNavigation()),
                                                                          ModalRoute.withName(
                                                                              ""))
                                                                      .then((value) =>
                                                                          SystemChrome
                                                                              .setPreferredOrientations([
                                                                            DeviceOrientation.portraitUp,
                                                                          ]));
                                                                  ;
                                                                } else if (widget
                                                                        .calledFrom ==
                                                                    'VesselSingleView') {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                } else if (widget
                                                                        .calledFrom ==
                                                                    'tripList') {
                                                                  Navigator.pushAndRemoveUntil(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => BottomNavigation(
                                                                                    tabIndex: commonProvider.bottomNavIndex,
                                                                                  )),
                                                                          ModalRoute.withName(""))
                                                                      .then((value) => SystemChrome.setPreferredOrientations([
                                                                            DeviceOrientation.portraitUp,
                                                                          ]));
                                                                  ;
                                                                } else {
                                                                  Navigator.pushAndRemoveUntil(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  BottomNavigation()),
                                                                          ModalRoute.withName(
                                                                              ""))
                                                                      .then((value) =>
                                                                          SystemChrome
                                                                              .setPreferredOrientations([
                                                                            DeviceOrientation.portraitUp,
                                                                          ]));
                                                                  ;
                                                                }
                                                              }
                                                            });
                                                          }, onCancelClick: () {
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        }
                                                        else {
                                                          Utils()
                                                              .showEndTripDialog(
                                                                  context,
                                                                  () async {
                                                                    LPRDeviceHandler().isSelfDisconnected = true;
                                                            endTrip();
                                                          }, () {
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        }
                                                      }),
                                        ),
                                      ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
//Todo Showing The LpR Stream Status And Info Remove once testing is completed
                                        sensorDailog(),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mapLegend() {
    return Padding(
      padding: const EdgeInsets.only(right: 34, left: 34, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: commonText(
                    context: context,
                    text: '\$0/hr',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.028,
                    textAlign: TextAlign.start),
              ),
              Expanded(
                child: commonText(
                    context: context,
                    text: '\$0-30/hr',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.028,
                    textAlign: TextAlign.start),
              ),
              Expanded(
                child: commonText(
                    context: context,
                    text: '\$30-40/hr',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.028,
                    textAlign: TextAlign.start),
              ),
              Expanded(
                child: commonText(
                    context: context,
                    text: '\$50+/hr',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.028,
                    textAlign: TextAlign.start),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: displayWidth(context),
                  color: Color(0xFF61E4AD),
                  height: 8,
                ),
              ),
              Expanded(
                child: Container(
                  width: displayWidth(context),
                  color: Color(0xFFF5D529),
                  height: 8,
                ),
              ),
              Expanded(
                child: Container(
                  width: displayWidth(context),
                  color: Color(0xFFFA8529),
                  height: 8,
                ),
              ),
              Expanded(
                child: Container(
                  width: displayWidth(context),
                  color: Color(0xFFFB1B5E),
                  height: 8,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  endTrip({bool isTripDeleted = false}) {
    if (durationTimer != null) {
      durationTimer!.cancel();
    }

    setState(() {
      isTripEnded = true;
    });

    Navigator.pop(context);

    Utils.customPrint("TRIP DURATION WHILE END TRIP $tripDuration");

    EndTrip().endTrip(
        context: context,
        scaffoldKey: widget.scaffoldKey,
        duration: tripDuration,
        IOSAvgSpeed: tripAvgSpeed,
        IOSpeed: tripSpeed,
        IOStripDistance: tripDistance,
        onEnded: () async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);

          if (mounted) {
            setState(() {
              tripIsRunning = false;
              isTripEnded = false;
            });
          }

          if (!isTripDeleted) {
            Trip tripDetails = await _databaseService.getTrip(tripData!.id!);

            setState(() {
              tripData = tripDetails;
            });
          }

          isDataUpdated = true;

          if (!isTripDeleted) {
            if (widget.calledFrom == 'bottom_nav') {
                                                                  Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId:tripData!.id ,
                                                                                    vesselId: vesselData?.id,
                                                                                    tripData: tripData,
                                                                                    calledFrom: 'End Trip',
                                                                                                                                                                        vessel: vesselData,

                                                                                  )))
                  .then((value) => SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]));
              ;
            } else if (widget.calledFrom == 'VesselSingleView') {
              Navigator.of(context).pop(true);
            } else if (widget.calledFrom == 'tripList') {
                                                                                Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: tripData?.id,
                                                                                    tripData: tripData,
                                                                                                                                                                        vesselId: tripData?.vesselId,

                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                                                                                                        vessel: vesselData,


                                                                                  )))

                  .then((value) => SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]));
              ;
            } else {
                                                                                Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: tripData?.id,
                                                                                    tripData: tripData,
                                                                                    vessel: vesselData,
                                                                                    vesselId: tripData?.vesselId,
                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                  )))

                  .then((value) => SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]));
              ;
            }
          }
          LPRDeviceHandler().isSelfDisconnected = false;
        });
  }

  getData() async {
    final DatabaseService _databaseService = DatabaseService();
    final tripDetails = await _databaseService.getTrip(widget.tripId!);

    List<CreateVessel> vesselDetails =
        await _databaseService.getVesselNameByID(widget.vesselId!);

    setState(() {
      tripData = tripDetails;
      vesselData = vesselDetails[0];
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  showEndTripDialogBox(BuildContext context) async {
    if (sharedPreferences != null) {
      sharedPreferences!.setBool('reset_dialog_opened', true);
      sharedPreferences!.setBool('key_lat_time_dialog_open', true);
    }

    await SystemChrome.setPreferredOrientations([
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
            child: OrientationBuilder(builder: (ctx2, orientation) {
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
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
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
                                  Center(
                                    child: isEndTripBtnClicked
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            height:
                                                displayHeight(context) * 0.054,
                                            width:
                                                displayWidth(context) * 0.064,
                                            child: CircularProgressIndicator(
                                              color: blueColor,
                                            ))
                                        : CommonButtons.getAcceptButton(
                                            'End Trip',
                                            context,
                                            Colors.transparent, () async {
                                            await SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                            ]);

                                            setState(() {
                                              lastTimePopupBtnClicked = true;
                                            });

                                            bool isSmallTrip = Utils()
                                                .checkIfTripDurationIsGraterThan10Seconds(
                                                    tripDuration.split(":"));

                                            if (!isSmallTrip) {
                                              Navigator.pop(context);

                                              Utils().showDeleteTripDialog(
                                                  context, endTripBtnClick: () {
                                                if (durationTimer != null) {
                                                  durationTimer!.cancel();
                                                }
                                                setState(() {
                                                  isTripEnded = true;
                                                });
                                                Navigator.pop(context);

                                                EndTrip().endTrip(
                                                    context: context,
                                                    scaffoldKey:
                                                        widget.scaffoldKey,
                                                    duration: tripDuration,
                                                    IOSAvgSpeed: tripAvgSpeed,
                                                    IOSpeed: tripSpeed,
                                                    IOStripDistance:
                                                        tripDistance,
                                                    onEnded: () async {
                                                      setState(() {
                                                        tripIsRunning = false;
                                                        isTripEnded = false;
                                                      });
                                                      Trip tripDetails =
                                                          await _databaseService
                                                              .getTrip(tripData!
                                                                  .id!);
                                                      Utils.customPrint(
                                                          "abhi:${tripDetails.time}");
                                                      Utils.customPrint(
                                                          "abhi:${tripDuration}");
                                                      Utils.customPrint(
                                                          "abhi:${tripAvgSpeed}");
                                                      Utils.customPrint(
                                                          "abhi:${tripSpeed}");
                                                      setState(() {
                                                        tripData = tripDetails;
                                                      });

                                                      Utils.customPrint(
                                                          'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                                      Utils.customPrint(
                                                          'TRIP ENDED DETAILS: ${tripData!.isSync}');

                                                      isDataUpdated = true;

                                                      Future.delayed(
                                                          Duration(seconds: 1),
                                                          () {
                                                        if (!isSmallTrip) {
                                                          print('the widget is called from-----' +
                                                              widget.calledFrom
                                                                  .toString());
                                                          Utils.customPrint(
                                                              "SMALL TRIPP IDDD ${tripData!.id!}");
                                                          DatabaseService()
                                                              .deleteTripFromDB(
                                                                  tripData!
                                                                      .id!);

                                                          if (widget
                                                                  .calledFrom ==
                                                              'bottom_nav') {
                                                            Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                BottomNavigation()),
                                                                    ModalRoute
                                                                        .withName(
                                                                            ""))
                                                                .then((value) =>
                                                                    SystemChrome
                                                                        .setPreferredOrientations([
                                                                      DeviceOrientation
                                                                          .portraitUp,
                                                                    ]));
                                                            ;
                                                          } else if (widget
                                                                  .calledFrom ==
                                                              'VesselSingleView') {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          } else if (widget
                                                                  .calledFrom ==
                                                              'tripList') {
                                                            Navigator
                                                                    .pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                BottomNavigation(
                                                                                  tabIndex: commonProvider.bottomNavIndex,
                                                                                )),
                                                                        ModalRoute.withName(
                                                                            ""))
                                                                .then((value) =>
                                                                    SystemChrome
                                                                        .setPreferredOrientations([
                                                                      DeviceOrientation
                                                                          .portraitUp,
                                                                    ]));
                                                            ;
                                                          } else {
                                                            Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                BottomNavigation()),
                                                                    ModalRoute
                                                                        .withName(
                                                                            ""))
                                                                .then((value) =>
                                                                    SystemChrome
                                                                        .setPreferredOrientations([
                                                                      DeviceOrientation
                                                                          .portraitUp,
                                                                    ]));
                                                            ;
                                                          }
                                                        }
                                                      });
                                                    });

                                                Utils.customPrint(
                                                    "SMALL TRIPP IDDD ${tripData!.id!}");
                                              }, onCancelClick: () {
                                                Navigator.pop(context);
                                              });
                                            } else {
                                              setDialogState(() {
                                                isEndTripBtnClicked = true;
                                              });

                                              if (durationTimer != null) {
                                                durationTimer!.cancel();
                                              }
                                              setState(() {
                                                isTripEnded = true;
                                              });
                                              Navigator.pop(context);

                                              EndTrip().endTrip(
                                                  context: context,
                                                  scaffoldKey:
                                                      widget.scaffoldKey,
                                                  duration: tripDuration,
                                                  IOSAvgSpeed: tripAvgSpeed,
                                                  IOSpeed: tripSpeed,
                                                  IOStripDistance: tripDistance,
                                                  onEnded: () async {
                                                    await SystemChrome
                                                        .setPreferredOrientations([
                                                      DeviceOrientation
                                                          .portraitUp,
                                                    ]);

                                                    setState(() {
                                                      tripIsRunning = false;
                                                      isTripEnded = false;
                                                    });
                                                    Trip tripDetails =
                                                        await _databaseService
                                                            .getTrip(
                                                                tripData!.id!);
                                                    Utils.customPrint(
                                                        "abhi:${tripDetails.time}");
                                                    Utils.customPrint(
                                                        "abhi:${tripDuration}");
                                                    Utils.customPrint(
                                                        "abhi:${tripAvgSpeed}");
                                                    Utils.customPrint(
                                                        "abhi:${tripSpeed}");
                                                    setState(() {
                                                      tripData = tripDetails;
                                                    });

                                                    Utils.customPrint(
                                                        'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                                    Utils.customPrint(
                                                        'TRIP ENDED DETAILS: ${tripData!.isSync}');

                                                    isDataUpdated = true;

                                                    if (widget.calledFrom ==
                                                        'bottom_nav') {
                                                                                                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: tripData?.id,
                                                                                    //tripData: tripData,
                                                                                    vesselId: tripData?.vesselId,
                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                  )));

                                                      // Navigator.pushAndRemoveUntil(
                                                      //         context,
                                                      //         MaterialPageRoute(
                                                      //             builder:
                                                      //                 (context) =>
                                                      //                     BottomNavigation()),
                                                      //         ModalRoute
                                                      //             .withName(""))
                                                      //     .then((value) =>
                                                      //         SystemChrome
                                                      //             .setPreferredOrientations([
                                                      //           DeviceOrientation
                                                      //               .portraitUp,
                                                      //         ]));
                                                      ;
                                                    } else if (widget
                                                            .calledFrom ==
                                                        'VesselSingleView') {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    } else if (widget
                                                            .calledFrom ==
                                                        'tripList') {
                                                                                                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: tripData?.id,
                                                                                    //tripData: tripData,
                                                                                    vesselId: tripData?.vesselId,
                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                  )));

                                                      // Navigator
                                                      //         .pushAndRemoveUntil(
                                                      //             context,
                                                      //             MaterialPageRoute(
                                                      //                 builder:
                                                      //                     (context) =>
                                                      //                         BottomNavigation(
                                                      //                           tabIndex: commonProvider.bottomNavIndex,
                                                      //                         )),
                                                      //             ModalRoute
                                                      //                 .withName(
                                                      //                     ""))
                                                      //     .then((value) =>
                                                      //         SystemChrome
                                                      //             .setPreferredOrientations([
                                                      //           DeviceOrientation
                                                      //               .portraitUp,
                                                      //         ]));
                                                    } else {
                                                                                                                                                  Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId: tripData?.id,
                                                                                    //tripData: tripData,
                                                                                    vesselId: tripData?.vesselId,
                                                                                                                                                                        calledFrom: 'End Trip',

                                                                                  )));

                                                      // Navigator.pushAndRemoveUntil(
                                                      //         context,
                                                      //         MaterialPageRoute(
                                                      //             builder:
                                                      //                 (context) =>
                                                      //                     BottomNavigation()),
                                                      //         ModalRoute
                                                      //             .withName(""))
                                                      //     .then((value) =>
                                                      //         SystemChrome
                                                      //             .setPreferredOrientations([
                                                      //           DeviceOrientation
                                                      //               .portraitUp,
                                                      //         ]));
                                                    }
                                                  });
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: CommonButtons.getAcceptButton(
                                        'Continue Trip',
                                        context,
                                        Colors.transparent, () async {
                                      setState(() {
                                        lastTimePopupBtnClicked = true;
                                      });

                                      bool onStartTripLPRDeviceConnected = sharedPreferences!.getBool('onStartTripLPRDeviceConnected') ?? false;

                                      if(onStartTripLPRDeviceConnected){
                                        List<BluetoothDevice> connectedDeviceList = FlutterBluePlus.connectedDevices;
                                        if(connectedDeviceList.isNotEmpty)
                                        {

                                          final _isRunning =
                                          await BackgroundLocator();

                                          Utils.customPrint(
                                              'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                          List<String>? tripData =
                                          sharedPreferences!
                                              .getStringList('trip_data');

                                          reInitializeService();

                                          StartTrip().startBGLocatorTrip(
                                              tripData![0], DateTime.now(), true);

                                          final isRunning2 = await BackgroundLocator
                                              .isServiceRunning();

                                          Utils.customPrint(
                                              'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                          LPRDeviceHandler().setLPRDevice(connectedDeviceList.first);
                                          Navigator.of(context).pop();
                                        }
                                        else
                                        {
                                          final _isRunning =
                                          await BackgroundLocator();

                                          Utils.customPrint(
                                              'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                          List<String>? tripData =
                                          sharedPreferences!
                                              .getStringList('trip_data');

                                          reInitializeService();

                                          StartTrip().startBGLocatorTrip(
                                              tripData![0], DateTime.now(), true);

                                          final isRunning2 = await BackgroundLocator
                                              .isServiceRunning();

                                          Utils.customPrint(
                                              'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                          Navigator.of(context).pop();
                                          LPRDeviceHandler().showDeviceDisconnectedDialog(null);
                                        }
                                      }
                                      else{
                                        final _isRunning =
                                        await BackgroundLocator();

                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                        List<String>? tripData =
                                        sharedPreferences!
                                            .getStringList('trip_data');

                                        reInitializeService();

                                        StartTrip().startBGLocatorTrip(
                                            tripData![0], DateTime.now(), true);

                                        final isRunning2 = await BackgroundLocator
                                            .isServiceRunning();

                                        Utils.customPrint(
                                            'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                        Navigator.of(context).pop();
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
              );
            }),
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

Widget sensorDailog(){
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2)
    ),
    height: displayHeight(context)/2,
    padding: EdgeInsets.all(8),
child: SingleChildScrollView(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

                              lprinfoText('Connected Bluetooth Name: ',connectedBluetoothDeviceName.toString()??'',TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: Colors.orange


      ) ),


                        lprinfoText('LPR UartTX  Status: ',lprUartTxStatus.toString()??'',TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.green


      ) ),




                        lprinfoText('LPR Transparent Service Id Status: ',lprTransperntServiceIdStatus.toString()??'',TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.green


      ) ),


                  lprinfoText('LPR Transparent Service Id:',lprTransperntServiceId??'',TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.deepPurple


      ) ),


            lprinfoText('LPR UartTX Id: ',lprUartTX??'',TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.deepPurple


      ) ),

  
      lprinfoText('Lpr Streaming data:',lprStreamingData??'',TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black
      ),TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.teal


      ) )
      //     Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Text('Lpr Streaming data:  $lprStreamingData',
      //                           style: TextStyle(
      //     color: Colors.black,
      //     fontSize: 16,
      //     fontWeight: FontWeight.w900
      //   ),

        
      //   ),
      // ),
  
    ],
  ),
),

  );
}

Widget lprinfoText(String title,String description,TextStyle titleTextStyle,TextStyle descriptionTextStyle){
  return Padding(
          padding: const EdgeInsets.all(8.0),

  
child:RichText(
      text: TextSpan(
        text: '',
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: title,
              style: titleTextStyle),
          TextSpan(text: description,
          
          style: descriptionTextStyle
          ),
        ],
      ),
    ));

}

}
