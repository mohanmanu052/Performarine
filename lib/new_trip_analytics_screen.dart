import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/custom_chart/custom_barchart_widget.dart';
import 'package:performarine/models/speed_reports_model.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/utils/constants.dart';
import 'common_widgets/utils/utils.dart';
import 'common_widgets/widgets/common_buttons.dart';
import 'common_widgets/widgets/common_widgets.dart';
import 'common_widgets/widgets/log_level.dart';
import 'common_widgets/widgets/user_feed_back.dart';
import 'main.dart';
import 'models/reports_model.dart';
import 'models/trip.dart';
import 'models/vessel.dart';

class NewTripAnalyticsScreen extends StatefulWidget {
  String? vesselName;
  String? tripId;
  AvgInfo? avgInfo;
  CreateVessel? vessel;
  final String? vesselId, calledFrom;
  final bool? tripIsRunningOrNot;
  final bool isAppKilled;
  Trip? tripData;
  VoidCallback? isTripDeleted;

  NewTripAnalyticsScreen({
    super.key,
    this.vesselName,
    this.avgInfo,
    this.tripId,
    this.vesselId,
    this.vessel,
    this.tripIsRunningOrNot,
    this.isAppKilled = false,
    this.calledFrom,
    this.tripData,
    this.isTripDeleted,
  });

  @override
  State<NewTripAnalyticsScreen> createState() => _NewTripAnalyticsScreenState();
}

