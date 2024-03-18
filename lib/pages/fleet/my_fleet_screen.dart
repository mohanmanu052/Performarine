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
import 'package:performarine/pages/fleet/widgets/fleet_invites_single_card.dart';
import 'package:performarine/pages/fleet/widgets/fleets_im_in_single_card.dart';
import 'package:performarine/pages/fleet/widgets/my_fleet_single_card.dart';
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

   Future<FleetDashboardModel>? future;

  bool? isAcceptBtnClicked = false, isRejectBtnClicked = false, isFleetIsEmpty = false, leaveFleetBtn = false;
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop)async{
        if(didPop) return;
     //   if(widget.isComingFromUnilink??false){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:((context) =>  BottomNavigation())), (route) => true);

        // }else{
        //   Navigator.of(context).pop();

        // }

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
               // if(widget.isComingFromUnilink??false){
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:((context) =>  BottomNavigation())), (route) => true);
                
                // }else{
                // Navigator.of(context).pop();

                // }
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
              margin: EdgeInsets.only(bottom:displayHeight(context) * 0.14),
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
                              child: Center(child: const CircularProgressIndicator(color: blueColor)));
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
                                                  return MyFleetSingleCard(
                                                    myFleets: snapShot.data!.myFleets![index],
                                                    scaffoldKey: scaffoldKey,
                                                    onTap: (){
                                                      setter(() {
                                                        future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                                      });
                                                    },
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

                                                  return FleetsImInSingleCard(
                                                    fleetsIamIn: snapShot.data!.fleetsIamIn![index],
                                                    scaffoldKey: scaffoldKey,
                                                    fleetsList: snapShot.data!.fleetsIamIn,
                                                    onTap: (){
                                                      setter(() {
                                                        future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                                      });
                                                    },
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

                                                  return FleetInvitesSingleCard(
                                                    fleetInvites: snapShot.data!.fleetInvites![index],
                                                    scaffoldKey: scaffoldKey,
                                                    onTap: (){
                                                      setter(() {
                                                        future = commonProvider.fleetDashboardDetails(context, commonProvider.loginModel!.token!, scaffoldKey);
                                                      });
                                                    },
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