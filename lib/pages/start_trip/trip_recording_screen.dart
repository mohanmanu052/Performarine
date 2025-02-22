import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/start_trip/trip_recording_analytics_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wakelock/wakelock.dart';

import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class TripRecordingScreen extends StatefulWidget {
  final String? vesselId, tripId, vesselName;
  final bool? tripIsRunningOrNot;
  final bool isAppKilled;
  final String? calledFrom;
  final int? bottomNavIndex;

  const TripRecordingScreen(
      {super.key,
      this.tripId,
      this.vesselId,
      this.tripIsRunningOrNot,
      this.isAppKilled = false,
      this.calledFrom = '',
      this.vesselName,
      this.bottomNavIndex});

  @override
  State<TripRecordingScreen> createState() => _TripRecordingScreenState();
}

class _TripRecordingScreenState extends State<TripRecordingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late TabController tabController;
  int currentTabIndex = 0;
  late CommonProvider commonProvider;
  final controller = ScreenshotController();
  bool isEndTripBtnClicked = false,
      tripIsRunning = false,
      isTripEnded = false,
      isDataUpdated = false;
  String tripDistance = '0.00',
      tripDuration = '00:00:00',
      tripSpeed = '0.0',
      tripAvgSpeed = '0.0';
  Timer? durationTimer;
  final DatabaseService _databaseService = DatabaseService();

  Trip? tripData;
  CreateVessel? vesselData;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();

    commonProvider = context.read<CommonProvider>();
    Wakelock.enable();
    tabController = TabController(initialIndex: 0, length: 1, vsync: this);
    tabController.addListener(() {
      setState(() {
        currentTabIndex = tabController.index;
      });
    });

    tripIsRunning = widget.tripIsRunningOrNot ?? false;
  }

  @override
  void dispose() {
    if (commonProvider.bottomNavIndex == 1) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ]);
    }

//     ]);

// }else{
//           SystemChrome.setPreferredOrientations([

//       DeviceOrientation.portraitDown,

//       DeviceOrientation.portraitUp

//     ]);

// }

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Screenshot(
      controller: controller,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async
        {
          if(didPop)  return;

          print('XXXXXX: ${widget.calledFrom}');
          Wakelock.disable().then((value) async {
            if (widget.calledFrom != null) {
              if (widget.calledFrom!.isNotEmpty) {
                if (widget.calledFrom == 'bottom_nav' ||
                    widget.calledFrom == 'notification') {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation(
                            tabIndex:
                            widget.calledFrom == 'notification'
                                ? 0
                                : commonProvider.bottomNavIndex,
                          )),
                      ModalRoute.withName(""))
                      .then((value) => SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]));
                  ;
                  ;
                } else {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
              return false;
            } else {
              Navigator.of(context).pop();
              return false;
            }
          });
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                Wakelock.disable().then((value) async {
                  if (widget.calledFrom != null) {
                    if (widget.calledFrom!.isNotEmpty) {
                      if (widget.calledFrom == 'bottom_nav' ||
                          widget.calledFrom == 'notification') {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation(
                                      tabIndex:
                                          widget.calledFrom == 'notification'
                                              ? 0
                                              : commonProvider.bottomNavIndex,
                                    )),
                            ModalRoute.withName(""));
                      } else {
                        Navigator.of(context).pop();
                      }
                      /*else if(widget.calledFrom == 'VesselSingleView')
                      {
                        CreateVessel? vesselData = await DatabaseService()
                            .getVesselFromVesselID(widget.vesselId!);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => VesselSingleView(
                            vessel: vesselData,
                            isCalledFromSuccessScreen: true,
                          )),);
                      }*/
                    } else {
                      // if(mounted){
                      //   Navigator.pushAndRemoveUntil(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => BottomNavigation(
                      //         tabIndex: 0,
                      //       )),
                      //       ModalRoute.withName(""));
                      // }

                      Navigator.of(context).pop();
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                });

                //Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Container(
              child: Text(
                widget.vesselName != null
                    ? widget.vesselName!
                    : 'Trip Recording',
                //widget.vesselName != null ? widget.vesselName :'Trip Recording',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: displayWidth(context) * 0.045,
                  color: Colors.black87,
                  fontFamily: outfit,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),

              /* commonText(
                context: context,
                text: widget.vesselName != null ? widget.vesselName :'Trip Recording',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.045,
              ),*/
            ),
            // bottom: TabBar(
            //   controller: tabController,
            //   padding: EdgeInsets.all(0),
            //   labelPadding: EdgeInsets.zero,
            //   isScrollable: true,
            //   indicatorColor: Colors.white,
            //   onTap: (int value) {
            //     setState(() {
            //       currentTabIndex = value;
            //     });
            //   },
            //   tabs: [
            //     Container(
            //       margin: EdgeInsets.only(right: 2),
            //       width: displayWidth(context) * 0.35,
            //       decoration: BoxDecoration(
            //           color: currentTabIndex == 0
            //               ? Color(0xff2663DB)
            //               : backgroundColor,
            //           border: Border.all(color: Color(0xff2663DB)),
            //           borderRadius: BorderRadius.all(Radius.circular(10))),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 9.0),
            //         child: commonText(
            //           context: context,
            //           text: 'Map View',
            //           fontWeight: FontWeight.w400,
            //           textColor:
            //               currentTabIndex == 0 ? Colors.white : Colors.black,
            //           textSize: displayWidth(context) * 0.034,
            //         ),
            //         // Text('Vessels'),
            //       ),
            //     ),
            //     Container(
            //       margin: EdgeInsets.only(left: 12),
            //       width: displayWidth(context) * 0.35,
            //       decoration: BoxDecoration(
            //           color: currentTabIndex == 1
            //               ? Color(0xff2663DB)
            //               : backgroundColor,
            //           border: Border.all(color: Color(0xff2663DB)),
            //           borderRadius: BorderRadius.all(Radius.circular(10))),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 9.0),
            //         child: commonText(
            //           context: context,
            //           text: 'Analytics',
            //           fontWeight: FontWeight.w400,
            //           textColor:
            //               currentTabIndex == 1 ? Colors.white : Colors.black,
            //           textSize: displayWidth(context) * 0.034,
            //         ),
            //       ),
            //     ),
              //],
           // ),
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
                            ModalRoute.withName(""))
                        .then((value) => SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                            ]));
                    ;
                    ;
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
          body: Stack(
            children: [
              TabBarView(
                controller: tabController,
                children: [

                  TripRecordingAnalyticsScreen(
                      calledFrom: widget.calledFrom,
                      scaffoldKey: scaffoldKey,
                      tripId: widget.tripId,
                      vesselId: widget.vesselId,
                      tripIsRunningOrNot: widget.tripIsRunningOrNot,
                      context: context,
                      isAppKilled: widget.isAppKilled),

                  // MapScreen(
                  //     calledFrom: widget.calledFrom,
                  //     scaffoldKey: scaffoldKey,
                  //     tripId: widget.tripId,
                  //     vesselId: widget.vesselId,
                  //     tripIsRunningOrNot: widget.tripIsRunningOrNot,
                  //     context: context,
                  //     isAppKilled: widget.isAppKilled),
                ],
              ),
              Positioned(
                  bottom: displayHeight(context)*0.01,
                  child: GestureDetector(
                      onTap: () async {
                        final image = await controller.capture();
                        await SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.portraitUp]);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackReport(
                                      imagePath: image.toString(),
                                      uIntList: image,
                                    )));
                      },
                      child: UserFeedback().getUserFeedback(context)))
            ],
          ),
        ),
      ),
    );
  }
}
