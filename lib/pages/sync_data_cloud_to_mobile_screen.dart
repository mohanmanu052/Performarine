import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:status_stepper/status_stepper.dart';

class SyncDataCloudToMobileScreen extends StatefulWidget {
  const SyncDataCloudToMobileScreen({Key? key}) : super(key: key);

  @override
  State<SyncDataCloudToMobileScreen> createState() =>
      _SyncDataCloudToMobileScreenState();
}

class _SyncDataCloudToMobileScreenState
    extends State<SyncDataCloudToMobileScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final statuses = List.generate(
    3,
    (index) => SizedBox.square(
      dimension: 14,
      child: Center(child: Text('')),
    ),
  );

  int curIndex = -1;
  int lastIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            children: [
              SizedBox(
                height: displayHeight(context) * 0.1,
              ),
              Image.asset(
                'assets/images/cloud.png',
                height: displayHeight(context) * 0.3,
              ),
              SizedBox(
                height: displayHeight(context) * 0.08,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: commonText(
                  text: 'Restoring your data from cloud',
                  context: context,
                  textSize: displayWidth(context) * 0.055,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.08,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  child: stepperWidget(),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.08,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: commonText(
                  text:
                      'Don’t click back button while restoring data until its fully completed ',
                  context: context,
                  textSize: displayWidth(context) * 0.03,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  stepperWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: Column(
        children: [
          StatusStepper(
            connectorCurve: Curves.easeIn,
            itemCurve: Curves.easeOut,
            activeColor: Colors.black,
            disabledColor: Colors.grey,
            animationDuration: const Duration(milliseconds: 500),
            children: statuses,
            lastActiveIndex: lastIndex,
            currentIndex: curIndex,
            connectorThickness: 5,
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: commonText(
                        text: 'Fetching data\nfrom cloud',
                        context: context,
                        textSize: displayWidth(context) * 0.025,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ))),
              Expanded(
                  child: Center(
                      child: commonText(
                text: 'Data\nprocessing',
                context: context,
                textSize: displayWidth(context) * 0.025,
                textColor: Colors.black,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ))),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: commonText(
                        text: 'Data restoring\nfrom cloud',
                        context: context,
                        textSize: displayWidth(context) * 0.025,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      )))
            ],
          )
        ],
      ),
    );
  }
}
