import 'dart:async';
import 'dart:io';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/analytics/location_callback_handler.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wakelock/wakelock.dart';

import '../common_widgets/widgets/status_tag.dart';
import '../common_widgets/widgets/user_feed_back.dart';
import '../models/reports_model.dart';
import 'bottom_navigation.dart';
import 'feedback_report.dart';

class TripAnalyticsScreen extends StatefulWidget {
  String? vesselName;
  String? tripId;
  AvgInfo? avgInfo;
  List<CreateVessel>? vesselDetails;
  final String? vesselId, calledFrom;
  final bool? tripIsRunningOrNot;
  final bool isAppKilled;
  TripAnalyticsScreen(
      {Key? key,
        this.vesselName,
        this.avgInfo,
        this.tripId,
        this.vesselId,
        this.tripIsRunningOrNot,
        this.isAppKilled = false,
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
  String tripSpeed = '0.1';
  String tripAvgSpeed = '0.1';

  String? finalTripDuration, finalTripDistance, finalAvgSpeed;

  bool isTripUploaded = false,
      vesselIsSync = false,
      isDataUpdated = false,
      getTripDetailsFromNoti = false,
      isEndTripBtnClicked = false, locationAccuracy = false;

  int progress = 0;
  Timer? durationTimer;
  double finalProgress = 0;

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;
  late DeviceInfoPlugin deviceDetails;

  final controller = ScreenshotController();

  @override
  void initState() {
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // TODO: implement initState
    super.initState();

    Utils.customPrint('CURRENT TIME TIME ${widget.tripId}');
    Utils.customPrint('CURRENT TIME TIME ${widget.vesselId}');
    Utils.customPrint('CURRENT TIME TIME ${widget.tripIsRunningOrNot}');
    Utils.customPrint('CURRENT TIME TIME ${widget.isAppKilled}');

    sharedPreferences!.remove('sp_key_called_from_noti');

    setState(() {
      tripIsRunning = widget.tripIsRunningOrNot!;
      getData();
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
      Wakelock.enable();

      if(widget.isAppKilled){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(Duration(seconds: 1), (){
            showEndTripDialogBox(context);
          });
        });

      }
    }

    commonProvider = context.read<CommonProvider>();

    deviceDetails = DeviceInfoPlugin();
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
  }

  getRealTimeTripDetails() async {
    if (mounted) {
      setState(() {
        getTripDetailsFromNoti = true;
      });
    }

    final currentTrip = await _databaseService.getTrip(widget.tripId!);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    WidgetsFlutterBinding.ensureInitialized();

    await sharedPreferences!.reload();

    durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Utils.customPrint('##TDATA updated time delay from 1 sec to 400 MS by abhi');
      tripDistance = sharedPreferences!.getString('tripDistance') ?? "0";
      tripSpeed = sharedPreferences!.getString('tripSpeed') ?? "0.0";
      tripAvgSpeed = sharedPreferences!.getString('tripAvgSpeed') ?? "0.0";

      Utils.customPrint("TRIP ANALYTICS SPEED $tripSpeed");
      Utils.customPrint("TRIP ANALYTICS AVG SPEED $tripAvgSpeed");

      var durationTime = DateTime.now().toUtc().difference(createdAtTime);
      tripDuration = Utils.calculateTripDuration(
          ((durationTime.inMilliseconds) ~/ 1000).toInt());

      if (mounted)
        setState(() {
          getTripDetailsFromNoti = false;
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop)
      {
        if(didPop)  return;
        Wakelock.disable().then((value) {
          if (widget.calledFrom == null) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigation()),
                ModalRoute.withName(""));
            return false;
          } else if (widget.calledFrom! == 'HomePage') {
            if (isDataUpdated) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BottomNavigation(
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
          } else if (widget.calledFrom == 'Report') {
            Navigator.pop(context);
            return false;
          }
        });
      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          backgroundColor: Color(0xfff2fffb),
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: Color(0xfff2fffb),
            elevation: 0,
            leading: IconButton(
              onPressed: () {

                Wakelock.disable().then((value) {
                  if (widget.calledFrom == null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavigation()),
                        ModalRoute.withName(""));
                  }  else if (widget.calledFrom! == 'HomePage') {
                    if (isDataUpdated) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavigation(
                                tabIndex: 1,
                              )),
                          ModalRoute.withName(""));
                    } else {
                      Navigator.of(context).pop();
                    }
                  } else if (widget.calledFrom == 'VesselSingleView') {
                    Navigator.of(context).pop(isDataUpdated);
                  } else if (widget.calledFrom == "Report") {
                    Navigator.pop(context);
                  }
                });
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: widget.calledFrom == "Report"
                ? commonText(
              context: context,
              text: widget.vesselName,
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.032,
            )
                : commonText(
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
          body: tripData == null && vesselData == null
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container(
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
                widget.calledFrom == 'Report'
                    ? Expanded(
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
                                                ': ${DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!))}',
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
                                                ': ${DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.updatedAt!))}',
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
                              child: tripData!.isCloud != 0
                                  ? Column(
                                children: [
                                  SizedBox(
                                    width: displayWidth(context),
                                    child: CommonButtons
                                        .getActionButton(
                                        title: 'Home',
                                        context: context,
                                        fontSize: displayWidth(
                                            context) *
                                            0.034,
                                        textColor: Colors.white,
                                        buttonPrimaryColor:
                                        buttonBGColor,
                                        borderColor:
                                        buttonBGColor,
                                        width: displayWidth(
                                            context) /
                                            2.3,
                                        onTap: () async {
                                          Navigator
                                              .pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                    BottomNavigation(),
                                              ),
                                              ModalRoute
                                                  .withName(
                                                  ""));
                                        }),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
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
                              )
                                  : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      CommonButtons.getActionButton(
                                          title:
                                          'Download Trip',
                                          context: context,
                                          fontSize: displayWidth(
                                              context) *
                                              0.034,
                                          textColor: Colors.white,
                                          buttonPrimaryColor:
                                          Color(0xFF889BAB),
                                          borderColor:
                                          Color(0xFF889BAB),
                                          width: displayWidth(
                                              context) /
                                              2.3,
                                          onTap: () async {
                                            DownloadTrip()
                                                .downloadTrip(
                                                context,
                                                scaffoldKey,
                                                tripData!.id!);
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
                                          context:
                                          context,
                                          fontSize: displayWidth(
                                              context) *
                                              0.034,
                                          textColor:
                                          Colors
                                              .white,
                                          buttonPrimaryColor:
                                          buttonBGColor,
                                          borderColor:
                                          buttonBGColor,
                                          width:
                                          displayWidth(
                                              context) /
                                              2.3,
                                          onTap:
                                              () async {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BottomNavigation(),
                                                ),
                                                ModalRoute.withName(""));
                                          })
                                          : CommonButtons
                                          .getActionButton(
                                          title:
                                          'Upload Trip Data',
                                          context:
                                          context,
                                          fontSize:
                                          displayWidth(
                                              context) *
                                              0.034,
                                          textColor:
                                          Colors
                                              .white,
                                          buttonPrimaryColor:
                                          buttonBGColor,
                                          borderColor:
                                          buttonBGColor,
                                          width: displayWidth(
                                              context) /
                                              2.3,
                                          onTap:
                                              () async {
                                            await Utils()
                                                .check(
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
                                              setState(
                                                      () {
                                                    isTripUploaded =
                                                    true;
                                                  });
                                              uploadDataIfDataIsNotSync();

                                              Utils.customPrint(
                                                  'WIFI');
                                            }
                                          })
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      // top: displayWidth(context) * 0.03,
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
                )
                    : Expanded(
                  child: tripIsRunning
                      ? Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              height:
                              displayHeight(context) / 1.8,
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
                                    CrossAxisAlignment
                                        .start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets
                                            .symmetric(
                                            horizontal: 12),
                                        child: commonText(
                                          context: context,
                                          text: 'Analytics',
                                          fontWeight:
                                          FontWeight.w700,
                                          textColor:
                                          Colors.black87,
                                          textSize:
                                          displayWidth(
                                              context) *
                                              0.032,
                                        ),
                                      ),
                                      getTripDetailsFromNoti
                                          ? Container(
                                        height: displayHeight(
                                            context) *
                                            0.2,
                                        child: Center(
                                            child:
                                            CircularProgressIndicator()),
                                      )
                                          : vesselAnalytics(
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
                                    displayHeight(context) *
                                        0.01,
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
                                child:
                                CircularProgressIndicator(
                                  valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                      circularProgressColor),
                                ))
                                : Column(
                              children: [
                                CommonButtons.getActionButton(
                                    title: 'End Trip',
                                    context: context,
                                    fontSize:
                                    displayWidth(context) *
                                        0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor:
                                    buttonBGColor,
                                    borderColor: buttonBGColor,
                                    width:
                                    displayWidth(context),
                                    onTap: () async {
                                      //BgGeoTrip().endTrip();

                                      Utils.customPrint(
                                          "END TRIP CURRENT TIME ${DateTime.now()}");

                                      bool isSmallTrip =  Utils().checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));

                                      Utils.customPrint("SMALL TRIPP IDDD bool$isSmallTrip");

                                      if(!isSmallTrip)
                                      {
                                        Utils().showDeleteTripDialog(context,
                                            endTripBtnClick: (){

                                              endTrip(isTripDeleted: true);

                                              Utils.customPrint("SMALL TRIPP IDDD ${tripData!
                                                  .id!}");

                                              int value = Platform.isAndroid ? 1 : 0;

                                              Future.delayed(Duration(seconds: value), (){
                                                if(!isSmallTrip)
                                                {

                                                  Utils.customPrint("SMALL TRIPP IDDD ${tripData!
                                                      .id!}");
                                                  DatabaseService().deleteTripFromDB(tripData!
                                                      .id!);

                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => BottomNavigation()),
                                                      ModalRoute.withName(""));
                                                }
                                              });
                                            },
                                            onCancelClick: (){
                                              Navigator.pop(context);
                                            }
                                        );
                                      }
                                      else
                                      {
                                        Utils().showEndTripDialog(
                                            context, () async {

                                          endTrip();

                                        }, () {
                                          Navigator.pop(context);
                                        });
                                      }


                                    }),

                                Padding(
                                  padding: EdgeInsets.only(

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
                                height: displayHeight(context) /
                                    1.8,
                                margin: EdgeInsets.only(
                                    top: 20,
                                    left: 17,
                                    right: 17),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets
                                              .symmetric(
                                              horizontal:
                                              12),
                                          child: commonText(
                                            context: context,
                                            text: 'Analytics',
                                            fontWeight:
                                            FontWeight.w700,
                                            textColor:
                                            Colors.black87,
                                            textSize:
                                            displayWidth(
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
                                      height: displayHeight(
                                          context) *
                                          0.01,
                                    ),
                                    Container(
                                      margin:
                                      EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              commonText(
                                                context:
                                                context,
                                                text:
                                                'Trip Details',
                                                fontWeight:
                                                FontWeight
                                                    .w700,
                                                textColor: Colors
                                                    .black87,
                                                textSize:
                                                displayWidth(
                                                    context) *
                                                    0.032,
                                              ),
                                              Row(
                                                children: [
                                                  commonText(
                                                    context:
                                                    context,
                                                    text:
                                                    'Trip Status:',
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                    textColor:
                                                    Colors
                                                        .black87,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.03,
                                                  ),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  commonText(
                                                    context:
                                                    context,
                                                    text: tripIsRunning
                                                        ? 'Trip InProgress'
                                                        : 'Trip Ended',
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                    textColor: tripIsRunning
                                                        ? Color(
                                                        0xFFAE6827)
                                                        : Colors
                                                        .green,
                                                    textSize:
                                                    displayWidth(context) *
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
                                                context:
                                                context,
                                                text:
                                                'Start Date',
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
                                                    0.04,
                                              ),
                                              commonText(
                                                context:
                                                context,
                                                text:
                                                ': ${DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.createdAt!))}',
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
                                          Row(
                                            children: [
                                              commonText(
                                                context:
                                                context,
                                                text:
                                                'Start Time',
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
                                                    0.04,
                                              ),
                                              commonText(
                                                context:
                                                context,
                                                text:
                                                ': ${DateFormat('hh:mm').format(DateTime.parse(tripData!.createdAt!))}',
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
                                                'End Date',
                                                fontWeight:
                                                FontWeight
                                                    .w500,
                                                textColor:
                                                Colors
                                                    .grey,
                                                textSize:
                                                displayWidth(context) *
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
                                                ': ${DateFormat('yyyy-MM-dd').format(DateTime.parse(tripData!.updatedAt!))}',
                                                fontWeight:
                                                FontWeight
                                                    .w500,
                                                textColor:
                                                Colors
                                                    .black,
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
                                                context:
                                                context,
                                                text:
                                                'End Time',
                                                fontWeight:
                                                FontWeight
                                                    .w500,
                                                textColor:
                                                Colors
                                                    .grey,
                                                textSize:
                                                displayWidth(context) *
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
                              child: tripData!.isCloud != 0
                                  ? Column(
                                children: [
                                  SizedBox(
                                    width:
                                    displayWidth(context),
                                    child: CommonButtons
                                        .getActionButton(
                                        title: 'Home',
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
                                          Navigator
                                              .pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation(),
                                              ),
                                              ModalRoute.withName(
                                                  ""));
                                        }),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                      // top: displayWidth(context) * 0.03,
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
                              )
                                  : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      CommonButtons
                                          .getActionButton(
                                          title:
                                          'Download Trip',
                                          context:
                                          context,
                                          fontSize:
                                          displayWidth(context) *
                                              0.034,
                                          textColor:
                                          Colors
                                              .white,
                                          buttonPrimaryColor:
                                          Color(
                                              0xFF889BAB),
                                          borderColor: Color(
                                              0xFF889BAB),
                                          width: displayWidth(
                                              context) /
                                              2.3,
                                          onTap:
                                              () async {
                                            DownloadTrip().downloadTrip(
                                                context,
                                                scaffoldKey,
                                                tripData!
                                                    .id!);
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
                                              valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                                  circularProgressColor),
                                            )),
                                      )
                                          : tripData?.isSync !=
                                          0
                                          ? CommonButtons
                                          .getActionButton(
                                          title:
                                          'Home',
                                          context:
                                          context,
                                          fontSize:
                                          displayWidth(context) *
                                              0.034,
                                          textColor:
                                          Colors
                                              .white,
                                          buttonPrimaryColor:
                                          buttonBGColor,
                                          borderColor:
                                          buttonBGColor,
                                          width: displayWidth(context) /
                                              2.3,
                                          onTap:
                                              () async {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BottomNavigation(),
                                                ),
                                                ModalRoute.withName(""));
                                          })
                                          : CommonButtons
                                          .getActionButton(
                                          title:
                                          'Upload Trip Data',
                                          context:
                                          context,
                                          fontSize:
                                          displayWidth(context) *
                                              0.034,
                                          textColor:
                                          Colors
                                              .white,
                                          buttonPrimaryColor:
                                          buttonBGColor,
                                          borderColor:
                                          buttonBGColor,
                                          width: displayWidth(context) /
                                              2.3,
                                          onTap:
                                              () async {
                                            await Utils()
                                                .check(scaffoldKey);

                                            if (tripData?.isSync !=
                                                0) {
                                              Utils.customPrint('UPLOADED ${tripData?.isSync != 0}');
                                              Utils.customPrint('UPLOADED 1 ${isTripUploaded}');

                                              Utils.showSnackBar(
                                                context,
                                                scaffoldKey: scaffoldKey,
                                                message: 'File already uploaded',
                                              );
                                              return;
                                            }

                                            //downloadTrip(true);

                                            var connectivityResult =
                                            await (Connectivity().checkConnectivity());
                                            if (connectivityResult ==
                                                ConnectivityResult.mobile) {
                                              Utils.customPrint('Mobile');
                                              showDialogBoxToUploadTrip();
                                            } else if (connectivityResult ==
                                                ConnectivityResult.wifi) {
                                              setState(() {
                                                isTripUploaded = true;
                                              });
                                              uploadDataIfDataIsNotSync();

                                              Utils.customPrint('WIFI');
                                            }
                                          })
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      //top: displayWidth(context) * 0.01,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Check vessel is sync or not
  Future<bool> vesselIsSyncOrNot(String vesselId) async {
    bool result = await _databaseService.getVesselIsSyncOrNot(vesselId);

    setState(() {
      vesselIsSync = result;
      Utils.customPrint('Vessel isSync $vesselIsSync');
    });

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

  /// Upload sensor data to database
  startSensorFunctionality(Trip tripData) async {
    AndroidDeviceInfo? androidDeviceInfo;
    IosDeviceInfo? iosDeviceInfo;
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceDetails.androidInfo;
    } else {
      iosDeviceInfo = await deviceDetails.iosInfo;
    }

    String tripDuration = '';
    if (Platform.isAndroid) {
      tripDuration = tripData.time ?? '00:00:00';
    } else {
      DateTime createdAtTime = DateTime.parse(tripData.createdAt!);
      DateTime updatedAtTime = DateTime.parse(tripData.updatedAt!);

      var durationTime = updatedAtTime.difference(createdAtTime);
      tripDuration = Utils.calculateTripDuration(
          ((durationTime.inMilliseconds) / 1000).toInt());
    }

    String? tripDistance = tripData.distance ?? '1';
    String? tripSpeed = tripData.speed ?? '1';
    String? tripAvgSpeed = tripData.avgSpeed ?? '1';

    var startPosition = tripData.startPosition!.split(",");
    var endPosition = tripData.endPosition!.split(",");
    Utils.customPrint('START POSITION 0 ${startPosition}');

    Directory tripDir = await getApplicationDocumentsDirectory();
    var sensorInfo = await Utils().getSensorObjectWithAvailability();


    var queryParameters;
    queryParameters = {
      "id": tripData.id,
      "load": tripData.currentLoad,
      "trip_name":tripData.name,

      "sensorInfo": sensorInfo['sensorInfo'],
      "deviceInfo": {
        "deviceId": Platform.isAndroid ? androidDeviceInfo!.id : '',
        "model": Platform.isAndroid
            ? androidDeviceInfo!.model
            : iosDeviceInfo!.model,
        "version": Platform.isAndroid
            ? androidDeviceInfo!.version.release
            : iosDeviceInfo!.utsname.release,
        "make": Platform.isAndroid
            ? androidDeviceInfo!.manufacturer
            : iosDeviceInfo?.utsname.machine,
        "board": Platform.isAndroid
            ? androidDeviceInfo!.board
            : iosDeviceInfo!.utsname.machine,
        "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
      },
      "startPosition": startPosition,
      "endPosition": endPosition,
      "number_of_passengers": tripData.numberOfPassengers,
      "vesselId": tripData.vesselId,
      "filePath": Platform.isAndroid
          ? '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'
          : '${tripDir.path}/${tripData.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      "duration": tripDuration,
      "distance": double.parse(tripDistance),
      "speed": double.parse(tripSpeed),
      "avgSpeed": double.parse(tripAvgSpeed),
    };

    Utils.customPrint('Send Sensor Data: $queryParameters');

    commonProvider
        .sendSensorInfo(
        Get.context!,
        commonProvider.loginModel!.token!,
        File(Platform.isAndroid
            ? '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'
            : '${tripDir.path}/${tripData.id}.zip'),
        queryParameters,
        tripData.id!,
        scaffoldKey)
        .then((value) async {
      if (value != null) {
        commonProvider.updateTripUploadingStatus(false);
        if (value.status!) {
          await cancelOnGoingProgressNotification(tripData.id!);

          if (mounted) {
            setState(() {
              isTripUploaded = false;
            });
          }
          Utils.customPrint("tripData!.id: ${tripData.id}");
          _databaseService.updateTripIsSyncStatus(1, tripData.id.toString());
          Trip tripDetails = await _databaseService.getTrip(tripData.id!);
          Utils.customPrint('TRIP DETAILS: ${tripDetails.toJson()}');
          if (mounted) {
            setState(() {
              this.tripData = tripDetails;
              Utils.customPrint('TRIP STATUS ${tripData.isSync}');
            });
          }

          showSuccessNoti();

          isDataUpdated = true;
        } else {
          if (mounted) {
            setState(() {
              isTripUploaded = false;
            });
          }
          showFailedNoti(tripData.id!);
        }
      } else {
        commonProvider.updateTripUploadingStatus(false);
        if (mounted) {
          setState(() {
            isTripUploaded = false;
          });
        }
        showFailedNoti(tripData.id!);
      }
    }).catchError((onError, s) {
      if (mounted) {
        setState(() {
          isTripUploaded = false;
        });
      }
      Utils.customPrint('ON ERROR $onError \n $s');
    });
  }

  /// To cancel notification
  Future<void> cancelOnGoingProgressNotification(String id) async {
    flutterLocalNotificationsPlugin.cancel(9989);

    return;
  }

  /// If data is not sync then it will upload first vessel and then trip
  uploadDataIfDataIsNotSync() async {
    commonProvider.updateTripUploadingStatus(true);
    await vesselIsSyncOrNot(tripData!.vesselId.toString());
    Utils.customPrint('VESSEL STATUS isSync $vesselIsSync');

    commonProvider.updateTripUploadingStatus(true);
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
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(
        9989, 'Uploading vessel details...', '', platformChannelSpecifics,
        payload: 'item x');

    commonProvider.init();

    CreateVessel? vesselData = await _databaseService
        .getVesselFromVesselID((tripData!.vesselId.toString()));

   if(vesselData!.createdBy == commonProvider.loginModel!.userId)
     {
       if (!vesselIsSync) {
         Utils.customPrint('VESSEL DATA ${vesselData!.id}');

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
         commonProvider.addVesselRequestModel!.vesselStatus =
             vesselData.vesselStatus;
         commonProvider.addVesselRequestModel!.batteryCapacity =
             vesselData.batteryCapacity;
         commonProvider.addVesselRequestModel!.createdBy = vesselData.createdBy;
         commonProvider.addVesselRequestModel!.updatedBy = vesselData.updatedBy;
         /*commonProvider.addVesselRequestModel!.displacement =
          vesselData.displacement;*/

         if (vesselData.imageURLs != null && vesselData.imageURLs!.isNotEmpty) {
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
               await _databaseService.updateIsSyncStatus(
                   1, tripData!.vesselId.toString());

               startSensorFunctionality(tripData!);
             } else {
               commonProvider.updateTripUploadingStatus(false);
               Utils.customPrint('UPLOADEDDDD: ${value.message}');
               await cancelOnGoingProgressNotification(tripData!.id!);
               showFailedNoti(tripData!.id!);
               if (mounted) {
                 setState(() {
                   isTripUploaded = false;
                 });
               }
             }
           } else {
             commonProvider.updateTripUploadingStatus(false);
             await cancelOnGoingProgressNotification(tripData!.id!);
             showFailedNoti(tripData!.id!);
             if (mounted) {
               setState(() {
                 isTripUploaded = false;
               });
             }
           }
         });
       }
     }else {
      if (mounted) {
        setState(() {
          isTripUploaded = false;
        });
      }
      startSensorFunctionality(tripData!);
    }
  }

  /// To show failed notification if error occure while uploading trip
  showFailedNoti(String id) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: false);
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(9987, id,
        'Failed to upload. Please try again', platformChannelSpecifics,
        payload: 'item x');
  }

  /// To show success notification after uploading trip
  showSuccessNoti() async {
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
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(
        9989, 'Trip uploaded successfully', '', platformChannelSpecifics,
        payload: 'item x');
  }

  showEndTripDialogBox(BuildContext context) {
    if(sharedPreferences != null){
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }

            SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
                                  lastTimeUsedText,
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
                          margin: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: isEndTripBtnClicked
                                    ? CircularProgressIndicator()
                                    : CommonButtons.getAcceptButton(
                                    'End Trip', context, Colors.transparent,
                                        () async {

                                      bool isSmallTrip =  Utils().checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));

                                      if(!isSmallTrip)
                                      {
                                        Navigator.pop(context);

                                        Utils().showDeleteTripDialog(context,
                                            endTripBtnClick: (){

                                              if (durationTimer !=
                                                  null) {
                                                durationTimer!
                                                    .cancel();
                                              }
                                              setState(() {
                                                isTripEnded = true;
                                              });
                                              Navigator.pop(context);

                                              EndTrip().endTrip(
                                                  context: context,
                                                  scaffoldKey:
                                                  scaffoldKey,
                                                  duration:
                                                  tripDuration,
                                                  IOSAvgSpeed:
                                                  tripAvgSpeed,
                                                  IOSpeed: tripSpeed,
                                                  IOStripDistance:
                                                  tripDistance,
                                                  onEnded: () async {
                                                    setState(() {
                                                      tripIsRunning =
                                                      false;
                                                      isTripEnded =
                                                      false;
                                                    });
                                                    Trip tripDetails =
                                                    await _databaseService
                                                        .getTrip(
                                                        tripData!
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
                                                      tripData =
                                                          tripDetails;
                                                    });

                                                    Utils.customPrint(
                                                        'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                                    Utils.customPrint(
                                                        'TRIP ENDED DETAILS: ${tripData!.isSync}');

                                                    isDataUpdated = true;

                                                    Future.delayed(Duration(seconds: 1), (){
                                                      if(!isSmallTrip)
                                                      {
                                                        Utils.customPrint("SMALL TRIPP IDDD ${tripData!
                                                            .id!}");
                                                        DatabaseService().deleteTripFromDB(tripData!
                                                            .id!);
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
                                                        //     context,
                                                        //     MaterialPageRoute(builder: (context) => BottomNavigation()),
                                                        //     ModalRoute.withName(""));
                                                      }
                                                    });
                                                  });

                                              Utils.customPrint("SMALL TRIPP IDDD ${tripData!
                                                  .id!}");

                                            },
                                            onCancelClick: (){
                                              Navigator.pop(context);
                                            }
                                        );
                                      }
                                      else
                                      {
                                        setDialogState(() {
                                          isEndTripBtnClicked = true;
                                        });

                                        if (durationTimer !=
                                            null) {
                                          durationTimer!
                                              .cancel();
                                        }
                                        setState(() {
                                          isTripEnded = true;
                                        });
                                        Navigator.pop(context);

                                        EndTrip().endTrip(
                                            context: context,
                                            scaffoldKey:
                                            scaffoldKey,
                                            duration:
                                            tripDuration,
                                            IOSAvgSpeed:
                                            tripAvgSpeed,
                                            IOSpeed: tripSpeed,
                                            IOStripDistance:
                                            tripDistance,
                                            onEnded: () async {
                                              setState(() {
                                                tripIsRunning =
                                                false;
                                                isTripEnded =
                                                false;
                                              });
                                              Trip tripDetails =
                                              await _databaseService
                                                  .getTrip(
                                                  tripData!
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
                                                tripData =
                                                    tripDetails;
                                              });

                                              Utils.customPrint(
                                                  'TRIP ENDED DETAILS: ${tripDetails.isSync}');
                                              Utils.customPrint(
                                                  'TRIP ENDED DETAILS: ${tripData!.isSync}');

                                              isDataUpdated = true;
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
                              SizedBox(height: 10,),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Continue Trip', context, Colors.transparent,
                                        () async {
bool? runningTrip = sharedPreferences!
                                            .getBool("trip_started");

                                      final _isRunning = await BackgroundLocator();

                                      Utils.customPrint('INTRO TRIP IS RUNNING 1212 $_isRunning');

                                      List<String>? tripData = sharedPreferences!.getStringList('trip_data');

                                      reInitializeService();

                                      StartTrip().startBGLocatorTrip(tripData![0], DateTime.now(), true);

                                      final isRunning2 = await BackgroundLocator.isServiceRunning();

                                      Utils.customPrint('INTRO TRIP IS RUNNING 22222 $isRunning2');
                                      Navigator.of(context).pop();
                                        Navigator.push(
                                            dialogContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TripRecordingScreen(
                                                      //bottomNavIndex: _bottomNavIndex,
                                                        tripId: tripData[0],
                                                        vesselId: tripData![1],
                                                        vesselName: tripData[2],
                                                        tripIsRunningOrNot:
                                                            runningTrip)));



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

  endTrip({bool isTripDeleted = false})
  {

    if (durationTimer !=
        null) {
      durationTimer!
          .cancel();
    }

    setState(() {
      isTripEnded = true;
    });

    Navigator.pop(context);

    Utils.customPrint(
        "TRIP DURATION WHILE END TRIP $tripDuration");

    EndTrip().endTrip(
        context: context,
        scaffoldKey:
        scaffoldKey,
        duration:
        tripDuration,
        IOSAvgSpeed:
        tripAvgSpeed,
        IOSpeed: tripSpeed,
        IOStripDistance:
        tripDistance,
        onEnded: () async {

          if(mounted)
            {
              setState(() {
                tripIsRunning =
                false;
                isTripEnded =
                false;
              });
            }

          if(!isTripDeleted)
            {
              Trip tripDetails =
              await _databaseService
                  .getTrip(
                  tripData!
                      .id!);

              setState(() {
                tripData =
                    tripDetails;
              });
            }

          isDataUpdated =
          true;
        });
  }
}