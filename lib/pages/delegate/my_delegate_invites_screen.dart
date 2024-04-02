import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/my_delegate_invite_model.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class MyDelegateInvitesScreen extends StatefulWidget {
  const MyDelegateInvitesScreen({super.key});

  @override
  State<MyDelegateInvitesScreen> createState() => _MyDelegateInvitesScreenState();
}

class _MyDelegateInvitesScreenState extends State<MyDelegateInvitesScreen> {

  final controller = ScreenshotController();

GlobalKey<ScaffoldState> scfoldKey=GlobalKey();
CommonProvider? commonProvider;
     Future<MyDelegateInviteModel>? future;

@override
  void initState() {
        commonProvider = context.read<CommonProvider>();
getDelgateInvites();
    // TODO: implement initState
    super.initState();
  }
void getDelgateInvites()async{
  future=commonProvider?.getDelegateInvites(context, commonProvider!.loginModel!.token!, scfoldKey);

}

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        key: scfoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: commonText(
              context: context,
              text: 'My Delegate Invites',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
            actions: [
      
              InkWell(
                onTap: ()async{
                },
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid ? displayWidth(context) * 0.05 : displayWidth(context) * 0.05,
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async{
                   await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
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
              ),
            ],
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 4),
          child: GestureDetector(
              onTap: ()async{
                final image = await controller.capture();

                Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                  imagePath: image.toString(),
                  uIntList: image,)));
              },
              child: UserFeedback().getUserFeedback(context)
          ),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          child:   FutureBuilder<MyDelegateInviteModel>(
                      future: future,
                      builder: (context, snapShot)
                      {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            height: displayHeight(context)/1.5,
                              child: Center(child: const CircularProgressIndicator(color: blueColor)));
                        }
                        else if (snapShot.data == null||snapShot.data!.myDelegateInvities!.isEmpty) {
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
          
          
        return  Column(
            children:
            
             [
              SizedBox(height: displayHeight(context) * 0.01,),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapShot.data!.myDelegateInvities!.length,
                  itemBuilder: (context, index)
                  {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: [
                          Container(
                            color: snapShot.data!.myDelegateInvities![index].status == 1
                                ? Colors.grey.shade50
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                        context: context,
                                        text: snapShot.data!.myDelegateInvities![index].vesselName,
                                        fontWeight: FontWeight.w500,
                                        textColor: snapShot.data!.myDelegateInvities![index].status == 1
                                            ? Colors.grey
                                            : Colors.black,
                                        textSize: displayWidth(context) * 0.042,
                                        textAlign: TextAlign.start,),

                                      commonText(
                                          context: context,
                                          text: snapShot.data!.myDelegateInvities![index].invitedByUsername,
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                          textSize: displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start),


                                      commonText(
                                          context: context,
                                          text: 'Permissions: ',
                                          fontWeight: FontWeight.w400,
                                          textColor: snapShot.data!.myDelegateInvities![index].status==1
                                              ? Colors.grey
                                              : Colors.black87,
                                          textSize: displayWidth(context) * 0.03,
                                          textAlign: TextAlign.start),

                                      commonText(
                                          context: context,
                                          text: 'Reports | Manage Trips | Edit ',
                                          fontWeight: FontWeight.w400,
                                          textColor: snapShot.data!.myDelegateInvities![index].status==1
                                              ? Colors.grey
                                              : Colors.black87,
                                          textSize: displayWidth(context) * 0.026,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4,),
                                snapShot.data!.myDelegateInvities![index].status==1
                                    ?  commonText(
                                    context: context,
                                    text: 'Expired',
                                    fontWeight: FontWeight.w300,
                                    textColor: Colors.red.shade200,
                                    textSize: displayWidth(context) * 0.032,
                                    textAlign: TextAlign.start,
                                    fontFamily: poppins)
                                    : Row(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                                          CustomFleetDailog().showFleetDialog(
                    context: context,
                    title: 'Are you sure you want to reject the Delegate invite?',
                    subtext: 'Vessel Name',
                    postiveButtonColor: deleteTripBtnColor,
                    positiveButtonText: 'Reject',
                    onNegativeButtonTap: (){
                      Navigator.of(context).pop();
                    },
                    onPositiveButtonTap: ()async{

                      commonProvider?.delegateAcceptReject(context, commonProvider?.loginModel?.token??'', scfoldKey, false, snapShot.data!.myDelegateInvities![index].invitationLink!);


                      Navigator.of(context).pop();
                    });                                                      

                                      },
                                      child: commonText(
                                          context: context,
                                          text: 'Reject',
                                          fontWeight: FontWeight.w300,
                                          textColor: userFeedbackBtnColor,
                                          textSize: displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start,
                                          fontFamily: poppins),
                                    ),

                                    SizedBox(width: displayWidth(context) * 0.04,),
                                    Container(
                                      width: displayWidth(context) * 0.18,
                                      decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: InkWell(
                                        onTap: (){
                                                                      CustomFleetDailog().showFleetDialog(context: context,title: 'Are you sure you want to accept the Delegate Invite?',subtext: 'Vessel Name',
                                postiveButtonColor: blueColor,positiveButtonText: 'Accept', negtiveButtuonColor: primaryColor,
                              
                                onNegativeButtonTap: (){
                                  Navigator.of(context).pop();
                                },
                                onPositiveButtonTap: (){

commonProvider?.delegateAcceptReject(context, commonProvider?.loginModel?.token??'', scfoldKey, true, snapShot.data!.myDelegateInvities![index].invitationLink!);


                                  Navigator.of(context).pop();
                                

                                        },);
                                        },
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                                            child: commonText(
                                                context: context,
                                                text: 'Accept',
                                                fontWeight: FontWeight.w300,
                                                textColor: Colors.white,
                                                textSize: displayWidth(context) * 0.032,
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
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                          )
                        ],
                      ),
                    );
                  }
              ),
            ],
          );
                          }                
  })
      ),
    ));
  }
}

class InvitesModel
{
  String? fleetName, sendBy, status;

  InvitesModel({this.fleetName, this.sendBy, this.status});
}
