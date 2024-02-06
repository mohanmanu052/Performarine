import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/fleet/search_widget.dart';
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

  List<int> inviteCountList = [];
  List<String> inviteEmailList = [];

  List<SearchWidget> searchWidgetList = [];
  List<Key> fieldKeyList = [];

  final items = [
    'Fleet 011513',
    'Fleet 011514',
    'Fleet 011515',
    'Fleet 011516'
  ];
  String selectedValue = 'Fleet 011513';

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
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButton<String>(
                        value: selectedValue,
                        onChanged: (String? newValue) =>
                            setState(() => selectedValue = newValue!),
                        items: items
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                            .toList(),

                        // add extra sugar..
                        icon: Icon(Icons.keyboard_arrow_down_rounded),
                        iconSize: 24,
                        underline: SizedBox(),
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
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
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(children.length, (index1) {
                        return children[index1];
                      }).toList(),
                    ),
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
                        onTap: inviteEmailList.contains('')
                            ? null
                            : () {
                          fieldKeyList.add(
                              Key(Random().nextInt(9999).toString()));
                          inviteEmailList.add('');

                          setState(() {});
                        },
                        child: commonText(
                            context: context,
                            text: '+ Add Another Invite',
                            fontWeight: FontWeight.w500,
                            textColor: inviteEmailList.contains('')
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
                          onTap: () {
                            /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyDelegateInvitesScreen()),
                            );*/
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
