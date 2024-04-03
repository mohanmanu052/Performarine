import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/pages/fleet/fleet_vessel_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/widgets/common_widgets.dart';
import '../../../models/fleet_list_model.dart';

class MyFleetSingleCard extends StatefulWidget {
  final MyFleets? myFleets;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  const MyFleetSingleCard({super.key, this.myFleets, this.scaffoldKey, this.onTap});

  @override
  State<MyFleetSingleCard> createState() => _MyFleetSingleCardState();
}

class _MyFleetSingleCardState extends State<MyFleetSingleCard> {

  bool deleteFleetBtn = false, isUpdateBtnClicked = false;
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
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [

            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.myFleets!.fleetName!,
                              style: TextStyle(
                                  fontSize: displayWidth(context) * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: outfit
                              ),
                              textAlign: TextAlign.start,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(width: displayWidth(context) * 0.01,),
                          InkWell(
                              onTap: (){
                                FleetData data = FleetData(
                                  fleetName: widget.myFleets!.fleetName,
                                  id: widget.myFleets!.id,
                                  // fleetOwnerId:snapShot. data!.myFleets![index].
                                );
                                CustomFleetDailog().showEditFleetDialog(
                                    context: context,
                                    fleetData:[data],selectedFleetValue: data,
                                    isDropDownEnabled: false,
                                  onUpdateChange: (value)
                                    {
                                      Navigator.pop(context);

                                      setState(() {
                                        isUpdateBtnClicked = true;
                                      });

                                      commonProvider.editFleetDetails(context, commonProvider.loginModel!.token!, value.first, value.last, widget.scaffoldKey!).then((value)
                                      {
                                        if(value != null)
                                        {
                                          if(value.status!)
                                          {
                                            setState(() {
                                              isUpdateBtnClicked = false;
                                            });
                                            widget.onTap!.call();
                                          }
                                          else
                                          {
                                            setState(() {
                                              isUpdateBtnClicked = false;
                                            });
                                          }
                                        }
                                        else
                                        {
                                          setState(() {
                                            isUpdateBtnClicked = false;
                                          });
                                        }
                                      }).catchError((e){
                                        setState(() {
                                          isUpdateBtnClicked = false;
                                        });
                                      });
                                    }
                                );
                              },

                              child: isUpdateBtnClicked
                              ? Container(
                                height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: blueColor, strokeWidth: 2,))
                              : Image.asset('assets/icons/Edit.png', height: displayHeight(context) * 0.018, color: blueColor,)),
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
                              text: widget.myFleets!.vesselCount.toString(),
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.028,
                              textAlign: TextAlign.start),
                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      commonText(
                        context: context,
                        text: 'Member Details',
                        fontWeight: FontWeight.w300,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.03,
                        textAlign: TextAlign.center,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                text: widget.myFleets!.acceptedCount.toString(),
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
                                text: widget.myFleets!.pendingCount.toString(),
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
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => FleetVesselScreen(
                            tabIndex: 1,
                            isCalledFromMyFleet: true,
                            fleetId: widget.myFleets!.id,
                          ))));
                        },
                        child: Container(
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
                      ),
                      SizedBox(width: displayWidth(context) * 0.02,),
                      InkWell(
                          onTap: (){
                            CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to Delete this fleet?',subtext: widget.myFleets!.fleetName??'',description: 'If you delete the fleet your fleet members cannot view vessels & Reports',
                                postiveButtonColor: deleteTripBtnColor,positiveButtonText: 'Delete',
                                onPositiveButtonTap: ()async{

                                  Navigator.of(context).pop();

                                  setState(() {
                                    deleteFleetBtn = true;
                                  });
                                  commonProvider.deleteFleet(context, commonProvider.loginModel!.token!, widget.myFleets!.id!, widget.scaffoldKey!).then((value)
                                  {
                                    if(value != null)
                                    {
                                      if(value.status!)
                                      {
                                        setState(() {
                                          deleteFleetBtn = false;
                                        });
                                        widget.onTap!.call();
                                      }
                                      else
                                        {
                                          setState(() {
                                            deleteFleetBtn = false;
                                          });
                                        }
                                    }
                                    else
                                      {
                                        setState(() {
                                          deleteFleetBtn = false;
                                        });
                                      }
                                  }).catchError((e) {
                                    setState(() {
                                      deleteFleetBtn = false;
                                    });
                                  });
                                },
                                onNegativeButtonTap: (){
                                  Navigator.of(context).pop();
                                }
                            );

                          },
                          child: deleteFleetBtn
                              ? Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: blueColor, strokeWidth: 2.5,))
                              : Image.asset('assets/images/Trash.png', height: displayHeight(context) * 0.02, color: Colors.red,)),
                    ],
                  ),
                )
              ],
            ),

            Divider(
              color: Colors.grey.shade300,
              thickness: 2,
            )
          ],
        ),
      ),
    );
  }
}
