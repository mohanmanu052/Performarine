import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class FleetInvitesSingleCard extends StatefulWidget {
  final FleetInvites? fleetInvites;
  final Function()? onTap;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const FleetInvitesSingleCard({super.key,this.fleetInvites, this.scaffoldKey, this.onTap});

  @override
  State<FleetInvitesSingleCard> createState() => _FleetInvitesSingleCardState();
}

class _FleetInvitesSingleCardState extends State<FleetInvitesSingleCard> {

  bool? isAcceptBtnClicked = false, isRejectBtnClicked = false;

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonText(
                      context: context,
                      text: widget.fleetInvites!.fleetName,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start,),

                    commonText(
                        context: context,
                        text: 'Sent By ${widget.fleetInvites!.fleetCreatedBy}',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                        textSize: displayWidth(context) * 0.028,
                        textAlign: TextAlign.start),
                  ],
                ),
              ),
              SizedBox(width: 4,),
              Row(
                children: [
                  isRejectBtnClicked!
                      ? Container(
                      height: 30,
                      width: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircularProgressIndicator(color: blueColor,strokeWidth: 3,),
                      ))
                      : InkWell(
                    onTap: (){
                      CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to reject the fleet invite?',subtext: widget.fleetInvites!.fleetName??'',
                          postiveButtonColor: deleteTripBtnColor, positiveButtonText: 'Reject',
                          onNegativeButtonTap: (){
                            Navigator.of(context).pop();
                          },
                          onPositiveButtonTap: (){
                            setState(() {
                              isRejectBtnClicked = true;
                            });
                            Navigator.of(context).pop();

                            commonProvider.fleetMemberInvitation(context, commonProvider.loginModel!.token!,
                                widget.fleetInvites!.invitationToken!, 'false', widget.scaffoldKey!).then((value) {
                              if(value != null)
                              {
                                if(value.status!)
                                {
                                  setState(() {
                                    isRejectBtnClicked = false;
                                  });

                                  widget.onTap!.call();
                                }
                                else
                                {
                                  setState(() {
                                    isRejectBtnClicked = false;
                                  });

                                }
                              }
                              else
                              {
                                setState(() {
                                  isRejectBtnClicked = false;
                                });
                              }
                            }).catchError((e){
                              setState(() {
                                isRejectBtnClicked = false;
                              });
                            });
                          }
                      );

                    },
                    child: commonText(
                        context: context,
                        text: 'Reject',
                        fontWeight: FontWeight.w300,
                        textColor: Colors.red,
                        textSize: displayWidth(context) * 0.03,
                        textAlign: TextAlign.start,
                        fontFamily: poppins),
                  ),
                  SizedBox(width: displayWidth(context) * 0.04,),
                  isAcceptBtnClicked!
                      ? Container(
                      height: 30,
                      width: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircularProgressIndicator(color: blueColor,strokeWidth: 3,),
                      ))
                      : Container(
                    width: displayWidth(context) * 0.18,
                    decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child:  InkWell(
                          onTap: (){

                            CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to accept the fleet Invite?',subtext: widget.fleetInvites!.fleetName??'',
                                postiveButtonColor: blueColor,positiveButtonText: 'Accept', negtiveButtuonColor: blueColor,
                                onNegativeButtonTap: (){
                                  Navigator.of(context).pop();
                                },
                                onPositiveButtonTap: (){
                                  setState(() {
                                    isAcceptBtnClicked = true;
                                  });
                                  Navigator.of(context).pop();

                                  commonProvider.fleetMemberInvitation(context, commonProvider.loginModel!.token!,
                                      widget.fleetInvites!.invitationToken!, 'true', widget.scaffoldKey!).then((value) {
                                    if(value != null)
                                    {
                                      if(value.status!)
                                      {
                                        setState(() {
                                          isAcceptBtnClicked = false;
                                        });

                                        widget.onTap!.call();
                                      }
                                      else
                                      {
                                        setState(() {
                                          isAcceptBtnClicked = false;
                                        });
                                      }
                                    }
                                    else
                                    {
                                      setState(() {
                                        isAcceptBtnClicked = false;
                                      });
                                    }
                                  }).catchError((e){
                                    setState(() {
                                      isAcceptBtnClicked = false;
                                    });
                                  });
                                });
                          },
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
                  ),
                ],
              )
            ],
          ),
          Divider(
            color: Colors.grey.shade200,
            thickness: 2,
          )
        ],
      ),
    );
  }
}