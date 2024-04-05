import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/vessel_delegate_model.dart';
import 'package:performarine/pages/delegate/update_delegate_access_screen.dart';

class SingleDelegateCard extends StatefulWidget {
  Delegates? delegates;
  SingleDelegateCard({super.key, this.delegates});

  @override
  State<SingleDelegateCard> createState() => _SingleDelegateCardState();
}

class _SingleDelegateCardState extends State<SingleDelegateCard> {

  Delegates? delegates;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    delegates = widget.delegates ;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
                children: [
                  Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Row(
                    children: [
                      commonText(
                          text: delegates!.delegateUserName!.trim(),
                          context: context,
                          textSize: displayWidth(context) * 0.042,
                          fontWeight: FontWeight.w500,
                          fontFamily: outfit,
                      textAlign: TextAlign.start),
                      tag(colorgreenLight, delegates!.delegateaccessType.toString() == '1' ?'24 Hr Access' : delegates!.delegateaccessType.toString() == '2' ? '7 Days':delegates!.delegateaccessType.toString() == '3' ? '1 Month': delegates!.delegateaccessType.toString() == '4' ? 'Custom time': 'Always')
                    ],
                  )),
              Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Row(
                    children: [
                      Visibility(
                          child: commonText(
                              text: delegates!.status,
                              textColor: Colors.green,
                              fontWeight:
                              FontWeight.w500,
                              textSize: displayWidth(
                                  context) *
                                  0.03)),
                      Padding(
                          padding:
                          EdgeInsets.symmetric(
                              horizontal: 8),
                          child: InkWell(
                              onTap: () {
                                CustomFleetDailog()
                                    .showFleetDialog(
                                    context:
                                    context,
                                    title:
                                    'Are you sure you want to remove this Delegate Member?',
                                    subtext:
                                    'First Name Last Name',
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
                                      Navigator.of(
                                          context)
                                          .pop();
                                    });
                              },
                              child: Image.asset(
                                'assets/images/Trash.png',
                                height: 18,
                                width: 18,
                              )))
                    ],
                  ))
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
