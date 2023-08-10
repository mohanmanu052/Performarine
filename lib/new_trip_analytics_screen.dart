import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/utils/utils.dart';
import 'common_widgets/widgets/common_widgets.dart';
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
   NewTripAnalyticsScreen({
     super.key, this.vesselName,
    this.avgInfo,
    this.tripId,
    this.vesselId,
     this.vessel,
    this.tripIsRunningOrNot,
    this.isAppKilled = false,
    this.calledFrom});

  @override
  State<NewTripAnalyticsScreen> createState() => _NewTripAnalyticsScreenState();
}

class _NewTripAnalyticsScreenState extends State<NewTripAnalyticsScreen> {

  GlobalKey<ScaffoldState>  scaffoldKey = GlobalKey();

  final DatabaseService _databaseService = DatabaseService();

  CreateVessel? vesselData;
  Trip? tripData;

  String tripDistance = '0.00', tripDuration = '00:00:00', dateOfJourney = '', yearOfTheJourney = '';

  String? finalTripDuration, finalTripDistance, finalAvgSpeed;

  final List<NewChartData> chartData = [
    NewChartData(2010, 35),
    NewChartData(2011, 13),
    NewChartData(2012, 34),
    NewChartData(2013, 27),
    NewChartData(2014, 40)
  ];

  bool getTripDetailsFromNoti = false, tripIsRunning = false;

  List<SalesData> data = [
    SalesData('06-22-2023', 35, 25),
    SalesData('06-28-2023', 28, 38),
    SalesData('07-02-2023', 34, 24),
    SalesData('07-10-2023', 32, 52),
    SalesData('07-14-2023', 40, 60)
  ];

  Timer? durationTimer;

  final controller = ScreenshotController();

  late CommonProvider commonProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();

    Utils.customPrint("DATE DATE ${dateOfJourney}");
    Utils.customPrint("DATE DATE ${yearOfTheJourney}");

    sharedPreferences!.remove('sp_key_called_from_noti');

    setState(() {
      getData();
    });

