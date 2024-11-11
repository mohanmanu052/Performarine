import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/pages/fleet/fleet_vessel_screen.dart';
import 'package:performarine/pages/fleet/manage_permissions_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class FleetsImInSingleCard extends StatefulWidget {
  final FleetsIamIn? fleetsIamIn;
  final List<FleetsIamIn>? fleetsList;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  const FleetsImInSingleCard({super.key, this.fleetsIamIn, this.scaffoldKey, this.onTap,this.fleetsList});

  @override
  State<FleetsImInSingleCard> createState() => _FleetsImInSingleCardState();
}

class _FleetsImInSingleCardState extends State<FleetsImInSingleCard> {

  bool leaveFleetBtn = false;

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

    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: ((context) => FleetVesselScreen(
          tabIndex: 1,
          isCalledFromMyFleetScreen: true,
          isCalledFromFleetsImInWidget: true,
          //fleetsIamIn: widget.fleetsIamIn!,
          fleetId: widget.fleetsIamIn!.fleetId,
          fleetName: widget.fleetsIamIn!.fleetName,
        ))));
      },
      child: Padding(
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
                  text: widget.fleetsIamIn!.fleetName,
                  fontWeight: FontWeight.w500,
                  textColor: blueColor,
                  textSize: displayWidth(context) * 0.04,
                  textAlign: TextAlign.start,),
                SizedBox(height: 4,),
                Row(
                  children: [
                    commonText(
                        context: context,
                        text: 'Created By : ',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                        textSize: displayWidth(context) * 0.028,
                        textAlign: TextAlign.start),
                    Container(
                      width: displayWidth(context) * 0.28,
                      child: Text(
                        widget.fleetsIamIn!.fleetCreatedBy!.trim().isEmpty ? '-' : widget.fleetsIamIn!.fleetCreatedBy!,
                        style: TextStyle(
                          color: Colors.black,
                            fontFamily: outfit,
                            fontWeight: FontWeight.w500,
                            fontSize: displayWidth(context) * 0.028),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(width: displayWidth(context) * 0.03,),
                  ],
                ),
                SizedBox(height: 4,),
                Row(
                  children: [
                    Container(
                      width: displayWidth(context) * 0.24,
                      child: Row(
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
                              text:widget.fleetsIamIn!.fleetJoinedDate!=null? DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.fleetsIamIn!.fleetJoinedDate!)):'',
                              //text: snapShot.data!.fleetsIamIn![index].fleetJoinedDate,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.028,
                              textAlign: TextAlign.start),
                        ],
                      ),
                    ),
                    // SizedBox(width: displayWidth(context) * 0.02,),
                    commonText(
                        context: context,
                        text: 'No of Vessels: ',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                        textSize: displayWidth(context) * 0.028,
                        textAlign: TextAlign.start),
                    commonText(
                        context: context,
                        text: widget.fleetsIamIn!.vesselCount.toString(),
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
                InkWell(
                  onTap: (){

                    debugPrint("ACTUAL FLEET ID ${widget.fleetsIamIn!.fleetId}");
                    debugPrint("ACTUAL FLEET MEMBER ID ${widget.fleetsIamIn!.fleetMemberId}");

                    CustomFleetDailog().showFleetDialog(
                      context: context,
                      title: 'Are you sure you want to leave this fleet?',
                      subtext: widget.fleetsIamIn!.fleetName?? '',
                      description: 'If you leave the fleet your fleet manager cannot view your vessels & Reports',
                      postiveButtonColor: deleteTripBtnColor,
                      positiveButtonText: 'Leave',
                      onNegativeButtonTap: (){
                        Navigator.of(context).pop();
                      },
                      onPositiveButtonTap: ()async{

                        Navigator.of(context).pop();

                        setState(() {
                          leaveFleetBtn = true;
                        });
                        commonProvider.leaveFleet(context, commonProvider.loginModel!.token!, widget.fleetsIamIn!.fleetId!, widget.scaffoldKey!).then((value)
                        {
                          if(value.status!)
                          {
                            setState(() {
                              leaveFleetBtn = false;
                            });
                            widget.onTap!.call();
                          }
                          else
                          {
                            setState(() {
                              leaveFleetBtn = false;
                            });
                          }
                                                }).catchError((e) {
                          setState(() {
                            leaveFleetBtn = false;
                          });
                        });
                      },
                    );
                  },
                  child: leaveFleetBtn
                      ? Container(
                    height: 30,
                      width: 30,
                      child: CircularProgressIndicator(color: blueColor, strokeWidth: 3,))
                      : commonText(
                      context: context,
                      text: 'Leave',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.red,
                      textSize: displayWidth(context) * 0.03,
                      textAlign: TextAlign.start,
                      fontFamily: poppins),
                ),

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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ManagePermissionsScreen(
      selectedFleetvalue: widget.fleetsIamIn,
      fleetItemList: widget.fleetsList,


                        )));
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
      ),
    );
  }
}
