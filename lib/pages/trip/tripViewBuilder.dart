import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class TripViewListing extends StatefulWidget {
  String? vesselId;
  VoidCallback? onTripEnded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  TripViewListing({this.vesselId, this.onTripEnded, this.scaffoldKey});

  @override
  State<TripViewListing> createState() => _TripViewListingState();
}

class _TripViewListingState extends State<TripViewListing> {
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();
  late CommonProvider commonProvider;

  bool tripIsRunning = false;

  late Future<List<Trip>> future;
  List<Trip> getTripsByIdFuture = [];
  Future<List<Trip>> getTripsByVesselId() async {
    if (widget.vesselId == null || widget.vesselId == "") {
      getTripsByIdFuture = await _databaseService.trips();
    } else {
      getTripsByIdFuture = await _databaseService
          .getAllTripsByVesselId(widget.vesselId.toString());
    }
    return getTripsByIdFuture;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return FutureBuilder<List<Trip>>(
      future: getTripsByVesselId(),
      builder: (context, snapshot) {
        return snapshot.data != null
            ? StatefulBuilder(
                builder: (BuildContext context, StateSetter setter) {
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return snapshot.data!.isNotEmpty
                          ? TripWidget(
                              scaffoldKey: widget.scaffoldKey,
                              tripList: snapshot.data![index],
                              tripUploadedSuccessfully: () {
                                setState(() {
                                  future = _databaseService.trips();
                                  //snapshot.data![index].tripStatus = 1;
                                });
                                commonProvider.getTripsCount();
                              },
                              onTap: () async {
                                Utils().showEndTripDialog(context, () async {
                                  Navigator.of(context).pop();

                                  await commonProvider.updateTripStatus(true);

                                  setState(() {
                                    snapshot.data![index].isEndTripClicked =
                                        true;
                                  });

                                  CreateTrip().endTrip(
                                      context: context,
                                      scaffoldKey: widget.scaffoldKey,
                                      onEnded: () async {
                                        setState(() {
                                          //future = _databaseService.trips();
                                          snapshot.data![index].tripStatus = 1;
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
                                    textColor: Theme.of(context).brightness ==
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
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              );
      },
    );
  }

  Future<bool> tripIsRunningOrNot(Trip trip) async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      print('Trip is Running $tripIsRunning');
      setState(() {
        trip.isEndTripClicked = false;
      });
    });

    /*setState(() {
      isEndTripButton = tripIsRunning;
      isStartButton = !tripIsRunning;
    });*/
    return result;
  }
}
