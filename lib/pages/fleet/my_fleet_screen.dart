import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/fleet/fleet_vessel_screen.dart';
import 'package:performarine/pages/fleet/send_invite_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
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
  bool? isComingFromUnilink;
  MyFleetScreen({super.key, this.bottomNavIndex,this.isComingFromUnilink});

  @override
  State<MyFleetScreen> createState() => _MyFleetScreenState();
}

class _MyFleetScreenState extends State<MyFleetScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final controller = ScreenshotController();

  late CommonProvider commonProvider;

  late Future<FleetDashboardModel>? future;

  bool? isAcceptBtnClicked = false, isRejectBtnClicked = false, isFleetIsEmpty = false;
String? token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    commonProvider = context.read<CommonProvider>();
    getLoginToken();
  }


  getLoginToken()async{
    if(token==null||token!.isEmpty){
      await commonProvider.init();
      token=commonProvider.loginModel!.token??'';
      future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
setState(() {

});
    }else{
      future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
setState(() {

});
    }

  }


  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: ()async{
        if(widget.isComingFromUnilink??false){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:((context) =>  BottomNavigation())), (route) => true);
          return false;
        }else{
          Navigator.of(context).pop();
return false;
        }
        return false;

      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                if(widget.isComingFromUnilink??false){
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:((context) =>  BottomNavigation())), (route) => true);
                }else{
                Navigator.of(context).pop();

                }
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
              Container(
              height: displayHeight(context),
              margin: EdgeInsets.only(bottom:displayHeight(context) * 0.14) ,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    width: displayWidth(context),
                    //height: displayHeight(context),
                    margin: EdgeInsets.only(left: 17, right: 17, top: 17, bottom: displayHeight(context) * 0.14),
                    child: FutureBuilder<FleetDashboardModel>(
                      future: future,
                      builder: (context, snapShot)
                      {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            height: displayHeight(context)/1.5,
                              child: Center(child: const CircularProgressIndicator(color: circularProgressColor)));
                        }
                        else if (snapShot.data == null) {
                          return  Container(
                            height: displayHeight(context)/ 1.4,
                            child: Center(
                              child: commonText(
                                  context: context,
                                  text: 'No data found',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.05,
                                  textAlign: TextAlign.start),
                            ),
                          );
                        }
                        else
                          {
                            return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setter)
                                {
                                  return Column(
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

                                            snapShot.data!.myFleets!.isNotEmpty
                                                ? ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: snapShot.data!.myFleets!.length,
                                                itemBuilder: (context, index)
                                                {
                                                  return Padding(
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
                                                                          snapShot.data!.myFleets![index].fleetName!,
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
                                                                            FleetData data=FleetData(
                                                                              fleetName: snapShot.data!.myFleets![index].fleetName,
                                                                              id: snapShot.data!.myFleets![index].id,
                                                                             // fleetOwnerId:snapShot. data!.myFleets![index].
                                                                            );
                                                                            CustomFleetDailog().showEditFleetDialog(context: context,fleetData:[data],selectedFleetValue: data,isDropDownEnabled: false );
                                                                          },

                                                                          child: Image.asset('assets/icons/Edit.png', height: displayHeight(context) * 0.018, color: blueColor,)),
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
                                                                          text: snapShot.data!.myFleets![index].vesselCount.toString(),
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
                                                                            text: snapShot.data!.myFleets![index].acceptedCount.toString(),
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
                                                                            text: snapShot.data!.myFleets![index].pendingCount.toString(),
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
                                                                        CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to leave this fleet?',subtext: snapShot.data!.myFleets![index].fleetName??'',description: 'If you leave the fleet your fleet manager cannot view your vessels & Reports',
                                                                            postiveButtonColor: deleteTripBtnColor,positiveButtonText: 'Leave');

                                                                      },

                                                                      child: Image.asset('assets/images/Trash.png', height: displayHeight(context) * 0.02, color: Colors.red,)),
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
                                              text: 'Fleets I am In',
                                              fontWeight: FontWeight.w500,
                                              textColor: blueColor,
                                              textSize: displayWidth(context) * 0.048,
                                              textAlign: TextAlign.start),
                                          children: <Widget>[

                                            snapShot.data!.fleetsIamIn!.isNotEmpty
                                                ? ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: snapShot.data!.fleetsIamIn!.length,
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
                                                              text: snapShot.data!.fleetsIamIn![index].fleetName,
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
                                                                    text: snapShot.data!.fleetsIamIn![index].fleetName,
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
                                                                         text: DateFormat("yyyy-MM-dd").format(DateTime.parse(snapShot.data!.fleetsIamIn![index].fleetJoinedDate!)),
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
                                                                    text: snapShot.data!.fleetsIamIn![index].vesselCount.toString(),
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
                                                                CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to leave this fleet?',subtext: snapShot.data!.myFleets![index].fleetName??'',description: 'If you leave the fleet your fleet manager cannot view your vessels & Reports',
                                                                  postiveButtonColor: deleteTripBtnColor,positiveButtonText: 'Leave',

                                                                );


                                                              },
                                                              child: commonText(
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
                                            snapShot.data!.fleetInvites!.isNotEmpty
                                                ? ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: snapShot.data!.fleetInvites!.length,
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
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  commonText(
                                                                    context: context,
                                                                    text: snapShot.data!.fleetInvites![index].fleetName,
                                                                    fontWeight: FontWeight.w500,
                                                                    textColor: Colors.black,
                                                                    textSize: displayWidth(context) * 0.04,
                                                                    textAlign: TextAlign.start,),

                                                                  commonText(
                                                                      context: context,
                                                                      text: 'Sent By ${snapShot.data!.fleetInvites![index].fleetCreatedBy}',
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
                                                                      child: CircularProgressIndicator(color: circularProgressColor,strokeWidth: 3,),
                                                                    ))
                                                                    : InkWell(
                                                                  onTap: (){
                                                                    CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to Reject fleet Invite??',subtext: snapShot.data!.fleetInvites![index].fleetName??'',
                                                                      postiveButtonColor: deleteTripBtnColor, positiveButtonText: 'Reject',
                                                                    onNgeitiveButtonTap: (){
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                      onPostiveButtonTap: (){
                                                                        setState(() {
                                                                          isRejectBtnClicked = true;
                                                                        });
                                                                        Navigator.of(context).pop();

                                                                        commonProvider.fleetMemberInvitation(context, commonProvider.loginModel!.token!,
                                                                            snapShot.data!.fleetInvites![index].invitationToken!, 'false', scaffoldKey).then((value) {
                                                                          if(value != null)
                                                                          {
                                                                            if(value.status!)
                                                                            {
                                                                              setState(() {
                                                                                isRejectBtnClicked = false;
                                                                              });

                                                                              future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
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
                                                                      child: CircularProgressIndicator(color: circularProgressColor,strokeWidth: 3,),
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

                                                                          CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to accept fleet Invite?',subtext: snapShot.data!.fleetInvites![index].fleetName??'',
                                                                              postiveButtonColor: blueColor,positiveButtonText: 'Accept', negtiveButtuonColor: blueColor,
                                                                              onNgeitiveButtonTap: (){
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              onPostiveButtonTap: (){
                                                                            setState(() {
                                                                              isAcceptBtnClicked = true;
                                                                            });
                                                                            Navigator.of(context).pop();

                                                                            commonProvider.fleetMemberInvitation(context, commonProvider.loginModel!.token!,
                                                                                snapShot.data!.fleetInvites![index].invitationToken!, 'true', scaffoldKey).then((value) {
                                                                                  if(value != null)
                                                                                    {
                                                                                      if(value.status!)
                                                                                        {
                                                                                          setState(() {
                                                                                            isAcceptBtnClicked = false;
                                                                                          });

                                                                                          future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
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
                                  );
                                }
                            );
                          }

                      },
                    ),
                  )

                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,

                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 17, right: 17, top: 8),
                        child: CommonButtons.getActionButton(
                            title: commonProvider.isMyFleetNotEmpty ? 'Invite to Fleet' : 'Create New Fleet',
                            context: context,
                            fontSize: displayWidth(context) * 0.042,
                            textColor: Colors.white,
                            buttonPrimaryColor: blueColor,
                            borderColor: blueColor,
                            width: displayWidth(context),
                            onTap:  commonProvider.isMyFleetNotEmpty
                              ? ()async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SendInviteScreen()),
                              );

                              if(result != null)
                                {
                                  if(result)
                                    {
                                      setState(() {
                                        future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                      });
                                    }
                                }
                            }
                            : ()async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateNewFleetScreen()),
                              );

                              if(result != null)
                              {
                                if(result)
                                {
                                  setState(() {
                                    future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                  });
                                }
                              }

                            }),
                      ),
                      commonProvider.isMyFleetNotEmpty ?
                      Column(
                        children: [
                          SizedBox(height: displayHeight(context) * 0.01,),
                          InkWell(
                            onTap: ()async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateNewFleetScreen()),
                              );

                              if(result != null)
                              {
                                if(result)
                                {
                                  setState(() {
                                    future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                  });
                                }
                              }

                            },
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
                      )
                          :SizedBox(),

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
      ),
    );
  }
}