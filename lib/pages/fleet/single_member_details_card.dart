import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class SingleMemberDetailsCard extends StatefulWidget {
  Members? memberList;
  bool? isCalledFromFleetsImIn;
  String? fleetId;
  DateTime? fleetJoinDate;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  SingleMemberDetailsCard({super.key, this.memberList, this.isCalledFromFleetsImIn, this.scaffoldKey, this.fleetId, this.fleetJoinDate, this.onTap});

  @override
  State<SingleMemberDetailsCard> createState() => _SingleMemberDetailsCardState();
}

class _SingleMemberDetailsCardState extends State<SingleMemberDetailsCard> {

  late CommonProvider commonProvider;

  bool? removeMemberBtnColor = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commonProvider = context.read<CommonProvider>();

  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: commonText(
                  text: widget.memberList!.memberName!,
                  fontWeight: FontWeight.w600,
                  textSize: 16,
                  textAlign: TextAlign.start),
            ),
            Row(
              children: [
                Container(
                  child: widget.memberList!.memberStatus ==
                      1
                      ? statusTag(
                      'Accepted',
                      acceptBackgrounGreen,
                      acceptTextGreen)
                      : statusTag(
                      'Pending',
                      pendingBacgroundRed,
                      pendingTextRed),
                ),
                widget.isCalledFromFleetsImIn!
                    ? SizedBox()
                    : Container(
                  margin: EdgeInsets.only(left: 8, right: 2),
                  child: InkWell(
                      onTap: () {
                        CustomFleetDailog().showFleetDialog(
                            context: context,
                            title:
                            'Are you sure you want to remove this fleet member?',
                            subtext:
                            widget.memberList!.memberName ??
                                '',
                            description:
                            'Your permissions to their vessels will be removed & cannot be viewed',
                            postiveButtonColor:
                            deleteTripBtnColor,
                            positiveButtonText: 'Remove',
                            onPositiveButtonTap: (){
                              setState(() {
                                removeMemberBtnColor = true;
                              });

                              Navigator.of(context).pop();

                              Map<String, dynamic>? body = {
                                "fleetId": widget.fleetId,
                                "fleetmemberId": widget.memberList!.memberId,
                              };

                              commonProvider.removeFleetMember(context, commonProvider.loginModel!.token!, body, widget.scaffoldKey!).then((value)
                              {
                                if(value != null)
                                {
                                  if(value.status!)
                                  {
                                    setState(() {
                                      removeMemberBtnColor = false;
                                    });
                                    widget.onTap!.call();
                                  }
                                  else
                                  {
                                    setState(() {
                                      removeMemberBtnColor = false;
                                    });
                                  }
                                }
                                else
                                {
                                  setState(() {
                                    removeMemberBtnColor = false;
                                  });

                                }
                              }).catchError((e){
                                setState(() {
                                  removeMemberBtnColor = false;
                                });
                              });

                              Future.delayed(Duration(seconds: 3), (){
                                if(mounted)
                                  {
                                    setState(() {
                                      removeMemberBtnColor = false;
                                    });
                                  }
                              });
                            }
                        );
                      },
                      child: removeMemberBtnColor!
                          ? Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: blueColor, strokeWidth: 2.5,))
                          : Image.asset(
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
                      widget.fleetJoinDate != null ?
                      (DateFormat("yyyy-MM-dd").format(widget.fleetJoinDate!)) : '-',
                      Colors.black)),
              if (widget.memberList!.vesselCount !=
                  null)
                Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 4),
                    child: dateofJoin(
                        'No of Vessels:',
                        widget.memberList!
                            .vesselCount
                            .toString(),
                        buttonBGColor))
            ],
          ),
        ),
        Divider(),
      ],
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
