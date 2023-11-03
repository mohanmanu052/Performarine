import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../provider/common_provider.dart';
import '../trip/tripViewBuilder.dart';

class Trips extends StatefulWidget {
  const Trips({Key? key}) : super(key: key);

  @override
  State<Trips> createState() => _TripsState();
}

class _TripsState extends State<Trips> {

  final controller = ScreenshotController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  late CommonProvider commonProvider;

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Screenshot(
      controller: controller,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          body: SingleChildScrollView(
            child: Column(
              children: [

                TripViewListing(
                  scaffoldKey: scaffoldKey,
                  calledFrom: 'tripList',
                  isTripDeleted: ()async{
                  },
                  onTripEnded: (){
                    commonProvider.getTripsByVesselId('');
                  },
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}
