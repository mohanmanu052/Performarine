import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/fleet/send_invite_screen.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../feedback_report.dart';
import 'manage_permissions_screen.dart';
import 'my_delegate_invites_screen.dart';


class MyFleetScreen extends StatefulWidget {
  int?bottomNavIndex;

  MyFleetScreen({super.key, this.bottomNavIndex});

  @override
  State<MyFleetScreen> createState() => _MyFleetScreenState();
}

class _MyFleetScreenState extends State<MyFleetScreen> {

  final controller = ScreenshotController();

  List<MyFleetModel> myFleetList =  [
    MyFleetModel(emailId: 'abhiram90@paccor.com', dateOfJoin: '03-26-2024', noOfVessel: '02', status: 'Accepted'),
    MyFleetModel(emailId: 'Rupali02@knds.com', dateOfJoin: '03-26-2024', noOfVessel: '02', status: 'Accepted'),
    MyFleetModel(emailId: 'Mohan80@paccor.com', dateOfJoin: '03-26-2024', noOfVessel: '00', status: 'Rejected'),
    MyFleetModel(emailId: 'Rupali80@paccor.com', dateOfJoin: '03-26-2024', noOfVessel: '00', status: 'Left'),
    MyFleetModel(emailId: 'bvudsam80@paccor.com', dateOfJoin: '03-26-2024', noOfVessel: '03', status: 'Pending'),
  ];

  List<FleetModel> fleetList =  [
    FleetModel(fleetName: 'Name of the fleet', dateOfJoin: '03-26-2024'),
    FleetModel(fleetName: 'Name of the fleet', dateOfJoin: '03-26-2024'),
    FleetModel(fleetName: 'Name of the fleet', dateOfJoin: '03-26-2024'),
  ];

