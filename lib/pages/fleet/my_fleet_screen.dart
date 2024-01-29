import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/fleet/send_invite_screen.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../feedback_report.dart';
import 'create_new_fleet_screen.dart';
import 'manage_permissions_screen.dart';


class MyFleetScreen extends StatefulWidget {
  int?bottomNavIndex;
  bool? data = false;
  MyFleetScreen({super.key, this.bottomNavIndex, this.data});

  @override
  State<MyFleetScreen> createState() => _MyFleetScreenState();
}

class _MyFleetScreenState extends State<MyFleetScreen> {

  final controller = ScreenshotController();

  List<MyFleetModel> myFleetList =  [
    MyFleetModel(fleetName: 'Fleet 011512', noOfVessel: '02', accepted: '02', pending: '02'),
    MyFleetModel(fleetName: 'Fleet 011513', noOfVessel: '02', accepted: '02', pending: '02'),
    MyFleetModel(fleetName: 'Fleet 011514', noOfVessel: '02', accepted: '02', pending: '02'),
  ];

  List<FleetModel> fleetList =  [
    FleetModel(fleetName: 'Fleet 011518', dateOfJoin: '03-26-2024', noOfVessels: '02', createdBy: 'Abhiram'),
    FleetModel(fleetName: 'Fleet 011519', dateOfJoin: '03-26-2024', noOfVessels: '02', createdBy: 'Abhiram'),
    FleetModel(fleetName: 'Fleet 011520', dateOfJoin: '03-26-2024', noOfVessels: '02', createdBy: 'Abhiram'),
  ];

