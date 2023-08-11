import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/single_vessel_card.dart';
import 'package:screenshot/screenshot.dart';

import '../pages/add_vessel_new/add_new_vessel_screen.dart';

//To show all vessels in home page
class VesselBuilder extends StatefulWidget {
  const VesselBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
    required this.scaffoldKey,
  }) : super(key: key);
  final Future<List<CreateVessel>> future;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<VesselBuilder> createState() => _VesselBuilderState();
}

class _VesselBuilderState extends State<VesselBuilder> {
  String page = "vessel_builder";
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Stack(
        children: [
          FutureBuilder<List<CreateVessel>>(
            future: widget.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(circularProgressColor),
                  ),
                );
              }
              Utils.customPrint('HAS DATA: ${snapshot.hasData}');
              Utils.customPrint('HAS DATA: ${snapshot.error}');
              Utils.customPrint('HAS DATA: ${snapshot.hasError}');
              CustomLogger().logWithFile(Level.info, "HAS DATA: ${snapshot.hasData} -> $page");
              CustomLogger().logWithFile(Level.error, "HAS DATA: ${snapshot.error} -> $page");
              CustomLogger().logWithFile(Level.error, "HAS DATA: ${snapshot.hasError} -> $page");
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/vessel_default_img.png',
                          height: displayHeight(context) * 0.28,
                        ),
                        commonText(
                            context: context,
                            text: 'No vessels available'.toString(),
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.04,
                            textAlign: TextAlign.start),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    color:backgroundColor,
                    padding: EdgeInsets.only(
                        left: displayWidth(context) * 0.04, right: displayWidth(context) * 0.04, top: 8, bottom: 0),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final vessel = snapshot.data![index];
                        return vessel.vesselStatus == 1
                            ? SingleVesselCard(vessel, (CreateVessel value) {
                                widget.onTap(value);
                              }, widget.scaffoldKey!)
                            : SizedBox();
                      },
                    ),
                  );
                }
              }
              return Container();
            },
          ),
       /*   Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  // color: Colors.transparent,
                  margin: EdgeInsets.only(left: 17, right: 17, top: 8),
                  child: CommonButtons.getActionButton(
                      title: 'Add Vessel',
                      context: context,
                      fontSize: displayWidth(context) * 0.042,
                      textColor: Colors.white,
                      buttonPrimaryColor: buttonBGColor,
                      borderColor: buttonBGColor,
                      width: displayWidth(context),
                      onTap: () async {
                        CustomLogger().logWithFile(Level.info, "User navigating to AddNewVesselScreen-> $page");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  AddNewVesselPage()),
                        );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom : displayWidth(context) * 0.03,
                  ),
                  child: GestureDetector(
                      onTap: ()async{
                        final image = await controller.capture();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                          imagePath: image.toString(),
                          uIntList: image,)));
                      },
                      child: UserFeedback().getUserFeedback(context)
                  ),
                ),
              ],
            ),
          ) */
        ],
      ),
    );
  }
}