    Utils.customPrint('CURRENT TIME TIME ${tripDuration}');
    //Utils.customPrint('CURRENT TIME TIME ${tripData!.time}');

  }

  @override
  Widget build(BuildContext context) {

    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: Scaffold(
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
            text: 'Trip ID #${widget.tripId}',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.032,
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
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: vesselData == null
              ? Center(
                child: CircularProgressIndicator(
          ),
              )
          : Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(bottom: displayHeight(context) * 0.1),
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
                                  vesselData!.imageURLs == 'string' ||
                                  vesselData!.imageURLs == '[]'
                                  ? Stack(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Image.asset(
                                      'assets/icons/default_boat.png',
                                      height: displayHeight(context) * 0.22,
                                      width: displayWidth(context),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                 /* Positioned(
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      child: Container(
                                        height: displayHeight(context) * 0.14,
                                        width: displayWidth(context),
                                        padding: const EdgeInsets.only(top: 20),
                                        decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(
                                              color:
                                              Colors.black.withOpacity(0.5),
                                              blurRadius: 50,
                                              spreadRadius: 5,
                                              offset: const Offset(0, 50))
                                        ]),
                                      ))*/
                                ],
                              )
                                  : Container(
                                height: displayHeight(context) * 0.22,
                                width: displayWidth(context),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                        File(vesselData!.imageURLs!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                              margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
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
                                          fontSize: displayWidth(context) * 0.05,
                                          fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.clip),
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: displayHeight(context) * 0.015,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            commonText(
                                                context: context,
                                                text:
                                                '${vesselData!.capacity}cc',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) * 0.038,
                                                textAlign: TextAlign.start),
                                            commonText(
                                                context: context,
                                                text: 'Capacity',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) * 0.024,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                          displayWidth(context) * 0.05,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            commonText(
                                                context: context,
                                                text: vesselData!.builtYear
                                                    .toString(),
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) * 0.038,
                                                textAlign: TextAlign.start),
                                            commonText(
                                                context: context,
                                                text: 'Built',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) * 0.024,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                          displayWidth(context) * 0.05,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            vesselData!.regNumber! == ""
                                                ? commonText(
                                                context: context,
                                                text: '-',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.04,
                                                textAlign: TextAlign.start)
                                                : commonText(
                                                context: context,
                                                text: vesselData!.regNumber,
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.038,
                                                textAlign: TextAlign.start),
                                            commonText(
                                                context: context,
                                                text: 'Registration Number',
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) * 0.024,
                                                textAlign: TextAlign.start),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(height: displayHeight(context) * 0.015,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        if(vesselData!.engineType!.isEmpty)
                                          SizedBox(),

                                        if(vesselData!.engineType!.toLowerCase() ==
                                            'combustion' && vesselData!.fuelCapacity != null)
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/fuel.png',
                                                    width: displayWidth(context) *
                                                        0.04,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                      '${vesselData!.fuelCapacity!}gal'
                                                          .toString(),
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                      textAlign: TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width:
                                                displayWidth(context) * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/combustion_engine.png',
                                                    width: displayWidth(context) *
                                                        0.04,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text: vesselData!.engineType!,
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                      textAlign: TextAlign.start),
                                                ],
                                              )
                                            ],
                                          ),

                                        if(vesselData!.engineType!.toLowerCase() ==
                                            'electric' && vesselData!.batteryCapacity != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          left: 4),
                                                      child: Image.asset(
                                                        'assets/images/battery.png',
                                                        width: displayWidth(
                                                            context) *
                                                            0.026,
                                                      )),
                                                  SizedBox(
                                                    width:
                                                    displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                      ' ${vesselData!.batteryCapacity!} kw'
                                                          .toString(),
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize: displayWidth(
                                                          context) *
                                                          0.028,
                                                      textAlign:
                                                      TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width: displayWidth(context) *
                                                    0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/electric_engine.png',
                                                    width:
                                                    displayWidth(context) *
                                                        0.04,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                    displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text: vesselData!
                                                          .engineType!,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize: displayWidth(
                                                          context) *
                                                          0.028,
                                                      textAlign:
                                                      TextAlign.start),
                                                ],
                                              )
                                            ],
                                          ),

                                        if(vesselData!.engineType!.toLowerCase() ==
                                            'hybrid')
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/fuel.png',
                                                    width: displayWidth(context) *
                                                        0.04,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text: vesselData!
                                                          .fuelCapacity ==
                                                          null
                                                          ? '-'
                                                          : '${vesselData!.fuelCapacity!}gal'
                                                          .toString(),
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                      textAlign: TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width:
                                                displayWidth(context) * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      margin: const EdgeInsets.only(
                                                          left: 4),
                                                      child: Image.asset(
                                                        'assets/images/battery.png',
                                                        width:
                                                        displayWidth(context) *
                                                            0.026,
                                                      )),
                                                  SizedBox(
                                                    width: displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                      ' ${vesselData!.batteryCapacity!} kw'
                                                          .toString(),
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                      textAlign: TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width:
                                                displayWidth(context) * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/hybrid_engine.png',
                                                    width: displayWidth(context) *
                                                        0.04,
                                                  ),
                                                  SizedBox(
                                                    width: displayWidth(context) *
                                                        0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text: vesselData!.engineType!,
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.white,
                                                      textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                      textAlign: TextAlign.start),
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
                      SizedBox(height: displayHeight(context) * 0.03,),

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
                                       text: 'Date of journey',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: dateOfJourney,
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: yearOfTheJourney,
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
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
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '${tripData!.time} ',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'hh:mm:ss',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
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
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '37 \$',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'CAD',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
                                     ),
                                   ],
                                 ),
                               ),
                               Expanded(
                                 child: Column(
                                   children: [
                                     commonText(
                                       context: context,
                                       text: 'Total Fuel Used',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '18.25',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'Ltr',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
                                     ),
                                   ],
                                 ),
                               )
                             ],
                           ),
                         ),
                         SizedBox(height: displayHeight(context) * 0.02,),
                         Container(
                           width: displayWidth(context),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               Expanded(
                                 child: Column(
                                   children: [
                                     commonText(
                                       context: context,
                                       text: 'Distance',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '${tripData!.distance} ',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'Nautical Miles',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
                                     ),
                                   ],
                                 ),
                               ),
                               Expanded(
                                 child: Column(
                                   children: [
                                     commonText(
                                       context: context,
                                       text: 'People On Board',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '3',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'People',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
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
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '6.23',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'kg',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
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
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     commonText(
                                       context: context,
                                       text: '27\$',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.044,
                                     ),

                                     commonText(
                                       context: context,
                                       text: 'CAD',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
                                     ),
                                   ],
                                 ),
                               )
                             ],
                           ),
                         )
                       ],
                     ),

                      SizedBox(height: displayHeight(context) * 0.01,),
                      Container(
                        height: displayHeight(context) * 0.3,
                        child: Stack(
                          children: [
                            Positioned(
                                top: 22,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 26.0),
                                  child: commonText(
                                    context: context,
                                    text: 'Past 5 Trips',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.028,
                                  ),
                                )),
                            SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                primaryXAxis:
                                CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
                                primaryYAxis: NumericAxis(
                                    isVisible: false, majorGridLines: MajorGridLines(width: 0)),
                                enableSideBySideSeriesPlacement: true,

                                legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.top,
                                    alignment: ChartAlignment.far),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <ChartSeries<SalesData, String>>[
                                  ColumnSeries<SalesData, String>(
                                      dataSource: data,
                                      color: blueColor,
                                      spacing: 0.1,
                                      xValueMapper: (SalesData sales, _) => sales.year,
                                      yValueMapper: (SalesData sales, _) => sales.diesel,
                                      name: 'Diesel',
                                      legendIconType: LegendIconType.rectangle,
                                      dataLabelSettings: DataLabelSettings(isVisible: false)),
                                  ColumnSeries<SalesData, String>(
                                      dataSource: data,
                                      spacing: 0.1,
                                      color: routeMapBtnColor,
                                      xValueMapper: (SalesData sales, _) => sales.year,
                                      yValueMapper: (SalesData sales, _) => sales.hybrid,
                                      name: 'Hybrid',
                                      legendIconType: LegendIconType.rectangle,
                                      dataLabelSettings: DataLabelSettings(isVisible: false))
                                ]),
                          ],
                        ),
                      ),
                      SizedBox(height: displayHeight(context) * 0.03,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                text: 'meters',
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
                                text: 'Minutes',
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
                                text: 'kt',
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
                                text: 'T',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.022,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: displayHeight(context) * 0.03,),
                      SfCartesianChart(
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
                      )
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10,),
                      width: displayWidth(context),
                      height: displayHeight(context) * 0.055,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/download.png',),
                              SizedBox(width: 10,),
                              commonText(
                                context: context,
                                text: 'Export Complete Report',
                                fontWeight: FontWeight.w600,
                                textColor: Colors.white,
                                textSize: displayWidth(context) * 0.036,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8
                      ),
                      child: GestureDetector(
                          onTap: ()async{
                            final image = await controller.capture();
                            Utils.customPrint("Image is: ${image.toString()}");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                              imagePath: image.toString(),
                              uIntList: image,)));
                          },
                          child: UserFeedback().getUserFeedback(context)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
    } else {
      final DatabaseService _databaseService = DatabaseService();
      final tripDetails = await _databaseService.getTrip(widget.tripId!);

      List<CreateVessel> vesselDetails =
      await _databaseService.getVesselNameByID(widget.vesselId!);

      setState(() {
        tripData = tripDetails;
        vesselData = vesselDetails[0];
      });
    }

    dateOfJourney = DateFormat('dd').format(DateTime.parse(vesselData!.createdAt!));
    yearOfTheJourney = DateFormat('yyyy').format(DateTime.parse(vesselData!.createdAt!));

  }

}

class AnalyticsData
{
  String? title, type, value;
  AnalyticsData({this.title, this.type, this.value});
}

class NewChartData {
  NewChartData(this.x, this.y);
  final int x;
  final double? y;
}

class SalesData {
  SalesData(this.year, this.diesel, this.hybrid);
  final String year;
  final double diesel, hybrid;
}

