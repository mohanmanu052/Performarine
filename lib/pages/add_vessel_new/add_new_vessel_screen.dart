import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/pages/add_vessel_new/add_new_vessel_step_two.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../models/vessel.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';
import 'add_new_vessel_step_one.dart';

class AddNewVesselPage extends StatefulWidget {
  final bool? isEdit;
  final CreateVessel? createVessel;
  final String? calledFrom;
  AddNewVesselPage({Key? key, this.isEdit = false, this.createVessel, this.calledFrom}) : super(key: key);

  @override
  State<AddNewVesselPage> createState() => _AddNewVesselPageState();
}

class _AddNewVesselPageState extends State<AddNewVesselPage> {

  String page = "Add_new_vessel_screen";
  final controller = ScreenshotController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late PageController pageController;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.calledFrom == 'SuccessFullScreen') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigation(),
              ),
              ModalRoute.withName(""));

          return false;
        } else if (pageIndex == 0) {
          Navigator.of(context).pop();
          return false;
        } else if (pageIndex == 1) {
          pageController.previousPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          return false;
        } else {
          return true;
        }
      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          key: scaffoldKey,
          //  resizeToAvoidBottomInset: false,
          backgroundColor: commonBackgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: commonBackgroundColor,
            leading: IconButton(
              onPressed: () {
                if (widget.calledFrom == 'SuccessFullScreen') {
                  CustomLogger().logWithFile(Level.info, "User navigating to Home page -> $page");
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavigation(),
                      ),
                      ModalRoute.withName(""));
                } else if (pageIndex == 1) {
                  pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            centerTitle: true,
            title: commonText(
                context: context,
                text: widget.isEdit! ? 'Edit Vessel' : 'Add New Vessel',
                fontWeight: FontWeight.w700,
                textColor: Colors.black,
                textSize: displayWidth(context) * 0.05,
                textAlign: TextAlign.start),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 17),
              width: MediaQuery.of(context).size.width,
              height: displayHeight(context) * 1.25,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageController,
                      onPageChanged: (value) {
                        setState(() {
                          pageIndex = value;
                        });
                        Utils.customPrint('PAGEVIEW INDEX $pageIndex');
                        CustomLogger().logWithFile(Level.info, "PAGEVIEW INDEX $pageIndex -> $page");
                      },
                      children: [
                        Column(
                          children: [
                            AddNewVesselStepOne(
                              pageController: pageController,
                              scaffoldKey: scaffoldKey,
                              addVesselData:
                              widget.isEdit! ? widget.createVessel : null,
                              isEdit: widget.isEdit,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                bottom : 0,
                              ),
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
                          ],
                        ),
                        Column(
                          children: [
                            AddNewVesselStepTwo(
                              pageController: pageController,
                              scaffoldKey: scaffoldKey,
                              addVesselData:
                              widget.isEdit! ? widget.createVessel : null,
                              isEdit: widget.isEdit,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                bottom : 0,
                              ),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
