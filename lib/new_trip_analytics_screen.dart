import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
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
     super.key, this.vesselName,
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

  GlobalKey<ScaffoldState>  scaffoldKey = GlobalKey();

  CreateVessel? vesselData;
  Trip? tripData;

  String tripDistance = '0.00', tripDuration = '00:00:00', dateOfJourney = '', yearOfTheJourney = '', peopleOnBoard = '';

  bool cancelVisible=true;
  bool? internet;

  final List<NewChartData> chartData = [
    NewChartData(2010, 35),
    NewChartData(2011, 13),
    NewChartData(2012, 34),
    NewChartData(2013, 27),
    NewChartData(2014, 40)
  ];

  List<SalesData> data = [
    SalesData('2023-08-15', 35, 25),
    SalesData('2023-08-16', 28, 38),
    SalesData('2023-08-17', 34, 24),
    SalesData('2023-08-18', 32, 52),
    SalesData('2023-08-19', 40, 60)
  ];


  final controller = ScreenshotController();

  late CommonProvider commonProvider;
  bool isBtnClick = false,
      isDeleteTripBtnClicked = false,
      isDeletedSuccessfully = false;
  StateSetter? internalStateSetter;

  int? tripIsSyncOrNot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    commonProvider = context.read<CommonProvider>();

    sharedPreferences!.remove('sp_key_called_from_noti');

    setState(() {
      getData();
    });

    Utils.customPrint('CURRENT TIME TIME ${tripDuration}');
    //Utils.customPrint('CURRENT TIME TIME ${tripData!.time}');

  }

