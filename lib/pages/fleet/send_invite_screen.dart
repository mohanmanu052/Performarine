import 'dart:math';

import 'package:flutter/material.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/fleet/manage_permissions_screen.dart';
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

  final controller = ScreenshotController();

  List<int> inviteCountList = [];
  List<String> inviteEmailList = [];

  List<SearchWidget> searchWidgetList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
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
                height: displayHeight(context),
                margin: EdgeInsets.only(
                    left: 17,
                    right: 17,
                    top: 17,
                    bottom: displayHeight(context) * 0.06),
                child: Column(
                  children: [
                    commonText(
                        context: context,
                        text: 'Invite to My fleet',
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.05,
                        textAlign: TextAlign.start),
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SearchWidget(
                          index: inviteCountList[index],
                          onSelect: (value) {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            if (!inviteEmailList.contains(value)) {
                              inviteEmailList.add(value);
                            }
                          },
                          onRemoved: (index, email) {
                            inviteEmailList.remove(email);
                            inviteCountList.remove(index);
                            setState(() {});
                          },
                        );
                      },
                      itemCount: inviteCountList.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                    )
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
                        child: TextButton(
                          child: commonText(
                              context: context,
                              text: '+ Add More Invite',
                              fontWeight: FontWeight.w500,
                              textColor: blueColor,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.start),
                          onPressed: () {
                            if (inviteCountList.isEmpty) {
                              inviteCountList.add(0);
                            } else {
                              inviteCountList.add(inviteCountList.last + 1);
                            }

                            setState(() {});
                          },
                        )),
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 17, right: 17, top: 8),
                      child: CommonButtons.getActionButton(
                          title: 'Invite Fleet',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () {
                            // print('INVITE EMAIL LIST: ${inviteCountList}');
                            // print('INVITE EMAIL LIST: ${inviteEmailList}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagePermissionsScreen()),
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
      ),
    );
  }
}

class EmailModel {
  String? email;
  EmailModel({this.email});
}
