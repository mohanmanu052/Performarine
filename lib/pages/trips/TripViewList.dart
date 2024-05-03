import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/pages/trips/trip_widget_new.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import 'dart:io';

import '../../main.dart';

class TripViewList extends StatefulWidget {
  String? vesselId, calledFrom;
  VoidCallback? onTripEnded;
  VoidCallback? isTripDeleted;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  TripViewList(
      {this.vesselId, this.calledFrom, this.onTripEnded, this.scaffoldKey,this.isTripDeleted});

  @override
  State<TripViewList> createState() => _TripViewListState();
}

class _TripViewListState extends State<TripViewList> {
  final DatabaseService _databaseService = DatabaseService();
  late CommonProvider commonProvider;

  bool tripIsRunning = false,
      isDeleteTripBtnClicked = false,
      isDeletedSuccessfully = false,
      isTripUploaded = false;

  bool isBtnClick = false;

  final controller = ScreenshotController();
  File? imageFile;

  late Future<List<Trip>> future;
  late Future<List<Trip>> getTripsByIdFuture;
  StateSetter? internalStateSetter;
  Future<List<Trip>> getTripsByVesselId() {
    if (widget.vesselId == null || widget.vesselId == "") {
      getTripsByIdFuture = _databaseService.trips();
    } else {
      getTripsByIdFuture =
          _databaseService.getAllTripsByVesselId(widget.vesselId.toString());
    }
    return getTripsByIdFuture;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    isBtnClick = false;
    commonProvider = context.read<CommonProvider>();
    commonProvider.getTripsByVesselId(widget.vesselId);
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: FutureBuilder<List<Trip>>(
        future: commonProvider.getTripsByIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: displayHeight(context),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(circularProgressColor),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Container(
                height: displayHeight(context) / 1.5,
                child: Center(
                  child: commonText(
                      text: 'oops! No Trips are added yet',
                      context: context,
                      textSize: displayWidth(context) * 0.04,
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              );
            } else {
              return snapshot.data != null
                  ? StatefulBuilder(
                  builder: (BuildContext context, StateSetter setter) {
                    Utils.customPrint("TRIP DETAILS ${snapshot.data!.length}");
                    Utils.customPrint(
                        "TRIP DETAILS 1 ${snapshot.data![0].distance}");
                    return Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8.0),
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final itemKey = ValueKey(index);
                            return snapshot.data!.isNotEmpty
                                ? TripWidget(
                                scaffoldKey: widget.scaffoldKey,
                                tripList: snapshot.data![index],
                                calledFrom: widget.calledFrom,
                                onTripEnded: (){
                                  if(mounted){
                                    setState(() {
                                      print("Call back for delete trips in list");
                                    });
                                  }
                                },
                                tripUploadedSuccessfully: () {
                                  if (mounted) {
                                    setState(() {
                                      isTripUploaded = true;
                                      commonProvider.getTripsByVesselId(
                                          widget.vesselId);
                                      future = _databaseService.trips();
                                      //snapshot.data![index].tripStatus = 1;
                                    });
                                  }
                                 // commonProvider.getTripsCount();
                                },
                                onTap: () async {

                                  final currentTrip = await _databaseService
                                      .getTrip(snapshot.data![index].id!);

                                  DateTime createdAtTime = DateTime.parse(
                                      currentTrip.createdAt!);

                                  var durationTime = DateTime.now()
                                      .toUtc()
                                      .difference(createdAtTime);
                                  String tripDuration =
                                  Utils.calculateTripDuration(
                                      ((durationTime.inMilliseconds) /
                                          1000)
                                          .toInt());
                                  debugPrint("DURATION !!!!!! $tripDuration");

                                  bool isSmallTrip =  Utils().checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));

                                  if(!isSmallTrip)
                                  {
                                    Utils().showDeleteTripDialog(context,
                                        endTripBtnClick: (){
                                          endTripMethod(tripDuration, snapshot.data![index]);
                                          debugPrint("SMALL TRIPP IDDD ${snapshot.data![index].id!}");

                                          Future.delayed(Duration(seconds: 1), (){
                                            if(!isSmallTrip)
                                            {
                                              debugPrint("SMALL TRIPP IDDD 11 ${snapshot.data![index].id!}");
                                              DatabaseService().deleteTripFromDB(snapshot.data![index].id!);
                                            }
                                          });
                                        }, onCancelClick: (){
                                          Navigator.of(context).pop();
                                        }
                                    );
                                  }
                                  else
                                  {
                                    Utils().showEndTripDialog(context,
                                            () async {

                                          final currentTrip = await _databaseService
                                              .getTrip(snapshot.data![index].id!);

                                          DateTime createdAtTime = DateTime.parse(
                                              currentTrip.createdAt!);

                                          var durationTime = DateTime.now()
                                              .toUtc()
                                              .difference(createdAtTime);
                                          String tripDuration =
                                          Utils.calculateTripDuration(
                                              ((durationTime.inMilliseconds) /
                                                  1000)
                                                  .toInt());
                                          debugPrint("DURATION !!!!!! $tripDuration");

                                          endTripMethod(tripDuration, snapshot.data![index]);

                                          return;
                                        }, () {
                                          Navigator.of(context).pop();
                                        });
                                  }
                                })
                                : Container(
                              height: displayHeight(context) / 1.5,
                              child: Center(
                                child: commonText(
                                    text: 'oops! No Trips are added yet',
                                    context: context,
                                    textSize: displayWidth(context) * 0.04,
                                    textColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                        ),);
                  })
                  : Container(
                height: displayHeight(context) / 1.5,
                child: Center(
                  child: commonText(
                      text: 'oops! No Trips are added yet',
                      context: context,
                      textSize: displayWidth(context) * 0.04,
                      textColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              );
            }
          }
          return Container();
        },

      ),
    );
  }

  /// To Check trip is Running or not
  Future<bool> tripIsRunningOrNot(Trip trip) async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      Utils.customPrint('Trip is Running $tripIsRunning');
      setState(() {
        trip.isEndTripClicked = false;
      });
    });

    return result;
  }

  endTripMethod(String tripDuration, Trip trip,)async
  {

    Navigator.of(context).pop();

    await commonProvider
        .updateTripStatus(true);

    setState(() {
      trip.isEndTripClicked =
      true;
    });

    final currentTrip = await _databaseService
        .getTrip(trip.id!);

    DateTime createdAtTime = DateTime.parse(
        currentTrip.createdAt!);

    var durationTime = DateTime.now()
        .toUtc()
        .difference(createdAtTime);
    String tripDuration =
    Utils.calculateTripDuration(
        ((durationTime.inMilliseconds) /
            1000)
            .toInt());

    Utils.customPrint('***DIST: ${currentTrip.toJson()}');

    EndTrip().endTrip(
        context: context,
        scaffoldKey: widget.scaffoldKey,
        duration: tripDuration,
        onEnded: () async {
          setState(() {
            trip.tripStatus =
            1;
          });

          await commonProvider
              .updateTripStatus(false);

          if (widget.onTripEnded != null) {
            widget.onTripEnded!.call();
          }

          await tripIsRunningOrNot(
              trip);
        });
  }
}

