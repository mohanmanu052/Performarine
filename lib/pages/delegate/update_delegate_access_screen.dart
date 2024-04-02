import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_time_picker.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/delegate/invite_delegate.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:table_calendar/table_calendar.dart';

class UpdateDelegateAccessScreen extends StatefulWidget {
  String? vesselID;
  UpdateDelegateAccessScreen({super.key, this.vesselID});

  @override
  State<UpdateDelegateAccessScreen> createState() => _UpdateDelegateAccessScreenState();
}

class _UpdateDelegateAccessScreenState extends State<UpdateDelegateAccessScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final controller = ScreenshotController();

  Future<CreateVessel?>? singleVesselDetails;
  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;
  List<ShareAccessModel> shareAccessModel = [];
  CreateVessel? vesselData;

  String? selectedShareUpdate;
  bool isCustomTime = false, isUpdateBtnClicked = false;

  String startTime = '01:00 AM',
      endTime = '01:00 AM',
      endDate = '',
      selectedDuration = '24 hrs',
      startDateText = '';
  int calenderType = 0;

  DateTime firstDate = DateTime(1980),
      lastDate = DateTime.now(),
      focusedDay = DateTime.now(),
      startDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    singleVesselDetails = _databaseService.getVesselFromVesselID(widget.vesselID!);
    singleVesselDetails!.then((value) {
      vesselData = value;
      setState(() {});
    });

    commonProvider = context.read<CommonProvider>();

    getShareAccessData();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
              context: context,
              text: 'Manage Access',
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              textSize: displayWidth(context) * 0.042,
              fontFamily: outfit),
          actions: [
            InkWell(
                    onTap: () async {},
                    child: Image.asset(
                      'assets/images/Trash.png',
                      width: Platform.isAndroid
                          ? displayWidth(context) * 0.055
                          : displayWidth(context) * 0.05,
                    ),
                  ),
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
                icon: Image.asset(
                    'assets/icons/performarine_appbar_icon.png'),
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
                  margin: EdgeInsets.only(bottom: displayHeight(context) * 0.14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: vesselData!.imageURLs == null ||
                                vesselData!.imageURLs!.isEmpty ||
                                vesselData!.imageURLs == 'string' ||
                                vesselData!.imageURLs == '[]'
                                ? Stack(
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Image.asset(
                                    'assets/images/vessel_default_img.png',
                                    height: displayHeight(context) * 0.1,
                                    width: displayWidth(context) * 0.22,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      height: displayHeight(context) * 0.14,
                                      width: displayWidth(context),
                                      padding: const EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.1),
                                            blurRadius: 50,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 50))
                                      ]),
                                    ))
                              ],
                            )
                                : Stack(
                              children: [
                                Container(
                                  height: displayHeight(context) * 0.22,
                                  width: displayWidth(context),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: FileImage(
                                          File(vesselData!.imageURLs!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      height: displayHeight(context) * 0.14,
                                      width: displayWidth(context),
                                      padding: const EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 50,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 50))
                                      ]),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: vesselData!.name,
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black87,
                                    textSize: displayWidth(context) * 0.042,
                                    fontFamily: outfit),

                                Row(
                                  children: [
                                    Icon(Icons.person_2_outlined, color: blueColor, ),
                                    SizedBox(width: 4,),
                                    commonText(
                                        context: context,
                                        text: 'Abhiram Pawan',
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.black87,
                                        textSize: displayWidth(context) * 0.036,
                                        fontFamily: outfit),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(Icons.mail_lock_outlined, color: blueColor,size: displayWidth(context) * 0.05, ),
                                    SizedBox(width: 4,),
                                    commonText(
                                        context: context,
                                        text: 'abhiram90@gmail.com',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black87,
                                        textSize: displayWidth(context) * 0.036,
                                        fontFamily: outfit),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        child: commonText(
                            text: 'Share Access upto',
                            textSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.005,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: displayHeight(context) * 0.14,
                              width: displayWidth(context),
                              child: Wrap(
                                runSpacing: 4,
                                spacing: 2,
                                children: shareAccessModel.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedShareUpdate = e.value;
                                          if (e.value == "4") {
                                            isCustomTime = true;
                                          } else {
                                            isCustomTime = false;
                                          }
                                        });
                                        debugPrint(
                                            "SELECTED VALUE 1 ${selectedShareUpdate}");
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Radio<String>(
                                              value: e.value!,
                                              groupValue: selectedShareUpdate,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedShareUpdate =
                                                      value.toString();
                                                  if (selectedShareUpdate ==
                                                      "4") {
                                                    isCustomTime = true;
                                                  } else {
                                                    isCustomTime = false;
                                                  }
                                                });
                                                debugPrint(
                                                    "SELECTED VALUE 1 ${selectedShareUpdate}");
                                                debugPrint(
                                                    "SELECTED VALUE 2 ${value}");
                                              },
                                            ),
                                            commonText(
                                                text: e.key,
                                                fontWeight: FontWeight.w400,
                                                textSize: 12),
                                          ]),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.015,
                            ),
                            Visibility(
                              visible: isCustomTime,
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 6,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: InkWell(
                                              onTap: () {
                                                calenderType = 0;
                                                setState(() {});
                                              },
                                              child: fromToDate('From Date: ',
                                                  startDateText))),
                                    ),
                                    Flexible(
                                      flex: 4,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: InkWell(
                                              onTap: () {
                                                calenderType = 1;
                                                setState(() {});
                                              },
                                              child: fromToDate(
                                                  'To Date: ', endDate))),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.01,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: displayWidth(context) * 0.045,
                                      right: displayWidth(context) * 0.045,
                                      top: 8,
                                      bottom: 8),
                                  child: Container(
                                    width: displayWidth(context),
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: calenderHeaderBackgroundColor,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                            30,
                                          ),
                                          topLeft: Radius.circular(
                                            30,
                                          ),
                                        )),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: displayWidth(context) * 0.03,
                                          top: displayWidth(context) * 0.05),
                                      child: Text(
                                        calenderType == 0
                                            ? "Select Start Date"
                                            : 'Select End Date',
                                        style: TextStyle(
                                            fontSize:
                                            displayWidth(context) * 0.038,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: dmsans),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: displayWidth(context) * 0.045,
                                      right: displayWidth(context) * 0.045),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: calenderBackgroundColor,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Visibility(
                                      // visible: !isEndDateSected!,
                                      child: TableCalendar(
                                        daysOfWeekVisible: true,
                                        focusedDay: startDate,
                                        firstDay: firstDate,
                                        lastDay: lastDate,
                                        onFormatChanged:
                                            (CalendarFormat _format) {},
                                        calendarBuilders: CalendarBuilders(
                                          selectedBuilder:
                                              (context, date, events) =>
                                              Container(
                                                margin: const EdgeInsets.all(5.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: blueColor,
                                                    borderRadius:
                                                    BorderRadius.circular(15)
                                                  //shape: BoxShape.circle

                                                ),
                                                child: commonText(
                                                    context: context,
                                                    text: date.day.toString(),
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.042,
                                                    fontFamily: dmsans),
                                              ),
                                        ),
                                        calendarStyle: CalendarStyle(
                                            todayDecoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: blueColor,
                                                )),
                                            isTodayHighlighted: true,
                                            selectedDecoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(8),

                                              // color: blueColor,
                                              shape: BoxShape.rectangle,
                                            ),
                                            selectedTextStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                displayWidth(context) *
                                                    0.032,
                                                fontFamily: dmsans,
                                                color: Colors.pink),
                                            todayTextStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize:
                                                displayWidth(context) *
                                                    0.03,
                                                fontFamily: dmsans,
                                                color:
                                                focusedDay == DateTime.now()
                                                    ? Colors.white
                                                    : blueColor)),
                                        selectedDayPredicate: (DateTime date) {
                                          return isSameDay(startDate, date);
                                        },
                                        startingDayOfWeek:
                                        StartingDayOfWeek.monday,
                                        onDaySelected: (DateTime? selectDay,
                                            DateTime? focusDay) {
                                          setState(() {
                                            focusedDay = focusDay!;
                                            startDate = selectDay!;
                                            if (calenderType == 0) {
                                              startDateText =
                                                  convertIntoMonthDayYear(
                                                      selectDay);
                                              calenderType = 1;
                                              setState(() {});
                                            } else {
                                              endDate = convertIntoMonthDayYear(
                                                  selectDay);
                                            }
                                          });
                                        },
                                        headerStyle: HeaderStyle(
                                          titleCentered: true,

                                          titleTextStyle: TextStyle(
                                              fontSize:
                                              displayWidth(context) * 0.032,
                                              fontFamily: dmsans,
                                              fontWeight: FontWeight.w600,
                                              color: blackcolorCalender),
                                          // Center the month title

                                          formatButtonVisible: false,
                                          formatButtonDecoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                            BorderRadius.circular(22.0),
                                          ),
                                          formatButtonTextStyle:
                                          TextStyle(color: Colors.white),
                                          formatButtonShowsNext: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 8),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child:
                                      fromToDate('Start Time: ', startTime),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(right: 8),
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child:
                                        fromToDate('End Time: ', endTime)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTimePicker(
                                      getTime: (time) {
                                        startTime = time;
                                        setState(() {});

                                        Utils.customPrint(
                                            'the start time was $time');
                                      },
                                    ),
                                    CustomTimePicker(
                                      getTime: (time) {
                                        endTime = time;
                                        setState(() {});
                                        Utils.customPrint(
                                            'the end time was $time');
                                      },
                                    )
                                  ],
                                )
                              ]),
                            )
                          ])
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.bottomCenter,
                  height: displayHeight(context) / 7.9,
                  width: displayWidth(context),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isUpdateBtnClicked
                          ? CircularProgressIndicator()
                          : CommonButtons.getActionButton(
                        title: 'Update',
                        context: context,
                        fontSize: displayWidth(context) * 0.044,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        onTap: () {
                          if((selectedShareUpdate ?? '').isNotEmpty)
                          {

                            /*setState(() {
                              isUpdateBtnClicked = true;
                            });*/

                          }
                        },
                        width: displayWidth(context) / 1.3,
                      ),
                      GestureDetector(
                          onTap: (() async {
                            final image = await controller.capture();
                            await SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeedbackReport(
                                      imagePath: image.toString(),
                                      uIntList: image,
                                    )));
                          }),
                          child: UserFeedback().getUserFeedback(
                            context,
                          )),
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

  String convertIntoMonthDayYear(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);

    return dateString;
  }

  Widget fromToDate(String title, String date) {
    return Container(
      // color: Colors.amber,
      child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: title,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: displayWidth(context) * 0.03,
                    fontFamily: outfit,
                    color: Colors.black)),
            WidgetSpan(
                child: SizedBox(
                  width: 5,
                )),
            TextSpan(
                text: date,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: displayWidth(context) * 0.03,
                    fontFamily: outfit,
                    color: blueColor)),
          ])),
    );
  }

  void getShareAccessData() async {
    FirebaseRemoteConfig data = await setupRemoteConfig();
    String shareAccessData = data.getString('share_access_data');

    Utils.customPrint('VINNNNNNNNNNNNNNN ${jsonDecode(shareAccessData)}');
    var decodedData = jsonDecode(shareAccessData);
    //readData();

    for (Map<String, dynamic> data in decodedData["share_access_data"]) {
      shareAccessModel.add(ShareAccessModel.fromJson(data));
    }
    Utils.customPrint('LIST LENGTH ${shareAccessModel.length}');
    setState(() {});
  }

  Future<FirebaseRemoteConfig> setupRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }
}
