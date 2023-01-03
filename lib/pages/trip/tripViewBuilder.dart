import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/services/database_service.dart';

// class TripViewBuilder extends StatefulWidget {
//   const TripViewBuilder({Key? key}) : super(key: key);
//
//   @override
//   State<TripViewBuilder> createState() => _TripViewBuilderState();
// }
//
// class _TripViewBuilderState extends State<TripViewBuilder> {
//   final DatabaseService _databaseService = DatabaseService();
//
//   Future<List<Trip>> getTripListByVesselId(String id) async {
//     return await _databaseService.getAllTripsByVesselId(id);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Trip>>(
//       future: getTripListByVesselId(id),
//       builder: (context, snapshot) {
//         return snapshot.data != null
//             ? StatefulBuilder(
//             builder: (BuildContext context, StateSetter setter) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     return snapshot.data!.isNotEmpty
//                         ? TripWidget(
//                       tripList: snapshot.data![index],
//                     )
//                         : commonText(
//                         text: 'oops! No Trips are added yet',
//                         context: context,
//                         textSize: displayWidth(context) * 0.04,
//                         textColor: Theme.of(context).brightness ==
//                             Brightness.dark
//                             ? Colors.white
//                             : Colors.black,
//                         fontWeight: FontWeight.w500);
//                   },
//                 ),
//               );
//             })
//             : Container(
//           child: commonText(
//               text: 'oops! No Trips are added yet',
//               context: context,
//               textSize: displayWidth(context) * 0.04,
//               textColor:
//               Theme.of(context).brightness == Brightness.dark
//                   ? Colors.white
//                   : Colors.black,
//               fontWeight: FontWeight.w500),
//         );
//       },
//     );
//   }
// }
class TripViewListing extends StatefulWidget {
  String? vesselId;
  VoidCallback? onTripEnded;
  TripViewListing({this.vesselId, this.onTripEnded});

  @override
  State<TripViewListing> createState() => _TripViewListingState();
}

class _TripViewListingState extends State<TripViewListing> {
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();

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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: getTripsByVesselId(),
      builder: (context, snapshot) {
        return snapshot.data != null
            ? StatefulBuilder(
                builder: (BuildContext context, StateSetter setter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return snapshot.data!.isNotEmpty
                          ? TripWidget(
                              tripList: snapshot.data![index],
                              onTap: () async {
                                Utils().showEndTripDialog(context, () async {
                                  Navigator.of(context).pop();
                                  bool isServiceRunning =
                                      await service.isRunning();

                                  print(
                                      'IS SERVICE RUNNING: $isServiceRunning');

                                  try {
                                    service.invoke('stopService');

                                    // instan.stopSelf();
                                  } on Exception catch (e) {
                                    print('SERVICE STOP BG EXE: $e');
                                  }

                                  File? zipFile;
                                  if (timer != null) timer!.cancel();
                                  print(
                                      'TIMER STOPPED ${ourDirectory!.path}/${snapshot.data![index].id}');
                                  final dataDir = Directory(
                                      '${ourDirectory!.path}/${snapshot.data![index].id}');

                                  try {
                                    zipFile = File(
                                        '${ourDirectory!.path}/${snapshot.data![index].id}.zip');

                                    ZipFile.createFromDirectory(
                                        sourceDir: dataDir,
                                        zipFile: zipFile,
                                        recurseSubDirs: true);
                                    print('our path is $dataDir');
                                  } catch (e) {
                                    print(e);
                                  }

                                  File file = File(zipFile!.path);
                                  print('FINAL PATH: ${file.path}');

                                  await _databaseService.updateTripStatus(
                                      1,
                                      file.path,
                                      DateTime.now().toString(),
                                      snapshot.data![index].id!);

                                  sharedPreferences!.remove('trip_data');

                                  setState(() {
                                    future = _databaseService.trips();
                                  });

                                  if (widget.onTripEnded != null) {
                                    widget.onTripEnded!.call();
                                  }
                                }, () {
                                  Navigator.of(context).pop();
                                });
                              })
                          : commonText(
                              text: 'oops! No Trips are added yet',
                              context: context,
                              textSize: displayWidth(context) * 0.04,
                              textColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500);
                    },
                  ),
                );
              })
            : Container(
                child: commonText(
                    text: 'oops! No Trips are added yet',
                    context: context,
                    textSize: displayWidth(context) * 0.04,
                    textColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500),
              );
      },
    );
  }
}
