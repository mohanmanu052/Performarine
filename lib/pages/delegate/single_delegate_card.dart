import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/vessel_delegate_model.dart';
import 'package:performarine/pages/delegate/update_delegate_access_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class SingleDelegateCard extends StatefulWidget {
  Delegates? delegates;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  String? vesselID;
  SingleDelegateCard({super.key, this.delegates, this.onTap, this.scaffoldKey, this.vesselID});

  @override
  State<SingleDelegateCard> createState() => _SingleDelegateCardState();
}

class _SingleDelegateCardState extends State<SingleDelegateCard> {

  Delegates? delegates;
  late CommonProvider commonProvider;
  bool? isDeleteDelegateClicked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    delegates = widget.delegates ;

    commonProvider = context.read<CommonProvider>();

  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
                children: [
                  Expanded(
                  child: Row(
                    children: [
                      commonText(
                          text: delegates!.delegateUserName!.trim(),
                          context: context,
                          textSize: displayWidth(context) * 0.042,
                          fontWeight: FontWeight.w500,
                          fontFamily: outfit,
                      textAlign: TextAlign.start),
                      tag(colorgreenLight, delegates!.delegateaccessType)
                    ],
                  )),
              Row(
                children: [
                  Visibility(
                      child: commonText(
                          text: delegates!.status,
                          textColor: delegates!.status == 'Removed' ? Colors.red : delegates!.status == 'Accepted' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                          textSize: displayWidth(
                              context) *
                              0.03)),
                  SizedBox(width: displayWidth(context) * 0.02,),
                  delegates!.status!.toLowerCase() == 'removed'
                  ? SizedBox()
                  : InkWell(
                      onTap: () {
                        CustomFleetDailog()
                            .showFleetDialog(
                            context:
                            context,
                            title:
                            'Are you sure you want to remove this Delegate Member?',
                            subtext:
                            '${delegates!.delegateUserName}',
                            description:
                            'Your permissions to their vessels will be removed & cannot be viewed',
                            postiveButtonColor:
                            deleteTripBtnColor,
                            positiveButtonText:
                            'Remove',
                            onNegativeButtonTap:
                                () {
                              Navigator.of(
                                  context)
                                  .pop();
                            },
                            onPositiveButtonTap:
                                () async {

                              setState(() {
                                isDeleteDelegateClicked = true;
                              });

                              Navigator.of(
                                  context)
                                  .pop();

                                  commonProvider.removeDelegate(context, commonProvider.loginModel!.token!, widget.vesselID!, delegates!.id, widget.scaffoldKey!).then((value)
                                  {
                                    if(value != null)
                                      {
                                        if(value.status!)
                                          {
                                            setState(() {
                                              isDeleteDelegateClicked = false;
                                            });

                                            widget.onTap!.call();
                                          }
                                        else
                                          {
                                            setState(() {
                                              isDeleteDelegateClicked = false;
                                            });
                                          }
                                      }
                                    else
                                      {
                                        setState(() {
                                          isDeleteDelegateClicked = false;
                                        });
                                      }
                                  }).catchError((e){
                                    setState(() {
                                      isDeleteDelegateClicked = false;
                                    });
                                  });

                            });
                      },
                      child: isDeleteDelegateClicked!
                    ? Container(
                        height: 25,
                          width: 25,
                          child: CircularProgressIndicator(color: blueColor, strokeWidth: 3,))
                      : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8),
                        child: Image.asset(
                          'assets/images/Trash.png',
                          height: 18,
                          width: 18,
                        ),
                      ))
                ],
              )
            ]),
            SizedBox(height: displayHeight(context) * 0.006,),
            Container(
              alignment: Alignment.centerLeft,
              child: commonText(
                  text:
                  delegates!.delegateUserEmail,
                  fontWeight:
                  FontWeight.w400,
                  textSize: displayWidth(context) * 0.032,
                  textColor: Colors.grey),
            ),
            SizedBox(height: displayHeight(context) * 0.005,),
            InkWell(
              onTap: () {
                //debugPrint("VESSEL ID DELEGATE SCREEN 2 - ${widget.vesselID}");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateDelegateAccessScreen(
                            //vesselID: widget.vesselID,
                          )),
                );
              },
              child: Container(
                alignment:
                Alignment.centerLeft,
                child: commonText(
                    text:
                    'Manage Share Settings',
                    fontWeight:
                    FontWeight.w300,
                    textSize: displayWidth(context) * 0.032,
                    textColor: blueColor),
              ),
            ),
            Divider()
          ],
        ));
  }

  Widget tag(Color tagColor, dynamic text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: delegateAccessStatus(text));
  }

  Widget delegateAccessStatus(int status) {
    switch (status) {
      case 1:
        return commonText(
            context: context,
            text: '24 Hours',
            fontWeight: FontWeight.w300,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.028,
            textAlign: TextAlign.start,
            fontFamily: outfit);

      case 2:
        return commonText(
            context: context,
            text: '7 Days',
            fontWeight: FontWeight.w300,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.028,
            textAlign: TextAlign.start,
            fontFamily: outfit);

      case 3:
        return commonText(
            context: context,
            text: '1 Month',
            fontWeight: FontWeight.w300,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.028,
            textAlign: TextAlign.start,
            fontFamily: outfit);

      case 4:
        return commonText(
            context: context,
            text: 'Custom Time',
            fontWeight: FontWeight.w300,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.028,
            textAlign: TextAlign.start,
            fontFamily: outfit);

      default:
        return commonText(
            context: context,
            text: 'Always',
            fontWeight: FontWeight.w300,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.028,
            textAlign: TextAlign.start,
            fontFamily: outfit);
        ;
    }
  }
}
