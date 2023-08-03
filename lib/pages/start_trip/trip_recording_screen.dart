import 'dart:async';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/start_trip/map_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_analytics_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/vessel_builder.dart';
import '../../services/database_service.dart';

class TripRecordingScreen extends StatefulWidget {
  final String? vesselId, tripId;
  final bool? tripIsRunningOrNot;
  const TripRecordingScreen({super.key, this.tripId, this.vesselId, this.tripIsRunningOrNot});

  @override
  State<TripRecordingScreen> createState() => _TripRecordingScreenState();
}

class _TripRecordingScreenState extends State<TripRecordingScreen>with TickerProviderStateMixin, WidgetsBindingObserver {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late TabController tabController;
  int currentTabIndex = 0;
  late CommonProvider commonProvider;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();

    tabController =
        TabController(initialIndex: 0, length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        currentTabIndex = tabController.index;
      });
    });


  }



  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        backgroundColor: commonBackgroundColor,
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
        title: Container(
          child: commonText(
            context: context,
            text: 'Trip Recording',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          padding: EdgeInsets.all(0),
          labelPadding: EdgeInsets.zero,
          isScrollable: true,
          indicatorColor: Colors.white,
          onTap: (int value) {
            setState(() {
              currentTabIndex = value;
            });
          },
          tabs: [
            Container(
              margin: EdgeInsets.only(right: 2),
              width: displayWidth(context) * 0.35,
              decoration: BoxDecoration(
                  color: currentTabIndex == 0
                      ? Color(0xff2663DB)
                      : commonBackgroundColor,
                  border: Border.all(color: Color(0xff2663DB)),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: commonText(
                  context: context,
                  text: 'Map View',
                  fontWeight: FontWeight.w400,
                  textColor:
                  currentTabIndex == 0 ? Colors.white : Colors.black,
                  textSize: displayWidth(context) * 0.036,
                ),
                // Text('Vessels'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12),
              width: displayWidth(context) * 0.35,
              decoration: BoxDecoration(
                  color: currentTabIndex == 1
                      ? Color(0xff2663DB)
                      : commonBackgroundColor,
                  border: Border.all(color: Color(0xff2663DB)),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: commonText(
                  context: context,
                  text:
                  'Analytics',
                  fontWeight: FontWeight.w400,
                  textColor:
                  currentTabIndex == 1 ? Colors.white : Colors.black,
                  textSize: displayWidth(context) * 0.036,
                ),
              ),
            ),
          ],
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
      body: TabBarView(
        controller: tabController,
        children: [
          MapScreen(scaffoldKey: scaffoldKey, tripId: widget.tripId, vesselId: widget.vesselId, tripIsRunningOrNot: widget.tripIsRunningOrNot,),
          TripRecordingAnalyticsScreen(),
        ],
      ),
    );
  }
}
