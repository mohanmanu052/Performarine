import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/status_tag.dart';
import 'package:performarine/models/trip.dart';
import 'package:get/get.dart';
// import 'package:performarine/models/Trip.dart';

class TripBuilder extends StatelessWidget {
  const TripBuilder({
    Key? key,
    required this.future,
  }) : super(key: key);
  final Future<List<Trip>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:snapshot.data!.length,
            itemBuilder: (context, index) {
              final Trip = snapshot.data![index];
              return _buildTripCard(Trip, index, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildTripCard(Trip trip, int index, BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.id!,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(trip.currentLoad!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: CustomPaint(
            painter: StatusTag(color: Colors.blue),
            child: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: commonText(
                    context: context,
                    text: trip.isSync == 1 ? "Synced" : " Un Synced ",
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    textSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
              ),
            ),
          ),

          /*Container(
                  padding: const EdgeInsets.only(
                      right: 5, left: 20, top: 5, bottom: 5),
                  color:
                      statusColor ?? const Color.fromARGB(255, 19, 49, 73),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),*/
        )
      ],
    );
  }
}
