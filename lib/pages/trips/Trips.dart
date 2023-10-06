import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/widgets/common_text_search_field.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../old_ui/old_trip_view_list_screen.dart';
import '../../provider/common_provider.dart';
import '../feedback_report.dart';
import '../trip/tripViewBuilder.dart';
import 'TripViewList.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.portraitUp
    // ]);
  }

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
