import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/pages/fleet/my_fleet_screen.dart';
import 'package:performarine/pages/fleet/search_widget.dart';
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

  final TextEditingController fleetNameEditingController = TextEditingController();
  final TextEditingController ownerNameEditingController = TextEditingController();

  List<int> inviteCountList = [];
  List<String> inviteEmailList = [];

  List<SearchWidget> searchWidgetList = [];

  final controller = ScreenshotController();

  List<Key> fieldKeyList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int index = 0; index < fieldKeyList.length; index++) {
      children.add(SearchWidget(
        key: fieldKeyList[index],
        index: index,
        onSelect: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (!inviteEmailList.contains(value)) {
            inviteEmailList[index] = value;
          }
        },
        onRemoved: (p0, p1) {
          inviteEmailList.removeAt(p0);
          fieldKeyList.removeAt(p0);
          setState(() {});
        },
      ));
    }
    return Scaffold(
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
                  TextFormField(
                    controller: fleetNameEditingController,
                    decoration: InputDecoration(
                      hintText: 'Fleet Name',
                        hintStyle: TextStyle(fontSize: displayWidth(context) * 0.038, fontFamily: outfit, color: Colors.grey),
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
                    ),

                  ),
                  SizedBox(height: displayHeight(context) * 0.04,),
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
                  ListView(
                    shrinkWrap: true,
                    children: List.generate(children.length, (index1) {
                      return children[index1];
                    }).toList(),
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
                        onTap: inviteEmailList.contains('')
                            ? null
                            : (){
                          fieldKeyList.add(
                              Key(Random().nextInt(9999).toString()));
                          inviteEmailList.add('');

                          setState(() {});
                          /*if (inviteCountList.isEmpty) {
                          inviteCountList.add(0);
                          } else {
                          inviteCountList.add(inviteCountList.last + 1);
                          }
*/
                          setState(() {});
                          },
                        child: commonText(
                            context: context,
                            text: '+ Add More Invite',
                            fontWeight: FontWeight.w500,
                            textColor: inviteEmailList.contains('')
                                ? Colors.grey
                                : blueColor,
                            textSize: displayWidth(context) * 0.038,
                            textAlign: TextAlign.start),
                      )
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 17, right: 17, top: 8),
                    child: CommonButtons.getActionButton(
                        title: 'Create',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        width: displayWidth(context),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MyFleetScreen(data: true,)),
                          );
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
                  SizedBox(height: 4,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
