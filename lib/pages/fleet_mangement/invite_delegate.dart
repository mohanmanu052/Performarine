import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:screenshot/screenshot.dart';

class InviteDelegate extends StatefulWidget {
  const InviteDelegate({super.key});

  @override
  State<InviteDelegate> createState() => _InviteDelegateState();
}

class _InviteDelegateState extends State<InviteDelegate> {
    final controller = ScreenshotController();
  GlobalKey<ScaffoldState>  scaffoldKey = GlobalKey();
  String selectedDuration = '24 hrs';

  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: controller,
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
          Navigator.pop(context);

        
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: commonText(
                context: context,
                text: 'Send Invite',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.042,
                fontFamily: outfit
            ),
            actions: [
      
              InkWell(
                onTap: ()async{
                },
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid ? displayWidth(context) * 0.065 : displayWidth(context) * 0.05,
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
          body: Container(
            child: Stack(
              children: [
//vesselSingleViewCard(context,CreateVessel(),((p0) {} ),scaffoldKey),

Positioned(
  top: 0,
  left: 0,
  right: 0,

  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    children: [
commonText(text:'Invite Delegate',
fontWeight: FontWeight.w700,
textSize: 20

),
SizedBox(height: 10,),
SizedBox(
  width: displayWidth(context)/1.1,
  child: CommonTextField(
                     // controller: nameController,
                     // focusNode: nameFocusNode,
                      labelText: 'Email ID',
                      hintText: '',
                      circularRadius: 20,
                      suffixText: null,
                      fillColor: dropDownBackgroundColor,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 32,
                      prefixIcon: null,
                      suffixIcon: Icon(Icons.close),
                     // requestFocusNode: modelFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {
                      },
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Valid Email';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                      }),
) ,

SizedBox(height: 10,),
Container(
  padding: EdgeInsets.all(8),
  alignment: Alignment.centerLeft,
  child: commonText(text: 'Share Access upto',
  textSize: 13,
  fontWeight: FontWeight.w400
  ),
),
SizedBox(height: 10,),

Column(
      children: [
        Row(
          children: [
        radioButton('24 hrs'),
            radioButton('7 days'),
            radioButton('1 month')
          ],
        ),
          
          Row(
            children: [
radioButton('Always')
            ],
          )

    ])

   ],
  ),
)),
                Positioned(
                  bottom: 20,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: displayHeight(context)/7.9,
                    padding: EdgeInsets.all(8),

                  child: Column(
                    children: [
                      CommonButtons.getActionButton(
            title: 'Invite Delegate',
            context: context,
            fontSize: displayWidth(context) * 0.044,
            textColor: Colors.white,
            buttonPrimaryColor: blueColor,
            borderColor: blueColor,
            onTap: (){

            },
            width: displayWidth(context)/1.3,
            
            ),

            SizedBox(height: 10,),
            GestureDetector(
              onTap: (()async {
                                          final image = await controller.capture();
                          await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                            imagePath: image.toString(),
                            uIntList: image,)));

              }),
                                      child: UserFeedback().getUserFeedback(
                                          context,
                                          )),
                    ],
                    

                  ),
                )),
                
            ]))));
  }

  Widget radioButton(String text){
    return Flexible(
      fit: FlexFit.tight,
      flex: 1,
        child:  Row(children: [
                        Radio(
              value: text,
              groupValue: selectedDuration,
              onChanged: (value) {
                setState(() {
                  selectedDuration = value.toString();
                });
              },
            ),
            commonText(text: text,
            fontWeight: FontWeight.w400,
            textSize: 12
            
            ),

    ]));
        }
}