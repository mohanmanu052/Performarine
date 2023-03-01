import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

class SyncDataCloudToMobileScreen extends StatefulWidget {
  const SyncDataCloudToMobileScreen({Key? key}) : super(key: key);

  @override
  State<SyncDataCloudToMobileScreen> createState() =>
      _SyncDataCloudToMobileScreenState();
}

class _SyncDataCloudToMobileScreenState
    extends State<SyncDataCloudToMobileScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            children: [
              Image.asset(
                'assets/images/cloud.png',
                height: displayHeight(context) * 0.4,
                width: displayWidth(context),
              ),
              commonText(
                text: 'Restoring your data from cloud',
                context: context,
                textSize: displayWidth(context) * 0.06,
                textColor: Colors.black,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
