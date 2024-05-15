import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/common_widgets/widgets/vessel_info_card.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/services/database_service.dart';
import 'package:screenshot/screenshot.dart';

class LPRTripsData extends StatefulWidget {
  const LPRTripsData({super.key});

  @override
  State<LPRTripsData> createState() => _LPRTripsDataState();
}

class _LPRTripsDataState extends State<LPRTripsData> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<String> sensorsList = ['Boat1', 'Boat2', 'Boat3',];
  String dropdownValue = 'Boat1';

  final DatabaseService _databaseService = DatabaseService();
  CreateVessel? vesselData;
  late Future<List<CreateVessel>> getVesselFuture;

  final controller = ScreenshotController();

  List multipleSelected = [];
  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 1,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 2,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 3,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 4,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 5,
      "value": false,
      "title": "MM-DD-YY Trip Recording file",
    },
    {
      "id": 6,
      "value": false,
      "title": "MM-DD-YY Trip Recording file 1",
    },
  ];

  @override
  void initState() {
    getVesselFuture = _databaseService.vessels();
      getVesselFuture.then((value) {
        vesselData = value[0];
        setState(() {});
      });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: backgroundColor,
          title: commonText(
              context: context,
              text: 'LPR Trips Data',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.045,
              fontFamily: outfit),
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon:
                Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(bottom: displayHeight(context) * 0.22),
                  child: Column(
                    children: [
                      SizedBox(height: displayHeight(context) * 0.02),

                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: dropDownBackgroundColor
                        ),
                        child: DropdownButtonFormField<String>(
                          value: dropdownValue,
                          hint: commonText(
                              text: 'Select Boat',
                              context: context,
                              textSize:displayWidth(context) * 0.045,
                              textColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: sensorsList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child:  commonText(
                                  text: item ?? '',
                                  context: context,
                                  textSize: displayWidth(context) * 0.04,
                                  textColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w400),

                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Select Boat';
                            }
                            return null;
                          },

                          // add extra sugar..
                          icon: Icon(
                              Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          //underline: SizedBox(),
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10),
                        ),
                      ),

                      vesselData != null
                          ? Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          width: displayWidth(context),
                          //height: displayHeight(context)*0.2,
                          child: VesselinfoCard(
                            vesselData: vesselData,
                          ))
                      : SizedBox(),

                      SizedBox(height: displayHeight(context) * 0.02),

                      Column(
                        children: List.generate(
                          checkListItems.length,
                              (index) {
                            return Column(
                              children: [
                                CheckboxListTile(
                                  activeColor: blueColor,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: commonText(
                                      context: context,
                                      text: checkListItems[index]["title"],
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black87,
                                      textSize: displayWidth(context) * 0.038,
                                      fontFamily: outfit,
                                      textAlign: TextAlign.start),
                                  value: checkListItems[index]["value"],
                                  onChanged: (value) {
                                    setState(() {
                                      checkListItems[index]["value"] = value;
                                      if (multipleSelected.contains(checkListItems[index])) {
                                        multipleSelected.remove(checkListItems[index]);
                                      } else {
                                        multipleSelected.add(checkListItems[index]);
                                      }
                                    });
                                  },
                                ),
                                Divider(
                                  color: Colors.grey,
                                )
                              ],
                            );
                              },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: displayWidth(context),
                  alignment: Alignment.bottomCenter,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          CommonButtons.getActionButton(
                              title: 'Download',
                              context: context,
                              fontSize: displayWidth(context) * 0.038,
                              textColor: Colors.white,
                              buttonPrimaryColor:blueColor,
                              borderColor: blueColor ,
                              width: displayWidth(context) ,
                              onTap:  (){
                              }),

                          SizedBox(height: displayHeight(context) * 0.01,),
                          CommonButtons.getActionButton(
                              title: 'Sync to cloud',
                              context: context,
                              fontSize: displayWidth(context) * 0.038,
                              textColor: blueColor,
                              buttonPrimaryColor: dropDownBackgroundColor,
                              borderColor:dropDownBackgroundColor,
                              width: displayWidth(context) ,
                              onTap:  (){
                              }),
                        ],
                      ),

                      GestureDetector(
                          onTap: ()async{
                            final image = await controller.capture();

                            Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                              imagePath: image.toString(),
                              uIntList: image,)));
                          },
                          child: UserFeedback().getUserFeedback(context)
                      ),
                      SizedBox(height: 4,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