@override
  void dispose() {
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp

    ]);

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
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
              text: 'Trip Analytics',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.042,
              fontFamily: outfit
          ),
          actions: [
    
            InkWell(
              onTap: ()async{
                Utils.customPrint("Trip id is: ${tripData!.id}");
                bool tripUploadedStatus = false;
                if (tripData!.isSync == 0){
                  tripUploadedStatus = true;
                }
                if(tripData!.tripStatus == 1){
                  showDeleteTripDialogBox(
                      context,
                      tripData!.id!,
                          (){
                        Utils.customPrint("call back for delete trip in list");

                      },scaffoldKey,
                      tripUploadedStatus
                  );
                } else{

                }
              },
              child: Image.asset(
                'assets/images/Trash.png',
                width: Platform.isAndroid ? displayWidth(context) * 0.065 : displayWidth(context) * 0.05,
              ),
            ),
    
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
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
                child: CircularProgressIndicator(
          ),
              )
          : Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(left: 17, right: 17, bottom: displayHeight(context) * 0.1),
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
                                      'assets/images/vessel_default_img.png',
                                      height: displayHeight(context) * 0.24,
                                      width: displayWidth(context),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
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
                                      ))
                                ],
                              )
                                  : Stack(
                                    children: [
                                      Container(
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
                                      Positioned(
                                          bottom: 0,
                                          right: 0,
                                          left: 0,
                                          child: Container(
                                            height: displayHeight(context) * 0.14,
                                            width: displayWidth(context),
                                            padding: const EdgeInsets.only(top: 20),
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black.withOpacity(0.5),
                                                  blurRadius: 50,
                                                  spreadRadius: 5,
                                                  offset: const Offset(0, 50))
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
                                                      '${vesselData!.fuelCapacity!} L'
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
                                                      ' ${vesselData!.batteryCapacity!} $kiloWattHour'
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
                                                          : '${vesselData!.fuelCapacity!} L'
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
                                                      ' ${vesselData!.batteryCapacity!} $kiloWattHour'
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
                                       text: 'Date',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),
    
                                     commonText(
                                       context: context,
                                       text: dateOfJourney,
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),
                                     SizedBox(height: displayHeight(context) * 0.005,),
    
                                     commonText(
                                       context: context,
                                       text: 'YYYY-MM-DD',
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

                                     SizedBox(height: displayHeight(context) * 0.005,),
    
                                     commonText(
                                       context: context,
                                       text: '${tripData!.time} ',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),
    
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
                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '37 \$',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),
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
                                       text: 'Total Fuel Used',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '18.25',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '$liters',
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
                                       text: 'Distance',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '${tripData!.distance} ',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),
    
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
                                       text: 'Avg Speed',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '${tripData!.avgSpeed}',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: speedKnot,
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.022,
                                     ),
                                   ],
                                 ),
                               ),
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
                                       text: 'People On Board',
                                       fontWeight: FontWeight.w400,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.024,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: peopleOnBoard,
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

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

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '6.23',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

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

                                     SizedBox(height: displayHeight(context) * 0.005,),

                                     commonText(
                                       context: context,
                                       text: '27\$',
                                       fontWeight: FontWeight.w700,
                                       textColor: Colors.black,
                                       textSize: displayWidth(context) * 0.048,
                                     ),

                                     SizedBox(height: displayHeight(context) * 0.005,),

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
                                    textSize: displayWidth(context) * 0.03,
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
                                  shouldAlwaysShowScrollbar: false,
                                 overflowMode: LegendItemOverflowMode.none,
                                  offset: Offset(80, -30),
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
                      SizedBox(height: displayHeight(context) * 0.01,),
    
                      /*InkWell(
                        onTap: (){
                          *//*Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              Trips()));*//*
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
                          ? CircularProgressIndicator(color: blueColor,)
                          : Container(
                        margin: EdgeInsets.only(top: 10, left: 17, right: 17),
                        width: displayWidth(context),
                        height: displayHeight(context) * 0.055,
                        decoration: BoxDecoration(
                          color: blueColor,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Center(
                          child: ElevatedButton(
                              onPressed: ()async{
                                debugPrint("DOWNLOAD TRIP ID ${widget.tripId!}");
                                debugPrint("DOWNLOAD TRIP ID ${tripData!.isCloud}");

                                if(tripData!.isCloud != 0)
                                {
                                  bool check = await Utils().check(scaffoldKey);
                                  Utils.customPrint("NETWORK $check");
                                  if(check)
                                  {
                                    commonProvider.downloadTripProgressBar(true);

                                    DownloadTrip().downloadTripFromCloud(context,scaffoldKey, tripData!.filePath!, commonProvider);

                                  }

                                }
                                else
                                {
                                  DownloadTrip().downloadTrip(
                                      context,
                                      scaffoldKey,
                                      widget.tripId!);
                                }
    
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(blueColor),
                                  fixedSize: MaterialStateProperty.all(
                                      Size(displayWidth(context), displayHeight(context) * 0.065)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: blueColor),
                                  ))),
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/icons/download.png', height: displayHeight(context) * 0.03,),
                                    SizedBox(width: 10,),
                                    commonText(
                                      context: context,
                                      text: 'Download Trip Data ',
                                      fontWeight: FontWeight.w600,
                                      textColor: Colors.white,
                                      textSize: displayWidth(context) * 0.036,
                                    ),
                                  ],
                                ),
    
                              ))
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showDeleteTripDialogBox(BuildContext context,String tripId,Function() onDeleteCallBack, GlobalKey<ScaffoldState> scaffoldKey,bool tripUploadStatus) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: ()async
            {
              return isBtnClick ? false : true;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(
                builder: (ctx,  stateSetter) {
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
                                height: displayHeight(context)/8.5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: commonText(
                                              context: context,
                                              text:
                                              'Do you want to delete the Trip? ',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(ctx) * 0.045,
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      SizedBox(
                                        height: displayHeight(ctx) * 0.008,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: commonText(
                                            context: context,
                                            text:
                                            'This action is irreversible. do you want to delete it?',
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
                                    top: 8.0,left: displayWidth(ctx) * 0.035,right: displayWidth(ctx) * 0.035
                                ),
                                child: SizedBox(
                                  height: displayHeight(context)/8.3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                
                                      isBtnClick ? Center(
                                        child: Container(
                                          width: displayWidth(ctx) * 0.32,
                                          child: Center(child: CircularProgressIndicator(
                                            color: blueColor,
                                          )),
                                        ),
                                      ) :  CommonButtons.getAcceptButton(
                                          'Confirm & Delete', context, deleteTripBtnColor,
                                              () async {
                                                stateSetter(() {
                                                  cancelVisible=false;
                                                  isBtnClick = true;
                                                });
                                            internalStateSetter = stateSetter;
                                             internet =
                                            await Utils().check(scaffoldKey);
                                                stateSetter(() {
                                                  internet;
                                                });

                                
                                            if(internet??false){
                                              stateSetter(() {
                                                isBtnClick = true;
                                              });
                                              Utils.customPrint("Ok button action : $isBtnClick");
                                              bool deletedtrip = false;
                                              deletedtrip =  await deleteTripFunctionality(
                                                  tripId,
                                                      (){
                                                    setState(() {
                                                      // widget.isTripDeleted!.call();
                                                      Navigator.pop(dialogContext);
                                                    //  Navigator.pop(context);
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => BottomNavigation()),
                                                          ModalRoute.withName(""));
                                                    });
                                                  }
                                              );
                                            } else if(tripUploadStatus){
                                              stateSetter(() {
                                                isBtnClick = true;
                                              });
                                              DatabaseService().deleteTripFromDB(tripId).then((value)
                                              {
                                                deleteFilePath('${ourDirectory!.path}/${tripId}.zip');
                                                deleteFolder('${ourDirectory!.path}/${tripId}');
                                                commonProvider.getTripsCount();
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
                                                        builder: (context) => BottomNavigation()),
                                                    ModalRoute.withName(""));
                                              });
                                            } else{
                                              stateSetter(() {
                                                isBtnClick = false;
                                              });
                                            }
                                          },
                                          displayWidth(ctx) ,
                                          displayHeight(ctx) * 0.07,
                                          deleteTripBtnColor,
                                          Colors.white,
                                          displayHeight(ctx) * 0.02,
                                          deleteTripBtnColor,
                                          '',
                                          fontWeight: FontWeight.w600),
                                
                                      CommonButtons.getAcceptButton(
                                          'Cancel',
                                          context,
                                          Colors.transparent,
                                
                                          (){
                                
                                            if(!cancelVisible&&internet==true){
                                            }else{
                                            Navigator.pop(dialogContext);
                                
                                            }
                                      
                                            
                                          },
                                          displayWidth(ctx) ,
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
                                shape: BoxShape.circle,),
                              child: Center(
                                child: isBtnClick ?
                                SizedBox()
                                : IconButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    icon: Icon(Icons.close_rounded, color: buttonBGColor)),
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
         if(value == null) {
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
      CustomLogger().logWithFile(Level.info, "Trip deleted successfully -> $page");
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

  bool deleteTripFunctionality(String tripId,VoidCallback onDeleteCallBack)
  {
    try{
      commonProvider.deleteTrip(context, commonProvider.loginModel!.token!, tripId, scaffoldKey).then((value) {
        if(value != null)
        {
          if(value.status!)
          {
            isDeletedSuccessfully = value.status!;
            DatabaseService().deleteTripFromDB(tripId).then((value)
            {
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

        } else{
          setState(() {
            isBtnClick = false;
          });
        }
      }).catchError((e){
        internalStateSetter!(() {

          isBtnClick = false;
        });
      });
    } catch(e){
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
      dateOfJourney = DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!));
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
      dateOfJourney = DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!));
    }
    peopleOnBoard = tripData!.numberOfPassengers.toString();

    Utils.customPrint("DATE DATE ${dateOfJourney}");
    Utils.customPrint("DATE DATE ${tripData!.isSync}");
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

