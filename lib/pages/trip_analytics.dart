import 'dart:async';
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

class TripAnalyticsScreen extends StatefulWidget {
  Trip? tripList;
  final CreateVessel? vessel;
  final bool? tripIsRunningOrNot;
  TripAnalyticsScreen(
      {Key? key, this.tripList, this.vessel, this.tripIsRunningOrNot})
      : super(key: key);

  @override
  State<TripAnalyticsScreen> createState() => _TripAnalyticsScreenState();
}

class _TripAnalyticsScreenState extends State<TripAnalyticsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  List<CreateVessel> getVesselById = [];
  Trip? tripData;

  bool tripIsRunning = false, isuploadTrip = false;

  int tripDistance = 0;
  int tripDuration = 0;
  String tripSpeed = '0.0';

  String? finalTripDuration, finalTripDistance, finalAvgSpeed;

  FlutterBackgroundService service = FlutterBackgroundService();

  bool isTripUploaded = false, vesselIsSync = false;

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
      tripData = widget.tripList;
      tripIsRunning = widget.tripIsRunningOrNot!;
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
    }

    commonProvider = context.read<CommonProvider>();

    deviceDetails = DeviceInfoPlugin();
  }

  getRealTimeTripDetails() async {
    service.on('tripAnalyticsData').listen((event) {
      tripDistance = event!['tripDistance'];
      tripDuration = event['tripDuration'];
      tripSpeed = event['tripSpeed'];

      if (mounted) setState(() {});
    });
  }

  getVesselDataById() async {
    getVesselById = await _databaseService
        .getVesselNameByID(widget.tripList!.vesselId.toString());

    debugPrint('VESSEL DATA ${getVesselById[0].name}');
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xfff2fffb),
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xfff2fffb),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              // Navigator.of(context).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: 'Trip Id - ${widget.tripList!.id}',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.032,
          ),
          //backgroundColor: Colors.white,
        ),
        body: Container(
          //margin: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            children: [
              SizedBox(
                height: displayHeight(context) * 0.33,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      commonText(
                        context: context,
                        text: '${widget.vessel!.name}',
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black87,
                        textSize: displayWidth(context) * 0.045,
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      dashboardRichText(
                          modelName: '${widget.vessel!.model}',
                          builderName: '${widget.vessel!.builderName}',
                          context: context,
                          color: Colors.grey),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.vessel!.imageURLs == null ||
                                  widget.vessel!.imageURLs!.isEmpty ||
                                  widget.vessel!.imageURLs == 'string'
                              ? Stack(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/images/vessel_default_img.png',
                                        height: displayHeight(context) * 0.22,
                                        width: displayWidth(context),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    /*Image.asset(
                                                      'assets/images/shadow_img.png',
                                                      height: displayHeight(context) * 0.22,
                                                      width: displayWidth(context),
                                                      fit: BoxFit.cover,
                                                    ),*/

                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: Container(
                                          height: displayHeight(context) * 0.14,
                                          width: displayWidth(context),
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
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
                                              File(widget.vessel!.imageURLs!)),
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
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 50,
                                                spreadRadius: 5,
                                                offset: const Offset(0, 50))
                                          ]),
                                        ))
                                  ],
                                )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
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
                              margin:
                                  EdgeInsets.only(top: 20, left: 17, right: 17),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: displayWidth(context),
                                        padding: widget.vessel!.engineType!
                                                    .toLowerCase() ==
                                                'combustion'
                                            ? EdgeInsets.symmetric(
                                                horizontal: 50)
                                            : widget.vessel!.engineType!
                                                        .toLowerCase() ==
                                                    'electric'
                                                ? EdgeInsets.symmetric(
                                                    horizontal: 0)
                                                : EdgeInsets.symmetric(
                                                    horizontal: 16),
                                        //color: Colors.red,
                                        child: widget.vessel!.engineType!
                                                    .toLowerCase() ==
                                                'combustion'
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Image.asset(
                                                          'assets/images/fuel.png',
                                                          width: displayWidth(
                                                                  context) *
                                                              0.04,
                                                          color: Colors.black),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.018,
                                                      ),
                                                      commonText(
                                                          context: context,
                                                          text:
                                                              '${widget.vessel!.fuelCapacity} gal',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textColor:
                                                              Colors.black,
                                                          textSize:
                                                              displayWidth(
                                                                      context) *
                                                                  0.038,
                                                          textAlign:
                                                              TextAlign.start),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Image.asset(
                                                          widget.vessel!
                                                                      .engineType!
                                                                      .toLowerCase() ==
                                                                  'hybrid'
                                                              ? 'assets/images/hybrid_engine.png'
                                                              : widget.vessel!
                                                                          .engineType!
                                                                          .toLowerCase() ==
                                                                      'electric'
                                                                  ? 'assets/images/electric_engine.png'
                                                                  : 'assets/images/combustion_engine.png',
                                                          width: displayWidth(
                                                                  context) *
                                                              0.07,
                                                          color: Colors.black),
                                                      SizedBox(
                                                        width: displayWidth(
                                                                context) *
                                                            0.02,
                                                      ),
                                                      Text(
                                                        widget.vessel!
                                                            .engineType!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.038,
                                                            fontFamily:
                                                                poppins),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : widget.vessel!.engineType!
                                                        .toLowerCase() ==
                                                    'electric'
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                              'assets/images/battery.png',
                                                              width: displayWidth(
                                                                      context) *
                                                                  0.04,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.batteryCapacity} kw',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.038,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                              widget.vessel!
                                                                          .engineType!
                                                                          .toLowerCase() ==
                                                                      'hybrid'
                                                                  ? 'assets/images/hybrid_engine.png'
                                                                  : widget.vessel!
                                                                              .engineType!
                                                                              .toLowerCase() ==
                                                                          'electric'
                                                                      ? 'assets/images/electric_engine.png'
                                                                      : 'assets/images/combustion_engine.png',
                                                              width: displayWidth(
                                                                      context) *
                                                                  0.07,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          Text(
                                                            widget.vessel!
                                                                .engineType!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.038,
                                                                fontFamily:
                                                                    poppins),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
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
                                                                  0.07,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.fuelCapacity} gal',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.038,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                              'assets/images/battery.png',
                                                              width: displayWidth(
                                                                      context) *
                                                                  0.045,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.02,
                                                          ),
                                                          commonText(
                                                              context: context,
                                                              text:
                                                                  '${widget.vessel!.batteryCapacity} kw',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              textColor:
                                                                  Colors.black,
                                                              textSize:
                                                                  displayWidth(
                                                                          context) *
                                                                      0.038,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                              widget.vessel!
                                                                          .engineType!
                                                                          .toLowerCase() ==
                                                                      'hybrid'
                                                                  ? 'assets/images/hybrid_engine.png'
                                                                  : widget.vessel!
                                                                              .engineType!
                                                                              .toLowerCase() ==
                                                                          'electric'
                                                                      ? 'assets/images/electric_engine.png'
                                                                      : 'assets/images/combustion_engine.png',
                                                              width: displayWidth(
                                                                      context) *
                                                                  0.08,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.018,
                                                          ),
                                                          Text(
                                                            widget.vessel!
                                                                .engineType!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.038,
                                                                fontFamily:
                                                                    poppins),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                      ),
                                      SizedBox(
                                        height: displayHeight(context) * 0.02,
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: commonText(
                                          context: context,
                                          text: 'Analytics',
                                          fontWeight: FontWeight.w700,
                                          textColor: Colors.black87,
                                          textSize:
                                              displayWidth(context) * 0.032,
                                        ),
                                      ),
                                      vesselAnalytics(
                                          context,
                                          tripIsRunning
                                              ? Utils.calculateTripDuration(
                                                  (tripDuration / 1000).toInt())
                                              : '${widget.tripList!.time}',
                                          tripIsRunning
                                              ? '${tripDistance.toStringAsFixed(2)} m'
                                              : '${widget.tripList!.distance} m',
                                          '20',
                                          tripIsRunning
                                              ? '${tripSpeed.toString()} nm/h'
                                              : '${widget.tripList!.speed}'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: displayHeight(context) * 0.01,
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            commonText(
                                              context: context,
                                              text: 'Trip Details',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black87,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                            ),
                                            Row(
                                              children: [
                                                commonText(
                                                  context: context,
                                                  text: 'Trip Status:',
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black87,
                                                  textSize:
                                                      displayWidth(context) *
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
                                                  fontWeight: FontWeight.w500,
                                                  textColor: tripIsRunning
                                                      ? Color(0xFFAE6827)
                                                      : Colors.green,
                                                  textSize:
                                                      displayWidth(context) *
                                                          0.03,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: displayHeight(context) * 0.02,
                                        ),
                                        Row(
                                          children: [
                                            commonText(
                                              context: context,
                                              text: 'Trip ID',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                                  displayWidth(context) * 0.03,
                                            ),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.1,
                                            ),
                                            commonText(
                                              context: context,
                                              text: ': ${widget.tripList!.id}',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.03,
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
                                              text: 'Start Date',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                                  displayWidth(context) * 0.03,
                                            ),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.04,
                                            ),
                                            commonText(
                                              context: context,
                                              text:
                                                  ': ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.tripList!.createdAt!))}',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.03,
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
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                                  displayWidth(context) * 0.03,
                                            ),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.04,
                                            ),
                                            commonText(
                                              context: context,
                                              text:
                                                  ': ${DateFormat('hh:mm').format(DateTime.parse(widget.tripList!.createdAt!))}',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.03,
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
                                                    context: context,
                                                    text: 'End Date',
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.grey,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.03,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.06,
                                                  ),
                                                  commonText(
                                                    context: context,
                                                    text:
                                                        ': ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.tripList!.updatedAt!))}',
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.black,
                                                    textSize:
                                                        displayWidth(context) *
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
                                                    context: context,
                                                    text: 'End Time',
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.grey,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.03,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.06,
                                                  ),
                                                  commonText(
                                                    context: context,
                                                    text:
                                                        ': ${DateFormat('hh:mm').format(DateTime.parse(widget.tripList!.updatedAt!))}',
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.black,
                                                    textSize:
                                                        displayWidth(context) *
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
                            child: tripIsRunning
                                ? CommonButtons.getActionButton(
                                    title: 'End Trip',
                                    context: context,
                                    fontSize: displayWidth(context) * 0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor: buttonBGColor,
                                    borderColor: buttonBGColor,
                                    width: displayWidth(context),
                                    onTap: () async {
                                      Utils().showEndTripDialog(context,
                                          () async {
                                        CreateTrip().endTrip(
                                            context: context,
                                            scaffoldKey: scaffoldKey,
                                            onEnded: () async {
                                              setState(() {
                                                tripIsRunning = false;
                                              });
                                              Trip tripDetails =
                                                  await _databaseService
                                                      .getTrip(
                                                          widget.tripList!.id!);
                                              setState(() {
                                                widget.tripList = tripDetails;
                                              });

                                              print(
                                                  'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                              print(
                                                  'TRIP ENDED DETAILS: ${widget.tripList!.isSync}');
                                              Navigator.pop(context);
                                            });
                                      }, () {
                                        Navigator.pop(context);
                                      });
                                    })
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CommonButtons.getActionButton(
                                          title: 'Download Trip Data',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.034,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: Color(0xFF889BAB),
                                          borderColor: Color(0xFF889BAB),
                                          width: displayWidth(context) / 2.3,
                                          onTap: () async {
                                            downloadTrip(false);
                                          }),
                                      isTripUploaded
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  right: displayWidth(context) *
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
                                          : CommonButtons.getActionButton(
                                              title: 'Upload Trip Data',
                                              context: context,
                                              fontSize:
                                                  displayWidth(context) * 0.034,
                                              textColor: Colors.white,
                                              buttonPrimaryColor: buttonBGColor,
                                              borderColor: buttonBGColor,
                                              width:
                                                  displayWidth(context) / 2.3,
                                              onTap: () async {
                                                Utils().check(scaffoldKey);

                                                if (widget.tripList?.isSync !=
                                                    0) {
                                                  Utils.showSnackBar(
                                                    context,
                                                    scaffoldKey: scaffoldKey,
                                                    message:
                                                        'File already uploaded',
                                                  );
                                                  return;
                                                }

                                                downloadTrip(true);

                                                var connectivityResult =
                                                    await (Connectivity()
                                                        .checkConnectivity());
                                                if (connectivityResult ==
                                                    ConnectivityResult.mobile) {
                                                  print('Mobile');
                                                  showDialogBoxToUploadTrip();
                                                } else if (connectivityResult ==
                                                    ConnectivityResult.wifi) {
                                                  setState(() {
                                                    isTripUploaded = true;
                                                  });
                                                  uploadDataIfDataIsNotSync();

                                                  print('WIFI');
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
      print('Vessel isSync $vesselIsSync');
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
    //fileName = '$fileIndex.csv';

    // flutterLocalNotificationsPlugin.cancel(9988);
    AndroidDeviceInfo androidDeviceInfo = await deviceDetails.androidInfo;

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
      "lat": tripData.startPosition,
      "long": tripData.endPosition,
      "vesselId": tripData.vesselId,
      "filePath": 'storage/emulated/0/Download/${widget.tripList!.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      //"userID": commonProvider.loginModel!.userId!
    };

    debugPrint('CREATE TRIP: $queryParameters');

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
          print("widget.tripList!.id: ${widget.tripList!.id}");
          _databaseService.updateTripIsSyncStatus(1, tripData.id.toString());
          Trip tripDetails =
              await _databaseService.getTrip(widget.tripList!.id!);
          print('TRIP DETAILS: ${tripDetails.toJson()}');
          setState(() {
            widget.tripList = tripDetails;
          });

          showSuccessNoti();

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
      debugPrint('ON ERROR $onError \n $s');
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
    await vesselIsSyncOrNot(widget.tripList!.vesselId.toString());
    debugPrint('VESSEL STATUS isSync $vesselIsSync');

    const int maxProgress = 10;
    progress = 0;

    /*progressTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      progress = progress + 100;
      //progress = timer.tick;
      int fileLength = 0;
      try {
        fileLength =
            File('storage/emulated/0/Download/${widget.tripList!.id}.zip')
                .lengthSync();
      } catch (e) {
        showFailedNoti(widget.tripList!.id!);
        setState(() {
          isTripUploaded = false;
        });
      }

      var value = progress / fileLength;

      finalProgress = value * 100;

      finalProgress = finalProgress > 100 ? 100 : finalProgress;

      if (finalProgress == 100) {
        progressTimer!.cancel();
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('progress channel', 'progress channel',
              channelDescription: 'progress channel description',
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showProgress: true,
              ongoing: true,
              indeterminate: false,
              progress: finalProgress.toInt(),
              maxProgress: 100);
      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      flutterLocalNotificationsPlugin.show(
          9986,
          '${widget.tripList!.id} ${finalProgress.toStringAsFixed(0)}/100%',
          '${finalProgress.toStringAsFixed(0)}/100%',
          platformChannelSpecifics,
          payload: 'item x');
    });*/

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
          .getVesselFromVesselID((widget.tripList!.vesselId.toString()));

      debugPrint('VESSEL DATA ${vesselData.id}');

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

        debugPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
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
            // print('DATA');
            await _databaseService.updateIsSyncStatus(
                1, widget.tripList!.vesselId.toString());

            /*setState(() {
              isTripUploaded = false;
            });*/

            startSensorFunctionality(widget.tripList!);
          } /* else if (value.statusCode == 400) {
            setState(() {
              isTripUploaded = false;
            });
          } */
          else {
            await cancelOnGoingProgressNotification(widget.tripList!.id!);
            showFailedNoti(widget.tripList!.id!);
            setState(() {
              isTripUploaded = false;
            });
          }
        } else {
          await cancelOnGoingProgressNotification(widget.tripList!.id!);
          showFailedNoti(widget.tripList!.id!);
          setState(() {
            isTripUploaded = false;
          });
        }
      });
    } else {
      setState(() {
        isTripUploaded = false;
      });
      startSensorFunctionality(widget.tripList!);
    }
  }

  showFailedNoti(String id) async {
    progressTimer!.cancel();
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
    debugPrint('DOWLOAD Started!!!');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted = androidInfo.version.sdkInt > 32
        ? await Permission.photos.status
        : await Permission.storage.status;
    if (isStoragePermitted.isGranted) {
      //File copiedFile = File('${ourDirectory!.path}.zip');
      File copiedFile =
          File('${ourDirectory!.path}/${widget.tripList!.id}.zip');

      print('DIR PATH R ${ourDirectory!.path}');

      Directory directory;

      if (Platform.isAndroid) {
        directory =
            Directory("storage/emulated/0/Download/${widget.tripList!.id}.zip");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      copiedFile.copy(directory.path);

      print('DOES FILE EXIST: ${copiedFile.existsSync()}');

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
                                                        print(
                                                            'Open Btn clicked ttttt');
                                                        var result =
                                                            await OpenFile.open(
                                                                directory.path);

                                                        print(
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
          directory = Directory(
              "storage/emulated/0/Download/${widget.tripList!.id}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);

        print('DOES FILE EXIST: ${copiedFile.existsSync()}');

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
                                                          print(
                                                              'Open Btn clicked');
                                                          OpenFile.open(
                                                                  directory.path)
                                                              .catchError(
                                                                  (onError) {
                                                            print(onError);
                                                          });
                                                        });*/
        }
      }
    }
  }
}
