import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/reports_module/reports.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';

import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/widgets/common_widgets.dart';
import 'custom_drawer.dart';

class BottomNavigation extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isComingFromReset, isAppKilled;
  String token;
   BottomNavigation({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset,this.token = "", this.isAppKilled = false}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  var _bottomNavIndex = 0;
  bool? isFloatBtnSelect = false;

  final iconList = [
    "assets/icons/Home.png",
    "assets/icons/reports.png",
    "assets/icons/trips.png",
    "assets/icons/vessels.png",
  ];

  final selectList = [
    "assets/icons/Home_select.png",
    "assets/icons/reports_select.png",
    "assets/icons/trips_select.png",
    "assets/icons/vessel_select.png",
  ];

  final bottomTabNames = [
    "Home",
    "Reports",
    "Trips",
    "Vessels",
  ];

  @override
  Widget build(BuildContext context) {
    var screensList = [
      HomePage(tripData: widget.tripData,tabIndex: widget.tabIndex,isComingFromReset: widget.isComingFromReset,isAppKilled: widget.isAppKilled,token: widget.token),
      ReportsModule(),
      HomePage(),
      HomePage(),
      StartTripRecordingScreen(),
    ];
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        notchMargin: 5,
        height: displayHeight(context) * 0.075,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return GestureDetector(
            onTap: (){
              isFloatBtnSelect = false;
              if(index == 0){
                setState(() {
                  _bottomNavIndex = 0;
                });
              }else if(index == 1){
                setState(() {
                  _bottomNavIndex = 1;
                });
              }else if(index == 2){
                setState(() {
                  _bottomNavIndex = 2;
                });
              }else if(index == 3){
                setState(() {
                  _bottomNavIndex = 3;
                });
              }
            },
            child:  Padding(
              padding: EdgeInsets.only(
                top: displayWidth(context) * 0.02,
                left: displayWidth(context) * 0.027,
              ),
              child: Stack(
                children: [
                  index == _bottomNavIndex ? Container(
                    width: displayWidth(context) * 0.12,
                    height: displayHeight(context) * 0.1,
                    decoration: BoxDecoration(
                        color: index == _bottomNavIndex ?  Color(0xff2663DB) : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(displayWidth(context) * 0.06))
                    ),
                  ) : SizedBox(),
                  Positioned(
                    top: displayWidth(context) * 0.01,
                    left: displayWidth(context) * 0.02,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: index != _bottomNavIndex ? AssetImage(iconList[index]) as ImageProvider : AssetImage(selectList[index]) as ImageProvider,
                          width: displayWidth(context) * 0.06,
                          height: displayHeight(context) * 0.035,
                        ),

                        commonText(
                          context: context,
                          text: bottomTabNames[index],
                          fontWeight: FontWeight.w600,
                          textColor: index == _bottomNavIndex ? Colors.white :  Colors.black87,
                          textSize: displayWidth(context) * 0.022,
                          fontFamily: reemKufi
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: commonBackgroundColor,
        activeIndex: _bottomNavIndex,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: displayWidth(context) * 0.09,
        rightCornerRadius: displayWidth(context) * 0.09,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: floatingBtnColor,
        tooltip: "Start Trip",
        foregroundColor: isFloatBtnSelect! ? floatingBtnColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the roundness
        ),
        onPressed: () {
          setState(() {
            isFloatBtnSelect = true;
            _bottomNavIndex = 4;

          });
        },
      //  child: isFloatBtnSelect! ? Icon(Icons.play_circle_filled) : Icon(Icons.play_arrow),
        child: Image.asset('assets/icons/start_btn.png',
          height: displayHeight(context) * 0.052,
          width: displayWidth(context) * 0.12,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      body: screensList[_bottomNavIndex],
    );
  }
}