  List<InvitesModel> inviteList =  [
    InvitesModel(fleetName: 'Fleet 011521', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Fleet 011522', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
    InvitesModel(fleetName: 'Fleet 011523', sendBy: 'Send By cjhdsn@jkvn.com', status: 'Pending'),
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
                width: displayWidth(context),
                height: widget.data! ? null :displayHeight(context),
                margin: EdgeInsets.only(left: 17, right: 17, top: 17, bottom: displayHeight(context) * 0.14),
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
                            text: 'My Fleets',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.048,
                            textAlign: TextAlign.start),
                        children: <Widget>[
                          widget.data!
                          ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: myFleetList.length,
                              itemBuilder: (context, index)
                              {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    children: [

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  commonText(
                                                    context: context,
                                                    text: myFleetList[index].fleetName,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.black,
                                                    textSize: displayWidth(context) * 0.04,
                                                    textAlign: TextAlign.start,),
                                                  SizedBox(width: displayWidth(context) * 0.01,),
                                                  Image.asset('assets/icons/Edit.png', height: displayHeight(context) * 0.018, color: blueColor,),
                                                ],
                                              ),
                                              SizedBox(height: displayHeight(context) * 0.005,),
                                              Row(
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
                                              ),

                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: commonText(
                                                  context: context,
                                                  text: 'Member Details',
                                                  fontWeight: FontWeight.w300,
                                                  textColor: Colors.black,
                                                  textSize: displayWidth(context) * 0.03,
                                                  textAlign: TextAlign.start,),
                                              ),

                                              Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      commonText(
                                                        context: context,
                                                        text: 'Accepted',
                                                        fontWeight: FontWeight.w300,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(context) * 0.03,
                                                        textAlign: TextAlign.start,),

                                                      commonText(
                                                        context: context,
                                                        text: myFleetList[index].accepted,
                                                        fontWeight: FontWeight.w300,
                                                        textColor: Colors.black,
                                                        textSize: displayWidth(context) * 0.03,
                                                        textAlign: TextAlign.start,),
                                                    ],
                                                  ),
                                                  SizedBox(width: displayWidth(context) * 0.01,),

                                                  Column(
                                                    children: [
                                                      commonText(
                                                        context: context,
                                                        text: 'Pending',
                                                        fontWeight: FontWeight.w300,
                                                        textColor: Colors.grey,
                                                        textSize: displayWidth(context) * 0.03,
                                                        textAlign: TextAlign.start,),

                                                      commonText(
                                                        context: context,
                                                        text: myFleetList[index].pending,
                                                        fontWeight: FontWeight.w300,
                                                        textColor: Colors.black,
                                                        textSize: displayWidth(context) * 0.03,
                                                        textAlign: TextAlign.start,),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: displayWidth(context) * 0.22,
                                                decoration: BoxDecoration(
                                                    color: blueColor,
                                                    borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                    child: commonText(
                                                        context: context,
                                                        text: 'Fleet Details',
                                                        fontWeight: FontWeight.w300,
                                                        textColor: Colors.white,
                                                        textSize: displayWidth(context) * 0.03,
                                                        textAlign: TextAlign.start,  fontFamily: poppins),
                                                  ),
                                                ),
                                              ),
                                             SizedBox(width: displayWidth(context) * 0.02,),
                                             Image.asset('assets/images/Trash.png', height: displayHeight(context) * 0.02, color: Colors.red,),
                                            ],
                                          )
                                        ],
                                      ),

                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 2,
                                      )
                                    ],
                                  ),
                                );
                              }
                          )
                              : Container(
                                alignment: Alignment.centerLeft,
                                height: displayHeight(context) * 0.08,
                                child: commonText(
                                context: context,
                                text: 'No fleets Created',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
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
                            text: 'Fleet I am In',
                            fontWeight: FontWeight.w500,
                            textColor: blueColor,
                            textSize: displayWidth(context) * 0.048,
                            textAlign: TextAlign.start),
                        children: <Widget>[

                          widget.data!
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: fleetList.length,
                              itemBuilder: (context, index)
                              {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                            context: context,
                                            text: fleetList[index].fleetName,
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize: displayWidth(context) * 0.04,
                                            textAlign: TextAlign.start,),
                                          SizedBox(height: 4,),
                                          Row(
                                            children: [
                                              commonText(
                                                  context: context,
                                                  text: 'Created By: ',
                                                  fontWeight: FontWeight.w400,
                                                  textColor: Colors.grey,
                                                  textSize: displayWidth(context) * 0.028,
                                                  textAlign: TextAlign.start),
                                              commonText(
                                                  context: context,
                                                  text: fleetList[index].createdBy,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black,
                                                  textSize: displayWidth(context) * 0.028,
                                                  textAlign: TextAlign.start),
                                              SizedBox(width: displayWidth(context) * 0.03,),
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          Row(
                                            children: [
                                              commonText(
                                                  context: context,
                                                  text: 'DOJ: ',
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
                                              SizedBox(width: displayWidth(context) * 0.02,),
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


                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 2,
                                          )
                                        ],
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Leave',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.red,
                                              textSize: displayWidth(context) * 0.03,
                                              textAlign: TextAlign.start,
                                              fontFamily: poppins),
                                          SizedBox(width: displayWidth(context) * 0.04,),
                                          Container(
                                            width: displayWidth(context) * 0.25,
                                            decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Center(
                                              child: InkWell(
                                                onTap: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ManagePermissionsScreen()));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                  child: commonText(
                                                      context: context,
                                                      text: 'Assign Vessel',
                                                      fontWeight: FontWeight.w300,
                                                      textColor: Colors.white,
                                                      textSize: displayWidth(context) * 0.03,
                                                      textAlign: TextAlign.start,
                                                      fontFamily: poppins),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }
                          )
                              : Container(
                            alignment: Alignment.centerLeft,
                            height: displayHeight(context) * 0.08,
                            child: commonText(
                                context: context,
                                text: 'You haven’t joined any fleet',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
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
                          widget.data!
                          ? ListView.builder(
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
                                                    textColor: Colors.red,
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
                              : Container(
                            alignment: Alignment.centerLeft,
                            height: displayHeight(context) * 0.08,
                            child: commonText(
                                context: context,
                                text: 'No Fleet Invites',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              )

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
                          title: widget.data! ? 'Invite to Fleet':'Create New Fleet',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () {
                            widget.data!
                            ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SendInviteScreen()),
                            )
                            : Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => CreateNewFleetScreen()),
                            );
                          }),
                    ),
                    widget.data!
                        ? Column(
                          children: [
                            SizedBox(height: displayHeight(context) * 0.01,),
                            InkWell(
                              onTap: (){},
                              child: commonText(
                              context: context,
                              text: '+ Create Another Fleet',
                              fontWeight: FontWeight.w500,
                              textColor: blueColor,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.start),
                                                ),
                            SizedBox(height: displayHeight(context) * 0.01,),
                          ],
                        ) : SizedBox(),

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
  String? fleetName, noOfVessel, accepted, pending;

  MyFleetModel({this.fleetName, this.noOfVessel, this.accepted, this.pending});
}

class FleetModel
{
  String? fleetName, dateOfJoin, noOfVessels, createdBy;

  FleetModel({this.fleetName, this.dateOfJoin, this.noOfVessels, this.createdBy});
}

class InvitesModel
{
  String? fleetName, sendBy, status;

  InvitesModel({this.fleetName, this.sendBy, this.status});
}