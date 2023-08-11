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
      child: Scaffold(
        backgroundColor: commonBackgroundColor,
        key: scaffoldKey,
        // appBar: AppBar(
        //   backgroundColor: commonBackgroundColor,
        //   elevation: 0,
        //   centerTitle: true,
        //   leading: InkWell(
        //     onTap: () {
        //       scaffoldKey.currentState!.openDrawer();
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.all(16),
        //       child: Image.asset(
        //         'assets/icons/menu.png',
        //       ),
        //     ),
        //   ),
        //   title: Container(
        //     width: MediaQuery.of(context).size.width / 2,
        //     // color: Colors.yellow,
        //     child: RichText(
        //       textAlign: TextAlign.center,
        //       text: TextSpan(
        //         children: [
        //           WidgetSpan(
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 children: [
        //                   Image.asset(
        //                     "assets/images/lognotitle.png",
        //                     height: 50,
        //                     width: 50,
        //                   ),
        //                   commonText(
        //                     context: context,
        //                     text: 'Trips',
        //                     fontWeight: FontWeight.w600,
        //                     textColor: Colors.black87,
        //                     textSize: displayWidth(context) * 0.045,
        //                   ),
        //                 ],
        //               )),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
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

            TripViewList(
              scaffoldKey: scaffoldKey,
              calledFrom: 'HomePage',
              isTripDeleted: ()async{

              },
              onTripEnded: (){
                commonProvider.getTripsByVesselId('');
              },
            ),
          ],
        ),
      ),
    );
  }
}
