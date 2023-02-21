import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../common_widgets/widgets/status_tag.dart';

class TripAnalyticsScreen extends StatefulWidget {
  String? tripId;
  final String? vesselId, calledFrom;
  final bool? tripIsRunningOrNot;
  TripAnalyticsScreen(
      {Key? key,
      this.tripId,
      this.vesselId,
      this.tripIsRunningOrNot,
      this.calledFrom})
      : super(key: key);

  @override
  State<TripAnalyticsScreen> createState() => _TripAnalyticsScreenState();
}

class _TripAnalyticsScreenState extends State<TripAnalyticsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  CreateVessel? vesselData;
  Trip? tripData;

  bool tripIsRunning = false, isuploadTrip = false, isTripEnded = false;

  String tripDistance = '0.00';
  String tripDuration = '00:00:00';
  String tripSpeed = '0.0';
  String tripAvgSpeed = '0.0';

  String? finalTripDuration, finalTripDistance, finalAvgSpeed;

  FlutterBackgroundService service = FlutterBackgroundService();

  bool isTripUploaded = false, vesselIsSync = false, isDataUpdated = false;

  int progress = 0;
  Timer? progressTimer;
  double finalProgress = 0;

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;
  late DeviceInfoPlugin deviceDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getVesselDataById();
    sharedPreferences!.remove('sp_key_called_from_noti');

    setState(() {
      tripIsRunning = widget.tripIsRunningOrNot!;
      getData();
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
    }

    commonProvider = context.read<CommonProvider>();

    deviceDetails = DeviceInfoPlugin();
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

  getRealTimeTripDetails() async {
    service.on('tripAnalyticsData').listen((event) {
      tripDistance = event!['tripDistance'];
      tripDuration = event['tripDuration'];
      tripSpeed = event['tripSpeed'].toString();
      tripAvgSpeed = event['tripAvgSpeed'].toString();

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        if (widget.calledFrom == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              ModalRoute.withName(""));
          return false;
        } else if (widget.calledFrom! == 'HomePage') {
          if (isDataUpdated) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          tabIndex: 1,
                        )),
                ModalRoute.withName(""));
            return false;
          } else {
            Navigator.of(context).pop();
          }
        } else if (widget.calledFrom == 'VesselSingleView') {
          Navigator.of(context).pop(isDataUpdated);
          return false;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xfff2fffb),
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xfff2fffb),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              // Navigator.of(context).pop();

              if (widget.calledFrom == null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    ModalRoute.withName(""));
              } else if (widget.calledFrom! == 'HomePage') {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              tabIndex: 1,
                            )),
                    ModalRoute.withName(""));
              } else if (widget.calledFrom! == 'HomePage') {
                if (isDataUpdated) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                tabIndex: 1,
                              )),
                      ModalRoute.withName(""));
                } else {
                  Navigator.of(context).pop();
                }
              } else if (widget.calledFrom == 'VesselSingleView') {
                Navigator.of(context).pop(isDataUpdated);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: vesselData == null
                ? ''
                : vesselData!.name == null || vesselData!.name == ''
                    ? ''
                    : vesselData!.name,
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.032,
          ),
          actions: [
            tripIsRunning
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: CustomPaint(
                      painter: StatusTag(color: Color(0XFF41C1C8)),
                      child: Container(
                        margin:
                            EdgeInsets.only(left: displayWidth(context) * 0.05),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: commonText(
                              context: context,
                              text: "Trip In Progress",
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
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
          //backgroundColor: Colors.white,
        ),
        body: tripData == null && vesselData == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                //margin: EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  children: [
                    SizedBox(
                      height: tripIsRunning
                          ? displayHeight(context) * 0.43
                          : displayHeight(context) * 0.3,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: displayHeight(context) * 0.01,
                            ),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Color(0xfff2fffb),
                                  child: Image.asset(
                                    'assets/images/boat.gif',
                                    height: displayHeight(context) * 0.22,
                                    width: displayWidth(context),
                                    fit: BoxFit.contain,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: tripIsRunning
                          ? Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Container(
                                        height: displayHeight(context) / 1.8,
                                        margin: EdgeInsets.only(
                                            top: 20, left: 17, right: 17),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 12),
                                                  child: commonText(
                                                    context: context,
                                                    text: 'Analytics',
                                                    fontWeight: FontWeight.w700,
                                                    textColor: Colors.black87,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.032,
                                                  ),
                                                ),
                                                vesselAnalytics(
                                                    context,
                                                    tripIsRunning
                                                        ? '$tripDuration'
                                                        : '${tripData!.time} ',
                                                    tripIsRunning
                                                        ? '${(tripDistance)}'
                                                        : '${tripData!.distance} ',
                                                    tripIsRunning
                                                        ? '${tripSpeed} '
                                                        : '${tripData!.speed} ',
                                                    tripIsRunning
                                                        ? '${tripAvgSpeed} '
                                                        : '${tripData!.avgSpeed} ',
                                                    tripIsRunning),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                                  displayHeight(context) * 0.01,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 17, vertical: 10),
                                      child: isTripEnded
                                          ? Center(
                                              child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      circularProgressColor),
                                            ))
                                          : CommonButtons.getActionButton(
                                              title: 'End Trip',
                                              context: context,
                                              fontSize:
                                                  displayWidth(context) * 0.042,
                                              textColor: Colors.white,
                                              buttonPrimaryColor: buttonBGColor,
                                              borderColor: buttonBGColor,
                                              width: displayWidth(context),
                                              onTap: () async {
                                                Utils().showEndTripDialog(
                                                    context, () async {
                                                  setState(() {
                                                    isTripEnded = true;
                                                  });
                                                  Navigator.pop(context);
                                                  CreateTrip().endTrip(
                                                      context: context,
                                                      scaffoldKey: scaffoldKey,
                                                      onEnded: () async {
                                                        setState(() {
                                                          tripIsRunning = false;
                                                          isTripEnded = true;
                                                        });
                                                        Trip tripDetails =
                                                            await _databaseService
                                                                .getTrip(
                                                                    tripData!
                                                                        .id!);
                                                        setState(() {
                                                          tripData =
                                                              tripDetails;
                                                        });

                                                        Utils.customPrint(
                                                            'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                                        Utils.customPrint(
                                                            'TRIP ENDED DETAILS: ${tripData!.isSync}');

                                                        isDataUpdated = true;
                                                        // Navigator.pop(context);
                                                      });
                                                }, () {
                                                  Navigator.pop(context);
                                                });
                                              }),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Card(
                              color: Colors.white,
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      topRight: Radius.circular(50))),
                              child: Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          height: displayHeight(context) / 1.8,
                                          margin: EdgeInsets.only(
                                              top: 20, left: 17, right: 17),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12),
                                                    child: commonText(
                                                      context: context,
                                                      text: 'Analytics',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      textColor: Colors.black87,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.032,
                                                    ),
                                                  ),
                                                  vesselAnalytics(
                                                      context,
                                                      tripIsRunning
                                                          ? '$tripDuration'
                                                          : '${tripData!.time} ',
                                                      tripIsRunning
                                                          ? '${(tripDistance)}'
                                                          : '${tripData!.distance} ',
                                                      tripIsRunning
                                                          ? '$tripSpeed '
                                                          : '${tripData!.speed} ',
                                                      tripIsRunning
                                                          ? '$tripAvgSpeed '
                                                          : '${tripData!.avgSpeed} ',
                                                      tripIsRunning),
                                                ],
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.01,
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 12),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        commonText(
                                                          context: context,
                                                          text: 'Trip Details',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          textColor:
                                                              Colors.black87,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.032,
                                                        ),
                                                        Row(
                                                          children: [
                                                            commonText(
                                                              context: context,
                                                              text:
                                                                  'Trip Status:',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor: Colors
                                                                  .black87,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.03,
                                                            ),
                                                            SizedBox(
                                                              width: 6,
                                                            ),
                                                            commonText(
                                                              context: context,
                                                              text: tripIsRunning
                                                                  ? 'Trip InProgress'
                                                                  : 'Trip Ended',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  tripIsRunning
                                                                      ? Color(
                                                                          0xFFAE6827)
                                                                      : Colors
                                                                          .green,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.03,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: displayHeight(
                                                              context) *
                                                          0.02,
                                                    ),
                                                    Row(
                                                      children: [
                                                        commonText(
                                                          context: context,
                                                          text: 'Start Date',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textColor:
                                                              Colors.grey,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.03,
                                                        ),
                                                        SizedBox(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.04,
                                                        ),
                                                        commonText(
                                                          context: context,
                                                          text:
                                                              ': ${DateFormat('dd/MM/yyyy').format(DateTime.parse(tripData!.createdAt!))}',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textColor:
                                                              Colors.black,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.03,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Row(
                                                      children: [
                                                        commonText(
                                                          context: context,
                                                          text: 'Start Time',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textColor:
                                                              Colors.grey,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.03,
                                                        ),
                                                        SizedBox(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.04,
                                                        ),
                                                        commonText(
                                                          context: context,
                                                          text:
                                                              ': ${DateFormat('hh:mm').format(DateTime.parse(tripData!.createdAt!))}',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textColor:
                                                              Colors.black,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.03,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    tripIsRunning
                                                        ? Container()
                                                        : Row(
                                                            children: [
                                                              commonText(
                                                                context:
                                                                    context,
                                                                text:
                                                                    'End Date',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                textColor:
                                                                    Colors.grey,
                                                                textSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.03,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.06,
                                                              ),
                                                              commonText(
                                                                context:
                                                                    context,
                                                                text:
                                                                    ': ${DateFormat('dd/MM/yyyy').format(DateTime.parse(tripData!.updatedAt!))}',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                textSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.03,
                                                              ),
                                                            ],
                                                          ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    tripIsRunning
                                                        ? Container()
                                                        : Row(
                                                            children: [
                                                              commonText(
                                                                context:
                                                                    context,
                                                                text:
                                                                    'End Time',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                textColor:
                                                                    Colors.grey,
                                                                textSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.03,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.06,
                                                              ),
                                                              commonText(
                                                                context:
                                                                    context,
                                                                text:
                                                                    ': ${DateFormat('hh:mm').format(DateTime.parse(tripData!.updatedAt!))}',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                textSize:
                                                                    displayWidth(
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
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 17, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CommonButtons.getActionButton(
                                                title: 'Download Trip Data',
                                                context: context,
                                                fontSize:
                                                    displayWidth(context) *
                                                        0.034,
                                                textColor: Colors.white,
                                                buttonPrimaryColor:
                                                    Color(0xFF889BAB),
                                                borderColor: Color(0xFF889BAB),
                                                width:
                                                    displayWidth(context) / 2.3,
                                                onTap: () async {
                                                  downloadTrip(false);
                                                }),
                                            isTripUploaded
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        right: displayWidth(
                                                                context) *
                                                            0.2),
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              circularProgressColor),
                                                    )),
                                                  )
                                                : tripData?.isSync != 0
                                                    ? CommonButtons
                                                        .getActionButton(
                                                            title: 'Home',
                                                            context: context,
                                                            fontSize: displayWidth(
                                                                    context) *
                                                                0.034,
                                                            textColor: Colors
                                                                .white,
                                                            buttonPrimaryColor:
                                                                buttonBGColor,
                                                            borderColor:
                                                                buttonBGColor,
                                                            width:
                                                                displayWidth(
                                                                        context) /
                                                                    2.3,
                                                            onTap: () async {
                                                              Navigator
                                                                  .pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                HomePage(),
                                                                      ),
                                                                      ModalRoute
                                                                          .withName(
                                                                              ""));
                                                            })
                                                    : CommonButtons
                                                        .getActionButton(
                                                            title:
                                                                'Upload Trip Data',
                                                            context: context,
                                                            fontSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.034,
                                                            textColor: Colors
                                                                .white,
                                                            buttonPrimaryColor:
                                                                buttonBGColor,
                                                            borderColor:
                                                                buttonBGColor,
                                                            width: displayWidth(
                                                                    context) /
                                                                2.3,
                                                            onTap: () async {
                                                              Utils().check(
                                                                  scaffoldKey);

                                                              if (tripData
                                                                      ?.isSync !=
                                                                  0) {
                                                                Utils.customPrint(
                                                                    'UPLOADED ${tripData?.isSync != 0}');
                                                                Utils.customPrint(
                                                                    'UPLOADED 1 ${isTripUploaded}');

                                                                Utils
                                                                    .showSnackBar(
                                                                  context,
                                                                  scaffoldKey:
                                                                      scaffoldKey,
                                                                  message:
                                                                      'File already uploaded',
                                                                );
                                                                return;
                                                              }

                                                              downloadTrip(
                                                                  true);

                                                              var connectivityResult =
                                                                  await (Connectivity()
                                                                      .checkConnectivity());
                                                              if (connectivityResult ==
                                                                  ConnectivityResult
                                                                      .mobile) {
                                                                Utils.customPrint(
                                                                    'Mobile');
                                                                showDialogBoxToUploadTrip();
                                                              } else if (connectivityResult ==
                                                                  ConnectivityResult
                                                                      .wifi) {
                                                                setState(() {
                                                                  isTripUploaded =
                                                                      true;
                                                                });
                                                                uploadDataIfDataIsNotSync();

                                                                Utils
                                                                    .customPrint(
                                                                        'WIFI');
                                                              }
                                                            })
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
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

  Future<bool> vesselIsSyncOrNot(String vesselId) async {
    bool result = await _databaseService.getVesselIsSyncOrNot(vesselId);

    setState(() {
      vesselIsSync = result;
      Utils.customPrint('Vessel isSync $vesselIsSync');
    });

    /*setState(() {
      isEndTripButton = tripIsRunning;
      isStartButton = !tripIsRunning;
    });*/
    return result;
  }

  showDialogBoxToUploadTrip() {
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
                  height: displayHeight(context) * 0.3,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                      'Your carrier may charge for Data Usage to upload trip data do you want to proceed?',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                              /* SizedBox(
                                height: displayHeight(context) * 0.015,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                      'The vessel will be visible in your vessel list and you can record trips with it again',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.grey,
                                  textSize: displayWidth(context) * 0.036,
                                  textAlign: TextAlign.center),*/
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey)),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Cancel', context, primaryColor, () {
                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      Colors.grey.shade400,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      displayHeight(context) * 0.018,
                                      Colors.grey.shade400,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'OK', context, primaryColor, () async {
                                    setState(() {
                                      isTripUploaded = true;
                                    });
                                    setDialogState(() {
                                      uploadDataIfDataIsNotSync();
                                    });

                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.018,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
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

  startSensorFunctionality(Trip tripData) async {
    AndroidDeviceInfo androidDeviceInfo = await deviceDetails.androidInfo;

    String? tripDuration =
        sharedPreferences!.getString("tripDuration") ?? '00:00:00';
    String? tripDistance = sharedPreferences!.getString("tripDistance") ?? '1';
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';
    String? tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '1';

    var startPosition = tripData.startPosition!.split(",");
    var endPosition = tripData.endPosition!.split(",");
    Utils.customPrint('START POSITION 0 ${startPosition}');

    //TODO remove below code
    /*setState(() {
      isTripUploaded = false;
    });
    return;*/
    //String startLong = ;

    var queryParameters;
    queryParameters = {
      "id": tripData.id,
      "load": tripData.currentLoad,
      "sensorInfo": [
        {"make": "qualicom", "name": "gps"}
      ],
      "deviceInfo": {
        "deviceId": androidDeviceInfo.id,
        "model": androidDeviceInfo.model,
        "version": androidDeviceInfo.version.release,
        "make": androidDeviceInfo.manufacturer,
        "board": androidDeviceInfo.board,
        "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
      },
      "startPosition": startPosition
      /*json
          .decode(tripData.startPosition!.toString())
          .cast<String>()
          .toList()*/
      ,
      "endPosition": endPosition,
      /*json.decode(tripData.endPosition!.toString()).cast<String>().toList()*/
      "vesselId": tripData.vesselId,
      "filePath": 'storage/emulated/0/Download/${tripData.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      "duration": tripDuration,
      "distance": double.parse(tripDistance),
      "speed": double.parse(tripSpeed),
      "avgSpeed": double.parse(tripAvgSpeed),
      //"userID": commonProvider.loginModel!.userId!
    };

    Utils.customPrint('Send Sensor Data: $queryParameters');

    commonProvider
        .sendSensorInfo(
            context,
            commonProvider.loginModel!.token!,
            File('${tripData.filePath}'),
            queryParameters,
            tripData.id!,
            scaffoldKey)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          await cancelOnGoingProgressNotification(tripData.id!);

          setState(() {
            isTripUploaded = false;
          });
          Utils.customPrint("tripData!.id: ${tripData.id}");
          _databaseService.updateTripIsSyncStatus(1, tripData.id.toString());
          Trip tripDetails = await _databaseService.getTrip(tripData.id!);
          Utils.customPrint('TRIP DETAILS: ${tripDetails.toJson()}');
          setState(() {
            this.tripData = tripDetails;
            Utils.customPrint('TRIP STATUS ${tripData.isSync}');
          });

          showSuccessNoti();

          isDataUpdated = true;

          // widget.tripUploadedSuccessfully!.call();
        } else {
          setState(() {
            isTripUploaded = false;
          });
          showFailedNoti(tripData.id!);
        }
      } else {
        setState(() {
          isTripUploaded = false;
        });
        showFailedNoti(tripData.id!);
      }
    }).catchError((onError, s) {
      if (mounted) {
        setState(() {
          isTripUploaded = false;
        });
      }
      // showFailedNoti(tripData.id!);
      Utils.customPrint('ON ERROR $onError \n $s');
    });
  }

  Future<void> cancelOnGoingProgressNotification(String id) async {
    //progressTimer!.cancel();
    flutterLocalNotificationsPlugin.cancel(9989);
    // setState(() {
    //   progress = 100;
    // });
    return;
  }

  uploadDataIfDataIsNotSync() async {
    await vesselIsSyncOrNot(tripData!.vesselId.toString());
    Utils.customPrint('VESSEL STATUS isSync $vesselIsSync');

    const int maxProgress = 10;
    progress = 0;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'progress channel',
      'progress channel',
      channelDescription: 'progress channel description',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: false,
      ongoing: true,
      indeterminate: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        9989, 'Uploading vessel details...', '', platformChannelSpecifics,
        payload: 'item x');

    commonProvider.init();

    if (!vesselIsSync) {
      CreateVessel vesselData = await _databaseService
          .getVesselFromVesselID((tripData!.vesselId.toString()));

      Utils.customPrint('VESSEL DATA ${vesselData.id}');

      commonProvider.addVesselRequestModel = CreateVessel();
      commonProvider.addVesselRequestModel!.id = vesselData.id;
      commonProvider.addVesselRequestModel!.name = vesselData.name;
      commonProvider.addVesselRequestModel!.model = vesselData.model;
      commonProvider.addVesselRequestModel!.builderName =
          vesselData.builderName;
      commonProvider.addVesselRequestModel!.regNumber = vesselData.regNumber;
      commonProvider.addVesselRequestModel!.mMSI = vesselData.mMSI;
      commonProvider.addVesselRequestModel!.engineType = vesselData.engineType;
      commonProvider.addVesselRequestModel!.fuelCapacity =
          vesselData.fuelCapacity;
      commonProvider.addVesselRequestModel!.weight = vesselData.weight;
      commonProvider.addVesselRequestModel!.freeBoard = vesselData.freeBoard;
      commonProvider.addVesselRequestModel!.lengthOverall =
          vesselData.lengthOverall;
      commonProvider.addVesselRequestModel!.beam = vesselData.beam;
      commonProvider.addVesselRequestModel!.draft = vesselData.draft;
      commonProvider.addVesselRequestModel!.vesselSize = vesselData.vesselSize;
      commonProvider.addVesselRequestModel!.capacity = vesselData.capacity;
      commonProvider.addVesselRequestModel!.builtYear = vesselData.builtYear;
      commonProvider.addVesselRequestModel!.createdAt = vesselData.createdAt;
      commonProvider.addVesselRequestModel!.batteryCapacity =
          vesselData.batteryCapacity;
      //commonProvider.addVesselRequestModel!.imageURLs = vesselData.imageURLs!;

      if (vesselData.imageURLs!.isNotEmpty) {
        finalSelectedFiles.add(File(vesselData.imageURLs!));
        commonProvider.addVesselRequestModel!.selectedImages =
            finalSelectedFiles;

        Utils.customPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
      } else {
        commonProvider.addVesselRequestModel!.selectedImages = [];
      }

      commonProvider
          .addVessel(
              context,
              commonProvider.addVesselRequestModel,
              commonProvider.loginModel!.userId!,
              commonProvider.loginModel!.token!,
              scaffoldKey)
          .then((value) async {
        if (value != null) {
          if (value.status!) {
            // Utils.customPrint('DATA');
            await _databaseService.updateIsSyncStatus(
                1, tripData!.vesselId.toString());

            /*setState(() {
              isTripUploaded = false;
            });*/

            startSensorFunctionality(tripData!);
          } /* else if (value.statusCode == 400) {
            setState(() {
              isTripUploaded = false;
            });
          } */
          else {
            Utils.customPrint('UPLOADEDDDD: ${value.message}');
            await cancelOnGoingProgressNotification(tripData!.id!);
            showFailedNoti(tripData!.id!);
            setState(() {
              isTripUploaded = false;
            });
          }
        } else {
          await cancelOnGoingProgressNotification(tripData!.id!);
          showFailedNoti(tripData!.id!);
          setState(() {
            isTripUploaded = false;
          });
        }
      });
    } else {
      setState(() {
        isTripUploaded = false;
      });
      startSensorFunctionality(tripData!);
    }
  }

  showFailedNoti(String id) async {
    // progressTimer!.cancel();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: false);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(9987, id,
        'Failed to upload. Please try again', platformChannelSpecifics,
        payload: 'item x');
  }

  showSuccessNoti() async {
    // progressTimer!.cancel();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            progress: 100,
            maxProgress: 100);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        9989, 'Trip uploaded successfully', '', platformChannelSpecifics,
        payload: 'item x');
  }

  downloadTrip(bool isuploadTrip) async {
    Utils.customPrint('DOWLOAD Started!!!');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted;
    if (androidInfo.version.sdkInt < 29) {
      isStoragePermitted = await Permission.storage.status;

      if (isStoragePermitted.isGranted) {
        //File copiedFile = File('${ourDirectory!.path}.zip');
        File copiedFile = File('${ourDirectory!.path}/${tripData!.id}.zip');

        Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

        Directory directory;

        if (Platform.isAndroid) {
          directory =
              Directory("storage/emulated/0/Download/${tripData!.id}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);

        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

        if (copiedFile.existsSync()) {
          if (!isuploadTrip) {
            Utils.showSnackBar(
              context,
              scaffoldKey: scaffoldKey,
              message: 'File downloaded successfully',
            );
          }
          /*Utils.showActionSnackBar(
                                                          context,
                                                          scaffoldKey,
                                                          'File downloaded successfully',
                                                          () async {
                                                        Utils.customPrint(
                                                            'Open Btn clicked ttttt');
                                                        var result =
                                                            await OpenFile.open(
                                                                directory.path);

                                                        Utils.customPrint(
                                                            "dataaaaa: ${result.message} ggg ${result.type}");
                                                      });*/
        }
      } else {
        await Utils.getStoragePermission(context);
        var isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          File copiedFile = File('${ourDirectory!.path}.zip');

          Directory directory;

          if (Platform.isAndroid) {
            directory =
                Directory("storage/emulated/0/Download/${tripData!.id}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          copiedFile.copy(directory.path);

          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

          if (copiedFile.existsSync()) {
            Utils.showSnackBar(
              context,
              scaffoldKey: scaffoldKey,
              message: 'File downloaded successfully',
            );

            /*Utils.showActionSnackBar(
                                                            context,
                                                            scaffoldKey,
                                                            'File downloaded successfully',
                                                            () {
                                                          Utils.customPrint(
                                                              'Open Btn clicked');
                                                          OpenFile.open(
                                                                  directory.path)
                                                              .catchError(
                                                                  (onError) {
                                                            Utils.customPrint(onError);
                                                          });
                                                        });*/
          }
        }
      }
    } else {
      //File copiedFile = File('${ourDirectory!.path}.zip');
      File copiedFile = File('${ourDirectory!.path}/${tripData!.id}.zip');

      Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

      Directory directory;

      if (Platform.isAndroid) {
        directory =
            Directory("storage/emulated/0/Download/${tripData!.id}.zip");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      copiedFile.copy(directory.path);

      Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

      if (copiedFile.existsSync()) {
        if (!isuploadTrip) {
          Utils.showSnackBar(
            context,
            scaffoldKey: scaffoldKey,
            message: 'File downloaded successfully',
          );
        }
      }
    }
  }
}
