import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/widgets/common_text_search_field.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../provider/common_provider.dart';
import '../feedback_report.dart';
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
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Screenshot(
      controller: controller,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: displayWidth(context) * 0.03,right: displayWidth(context) * 0.03),
                child: SearchTextField(
                    'Search by vessel, trip id, date',
                    searchController,
                    searchFocusNode,
                    false,
                    false, (value) {
                  if (value.length > 3) {
                    // future = commonProvider.getSearchData(
                    //     value, context, scaffoldKey);
                  }
                }, (value) {
                  /*if (value.length > 3) {
                            future = commonProvider.getSearchData(
                                value, context, scaffoldKey);
                          }*/
                }, TextInputType.text,
                    textInputAction: TextInputAction.search,
                    enabled: true,
                    isForTwoDecimal: false),
              ),

              Expanded(
                child: TripViewList(
                  scaffoldKey: scaffoldKey,
                  calledFrom: 'HomePage',
                  isTripDeleted: ()async{

                  },
                  onTripEnded: (){
                    commonProvider.getTripsByVesselId('');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
