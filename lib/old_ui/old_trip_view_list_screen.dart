
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/old_ui/old_trip_widget.dart';
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
import '../common_widgets/utils/constants.dart';

class OldTripViewListing extends StatefulWidget {
  String? vesselId, calledFrom;
  VoidCallback? onTripEnded;
  VoidCallback? isTripDeleted;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  OldTripViewListing(
      {this.vesselId, this.calledFrom, this.onTripEnded, this.scaffoldKey,this.isTripDeleted});

  @override
  State<OldTripViewListing> createState() => _OldTripViewListingState();
}

class _OldTripViewListingState extends State<OldTripViewListing> {
  final DatabaseService _databaseService = DatabaseService();
  late CommonProvider commonProvider;

  bool tripIsRunning = false,
      isDeleteTripBtnClicked = false,
      isDeletedSuccessfully = false,
      isTripUploaded = false;
    bool cancelVisible=true;

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
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8.0),
                            child: SlidableAutoCloseBehavior(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                primary: false,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final itemKey = ValueKey(index);
                                  return snapshot.data!.isNotEmpty
                                      ? Slidable(
                                    key: itemKey,
                                    endActionPane: snapshot.data![index].tripStatus == 0 ? null : ActionPane(
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
                                        ]),
                                    child: OldTripWidget(
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

  showDeleteTripDialogBox(BuildContext context,String tripId,String startDate, String totalTime, String distance,Function() onDeleteCallBack, GlobalKey<ScaffoldState> scaffoldKey,bool tripUploadStatus) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx,  stateSetter) {
                return Container(
                  height: displayHeight(ctx) * 0.45,
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

                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10),
                              child: Column(
                                children: [
                                  Center(
                                    child: commonText(
                                        context: context,
                                        text:
                                        'Do you want to delete the Trip? ',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.black,
                                        textSize: displayWidth(ctx) * 0.045,
                                        textAlign: TextAlign.center),
                                  ),
                                  SizedBox(
                                    height: displayHeight(ctx) * 0.005,
                                  ),
                                  commonText(
                                      context: context,
                                      text:
                                      deleteTripSubText,
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.grey,
                                      textSize: displayWidth(ctx) * 0.036,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 8.0,left: displayWidth(ctx) * 0.035,right: displayWidth(ctx) * 0.035
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  isBtnClick ? Center(
                                    child: Container(
                                      height: displayHeight(ctx) * 0.07,
                                      width: displayWidth(ctx) * 0.32,
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                  ) :  CommonButtons.getAcceptButton(
                                      'Confirm & Delete', context, deleteTripBtnColor,
                                          () async {
                                            internalStateSetter = stateSetter;
                                            bool internet =
                                            await Utils().check(scaffoldKey);
                                            stateSetter(() {
                                              isBtnClick = true;
                                                                                            cancelVisible=false;

                                            });
                                            if(internet){
                                              stateSetter(() {
                                              cancelVisible=false;

                                                isBtnClick = true;
                                              });
                                              Utils.customPrint("Ok button action : $isBtnClick");
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
                                            } else if(tripUploadStatus){
                                              stateSetter(() {
                                                isBtnClick = true;
                                              });
                                              DatabaseService().deleteTripFromDB(tripId).then((value)
                                              {
                                                deleteFilePath('${ourDirectory!.path}/${tripId}.zip');
                                                deleteFolder('${ourDirectory!.path}/${tripId}');
                                                commonProvider.getTripsCount();
                                                widget.isTripDeleted!.call();
                                                onDeleteCallBack.call();

                                                stateSetter(() {
                                                  isBtnClick = false;
                                                });
                                                Navigator.pop(dialogContext);
                                                Navigator.pop(dialogContext);
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
                                          if(!cancelVisible){
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
      if(value == null) {
        setState(() {
          isBtnClick = false;
        });
        // widget.isTripDeleted!.call();
        return;
      }
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

  bool deleteTripFunctionality(String tripId,VoidCallback onDeleteCallBack)
  {
    try{
      commonProvider.deleteTrip(context, commonProvider.loginModel!.token!, tripId,  widget.scaffoldKey!).then((value) {
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
                cancelVisible=true;
              });
            });
            onDeleteCallBack.call();
            setState(() {
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
}

