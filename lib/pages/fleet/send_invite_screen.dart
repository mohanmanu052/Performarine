import 'dart:io';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/fleet/my_fleet_screen.dart';
import 'package:performarine/pages/fleet/search_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';

class SendInviteScreen extends StatefulWidget {
  const SendInviteScreen({super.key});

  @override
  State<SendInviteScreen> createState() => _SendInviteScreenState();
}

class _SendInviteScreenState extends State<SendInviteScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final controller = ScreenshotController();
  CommonProvider? commonProvider;
  List<int> inviteCountList = [];
  List<String> inviteEmailList = [];
 FleetData? selectedFleetvalue;
  List<SearchWidget> searchWidgetList = [];
  List<Key> fieldKeyList = [];
  bool isLoading = false;
  List<TextEditingController> textControllersList = [];
  List<bool> enableControllerKeyList = [];
  GlobalKey<FormState> formKey = GlobalKey();
  FleetListModel? fleetdata;
  GlobalKey<FormState> selectVesselFormKey=GlobalKey();

  @override
  void initState() {
    //selectedFleetvalue=fleetList[0];
    commonProvider= context.read<CommonProvider>();
    getFleetList();
    // TODO: implement initState
    super.initState();
  }

void getFleetList()async{
 fleetdata=await   commonProvider?.getFleetListdata(
      token: commonProvider!.loginModel!.token,
      scaffoldKey: scaffoldKey,
      context: context
    );
setState(() {
  
});
}
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int index = 0; index < fieldKeyList.length; index++) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: fieldKeyList[index],
          controller: textControllersList[index],
          style: TextStyle(
              fontSize: displayWidth(context) * 0.038,
              fontFamily: outfit,
              color: Colors.black),
          decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                  fontSize: displayWidth(context) * 0.038,
                  fontFamily: outfit,
                  color: Colors.grey),
              filled: true,
              fillColor: Colors.blue.shade50,
              suffixIcon: InkWell(
                child: Icon(
                  Icons.close,
                  color: Colors.black87,
                ),
                onTap: () {
                  fieldKeyList.removeAt(index);
                  textControllersList.removeAt(index);
                  enableControllerKeyList.removeAt(index);
                  if (inviteEmailList.length > index)
                    inviteEmailList.removeAt(index);
                  setState(() {});
                  Future.delayed(Duration(milliseconds: 400), () {
                    setState(() {});
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade50),
                borderRadius: BorderRadius.circular(18),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade50),
                borderRadius: BorderRadius.circular(18),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade50),
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade50),
                borderRadius: BorderRadius.circular(18),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade50),
                borderRadius: BorderRadius.circular(18),
              )),
          readOnly: enableControllerKeyList[index],
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter email';
            } else if (!EmailValidator.validate(value)) {
              return 'Please enter valid email';
            } else if(EmailValidator.validate(value)){
              String emailExt = value.split(".").last;
              if(!['com', 'in', 'us'].contains(emailExt)){
                return 'Please enter valid email';
              }
            }
            else {
              return null;
            }
          },
          onFieldSubmitted: (value) {
            if (formKey.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              if (!inviteEmailList.contains(value)) {
                inviteEmailList.add(value);
                setState(() {
                  enableControllerKeyList[index] = true;
                });
              } else {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message: 'Email is already added');
                textControllersList[index].clear();
                setState(() {});
              }
            }
          },
        ),
      ));
    }
    return Screenshot(
      controller: controller,
      child: Scaffold(
        key: scaffoldKey,
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
          title: commonText(
              context: context,
              text: 'Send Invite',
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
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
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
            SingleChildScrollView(
              child: Container(
                width: displayWidth(context),
                // height: displayHeight(context),
                margin: EdgeInsets.only(
                    left: 17,
                    right: 17,
                    top: 17,
                    bottom: displayHeight(context) * 0.075),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.05,
                    ),
                    Center(
                      child: commonText(
                          context: context,
                          text: 'Invite to My fleet',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.048,
                          textAlign: TextAlign.start),
                    ),
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    SizedBox(
                      child:fleetdata!=null&&fleetdata!.data!=null? Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child:Form(
                          key: selectVesselFormKey,
                          child: FormField(
                            autovalidateMode:AutovalidateMode.onUserInteraction,
                                                      builder: (state) {
                                                        
                          
                                                return    DropdownButtonFormField<FleetData>(
                          
                            value: selectedFleetvalue,
                            hint: Text('Select Fleet'),
                            onChanged: (FleetData? newValue){
                                setState(() => selectedFleetvalue = newValue!);
                                selectVesselFormKey.currentState!.validate();
                                
                                },
                          items: fleetdata!.data!.map((item) {
                            return DropdownMenuItem<FleetData>(
                              value: item,
                              child: Text(item.fleetName??''),
                            );
                          }).toList(),
                                                                                        validator: (value) {
                                                            if (value == null) {
                                                              return 'Select Fleet';
                                                            }
                                                            return null;
                                                          },
                                               
                            // add extra sugar..
                            icon: Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: 24,
                            //underline: SizedBox(),
                            isExpanded: true,
                            decoration: InputDecoration(
                                  border: InputBorder.none,
                          
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),

                          );
                                                
                                                
                            }),
                        ))
                      :Center(child: CircularProgressIndicator()),
                    ),
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    commonText(
                        context: context,
                        text: 'Invite Members',
                        fontWeight: FontWeight.w500,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.04,
                        textAlign: TextAlign.start),
                    SizedBox(
                      height: displayHeight(context) * 0.015,
                    ),
                    Form(
                        key: formKey,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: List.generate(children.length, (index1) {
                            return children[index1];
                          }).toList(),
                        )),
                    Platform.isIOS
                        ? SizedBox(
                            height: displayHeight(context) * 0.055,
                          )
                        : SizedBox(
                            height: displayHeight(context) * 0.085,
                          ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 17, right: 17, top: 8, bottom: 0),
                      child: InkWell(
                        onTap: textControllersList
                                    .where((element) => element.text.isEmpty)
                                    .toList()
                                    .length >
                                0
                            ? null
                            : !(formKey.currentState?.validate() ?? true)
                                ? null
                                : () {
                                    if (enableControllerKeyList
                                        .contains(false)) {
                                      if (formKey.currentState!.validate()) {
                                        int index =
                                            enableControllerKeyList.indexWhere(
                                                (element) => element == false);
                                        if (!inviteEmailList.contains(
                                            textControllersList[index].text)) {
                                          inviteEmailList.add(
                                              textControllersList[index].text);
                                          enableControllerKeyList[index] = true;
                                        } else {
                                          Utils.showSnackBar(context,
                                              scaffoldKey: scaffoldKey,
                                              message:
                                                  'Email is already added');
                                          textControllersList[index].clear();
                                          enableControllerKeyList[index] =
                                              false;
                                        }
                                      }
                                    } else {
                                      fieldKeyList.add(Key(
                                          Random().nextInt(9999).toString()));
                                      textControllersList
                                          .add(TextEditingController());
                                      enableControllerKeyList.add(false);
                                    }

                                    //inviteEmailList.add('');

                                    setState(() {});
                                    /*if (inviteCountList.isEmpty) {
                          inviteCountList.add(0);
                          } else {
                          inviteCountList.add(inviteCountList.last + 1);
                          }
        */
                                  },
                        child: commonText(
                            context: context,
                            text: '+ Add Another Invite',
                            fontWeight: FontWeight.w500,
                            textColor: textControllersList
                                        .where(
                                            (element) => element.text.isEmpty)
                                        .toList()
                                        .length >
                                    0
                                ? Colors.grey
                                : !(formKey.currentState?.validate() ?? true)
                                    ? Colors.grey
                                    : blueColor,
                            textSize: displayWidth(context) * 0.038,
                            textAlign: TextAlign.start),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 17, right: 17, top: 12),
                      child: CommonButtons.getActionButton(
                          title: 'Invite Fleet',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () async{
                            if(selectVesselFormKey.currentState!.validate()){
                            if(textControllersList.isNotEmpty&&textControllersList!=null){
                            if(formKey.currentState!.validate()){
                              isLoading=true;
                              setState(() {
                                
                              });
                              List emailList=[];
                              for(int i=0;i<textControllersList.length;i++){
emailList.add(textControllersList[i].text);
                            
                            
                              }
Map<String,dynamic> data={
    "fleetId": selectedFleetvalue?.id,
    "fleetmembers": emailList
        
};


                     var res=      await   commonProvider?.sendFleetInvite(commonProvider!.loginModel!.token!, context, scaffoldKey, data);
                     if(res!.statusCode==200){
print('invitation sent sucessfully');
                              isLoading=false;
                              setState(() {
                                
                              });

                     }else{
                                                    isLoading=false;
                              setState(() {
                                
                              });

                     }
                              /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyDelegateInvitesScreen()),
                            );*/
                          }

}else{
  ScaffoldMessenger.maybeOf(context)!.showSnackBar(SnackBar(backgroundColor: Colors.blue, content: Text('Please Select Members')));
}

                          
  }}),
                    ),
                    GestureDetector(
                        onTap: () async {
                          final image = await controller.capture();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedbackReport(
                                        imagePath: image.toString(),
                                        uIntList: image,
                                      )));
                        },
                        child: UserFeedback().getUserFeedback(context)),
                    SizedBox(
                      height: 4,
                    )
                  ],
                ),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class EmailModel {
  String? email;

  EmailModel({this.email});
}