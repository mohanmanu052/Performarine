import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class MyDelegateInvitesScreen extends StatefulWidget {
  const MyDelegateInvitesScreen({super.key});

  @override
  State<MyDelegateInvitesScreen> createState() => _MyDelegateInvitesScreenState();
}

class _MyDelegateInvitesScreenState extends State<MyDelegateInvitesScreen> {

  final controller = ScreenshotController();

  List<InvitesModel> inviteList =  [
    InvitesModel(fleetName: 'Name of the Vessel', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the Vessel', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the Vessel', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the Vessel', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Expired'),
  ];

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: commonText(
              context: context,
              text: 'My Delegate Invites',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
            actions: [
      
              InkWell(
                onTap: ()async{
                },
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid ? displayWidth(context) * 0.065 : displayWidth(context) * 0.05,
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async{
                   await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavigation()),
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
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 4),
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
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          child:   Column(
            children: [
              SizedBox(height: displayHeight(context) * 0.01,),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: inviteList.length,
                  itemBuilder: (context, index)
                  {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: [
                          Container(
                            color: inviteList[index].status == 'Expired'
                                ? Colors.grey.shade50
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                        context: context,
                                        text: inviteList[index].fleetName,
                                        fontWeight: FontWeight.w500,
                                        textColor: inviteList[index].status == 'Expired'
                                            ? Colors.grey
                                            : Colors.black,
                                        textSize: displayWidth(context) * 0.042,
                                        textAlign: TextAlign.start,),

                                      commonText(
                                          context: context,
                                          text: inviteList[index].sendBy,
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                          textSize: displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start),


                                      commonText(
                                          context: context,
                                          text: 'Permissions: ',
                                          fontWeight: FontWeight.w400,
                                          textColor: inviteList[index].status == 'Expired'
                                              ? Colors.grey
                                              : Colors.black87,
                                          textSize: displayWidth(context) * 0.03,
                                          textAlign: TextAlign.start),

                                      commonText(
                                          context: context,
                                          text: 'Reports | Manage Trips | Edit ',
                                          fontWeight: FontWeight.w400,
                                          textColor: inviteList[index].status == 'Expired'
                                              ? Colors.grey
                                              : Colors.black87,
                                          textSize: displayWidth(context) * 0.026,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4,),
                                inviteList[index].status == 'Expired'
                                    ?  commonText(
                                    context: context,
                                    text: 'Expired',
                                    fontWeight: FontWeight.w300,
                                    textColor: Colors.red.shade200,
                                    textSize: displayWidth(context) * 0.032,
                                    textAlign: TextAlign.start,
                                    fontFamily: poppins)
                                    : Row(
                                  children: [
                                    commonText(
                                        context: context,
                                        text: 'Reject',
                                        fontWeight: FontWeight.w300,
                                        textColor: blueColor,
                                        textSize: displayWidth(context) * 0.032,
                                        textAlign: TextAlign.start,
                                        fontFamily: poppins),
                                    SizedBox(width: displayWidth(context) * 0.04,),
                                    Container(
                                      width: displayWidth(context) * 0.18,
                                      decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                                          child: commonText(
                                              context: context,
                                              text: 'Accept',
                                              fontWeight: FontWeight.w300,
                                              textColor: Colors.white,
                                              textSize: displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start,
                                              fontFamily: poppins),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                          )
                        ],
                      ),
                    );
                  }
              ),
            ],
          )
        ),
      ),
    );
  }
}

class InvitesModel
{
  String? fleetName, sendBy, status;

  InvitesModel({this.fleetName, this.sendBy, this.status});
}
