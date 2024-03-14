import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/fleet/send_invite_screen.dart';
import 'package:screenshot/screenshot.dart';

class MemberDetailsWidget extends StatefulWidget {
  List<Members>? memberList;
  MemberDetailsWidget({super.key, this.memberList});

  @override
  State<MemberDetailsWidget> createState() => _MemberDetailsWidgetState();
}

class _MemberDetailsWidgetState extends State<MemberDetailsWidget> {
  ScreenshotController controller = ScreenshotController();

  List<FleetDetailsInviteModel> fleetInviteData = [
    FleetDetailsInviteModel(
        email: 'abc70@gmail.com',
        dateOfJoin: '03-05-2023',
        numberofVessels: 3,
        status: 'Accepted'),
    FleetDetailsInviteModel(
        email: 'xyz80@gmail.com',
        dateOfJoin: '03-06-2023',
        numberofVessels: 5,
        status: 'Accepted'),
    FleetDetailsInviteModel(
        email: 'abkjjkjk@gmail.com',
        dateOfJoin: '08-11-2023',
        numberofVessels: 3,
        status: 'Accepted'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending'),
    FleetDetailsInviteModel(
        email: 'abc7poppsopo@gmail.com',
        dateOfJoin: '29-08-2023',
        status: 'Pending')
  ];

  @override
  Widget build(BuildContext context) {

    debugPrint("MEMBER DETAILS ${widget.memberList!.isEmpty}");

    return Screenshot(
      controller: controller,
      child: widget.memberList == null || widget.memberList!.isEmpty
        ? Center(
          child: commonText(
            context: context,
            text: 'No data found',
            fontWeight: FontWeight.w500,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.045,
            textAlign: TextAlign.start),
        )
      : Container(
        margin: EdgeInsets.only(top: 20),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: displayHeight(context) / 9),
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.memberList!.length,
                  itemBuilder: (context, index) {

                    String joinDate = '';
                    DateTime? fleetJoinDate;

                    debugPrint("JOINED DATE ${widget.memberList![index].memberStatus}");

                    if(widget.memberList![index].fleetJoinedDate != null && widget.memberList![index].fleetJoinedDate != '')
                      {
                        joinDate = widget.memberList![index].fleetJoinedDate ?? '';
                        debugPrint("JOINED DATE ${joinDate}");
                        fleetJoinDate = DateTime.parse(joinDate.substring(0,10));
                      }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: commonText(
                                  text: widget.memberList![index].memberName!,
                                  fontWeight: FontWeight.w600,
                                  textSize: 16,
                              textAlign: TextAlign.start),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: widget.memberList![index].memberStatus ==
                                          '1'
                                      ? statusTag(
                                      'Accepted',
                                          acceptBackgrounGreen,
                                          acceptTextGreen)
                                      : statusTag(
                                      'Pending',
                                          pendingBacgroundRed,
                                          pendingTextRed),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 8, right: 2),
                                  child: InkWell(
                                      onTap: () {
                                        CustomFleetDailog().showFleetDialog(
                                          context: context,
                                          title:
                                              'Are you sure you want to remove this fleet member?',
                                          subtext:
                                              fleetInviteData[index].email ??
                                                  '',
                                          description:
                                              'Your permissions to their vessels will be removed & cannot be viewed',
                                          postiveButtonColor:
                                              deleteTripBtnColor,
                                          positiveButtonText: 'Remove',
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/images/Trash.png',
                                        height: 20,
                                        width: 20,
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                  width: displayWidth(context) * 0.36,
                                  // padding: EdgeInsets.only(right: 4),
                                  child: dateofJoin(
                                      'Date of join:',
                                      fleetJoinDate != null ?
                                      (DateFormat("yyyy-MM-dd").format(fleetJoinDate)) : '-',
                                      Colors.black)),
                              if (fleetInviteData[index].numberofVessels !=
                                  null)
                                Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: dateofJoin(
                                        'No of Vessels:',
                                        widget.memberList![index]
                                            .vesselCount
                                            .toString(),
                                        buttonBGColor))
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  }),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                width: displayWidth(context),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      CommonButtons.getActionButton(
                          title: 'Invite To Fleet',
                          context: context,
                          fontSize: displayWidth(context) * 0.044,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SendInviteScreen()));
                          },
                          width: displayWidth(context) / 1.3,
                          height: displayHeight(context) * 0.060),
                      SizedBox(
                        height: 5,
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
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget statusTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: bgColor),
      child: commonText(
          text: text,
          textSize: 10,
          fontWeight: FontWeight.w300,
          fontFamily: poppins,
          textColor: textColor),
    );
  }

  Widget dateofJoin(String title, String date, Color color) {
    return Container(
      // color: Colors.amber,
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: title,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                fontFamily: outfit,
                color: tableHeaderColor)),
        WidgetSpan(
            child: SizedBox(
          width: 5,
        )),
        TextSpan(
            text: date,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: outfit,
                color: color ?? blueColor)),
      ])),
    );
  }
}

class FleetDetailsInviteModel {
  String? email;
  String? dateOfJoin;
  int? numberofVessels;
  String? status;
  FleetDetailsInviteModel(
      {this.email, this.dateOfJoin, this.numberofVessels, this.status});
}
