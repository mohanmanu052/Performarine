import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/reports_module/reports.dart';
import 'package:screenshot/screenshot.dart';

class FleetReports extends StatefulWidget {
  int? bottomNavIndex;
   FleetReports({super.key,this.bottomNavIndex});

  @override
  State<FleetReports> createState() => _FleetReportsState();
}

class _FleetReportsState extends State<FleetReports> {
    ScreenshotController screen_shot_controller = ScreenshotController();

    @override
  void initState() {
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);


    // TODO: implement initState
    super.initState();
  }

@override
  void dispose() {
    if(widget.bottomNavIndex==1){

    }else{
              SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

    }
    // TODO: implement dispose
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(widget.bottomNavIndex==1){
          Navigator.pop(context);
        }else{
                        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
          Navigator.pop(context);

        }
return Future.value(true);
      },
      child: Screenshot(
        controller: screen_shot_controller,
        child: Scaffold(
                  backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
if(widget.bottomNavIndex==1){

}else{
                                          SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);


}

                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              centerTitle: false,
              title: commonText(
                  context: context,
                  
                  text: 'Fleet Reports',
                  fontWeight: FontWeight.w600,
                  textColor: Colors.black,
                  textSize: 18,
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
        
          body: Column(
        children: [
        Expanded(child: ReportsModule(isTypeFleet: true,
        onScreenShotCaptureCallback: (() {
          captureScreenShot();
        }),
        
        
        ))
        ],
          
        ),
          
        ),
      ),
    );
  }

    void captureScreenShot() async {
    final image = await screen_shot_controller.capture();
    Utils.customPrint("Image is: ${image.toString()}");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FeedbackReport(
                  imagePath: image.toString(),
                  uIntList: image,
                )));
  }


}