import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../common_widgets/widgets/user_feed_back.dart';
import 'bottom_navigation.dart';
import 'feedback_report.dart';

class RetiredVesselsScreen extends StatefulWidget {
  int? bottomNavIndex;
   RetiredVesselsScreen({Key? key,this.bottomNavIndex}) : super(key: key);

  @override
  State<RetiredVesselsScreen> createState() => _RetiredVesselsScreenState();
}

class _RetiredVesselsScreenState extends State<RetiredVesselsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late Future<List<CreateVessel>> getVesselFuture;

  bool isUnretire = false;

  final controller = ScreenshotController();

  late CommonProvider commonProvider;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // TODO: implement initState
    super.initState();

    getVesselFuture = _databaseService.retiredVessels();

    commonProvider = context.read<CommonProvider>();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
if(widget.bottomNavIndex==1){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
}

  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
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
            text: 'Retired Vessels',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async{
                await  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                //top: displayWidth(context) * 0.01,
              ),
              child: GestureDetector(
                  onTap: ()async{
                    final image = await controller.capture();
                                      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                      imagePath: image.toString(),
                      uIntList: image,)));
                  },
                  child: UserFeedback().getUserFeedback(context)
              ),
            ),

            SizedBox(
              height: displayWidth(context) * 0.03,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: backgroundColor,
                child: FutureBuilder<List<CreateVessel>>(
                  future: getVesselFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(circularProgressColor),
                        ),
                      );
                    }
                    Utils.customPrint('HAS DATA: ${snapshot.hasData}');
                    Utils.customPrint('HAS DATA: ${snapshot.error}');
                    Utils.customPrint('HAS DATA: ${snapshot.hasError}');
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: displayHeight(context) * 0.43),
                          child: Center(
                            child: commonText(
                                context: context,
                                text: 'No vessels available'.toString(),
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              // height: displayHeight(context),
                              color: backgroundColor,
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8, bottom: 10),
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                primary: false,
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final vessel = snapshot.data![index];
                                  return snapshot.data![index].vesselStatus == 0
                                      ? vesselSingleViewCard(context, vessel, commonProvider.loginModel!.userId!,
                                          (CreateVessel value) {},  scaffoldKey)
                                      : SizedBox();
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return Container();
                  },
                ),
              ),

              SizedBox(
                height: displayWidth(context) * 0.04,
              )
            ],
          ),
        ),
      ),
    );
  }
}
