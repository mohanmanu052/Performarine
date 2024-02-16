import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
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
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class CreateNewFleetScreen extends StatefulWidget {
  const CreateNewFleetScreen({super.key});

  @override
  State<CreateNewFleetScreen> createState() => _CreateNewFleetScreenState();
}

class _CreateNewFleetScreenState extends State<CreateNewFleetScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  CommonProvider? commonProvider;
  final TextEditingController fleetNameEditingController =
      TextEditingController();
  final TextEditingController ownerNameEditingController =
      TextEditingController();
  final TextEditingController emailEditingController = TextEditingController();
  bool isLoading = false;

// List<String> inviteEmailList = [];

  List<SearchWidget> searchWidgetList = [];

  final controller = ScreenshotController();

  List<Key> fieldKeyList = [];
  List<TextEditingController> textControllersList = [];
  List<bool> enableControllerKeyList = [];
  List<String> inviteEmailList = [];
  final fleetName_formKey = GlobalKey<FormState>();

  @override
  void initState() {
    commonProvider = context.read<CommonProvider>();

// TODO: implement initState
    super.initState();
  }

  List<Widget> children = [];

  @override
  Widget build(BuildContext context) {
    for (int index = 0; index < fieldKeyList.length; index++) {
      children.add(
        Padding(
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
              } else if (!value.isEmail) {
                return 'Please enter valid email';
              } else {
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
        ),
/* SearchWidget(
        key: fieldKeyList[index],
        index: index,
        onSelect: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (!inviteEmailList.contains(value)) {
            inviteEmailList[index] = value;
          }
          else
          {
            fieldKeyList.removeAt(index);
            inviteEmailList.removeAt(index);
            setState(() {
            });

            Utils.showSnackBar(context, scaffoldKey: scaffoldKey, message: 'Email is already selected.');
          }
        },
        onRemoved: (p0, p1) {
          inviteEmailList.removeAt(p0);
          fieldKeyList.removeAt(p0);
          setState(() {});
        },
      )*/
      );
    }
    return Scaffold(
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
            text: 'Create New Fleet',
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
          SingleChildScrollView(
            child: Container(
//height: displayHeight(context),
              margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: fleetName_formKey,
                    child: TextFormField(
                      controller: fleetNameEditingController,
                      decoration: InputDecoration(
                        hintText: 'Fleet Name',
                        hintStyle: TextStyle(
                            fontSize: displayWidth(context) * 0.038,
                            fontFamily: outfit,
                            color: Colors.grey),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        enabledBorder: OutlineInputBorder(
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
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter fleet name';
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: displayHeight(context) * 0.04,
                  ),
                  commonText(
                      context: context,
                      text: 'Invite Members',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.042,
                      textAlign: TextAlign.start),
                  SizedBox(
                    height: displayHeight(context) * 0.015,
                  ),
                  Form(
                    key: formKey,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children:
                          List.generate(textControllersList.length, (index1) {
                        return children[index1];
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: displayHeight(context) * 0.14,
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
                          left: 17, right: 17, top: 8, bottom: 12),
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
                            text: '+ Add More Invite',
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
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 17, top: 8),
                    child: CommonButtons.getActionButton(
                        title: 'Create',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        width: displayWidth(context),
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            print('IS EMPTY: ${inviteEmailList}');
                            if (enableControllerKeyList.contains(false)) {
                              int index = enableControllerKeyList
                                  .indexWhere((element) => element == false);
                              if (!inviteEmailList
                                  .contains(textControllersList[index].text)) {
                                inviteEmailList
                                    .add(textControllersList[index].text);
                                enableControllerKeyList[index] = true;
                              } else {
                                Utils.showSnackBar(context,
                                    scaffoldKey: scaffoldKey,
                                    message: 'Email is already added');
                                textControllersList[index].clear();
                                enableControllerKeyList[index] = false;
                              }
                            }

                            if (fleetName_formKey.currentState!.validate()) {
                              isLoading = true;
                              setState(() {});
                              List emailList = [];
                              for (int i = 0;
                                  i < textControllersList.length;
                                  i++) {
                                emailList.add(textControllersList[i].text);
                              }
                              var data = {
                                'fleetName': fleetNameEditingController.text,
                                'fleetmembers': emailList
                              };

                              var res = await commonProvider!.createNewFleet(
                                  commonProvider!.loginModel!.token!,
                                  context,
                                  scaffoldKey,
                                  data);
                              if (res.statusCode == 200) {
                                isLoading = false;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyFleetScreen(
                                            data: true,
                                          )),
                                );
                              } else {
                                isLoading = false;
                                setState(() {});
                              }
                            }
                          }
                        }),
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
            )
        ],
      ),
    );
  }
}
