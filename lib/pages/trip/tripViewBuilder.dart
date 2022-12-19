import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
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
class TripViewListing extends StatelessWidget {
  TripViewListing({Key? key,required this.future,}) : super(key: key);
  final Future<List<Trip>> future;
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: future,
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
                    )
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
              textColor:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w500),
        );
      },
    );
  }
}