  List<InvitesModel> inviteList =  [
    InvitesModel(fleetName: 'Name of the fleet', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the fleet', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the fleet', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Name of the fleet', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Expired'),
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
          title: commonText(
              context: context,
              text: 'My Fleet',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
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
            )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                //height: displayHeight(context),
                margin: EdgeInsets.only(left: 17, right: 17, top: 17, bottom: displayHeight(context) * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: commonText(
                            context: context,
                            text: 'My Fleet',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.048,
                            textAlign: TextAlign.start),
                        children: <Widget>[
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: myFleetList.length,
                              itemBuilder: (context, index)
                              {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: commonText(
                                              context: context,
                                              text: myFleetList[index].emailId,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start,),
                                          ),
                                          Container(
                                            width: displayWidth(context) * 0.22,
                                            decoration: BoxDecoration(
                                                color: myFleetList[index].status == 'Accepted'
                                                    ? Colors.green.shade50
                                                    : myFleetList[index].status == 'Pending'
                                                    ? Colors.yellow.shade100
                                                    : myFleetList[index].status == 'Left'
                                                ? Colors.grey.shade100
                                                : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(20)
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                child: commonText(
                                                    context: context,
                                                    text: myFleetList[index].status,
                                                    fontWeight: FontWeight.w300,
                                                    textColor: myFleetList[index].status == 'Accepted'
                                                        ? Colors.green
                                                        : myFleetList[index].status == 'Pending'
                                                        ? Colors.yellow.shade700
                                                        :  myFleetList[index].status == 'Left'
                                                        ? Colors.grey
                                                    : Colors.red,
                                                    textSize: displayWidth(context) * 0.03,
                                                    textAlign: TextAlign.start,  fontFamily: poppins),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Date of join: ',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.grey,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: myFleetList[index].dateOfJoin,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          SizedBox(width: displayWidth(context) * 0.03,),

                                          myFleetList[index].status == 'Pending' || myFleetList[index].status == 'Rejected'
                                              ? SizedBox()
                                              : Row(
                                            children: [
                                              commonText(
                                                  context: context,
                                                  text: 'No of Vessels: ',
                                                  fontWeight: FontWeight.w400,
                                                  textColor: Colors.grey,
                                                  textSize: displayWidth(context) * 0.028,
                                                  textAlign: TextAlign.start),
                                              commonText(
                                                  context: context,
                                                  text: myFleetList[index].noOfVessel,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black,
                                                  textSize: displayWidth(context) * 0.028,
                                                  textAlign: TextAlign.start),
                                            ],
                                          )


                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                          )

                        ],
                      ),
                    ),
                    SizedBox(height: Platform.isAndroid ? displayHeight(context) * 0.01 : 0),
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: commonText(
                            context: context,
                            text: 'Fleet I am in',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.048,
                            textAlign: TextAlign.start),
                        children: <Widget>[
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: fleetList.length,
                              itemBuilder: (context, index)
                              {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: commonText(
                                              context: context,
                                              text: fleetList[index].fleetName,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start,),
                                          ),

                                          Container(
                                            width: displayWidth(context) * 0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(20)
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                child: commonText(
                                                    context: context,
                                                    text: 'Leave',
                                                    fontWeight: FontWeight.w300,
                                                    textColor: Colors.blue,
                                                    textSize: displayWidth(context) * 0.03,
                                                    textAlign: TextAlign.start,
                                                    fontFamily: poppins),
                                              ),
                                            ),
                                          )

                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Date of join: ',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.grey,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: fleetList[index].dateOfJoin,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          SizedBox(width: displayWidth(context) * 0.03,),
                                          commonText(
                                              context: context,
                                              text: 'No of Vessels: ',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.grey,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: myFleetList[index].noOfVessel,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize: displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                          SizedBox(width: displayWidth(context) * 0.015,),
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ManagePermissionsScreen()),
                                              );
                                            },
                                            child: commonText(
                                                context: context,
                                                text: 'Manage Vessels',
                                                fontWeight: FontWeight.w400,
                                                textColor: blueColor,
                                                textSize: displayWidth(context) * 0.028,
                                                textAlign: TextAlign.start),
                                          )
                                          /*TextButton(
                                            child: commonText(
                                                context: context,
                                                text: 'Manage Vessels',
                                                fontWeight: FontWeight.w400,
                                                textColor: blueColor,
                                                textSize: displayWidth(context) * 0.028,
                                                textAlign: TextAlign.start),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ManagePermissionsScreen()),
                                              );
                                            },
                                          )*/


                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 2,
                                      )
                                    ],
                                  ),
                                );
                              }
                          )

                        ],
                      ),
                    ),
                    SizedBox(height: Platform.isAndroid ? displayHeight(context) * 0.01 : 0,),
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: commonText(
                            context: context,
                            text: 'Fleet Invites',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.048,
                            textAlign: TextAlign.start),
                        children: <Widget>[
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
                                                    textSize: displayWidth(context) * 0.04,
                                                    textAlign: TextAlign.start,),

                                                  commonText(
                                                      context: context,
                                                      text: inviteList[index].sendBy,
                                                      fontWeight: FontWeight.w400,
                                                      textColor: Colors.grey,
                                                      textSize: displayWidth(context) * 0.028,
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
                                                textSize: displayWidth(context) * 0.03,
                                                textAlign: TextAlign.start,
                                                fontFamily: poppins)
                                            : Row(
                                              children: [
                                                commonText(
                                                    context: context,
                                                    text: 'Reject',
                                                    fontWeight: FontWeight.w300,
                                                    textColor: blueColor,
                                                    textSize: displayWidth(context) * 0.03,
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
                                                          textSize: displayWidth(context) * 0.03,
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
                          )

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 17, right: 17, top: 8),
                      child: CommonButtons.getActionButton(
                          title: 'Invite Fleet',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SendInviteScreen()),
                            );
                          }),
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
class MyFleetModel
{
  String? emailId, dateOfJoin, noOfVessel, status;

  MyFleetModel({this.emailId, this.dateOfJoin, this.noOfVessel, this.status});
}

class FleetModel
{
  String? fleetName, dateOfJoin;

  FleetModel({this.fleetName, this.dateOfJoin});
}

class InvitesModel
{
  String? fleetName, sendBy, status;

  InvitesModel({this.fleetName, this.sendBy, this.status});
}