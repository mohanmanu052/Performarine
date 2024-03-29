import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_add_sensor_dialog.dart';
import 'package:performarine/common_widgets/widgets/dash_rect.dart';
import 'package:performarine/common_widgets/widgets/dash_rect_button.dart';
import 'package:performarine/common_widgets/widgets/dotted_line.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/lpr_view/lpr_trips_data.dart';
import 'package:screenshot/screenshot.dart';

class LPRViewScreen extends StatefulWidget {
  const LPRViewScreen({super.key});

  @override
  State<LPRViewScreen> createState() => _LPRViewScreenState();
}

class _LPRViewScreenState extends State<LPRViewScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final controller = ScreenshotController();

  bool isDownloadTripBtnClicked = true, isUpdateLPRTimeBtnClicked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: backgroundColor,
          title: commonText(
              context: context,
              text: 'LPR View',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.045,
              fontFamily: outfit),
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon:
                Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                children: [

                  SizedBox(height: displayHeight(context) * 0.03,),

                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: dropDownBackgroundColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      child: Row(
                        children: [
                          commonText(
                              context: context,
                              text: 'LPR Time',
                              fontWeight: FontWeight.w400,
                              textColor: Colors.black87,
                              textSize: displayWidth(context) * 0.04,
                              fontFamily: outfit),

                          Expanded(
                            child: Column(
                              children: [
                                commonText(
                                    context: context,
                                    text: '17:30:23',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black87,
                                    textSize: displayWidth(context) * 0.06,
                                    fontFamily: outfit),
                                commonText(
                                    context: context,
                                    text: 'UTC',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.035,
                                    fontFamily: outfit),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: dropDownBackgroundColor,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      child: Row(
                        children: [
                          commonText(
                              context: context,
                              text: 'Shaft RPM',
                              fontWeight: FontWeight.w400,
                              textColor: Colors.black87,
                              textSize: displayWidth(context) * 0.04,
                              fontFamily: outfit),

                          Expanded(
                            child: Column(
                              children: [
                                commonText(
                                    context: context,
                                    text: '320',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black87,
                                    textSize: displayWidth(context) * 0.06,
                                    fontFamily: outfit),
                                commonText(
                                    context: context,
                                    text: 'RPM',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.035,
                                    fontFamily: outfit),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    height: displayHeight(context) * 0.08,
                    width: displayWidth(context),
                    decoration: BoxDecoration(
                        color: dropDownBackgroundColor,
                        borderRadius: BorderRadius.circular(18)
                    ),
                    child: DashedRectButton(
                      color: blueColor,
                      strokeWidth: 1.5,
                      gap: 3.0,
                      onTap: (){
                        showDialog(
                            context: scaffoldKey.currentContext!,
                            builder: (BuildContext context) {
                              return CustomAddSensorDialog(
                                positiveBtnOnTap: () {
                                  Navigator.of(scaffoldKey.currentContext!).pop();
                                  //check(scaffoldKey);
                                },
                              );
                            });
                      },
                      title: '+',
                      textSize: displayWidth(context) * 0.07,
                      primaryTextColor: blueColor,
                    ),
                  ),


                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 17),
                width: displayWidth(context),
                alignment: Alignment.bottomCenter,
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonButtons.getActionButton(
                            title: 'Download Trip Data',
                            context: context,
                            fontSize: displayWidth(context) * 0.038,
                            textColor: isDownloadTripBtnClicked ? Colors.white : blueColor,
                            buttonPrimaryColor:isDownloadTripBtnClicked ? blueColor : dropDownBackgroundColor,
                            borderColor: isDownloadTripBtnClicked ? blueColor : dropDownBackgroundColor,
                            width: displayWidth(context) * 0.44,
                            onTap:  (){
                              setState(() {
                                isDownloadTripBtnClicked = true;
                                isUpdateLPRTimeBtnClicked = false;
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LPRTripsData()),
                              );
                            }),

                        CommonButtons.getActionButton(
                            title: 'Update LPR Time',
                            context: context,
                            fontSize: displayWidth(context) * 0.038,
                            textColor: isUpdateLPRTimeBtnClicked ? Colors.white : blueColor,
                            buttonPrimaryColor: isUpdateLPRTimeBtnClicked ? blueColor : dropDownBackgroundColor,
                            borderColor: isUpdateLPRTimeBtnClicked ? blueColor : dropDownBackgroundColor,
                            width: displayWidth(context) * 0.44,
                            onTap:  (){
                              setState(() {
                                isUpdateLPRTimeBtnClicked = true;
                                isDownloadTripBtnClicked = false;
                              });
                            }),
                      ],
                    ),

                    GestureDetector(
                        onTap: ()async{
                          final image = await controller.capture();

                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                            imagePath: image.toString(),
                            uIntList: image,)));
                        },
                        child: UserFeedback().getUserFeedback(context)
                    ),
                    SizedBox(height: 4,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
