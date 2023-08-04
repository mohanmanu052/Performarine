import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wakelock/wakelock.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../main.dart';
import '../../models/trip.dart';
import '../../models/vessel.dart';
import '../../services/database_service.dart';
import '../feedback_report.dart';

class TripRecordingAnalyticsScreen extends StatefulWidget {
  final bool? tripIsRunningOrNot;
  final String? vesselId, tripId;
  final bool isAppKilled;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BuildContext? context;
  const TripRecordingAnalyticsScreen({super.key, this.scaffoldKey, this.tripIsRunningOrNot, this.vesselId, this.tripId, this.isAppKilled = false, this.context});

  @override
  State<TripRecordingAnalyticsScreen> createState() => _TripRecordingAnalyticsScreenState();
}

class _TripRecordingAnalyticsScreenState extends State<TripRecordingAnalyticsScreen> {

  final controller = ScreenshotController();

  String tripDistance = '0.00';
  String tripDuration = '00:00:00';
  String tripSpeed = '0.1';
  String tripAvgSpeed = '0.1';

  Trip? tripData;
  CreateVessel? vesselData;

  Timer? durationTimer;

  final DatabaseService _databaseService = DatabaseService();

  bool tripIsRunning = false, isuploadTrip = false, isTripEnded = false, isEndTripBtnClicked = false, isDataUpdated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      tripIsRunning = widget.tripIsRunningOrNot!;
      getData();
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
      Wakelock.enable();
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

    durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Utils.customPrint('##TDATA updated time delay from 1 sec to 400 MS by abhi');
      tripDistance = sharedPreferences!.getString('tripDistance') ?? "0";
      tripSpeed = sharedPreferences!.getString('tripSpeed') ?? "0.1";
      tripAvgSpeed = sharedPreferences!.getString('tripAvgSpeed') ?? "0.1";

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
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Container(
        margin: EdgeInsets.only(left: 17, right: 17, top: 17, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Column(
              children: [

                SizedBox(height: displayHeight(context) * 0.05,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Container(
                      width: displayWidth(context)* 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xffECF3F9)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          commonText(
                            context: context,
                            text: 'Distance',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.032,
                          ),

                          SizedBox(height: displayHeight(context) * 0.005,),

                          commonText(
                            context: context,
                            text: tripDistance,
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.06,
                          ),

                          SizedBox(height: displayHeight(context) * 0.005,),

                          commonText(
                            context: context,
                            text: 'Nautical Miles',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.028,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: displayWidth(context) * 0.02,),

                    Container(
                      width: displayWidth(context)* 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffECF3F9)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          commonText(
                            context: context,
                            text: 'Current Speed',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.032,
                          ),

                          SizedBox(height: displayHeight(context) * 0.005,),

                          commonText(
                            context: context,
                            text: tripSpeed,
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.06,
                          ),

                          SizedBox(height: displayHeight(context) * 0.005,),

                          commonText(
                            context: context,
                            text: 'KT/Hr',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.028,
                          ),
                        ],
                      ),
                    )

                  ],
                ),

                SizedBox(height: displayHeight(context) * 0.03,),

                Container(
                  width: displayWidth(context),
                  height: displayHeight(context) * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffECF3F9)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      commonText(
                        context: context,
                        text: 'Total Time',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.032,
                      ),

                      SizedBox(height: displayHeight(context) * 0.005,),

                      commonText(
                        context: context,
                        text: tripDuration,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.06,
                      ),

                      SizedBox(height: displayHeight(context) * 0.005,),

                      commonText(
                        context: context,
                        text: 'Nautical Miles',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.028,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Column(
              children: [

                isTripEnded
                    ? Center(
                    child:
                    CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                          circularProgressColor),
                    ))
                    : GestureDetector(
                  onTap: ()
                  {
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
                                    MaterialPageRoute(builder: (context) => HomePage()),
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
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20 ,top: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xff2663DB)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/end_btn.png',
                            height: displayHeight(context) * 0.05,
                            width: displayWidth(context) * 0.12,
                          ),
                          SizedBox(width: displayWidth(context) * 0.01,),
                          commonText(
                            context: context,
                            text: 'Stop Trip',
                            fontWeight: FontWeight.w600,
                            textColor: Colors.white,
                            textSize: displayWidth(context) * 0.042,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    top : displayWidth(context) * 0.005,
                  ),
                  child: GestureDetector(
                      onTap: ()async{
                        final image = await controller.capture();
                        Navigator.push(widget.context!, MaterialPageRoute(builder: (context) => FeedbackReport(
                          imagePath: image.toString(),
                          uIntList: image,)));
                      },
                      child: UserFeedback().getUserFeedback(context)
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
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
        widget.scaffoldKey,
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

          if(!isTripDeleted)
          {
            Navigator.pushAndRemoveUntil(
                widget.context!,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                ModalRoute.withName(""));
          }


        });
  }

  @override
  void dispose() {
    super.dispose();
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
  }
}
