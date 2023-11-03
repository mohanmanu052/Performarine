import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';


class TripViewListing extends StatefulWidget {
  String? vesselId, calledFrom;
  VoidCallback? onTripEnded;
  VoidCallback? isTripDeleted;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  TripViewListing(
      {this.vesselId, this.calledFrom, this.onTripEnded, this.scaffoldKey,this.isTripDeleted});

  @override
  State<TripViewListing> createState() => _TripViewListingState();
}

class _TripViewListingState extends State<TripViewListing> {
  final DatabaseService _databaseService = DatabaseService();
  late CommonProvider commonProvider;

  bool tripIsRunning = false,
      isDeleteTripBtnClicked = false,
      isDeletedSuccessfully = false,
      isTripUploaded = false;

  bool isBtnClick = false;

  final controller = ScreenshotController();
  File? imageFile;
  String? vesselImageUrl = '';

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

    debugPrint("TRIP WIDGET SCREEN CALLED FROM ${widget.calledFrom}");

    isBtnClick = false;
    commonProvider = context.read<CommonProvider>();
    commonProvider.getTripsByVesselId(widget.vesselId);
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: Column(
        children: [
          FutureBuilder<List<Trip>>(
            future: commonProvider.getTripsByIdFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: displayHeight(context),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(blueColor),
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
                            child: SlidableAutoCloseBehavior(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final itemKey = ValueKey(index);
                                  return snapshot.data!.isNotEmpty
                                      ? Slidable(
                                    key: itemKey,
                                   /* endActionPane: snapshot.data![index].tripStatus == 0 ? null : ActionPane(
                                      extentRatio: 0.25,
                                        motion: ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (BuildContext context)async{
                                              Utils.customPrint("Trip id is: ${snapshot.data![index].id!}");
                                              bool tripRunning = await tripIsRunningOrNot(snapshot.data![index]);
                                              bool tripUploadedStatus = false;
                                              if (snapshot.data![index].isSync == 0){
                                                tripUploadedStatus = true;
                                              }
                                              print("status: ${snapshot.data![index].tripStatus}");
                                              if(snapshot.data![index].tripStatus == 1){
                                                showDeleteTripDialogBox(
                                                    context,
                                                    snapshot.data![index].id!,
                                                    snapshot.data![index].createdAt!,
                                                    snapshot.data![index].time!,
                                                    snapshot.data![index].distance!,
                                                        (){
                                                      Utils.customPrint("call back for delete trip in list");
                                                      snapshot.data!.removeAt(index);
                                                      // Navigator.pop(context);

                                                    },widget.scaffoldKey!,
                                                    tripUploadedStatus
                                                );
                                              } else{
                                                // Future.delayed(Duration(microseconds: 500), (){
                                                //   showEndTripDialogBox(context);
                                                // });
                                              }
                                            },
                                            icon: Icons.delete,
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.transparent,
                                            label: "Delete",
                                          )
                                        ]), */
                                    child: widget.calledFrom == 'VesselSingleView'
                                      ? TripWidget(
                                        scaffoldKey: widget.scaffoldKey,
                                        tripList: snapshot.data![index],
                                        calledFrom: widget.calledFrom,
                                        onTripEnded: widget.onTripEnded,
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
                                          commonProvider.getTripsCount();
                                        },
                                        onTap: () async {

                                          commonProvider.updateStateOfOnTripEndClick(true);

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
                                                      commonProvider.updateStateOfOnTripEndClick(false);
                                                    }
                                                  });
                                                }, onCancelClick: (){
                                                  commonProvider.updateStateOfOnTripEndClick(false);
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
                                                  commonProvider.updateStateOfOnTripEndClick(false);
                                                  Navigator.of(context).pop();
                                                });
                                          }
                                        },
                                        onViewTripTap: ()async{
                                          var result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => TripRecordingScreen(
                                                  calledFrom: widget.calledFrom,
                                                  tripId: snapshot.data![index].id,
                                                  vesselName: snapshot.data![index].vesselName,
                                                  vesselId: snapshot.data![index].vesselId,
                                                  tripIsRunningOrNot: snapshot.data![index].tripStatus == 0)));

                                          if(result != null)
                                          {
                                            if(result)
                                            {
                                              if(widget.onTripEnded != null)
                                              {
                                                widget.onTripEnded!.call();
                                              }
                                              setState(() {

                                              });
                                            }
                                          }
                                        })
                                      : TripWidget(
                                        scaffoldKey: widget.scaffoldKey,
                                        tripList: snapshot.data![index],
                                        calledFrom: widget.calledFrom,
                                        onTripEnded: widget.onTripEnded,
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
                                          commonProvider.getTripsCount();
                                        },
                                        onTap: () async {

                                          commonProvider.updateStateOfOnTripEndClick(true);
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
                                                      commonProvider.updateStateOfOnTripEndClick(false);
                                                    }
                                                  });
                                                }, onCancelClick: (){
                                                  commonProvider.updateStateOfOnTripEndClick(false);
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
                                                  commonProvider.updateStateOfOnTripEndClick(false);
                                                  Navigator.of(context).pop();
                                                });
                                          }
                                        },
                                      onViewTripTap: ()async{
                                        var result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TripRecordingScreen(
                                                calledFrom: widget.calledFrom,
                                                tripId: snapshot.data![index].id,
                                                vesselName: snapshot.data![index].vesselName,
                                                vesselId: snapshot.data![index].vesselId,
                                                tripIsRunningOrNot: snapshot.data![index].tripStatus == 0)));

                                        if(result != null)
                                          {
                                            if(result)
                                              {
                                                if(widget.onTripEnded != null)
                                                  {
                                                    widget.onTripEnded!.call();
                                                  }
                                                setState(() {

                                                });
                                              }
                                          }
                                    }
                                    ),
                                  )
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
                              ),
                            ));
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
        ],
      ),
    );
  }

  /// To Check trip is Running or not
  Future<bool> tripIsRunningOrNot(Trip trip) async {
    bool result = await _databaseService.tripIsRunning();
if(mounted){

    setState(() {
      tripIsRunning = result;
      Utils.customPrint('Trip is Running $tripIsRunning');
      setState(() {
        trip.isEndTripClicked = false;
      });
    });
}
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
          if(mounted){
          setState(() {
            trip.tripStatus =
            1;
          });

          }

          await commonProvider
              .updateTripStatus(false);

          if (widget.onTripEnded != null) {
            widget.onTripEnded!.call();
          }

          await tripIsRunningOrNot(
              trip);
          commonProvider.updateStateOfOnTripEndClick(false);
        });
  }

}

