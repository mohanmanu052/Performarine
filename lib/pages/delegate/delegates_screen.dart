import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/common_widgets/widgets/vessel_info_card.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/delegate/invite_delegate.dart';
import 'package:performarine/services/database_service.dart';
import 'package:screenshot/screenshot.dart';

class DelegatesScreen extends StatefulWidget {
  const DelegatesScreen({super.key});

  @override
  State<DelegatesScreen> createState() => _DelegatesScreenState();
}

class _DelegatesScreenState extends State<DelegatesScreen> {
  final controller = ScreenshotController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late Future<List<CreateVessel>> getVesselFuture;
  CreateVessel? vesselData;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    getVesselFuture = _databaseService.vessels();
    getVesselFuture.then((value) {
      vesselData = value[0];
      setState(() {});
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: backgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
              context: context,
              text: 'Delegate’s',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.042,
              fontFamily: outfit),
          actions: [
            InkWell(
              onTap: () async {},
              child: Image.asset(
                'assets/images/Trash.png',
                width: Platform.isAndroid
                    ? displayWidth(context) * 0.065
                    : displayWidth(context) * 0.05,
              ),
            ),
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
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Container(
          child: Stack(
            children: [
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: displayHeight(context) / 8.5,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        CommonButtons.getActionButton(
                            title: 'Invite Delegate',
                            context: context,
                            fontSize: displayWidth(context) * 0.044,
                            textColor: Colors.white,
                            buttonPrimaryColor: blueColor,
                            borderColor: blueColor,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          InviteDelegate())));
                            },
                            width: displayWidth(context) / 1.3,
                            height: displayHeight(context) * 0.053),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                            onTap: (() async {
                              final image = await controller.capture();
                              await SystemChrome.setPreferredOrientations(
                                  [DeviceOrientation.portraitUp]);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FeedbackReport(
                                            imagePath: image.toString(),
                                            uIntList: image,
                                          )));
                            }),
                            child: UserFeedback().getUserFeedback(
                              context,
                            )),
                      ],
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(bottom: displayHeight(context) / 7.1),
                height: displayHeight(context) / 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      if (vesselData != null)
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            width: displayWidth(context),
                            //height: displayHeight(context)*0.2,

                            child: VesselinfoCard(
                              vesselData: vesselData,
                            )),

                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      Flexible(
                                          flex: 4,
                                          fit: FlexFit.tight,
                                          child: Row(
                                            children: [
                                              commonText(
                                                  text: 'Delegate Name',
                                                  context: context,
                                                  textSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: outfit),
                                              tag(colorgreenLight,
                                                  '24 Hr Access')
                                            ],
                                          )),
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: Row(
                                            children: [
                                              Visibility(
                                                  child: commonText(
                                                      text: 'Active',
                                                      textColor: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textSize: 11)),
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  child: Icon(
                                                    Icons.more_horiz,
                                                    size: 12,
                                                  ))
                                            ],
                                          ))
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          Flexible(
                                              fit: FlexFit.tight,
                                              flex: 10,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: commonText(
                                                    text:
                                                        'Janeiskij02@knds.com',
                                                    fontWeight: FontWeight.w400,
                                                    textSize: 11,
                                                    textColor: Colors.grey),
                                              )),
                                          Flexible(
                                              fit: FlexFit.tight,
                                              flex: 3,
                                              child: Visibility(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: colorLightRed,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20)),
                                                  ),
                                                  child: commonText(
                                                      text: 'Remove Access',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      textSize: 10,
                                                      textColor:
                                                          floatingBtnColor),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.tight,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: commonText(
                                                    text:
                                                        'Manage Share Settings',
                                                    fontWeight: FontWeight.w300,
                                                    textSize: 10,
                                                    textColor: blueColor),
                                              )),
                                          Flexible(
                                              flex: 2,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(children: [
                                                  commonText(
                                                      text: 'Permissions:',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      textSize: 10),
                                                  //                                                 commonText(text: 'Reports | Manage Trips | Edit',
                                                  // fontWeight: FontWeight.w400,
                                                  // textSize: 7
                                                  // ),
                                                ]),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ));
                          })

                      //vesselSingleViewCard(context, vesselData!, (p0) => null, scaffoldKey)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget tag(Color tagColor, String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: commonText(
          text: text,
          fontWeight: FontWeight.w300,
          textSize: 8,
          textColor: blutoothDialogTitleColor),
    );
  }
}
