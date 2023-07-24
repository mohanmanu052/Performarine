import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import 'dart:io';

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

  late Future<List<Trip>> future;
  late Future<List<Trip>> getTripsByIdFuture;
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
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return snapshot.data!.isNotEmpty
                                  ? Slidable(
                                    endActionPane: ActionPane(
                                        motion: ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                             onPressed: (BuildContext context)async{
                                             print("Trip id is: ${snapshot.data![index].id!}");
                                             if(snapshot.data![index].isSync != 0){
                                               showDeleteTripDialogBox(
                                                   context,
                                                   snapshot.data![index].id!,
                                                   snapshot.data![index].createdAt!,
                                                   snapshot.data![index].time!,
                                                   snapshot.data![index].distance!,
                                                   (){
                                                     Utils.customPrint("call back for delete trip in list");
                                                     snapshot.data!.removeAt(index);
                                                     //Navigator.pop(context);
                                                     // Navigator.pop(context);

                                                   },widget.scaffoldKey!
                                               );
                                             }
                                              },
                                            icon: Icons.delete,
                                            backgroundColor: Colors.red,
                                            label: "Delete",
                                          )
                                        ]),
                                    child: TripWidget(
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
                                    }),
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
                        );
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

  showDeleteTripDialogBox(BuildContext context,String tripId,String startDate, String totalTime, String distance,Function() onDeleteCallBack, GlobalKey<ScaffoldState> scaffoldKey) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, StateSetter stateSetter) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Stack(
                      children: [
                        Column(
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
                                  Center(
                                    child: commonText(
                                        context: context,
                                        text:
                                        'Do you want to delete the Trip? This action can"t be irreversible.',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.04,
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                left: displayHeight(context) * 0.06,
                                right: displayHeight(context) * 0.01,
                              ),
                              child: Row(
                                children: [
                                  commonText(
                                      context: context,
                                      text:
                                      'Start Date:   ',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),

                                  commonText(
                                      context: context,
                                      text:
                                      startDate,
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                left: displayHeight(context) * 0.06,
                                right: displayHeight(context) * 0.01,
                              ),
                              child: Row(
                                children: [
                                  commonText(
                                      context: context,
                                      text:
                                      'Total Time:   ',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),

                                  commonText(
                                      context: context,
                                      text:
                                      totalTime,
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                left: displayHeight(context) * 0.06,
                                right: displayHeight(context) * 0.01,
                              ),
                              child: Row(
                                children: [
                                  commonText(
                                      context: context,
                                      text:
                                      'Distance:   ',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),

                                  commonText(
                                      context: context,
                                      text:
                                      distance,
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.025,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CommonButtons.getAcceptButton(
                                      'Cancel',
                                      context,
                                      Colors.grey,
                                          (){
                                        Navigator.pop(dialogContext);
                                      },
                                      displayWidth(context) * 0.34,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey,
                                      displayHeight(context) * 0.015,
                                      Colors.transparent,
                                      '',
                                      fontWeight: FontWeight.w500),

                                 isBtnClick ? Center(
                                   child: CircularProgressIndicator(),
                                 ) :  Center(
                                   child: CommonButtons.getAcceptButton(
                                        'Delete Trip', context, buttonBGColor,
                                            () async {
                                              bool internet =
                                              await Utils().check(scaffoldKey);
                                              if(internet){
                                                  stateSetter(() {
                                                    isBtnClick = true;
                                                  });
                                                print("Ok button action : $isBtnClick");
                                                bool deletedtrip = false;
                                                deletedtrip =  await deleteTripFunctionality(
                                                    tripId,
                                                        (){
                                                      commonProvider.getTripsCount();
                                                      widget.isTripDeleted!.call();
                                                      onDeleteCallBack.call();
                                                      Navigator.pop(dialogContext);
                                                    }
                                                );
                                              } else{
                                                stateSetter(() {
                                                  isBtnClick = false;
                                                });
                                              }
                                        },
                                       displayWidth(context) * 0.34,
                                       displayHeight(context) * 0.05,
                                        primaryColor,
                                        Colors.white,
                                        displayHeight(context) * 0.018,
                                        buttonBGColor,
                                        '',
                                        fontWeight: FontWeight.w500),
                                 ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.005,
                            ),
                          ],
                        ),


                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,),
                            child: Center(
                              child: IconButton(
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
          );
        }).then((value) {

    });
  }

  //Delete trip dialog for user confirmation to delete trip
  showDeleteTripDialogConfirmation(BuildContext context,VoidCallback onLoading, Function() deleteTripBtnClick,
      Function() onCancelClick) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.24,
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
                          child: commonText(
                              context: context,
                              text: 'This action is irreversible. do you want to delete it?',
                              fontWeight: FontWeight.w600,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.042,
                              textAlign: TextAlign.center),
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
                                      'Cancel',
                                      context,
                                      Colors.transparent,
                                      (){
                                        Navigator.pop(dialogContext);
                                        onCancelClick.call();
                                      },
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey,
                                      displayHeight(context) * 0.015,
                                      Colors.transparent,
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
                                      'OK',
                                      context,
                                      buttonBGColor,
                                      (){
                                        Navigator.pop(dialogContext);
                                        deleteTripBtnClick.call();
                                      },
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.015,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
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

    print('***DIST: ${currentTrip.toJson()}');

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

  bool deleteTripFunctionality(String tripId,VoidCallback onDeleteCallBack)
  {
     commonProvider.deleteTrip(context, commonProvider.loginModel!.token!, tripId,  widget.scaffoldKey!).then((value) {
        if(value != null)
        {
          if(value.status!)
          {
            isDeletedSuccessfully = value.status!;
            DatabaseService().deleteTripFromDB(tripId).then((value)
            {
              setState(() {
                isDeleteTripBtnClicked = false;
              });
            });
            onDeleteCallBack.call();
            setState(() {
              isBtnClick = false;
              isDeleteTripBtnClicked = false;
            });
          }
        }
      });

    return isDeletedSuccessfully;
  /*  else
    {
      DatabaseService().deleteTripFromDB(tripId).then((value)
      {
        setState(() {
          isDeleteTripBtnClicked = false;
        });
      });
    } */
  }
}