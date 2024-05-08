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
import 'package:performarine/pages/fleet/single_member_details_card.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class MemberDetailsWidget extends StatefulWidget {
  List<Members>? memberList;
  bool? isCalledFromFleetsImIn;
  String? fleetId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  MemberDetailsWidget({super.key, this.memberList, this.scaffoldKey, this.isCalledFromFleetsImIn = false, this.fleetId, this.onTap});

  @override
  State<MemberDetailsWidget> createState() => _MemberDetailsWidgetState();
}

class _MemberDetailsWidgetState extends State<MemberDetailsWidget> {
  ScreenshotController controller = ScreenshotController();


  bool? removeMemberBtnColor = false;
  late CommonProvider commonProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    debugPrint("MEMBER DETAILS FLEET ${widget.isCalledFromFleetsImIn}");

    return Screenshot(
      controller: controller,
      child: Stack(
        children: [
          Column(
            children: [
              widget.memberList == null || widget.memberList!.isEmpty
                ? Container(
                height: displayHeight(context) / 1.5,
                  child: Center(
                    child: commonText(
                      context: context,
                      text: 'No members available',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.045,
                      textAlign: TextAlign.start),
                  ),
                )
              : Container(
                margin: EdgeInsets.only(bottom: displayHeight(context) / 9, top: 20),
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

                      return SingleMemberDetailsCard(
                        memberList: widget.memberList![index],
                        scaffoldKey: widget.scaffoldKey,
                        fleetId: widget.fleetId,
                        isCalledFromFleetsImIn: widget.isCalledFromFleetsImIn,
                        onTap: (){
                          widget.onTap!.call();
                        },
                      );
                    }),
              ),
            ],
          ),
          widget.isCalledFromFleetsImIn!
              ? SizedBox()
              : Positioned(
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