class _NewTripAnalyticsScreenState extends State<NewTripAnalyticsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  CreateVessel? vesselData;
  Trip? tripData;

  String tripDistance = '0.00',
      tripDuration = '00:00:00',
      dateOfJourney = '',
      yearOfTheJourney = '',
      peopleOnBoard = '';

  //This Value Make Help Every Bar Stick With 24 Hrs Based On This Calculations Will Be Performed
  //int total24HrsDuration=1440;

  bool cancelVisible = true;
  bool? internet;

  final List<NewChartData> chartData = [
    NewChartData(2010, 35),
    NewChartData(2011, 13),
    NewChartData(2012, 34),
    NewChartData(2013, 27),
    NewChartData(2014, 40)
  ];

  // List<SalesData> data = [
  //   SalesData('2023-08-15', '35', 25),
  //   SalesData('2023-08-15', '28', 38),
  //   SalesData('2023-08-17', '34', 24),
  //   SalesData('2023-08-18', '32', 52),
  //   SalesData('2023-08-19', '40', 60)
  // ];

  final controller = ScreenshotController();

  late CommonProvider commonProvider;
  bool isBtnClick = false,
      isDeleteTripBtnClicked = false,
      isDeletedSuccessfully = false;
  StateSetter? internalStateSetter;

  int? tripIsSyncOrNot;

  Future<SpeedReportsModel>? speedReportData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    commonProvider = context.read<CommonProvider>();

    sharedPreferences!.remove('sp_key_called_from_noti');
    getSpeedReport();

    // speedReportData = commonProvider.speedReport(context,
    //     commonProvider.loginModel!.token!, widget.vesselId!, scaffoldKey);

    setState(() {
      getData();
    });

    Utils.customPrint('CURRENT TIME TIME ${tripDuration}');

    //Utils.customPrint('CURRENT TIME TIME ${tripData!.time}');
  }

  getSpeedReport() async {
    if (commonProvider.loginModel?.token != null) {
      speedReportData = commonProvider.speedReport(context,
          commonProvider.loginModel!.token!, widget.vesselId!, scaffoldKey);
    } else {
      await commonProvider.getToken();
      speedReportData = commonProvider.speedReport(context,
          commonProvider.loginModel!.token!, widget.vesselId!, scaffoldKey);
    }
  }

  @override
  void dispose() {
    if (widget.calledFrom == 'Report') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ]);
    } else {}

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (widget.calledFrom == 'End Trip') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation()),
              ModalRoute.withName(""));
        } else {
          Navigator.pop(context);
        }
        return Future.value(true);
      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                if (widget.calledFrom == 'End Trip') {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: commonText(
                context: context,
                text:tripData?.name!=null&&tripData!.name!.isNotEmpty?tripData?.name: 'Trip Analytics',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.042,
                fontFamily: outfit),
            actions: [
              InkWell(
                onTap: () async {
                  Utils.customPrint("Trip id is: ${tripData!.id}");
                  bool tripUploadedStatus = false;
                  if (tripData!.isSync == 0) {
                    tripUploadedStatus = true;
                  }
                  if (tripData!.tripStatus == 1) {
                    showDeleteTripDialogBox(context, tripData!.id!, () {
                      Utils.customPrint("call back for delete trip in list");
                    }, scaffoldKey, tripUploadedStatus);
                  } else {}
                },
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid
                      ? displayWidth(context) * 0.055
                      : displayWidth(context) * 0.05,
                ),
              ),
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
          body: Container(
            child: vesselData == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 17,
                              right: 17,
                              bottom: displayHeight(context) * 0.1),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    width: displayWidth(context),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: vesselData!.imageURLs == null ||
                                              vesselData!.imageURLs!.isEmpty ||
                                              vesselData!.imageURLs ==
                                                  'string' ||
                                              vesselData!.imageURLs == '[]'
                                          ? Stack(
                                              children: [
                                                Container(
                                                  color: Colors.white,
                                                  child: Image.asset(
                                                    'assets/images/vessel_default_img.png',
                                                    height:
                                                        displayHeight(context) *
                                                            0.24,
                                                    width:
                                                        displayWidth(context),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    left: 0,
                                                    child: Container(
                                                      height: displayHeight(
                                                              context) *
                                                          0.14,
                                                      width:
                                                          displayWidth(context),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20),
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 50,
                                                                spreadRadius: 5,
                                                                offset:
                                                                    const Offset(
                                                                        0, 50))
                                                          ]),
                                                    ))
                                              ],
                                            )
                                          : Stack(
                                              children: [
                                                Container(
                                                  height:
                                                      displayHeight(context) *
                                                          0.22,
                                                  width: displayWidth(context),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: FileImage(File(
                                                          vesselData!
                                                              .imageURLs!)),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    left: 0,
                                                    child: Container(
                                                      height: displayHeight(
                                                              context) *
                                                          0.14,
                                                      width:
                                                          displayWidth(context),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20),
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 50,
                                                                spreadRadius: 5,
                                                                offset:
                                                                    const Offset(
                                                                        0, 50))
                                                          ]),
                                                    ))
                                              ],
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: displayWidth(context),
                                      //color: Colors.red,
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 0, bottom: 8),
                                      child: Container(
                                        padding: EdgeInsets.only(right: 10),
                                        //width: displayWidth(context) * 0.28,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${vesselData!.name}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.05,
                                                  fontWeight: FontWeight.w700,
                                                  overflow: TextOverflow.clip),
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              height: displayHeight(context) *
                                                  0.015,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Column(
                                                //   crossAxisAlignment:
                                                //   CrossAxisAlignment.start,
                                                //   children: [
                                                //     commonText(
                                                //         context: context,
                                                //         text:
                                                //         '${vesselData!.capacity}$cubicCapacity',
                                                //         fontWeight: FontWeight.w500,
                                                //         textColor: Colors.white,
                                                //         textSize:
                                                //         displayWidth(context) * 0.038,
                                                //         textAlign: TextAlign.start),
                                                //     commonText(
                                                //         context: context,
                                                //         text: 'Capacity',
                                                //         fontWeight: FontWeight.w400,
                                                //         textColor: Colors.white,
                                                //         textSize:
                                                //         displayWidth(context) * 0.024,
                                                //         textAlign: TextAlign.start),
                                                //   ],
                                                // ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.05,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    commonText(
                                                        context: context,
                                                        text: vesselData!
                                                            .builtYear
                                                            .toString(),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textColor: Colors.white,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.038,
                                                        textAlign:
                                                            TextAlign.start),
                                                    commonText(
                                                        context: context,
                                                        text: 'Built',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        textColor: Colors.white,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.05,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    vesselData!.regNumber! == ""
                                                        ? commonText(
                                                            context: context,
                                                            text: '-',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            textColor:
                                                                Colors.white,
                                                            textSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.04,
                                                            textAlign:
                                                                TextAlign.start)
                                                        : commonText(
                                                            context: context,
                                                            text: vesselData!
                                                                .regNumber,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            textColor:
                                                                Colors.white,
                                                            textSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.038,
                                                            textAlign: TextAlign
                                                                .start),
                                                    commonText(
                                                        context: context,
                                                        text:
                                                            'Registration Number',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        textColor: Colors.white,
                                                        textSize: displayWidth(
                                                                context) *
                                                            0.024,
                                                        textAlign:
                                                            TextAlign.start),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: displayHeight(context) *
                                                  0.015,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (vesselData!
                                                    .engineType!.isEmpty)
                                                  SizedBox(),
                                                if (vesselData!.engineType!
                                                            .toLowerCase() ==
                                                        'combustion' &&
                                                    vesselData!.fuelCapacity !=
                                                        null)
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/fuel.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: '${vesselData!.fuelCapacity!} $liters'
                                                                  .toString(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.05,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/combustion_engine.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: vesselData!
                                                                  .engineType!,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                if (vesselData!.engineType!
                                                            .toLowerCase() ==
                                                        'electric' &&
                                                    vesselData!
                                                            .batteryCapacity !=
                                                        null)
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 4),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/battery.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.026,
                                                              )),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: ' ${vesselData!.batteryCapacity!} $kiloWattHour'
                                                                  .toString(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.05,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/electric_engine.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: vesselData!
                                                                  .engineType!,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                if (vesselData!.engineType!
                                                        .toLowerCase() ==
                                                    'hybrid')
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/fuel.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: vesselData!.fuelCapacity ==
                                                                      null
                                                                  ? '-'
                                                                  : '${vesselData!.fuelCapacity!} $liters'
                                                                      .toString(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.05,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 4),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/battery.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.026,
                                                              )),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: ' ${vesselData!.batteryCapacity!} $kiloWattHour'
                                                                  .toString(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.05,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/hybrid_engine.png',
                                                            width: displayWidth(
                                                                    context) *
                                                                0.04,
                                                          ),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text: vesselData!
                                                                  .engineType!,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              textColor:
                                                                  Colors.white,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.028,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.03,
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: displayWidth(context),
                                    child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Date',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: dateOfJourney,
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: 'YYYY-MM-DD',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Total Time',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '${tripData!.time} ',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: 'hh:mm:ss',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Trip Cost',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '37 \$',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: cad,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: displayHeight(context) * 0.02,
                                  ),
                                  Container(
                                    width: displayWidth(context),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Total Fuel Used',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '18.25',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '$liters',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Distance',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '${tripData!.distance} ',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: nauticalMiles,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Avg Speed',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '${tripData!.avgSpeed}',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: speedKnot,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: displayHeight(context) * 0.02,
                                  ),
                                  Container(
                                    width: displayWidth(context),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'People On Board',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: peopleOnBoard,
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: 'People',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Total CO2 Emissions',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '6.23',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: kg,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              commonText(
                                                context: context,
                                                text: 'Savings if hybrid',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.024,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: '27\$',
                                                fontWeight: FontWeight.w700,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                              ),
                                              SizedBox(
                                                height: displayHeight(context) *
                                                    0.005,
                                              ),
                                              commonText(
                                                context: context,
                                                text: cad,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.022,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.03,
                              ),
                              FutureBuilder<SpeedReportsModel>(
                                future: speedReportData,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: displayHeight(context) * 0.05,
                                          bottom:
                                              displayHeight(context) * 0.05),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  circularProgressColor),
                                        ),
                                      ),
                                    );
                                  }
                                  Utils.customPrint(
                                      'HAS DATA: ${snapshot.hasData}');
                                  Utils.customPrint(
                                      'HAS DATA: ${snapshot.error}');
                                  Utils.customPrint(
                                      'HAS DATA: ${snapshot.hasError}');
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.data == null ||
                                        snapshot.data!.data!.isEmpty) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: displayHeight(context) * 0.05,
                                            bottom:
                                                displayHeight(context) * 0.05),
                                        child: Center(
                                          child: commonText(
                                              context: context,
                                              text:
                                                  'No trips data available\nPlease upload your data to view the graph.',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.04,
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    } else {
                                      debugPrint("SPEED REPORT MODEL LENGTH ${snapshot.data!.data!.length}");
                                      debugPrint("SPEED REPORT MODEL LENGTH ${commonProvider.data.length}");

                                      return Container(
                                        height: displayHeight(context) * 0.32,
                                        width: displayWidth(context),
                                        child: Stack(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0),
                                                    child: commonText(
                                                      context: context,
                                                      text: 'Past 5 Trips',
                                                      fontWeight: FontWeight.w500,
                                                      textColor: Colors.black,
                                                      textSize:
                                                          displayWidth(context) *
                                                              0.03,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex:3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 15.0),
                                                   // padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 14,
                                                              height: 14,
                                                              color: blueColor,
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text('ICE', style: TextStyle(color: Colors.black, fontSize: 10,  fontFamily: outfit),)
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 14,
                                                              height: 14,
                                                              color: Color(0xFF67C6C7),
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text('Hybrid', style: TextStyle(color: Colors.black, fontSize: 10,  fontFamily: outfit),)
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 14,
                                                              height: 14,
                                                              color: Colors.yellow,
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text('Fuel Savings', style: TextStyle(color: Colors.black, fontSize: 10,  fontFamily: outfit),)
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            CustomBarChartWidget(data: commonProvider.data),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                  return Container();
                                },
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.01,
                              ),

                              /*InkWell(
                          onTap: (){
                            */ /*Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                Trips()));*/ /*
                          },
                          child: commonText(
                            context: context,
                            text: 'View all Trips',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ),
                        SizedBox(height: displayHeight(context) * 0.04,),*/
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      commonText(
                                        context: context,
                                        text: 'Wave Height',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.024,
                                      ),
                                      commonText(
                                        context: context,
                                        text: '2.34',
                                        fontWeight: FontWeight.w700,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.044,
                                      ),
                                      commonText(
                                        context: context,
                                        text: meters,
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.022,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      commonText(
                                        context: context,
                                        text: 'Wave Period',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.024,
                                      ),
                                      commonText(
                                        context: context,
                                        text: '3:56',
                                        fontWeight: FontWeight.w700,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.044,
                                      ),
                                      commonText(
                                        context: context,
                                        text: minutes,
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.022,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      commonText(
                                        context: context,
                                        text: 'Wind Speed',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.024,
                                      ),
                                      commonText(
                                        context: context,
                                        text: '23.06',
                                        fontWeight: FontWeight.w700,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.044,
                                      ),
                                      commonText(
                                        context: context,
                                        text: knot,
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.022,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      commonText(
                                        context: context,
                                        text: 'Wind Direction',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.024,
                                      ),
                                      commonText(
                                        context: context,
                                        text: '330o',
                                        fontWeight: FontWeight.w700,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.044,
                                      ),
                                      commonText(
                                        context: context,
                                        text: cardinal,
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.022,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.03,
                              ),
                              /*SfCartesianChart(
                            series: <ChartSeries>[
                              SplineSeries<NewChartData, int>(
                                  dataSource: chartData,
                                  // Type of spline
                                  splineType: SplineType.cardinal,
                                  cardinalSplineTension: 0.9,
                                  xValueMapper: (NewChartData data, _) => data.x,
                                  yValueMapper: (NewChartData data, _) => data.y
                              )
                            ]
                        )*/
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          color: backgroundColor,
                          child: Column(
                            children: [
                              commonProvider.downloadTripData
                                  ? CircularProgressIndicator(
                                      color: blueColor,
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: 10, left: 17, right: 17),
                                      width: displayWidth(context),
                                      height: displayHeight(context) * 0.055,
                                      decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Center(
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                debugPrint(
                                                    "DOWNLOAD TRIP ID ${widget.tripId!}");
                                                debugPrint(
                                                    "DOWNLOAD TRIP ID ${tripData!.isCloud}");

                                                if (tripData!.isCloud != 0) {
                                                  bool check = await Utils()
                                                      .check(scaffoldKey);
                                                  Utils.customPrint(
                                                      "NETWORK $check");
                                                  if (check) {
                                                    commonProvider
                                                        .downloadTripProgressBar(
                                                            true);

                                                    DownloadTrip()
                                                        .downloadTripFromCloud(
                                                            context,
                                                            scaffoldKey,
                                                            tripData!.filePath!,
                                                            commonProvider);
                                                  }
                                                } else {
                                                  DownloadTrip().downloadTrip(
                                                      context,
                                                      scaffoldKey,
                                                      widget.tripId!);
                                                }
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                          blueColor),
                                                  fixedSize:
                                                      WidgetStateProperty.all(
                                                          Size(
                                                              displayWidth(
                                                                  context),
                                                              displayHeight(
                                                                      context) *
                                                                  0.065)),
                                                  shape:
                                                      WidgetStateProperty.all(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    side: BorderSide(
                                                        color: blueColor),
                                                  ))),
                                              child: Center(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/download.png',
                                                      height: displayHeight(
                                                              context) *
                                                          0.03,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    commonText(
                                                      context: context,
                                                      text:
                                                          'Download Trip Data ',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      textColor: Colors.white,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.036,
                                                    ),
                                                  ],
                                                ),
                                              ))),
                                    ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                    onTap: () async {
                                      final image = await controller.capture();
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
                                    },
                                    child: UserFeedback()
                                        .getUserFeedback(context)),
                              ),
                            ],
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

  double _parseDuration(String duration) {
    final parts = duration.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return hours * 3600 +
        minutes * 60 +
        seconds.toDouble(); // Convert duration to seconds
  }

  showDeleteTripDialogBox(
      BuildContext context,
      String tripId,
      Function() onDeleteCallBack,
      GlobalKey<ScaffoldState> scaffoldKey,
      bool tripUploadStatus) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              isBtnClick ? false : true;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(
                builder: (ctx, stateSetter) {
                  return Container(
                    height: displayHeight(ctx) * 0.46,
                    width: MediaQuery.of(ctx).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 15),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: displayHeight(ctx) * 0.02,
                              ),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    //color: Color(0xfff2fffb),
                                    child: Image.asset(
                                      'assets/images/boat.gif',
                                      height: displayHeight(ctx) * 0.12,
                                      width: displayWidth(ctx),
                                      fit: BoxFit.contain,
                                    ),
                                  )),
                              SizedBox(
                                height: displayHeight(ctx) * 0.02,
                              ),
                              SizedBox(
                                height: displayHeight(context) / 8.5,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: commonText(
                                              context: context,
                                              text:
                                                  'Do you want to delete the Trip? ',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(ctx) * 0.045,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      SizedBox(
                                        height: displayHeight(ctx) * 0.008,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: commonText(
                                            context: context,
                                            text: deleteTripSubText,
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.grey,
                                            textSize: displayWidth(ctx) * 0.036,
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 8.0,
                                    left: displayWidth(ctx) * 0.035,
                                    right: displayWidth(ctx) * 0.035),
                                child: SizedBox(
                                  height: displayHeight(context) / 8.3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      isBtnClick
                                          ? Center(
                                              child: Container(
                                                width: displayWidth(ctx) * 0.32,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                  color: blueColor,
                                                )),
                                              ),
                                            )
                                          : CommonButtons.getAcceptButton(
                                              'Confirm & Delete',
                                              context,
                                              deleteTripBtnColor, () async {
                                              stateSetter(() {
                                                cancelVisible = false;
                                                isBtnClick = true;
                                              });
                                              internalStateSetter = stateSetter;
                                              internet = await Utils()
                                                  .check(scaffoldKey);
                                              stateSetter(() {
                                                internet;
                                              });

                                              if (internet ?? false) {
                                                stateSetter(() {
                                                  isBtnClick = true;
                                                });
                                                Utils.customPrint(
                                                    "Ok button action : $isBtnClick");
                                                bool deletedtrip = false;
                                                deletedtrip =
                                                    await deleteTripFunctionality(
                                                        tripId, () {
                                                  setState(() {
                                                    // widget.isTripDeleted!.call();
                                                    Navigator.pop(
                                                        dialogContext);
                                                    //  Navigator.pop(context);
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BottomNavigation()),
                                                        ModalRoute.withName(
                                                            ""));
                                                  });
                                                });
                                              } else if (tripUploadStatus) {
                                                stateSetter(() {
                                                  isBtnClick = true;
                                                });
                                                DatabaseService()
                                                    .deleteTripFromDB(tripId)
                                                    .then((value) {
                                                  deleteFilePath(
                                                      '${ourDirectory!.path}/${tripId}.zip');
                                                  deleteFolder(
                                                      '${ourDirectory!.path}/${tripId}');
                                                  // commonProvider.getTripsCount();
                                                  // widget.isTripDeleted!.call();
                                                  onDeleteCallBack.call();

                                                  stateSetter(() {
                                                    isBtnClick = false;
                                                  });
                                                  Navigator.pop(dialogContext);
                                                  Navigator.pop(dialogContext);
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              BottomNavigation()),
                                                      ModalRoute.withName(""));
                                                });
                                              } else {
                                                stateSetter(() {
                                                  isBtnClick = false;
                                                });
                                              }
                                            },
                                              displayWidth(ctx),
                                              displayHeight(ctx) * 0.07,
                                              deleteTripBtnColor,
                                              Colors.white,
                                              displayHeight(ctx) * 0.02,
                                              deleteTripBtnColor,
                                              '',
                                              fontWeight: FontWeight.w600),
                                      CommonButtons.getAcceptButton(
                                          'Cancel', context, Colors.transparent,
                                          () {
                                        if (!cancelVisible &&
                                            internet == true) {
                                        } else {
                                          Navigator.pop(dialogContext);
                                        }
                                      },
                                          displayWidth(ctx),
                                          displayHeight(ctx) * 0.05,
                                          primaryColor,
                                          Theme.of(ctx).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey,
                                          displayHeight(ctx) * 0.02,
                                          Colors.transparent,
                                          '',
                                          fontWeight: FontWeight.w600),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: displayHeight(ctx) * 0.005,
                              ),
                            ],
                          ),
                          Positioned(
                            right: 10,
                            top: 2,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isBtnClick
                                    ? SizedBox()
                                    : IconButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        icon: Icon(Icons.close_rounded,
                                            color: buttonBGColor)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).then((value) {
      if (value == null) {
        setState(() {
          isBtnClick = false;
        });
        // widget.isTripDeleted!.call();
        return;
      }
    });
  }

  Future<void> deleteFilePath(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();

      Utils.customPrint('Trip deleted successfully');
      CustomLogger()
          .logWithFile(Level.info, "Trip deleted successfully -> $page");
    } catch (e) {
      CustomLogger().logWithFile(Level.error, "Failed to delete trip -> $page");
      Utils.customPrint('Failed to delete trip: $e');
    }
  }

  void deleteFolder(String folderPath) async {
    Directory directory = Directory(folderPath);

    if (await directory.exists()) {
      try {
        await directory.delete(recursive: true);
        print('Folder deleted successfully.');
      } catch (e) {
        print('Error while deleting folder: $e');
      }
    } else {
      print('Folder does not exist.');
    }
  }

  bool deleteTripFunctionality(String tripId, VoidCallback onDeleteCallBack) {
    try {
      commonProvider
          .deleteTrip(
              context, commonProvider.loginModel!.token!, tripId, scaffoldKey)
          .then((value) {
        if (value.status!) {
          isDeletedSuccessfully = value.status!;
          DatabaseService().deleteTripFromDB(tripId).then((value) {
            deleteFilePath('${ourDirectory!.path}/${tripId}.zip');
            deleteFolder('${ourDirectory!.path}/${tripId}');
            setState(() {
              isDeleteTripBtnClicked = false;
            });
          });
          onDeleteCallBack.call();

          internalStateSetter!(() {
            isBtnClick = false;
            isDeleteTripBtnClicked = false;
          });
        }
            }).catchError((e) {
        internalStateSetter!(() {
          isBtnClick = false;
        });
      });
    } catch (e) {
      internalStateSetter!(() {
        isBtnClick = false;
      });
    }
    return isDeletedSuccessfully;
  }

  getData() async {
    if (widget.calledFrom == 'Report') {
      final DatabaseService _databaseService = DatabaseService();
      final tripDetails = await _databaseService.getTrip(widget.tripId!);

      List<CreateVessel> vesselDetails =
          await _databaseService.getVesselNameByID(widget.vesselId!);

      setState(() {
        tripData = tripDetails;
        vesselData = vesselDetails[0];
      });
      tripIsSyncOrNot = tripData!.isSync;
      dateOfJourney =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!));
    } else {
      final DatabaseService _databaseService = DatabaseService();
      final tripDetails = await _databaseService.getTrip(widget.tripId!);

      List<CreateVessel> vesselDetails =
          await _databaseService.getVesselNameByID(widget.vesselId!);

      setState(() {
        tripData = tripDetails;
        vesselData = vesselDetails[0];
      });
      tripIsSyncOrNot = tripData!.isSync;
      dateOfJourney =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!));
    }
    peopleOnBoard = tripData!.numberOfPassengers.toString();

    Utils.customPrint("DATE DATE ${dateOfJourney}");
    Utils.customPrint("DATE DATE ${tripData!.isSync}");
  }
}

class AnalyticsData {
  String? title, type, value;

  AnalyticsData({this.title, this.type, this.value});
}

class NewChartData {
  NewChartData(this.x, this.y);

  final int x;
  final double? y;
}

class TripSpeedData {
  TripSpeedData(this.year, this.totalDuration, this.speedDuration,{this.timeType});

  final DateTime year;

  final String? timeType;
  final double totalDuration;
  final double speedDuration;
}
