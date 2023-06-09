import 'package:flutter/material.dart';
//import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class TripViewListing extends StatefulWidget {
  String? vesselId, calledFrom;
  VoidCallback? onTripEnded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  TripViewListing(
      {this.vesselId, this.calledFrom, this.onTripEnded, this.scaffoldKey});

  @override
  State<TripViewListing> createState() => _TripViewListingState();
}

class _TripViewListingState extends State<TripViewListing> {
  final DatabaseService _databaseService = DatabaseService();
  //FlutterBackgroundService service = FlutterBackgroundService();
  late CommonProvider commonProvider;

  bool tripIsRunning = false;

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

    commonProvider = context.read<CommonProvider>();
    commonProvider.getTripsByVesselId(widget.vesselId);
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return FutureBuilder<List<Trip>>(
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
                        "TRIP DETAILS 1 ${snapshot.data!.isEmpty}");
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return snapshot.data!.isNotEmpty
                              ? TripWidget(
                                  scaffoldKey: widget.scaffoldKey,
                                  tripList: snapshot.data![index],
                                  calledFrom: widget.calledFrom,
                                  onTripEnded: widget.onTripEnded,
                                  tripUploadedSuccessfully: () {
                                    if (mounted) {
                                      setState(() {
                                        commonProvider.getTripsByVesselId(
                                            widget.vesselId);
                                        future = _databaseService.trips();
                                        //snapshot.data![index].tripStatus = 1;
                                      });
                                    }
                                    commonProvider.getTripsCount();
                                  },
                                  onTap: () async {
                                    Utils().showEndTripDialog(context,
                                        () async {
                                      Navigator.of(context).pop();

                                      await commonProvider
                                          .updateTripStatus(true);

                                      setState(() {
                                        snapshot.data![index].isEndTripClicked =
                                            true;
                                      });

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

                                      EndTrip().endTrip(
                                          context: context,
                                          scaffoldKey: widget.scaffoldKey,
                                          duration: tripDuration,
                                          onEnded: () async {
                                            setState(() {
                                              //future = _databaseService.trips();
                                              snapshot.data![index].tripStatus =
                                                  1;
                                            });

                                            await commonProvider
                                                .updateTripStatus(false);

                                            if (widget.onTripEnded != null) {
                                              widget.onTripEnded!.call();
                                            }

                                            await tripIsRunningOrNot(
                                                snapshot.data![index]);
                                          });

                                      return;
                                    }, () {
                                      Navigator.of(context).pop();
                                    });
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
    );
  }

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
}
