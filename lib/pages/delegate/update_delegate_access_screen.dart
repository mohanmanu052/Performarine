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
import 'package:performarine/models/vessel_delegate_model.dart';
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
  Delegates? delegates;
  UpdateDelegateAccessScreen({super.key, this.vesselID, this.delegates});

  @override
  State<UpdateDelegateAccessScreen> createState() =>
      _UpdateDelegateAccessScreenState();
}

class _UpdateDelegateAccessScreenState
    extends State<UpdateDelegateAccessScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final controller = ScreenshotController();

  Future<CreateVessel?>? singleVesselDetails;
  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;
  List<ShareAccessModel> shareAccessModel = [];
  CreateVessel? vesselData;

  String? selectedShareUpdate;
  bool isCustomTime = false, isUpdateBtnClicked = false;

  DateTime firstDate = DateTime.now(),
      lastDate = DateTime(2100,1,1),
      focusedDay = DateTime.now(),
      startDate = DateTime.now(),
      globalStartDate = DateTime.now(),
      globalEndDate = DateTime.now();
  DateTime? selectedEndDate;

  Duration duration = const Duration();
  String startTime = '01:00 AM',
      endTime = '01:00 AM',
      endDate = '',
      selectedDuration = '24 hrs',
      startDateText = '',
      ampm = '',
      globalStartTime = '01 : 00 AM',
      globalEndTime = '01 : 00 AM';
  int calenderType = 0, hour = 0, min = 0;

  bool isCalenderVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint("VESSEL ID UPDATE DELEGATE SCREEN TIME ${widget.delegates!.toJson()}");
    debugPrint("VESSEL ID UPDATE DELEGATE SCREEN TYPE ${widget.delegates!.delegateaccessType}");
    debugPrint("VESSEL ID UPDATE DELEGATE SCREEN STATUS ${widget.delegates!.status}");
    singleVesselDetails =
        _databaseService.getVesselFromVesselID(widget.vesselID!);
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
            /*InkWell(
              onTap: () async {},
              child: Image.asset(
                'assets/images/Trash.png',
                width: Platform.isAndroid
                    ? displayWidth(context) * 0.055
                    : displayWidth(context) * 0.05,
              ),
            ),*/
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
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
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
                  margin:
                      EdgeInsets.only(bottom: displayHeight(context) * 0.14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: vesselData?.imageURLs == null ||
                                    vesselData!.imageURLs!.isEmpty ||
                                    vesselData?.imageURLs == 'string' ||
                                    vesselData?.imageURLs == '[]'
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
                                            height:
                                                displayHeight(context) * 0.14,
                                            width: displayWidth(context),
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
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
                                        height: displayHeight(context) * 0.1,
                                        width: displayWidth(context) * 0.22,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                            height:
                                                displayHeight(context) * 0.14,
                                            width:
                                                displayWidth(context) * 0.003,
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
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
                                    text: vesselData?.name ?? "",
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black87,
                                    textSize: displayWidth(context) * 0.042,
                                    fontFamily: outfit),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 2),
                                  child: Row(
                                    children: [
                                     Image.asset('assets/icons/person_icon.png', width: displayWidth(context) * 0.034,),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      commonText(
                                          context: context,
                                          text:
                                              '${widget.delegates!.delegateUserName!.trim()}',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black87,
                                          textSize:
                                              displayWidth(context) * 0.036,
                                          fontFamily: outfit),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset('assets/icons/mail_icon.png', width: displayWidth(context) * 0.04,),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    commonText(
                                        context: context,
                                        text:
                                            '${widget.delegates!.delegateUserEmail!.trim()}',
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
                              child: GridView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: shareAccessModel.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 2.5,
                                        mainAxisSpacing: 4),
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedShareUpdate =
                                            shareAccessModel[index].value;
                                        if (shareAccessModel[index].value ==
                                            "4") {
                                          isCustomTime = true;
                                          isCalenderVisible = true;
                                        } else {
                                          isCustomTime = false;
                                          isCalenderVisible = false;
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
                                            value:
                                                shareAccessModel[index].value!,
                                            groupValue: selectedShareUpdate,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedShareUpdate =
                                                    value.toString();
                                                if (selectedShareUpdate ==
                                                    "4") {
                                                  isCustomTime = true;
                                                  isCalenderVisible = true;
                                                } else {
                                                  isCalenderVisible = false;
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
                                              text: shareAccessModel[index].key,
                                              fontWeight: FontWeight.w400,
                                              textSize: displaySize(context).width * 0.031),
                                        ]),
                                  );
                                },
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
                                                isCalenderVisible = true;
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
                                                isCalenderVisible = true;

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
                                Visibility(
                                  visible: isCalenderVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: displayWidth(context) * 0.045,
                                            right:
                                                displayWidth(context) * 0.045,
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
                                                left: displayWidth(context) *
                                                    0.03,
                                                top: displayWidth(context) *
                                                    0.05),
                                            child: Text(
                                              calenderType == 0
                                                  ? "Select Start Date"
                                                  : 'Select End Date',
                                              style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.038,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: dmsans),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: displayWidth(context) * 0.045,
                                            right:
                                                displayWidth(context) * 0.045),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: calenderBackgroundColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: TableCalendar(
                                            daysOfWeekVisible: true,
                                            focusedDay: focusedDay,
                                            firstDay: firstDate,
                                            lastDay: lastDate,
                                            onFormatChanged:
                                                (CalendarFormat _format) {},
                                            calendarBuilders: CalendarBuilders(
                                              selectedBuilder:
                                                  (context, date, events) =>
                                                      Container(
                                                margin:
                                                    const EdgeInsets.all(5.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: blueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)
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
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: blueColor,
                                                    )),
                                                isTodayHighlighted: true,
                                                selectedDecoration:
                                                    BoxDecoration(
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize:
                                                        displayWidth(context) *
                                                            0.03,
                                                    fontFamily: dmsans,
                                                    color: focusedDay ==
                                                            DateTime.now()
                                                        ? Colors.white
                                                        : blueColor)),
                                            selectedDayPredicate:
                                                (DateTime date) {
                                              return isSameDay(
                                                  focusedDay, date);
                                            },
                                            startingDayOfWeek:
                                                StartingDayOfWeek.monday,
                                            onDaySelected: (DateTime? selectDay,
                                                DateTime? focusDay) {
                                              setState(() {
                                                //  focusedDay = focusDay!;
                                                if (calenderType == 0) {
                                                  focusedDay = startDate;
                                                  if (selectedEndDate != null) {
                                                    if (selectDay!.isAfter(
                                                            selectedEndDate!) ||
                                                        selectDay.isAtSameMomentAs(
                                                            selectedEndDate!)) {
                                                      Utils.showSnackBar(
                                                          context,
                                                          scaffoldKey:
                                                              scaffoldKey,
                                                          message:
                                                              'Start date should be below than end date');
                                                      return null;
                                                    } else {
                                                      isCalenderVisible = false;
                                                    }
                                                  }

                                                  startDate = selectDay!;
                                                  focusedDay = selectDay;
                                                  globalStartDate = selectDay;
                                                  startDateText =
                                                      convertIntoMonthDayYear(
                                                          selectDay);
                                                  calenderType = 1;
                                                  setState(() {});
                                                } else {
                                                  focusedDay =
                                                      selectedEndDate ??
                                                          DateTime.now();

                                                  if (selectDay!.isBefore(
                                                          startDate) ||
                                                      selectDay
                                                          .isAtSameMomentAs(
                                                              startDate!)) {
                                                    Utils.showSnackBar(context,
                                                        scaffoldKey:
                                                            scaffoldKey,
                                                        message:
                                                            'End date should be greater than start date');
                                                  } else {
                                                    selectedEndDate = selectDay;
                                                    focusedDay = selectDay;

                                                    globalEndDate = selectDay;
                                                    endDate =
                                                        convertIntoMonthDayYear(
                                                            selectDay);
                                                    isCalenderVisible = false;
                                                  }
                                                }
                                              });
                                            },
                                            headerStyle: HeaderStyle(
                                              titleCentered: true,

                                              titleTextStyle: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.032,
                                                  fontFamily: dmsans,
                                                  fontWeight: FontWeight.w600,
                                                  color: blackcolorCalender),
                                              // Center the month title

                                              formatButtonVisible: false,
                                              formatButtonDecoration:
                                                  BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(22.0),
                                              ),
                                              formatButtonTextStyle: TextStyle(
                                                  color: Colors.white),
                                              formatButtonShowsNext: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        flex: 6,
                                        fit: FlexFit.tight,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 2),
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: fromToDate(
                                              'Start Time: ', startTime),
                                        )),
                                    Flexible(
                                      flex: 4,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: fromToDate(
                                              'End Time: ', endTime)),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTimePicker(
                                      getTime: (time) {
                                        startTime = time;
                                        globalStartTime = time;
                                        setState(() {});

                                        Utils.customPrint(
                                            'the start time was $time');
                                      },
                                    ),
                                    CustomTimePicker(
                                      getTime: (time) {
                                        endTime = time;
                                        globalEndTime = time;
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
                  height: Platform.isAndroid ? displayHeight(context) / 7.9 : displayHeight(context) / 7.6,
                  width: displayWidth(context),
                  padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isUpdateBtnClicked
                          ? CircularProgressIndicator(
                              color: blueColor,
                            )
                          : CommonButtons.getActionButton(
                              title: 'Update',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              onTap: ()async {
                                if ((selectedShareUpdate ?? '').isNotEmpty) {
                                  if (selectedShareUpdate == '4') {
                                    if (globalStartDate.toString().isEmpty) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please select start date');
                                      return null;
                                    }
                                    if (globalEndDate.toString().isEmpty) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please select end date');
                                      return null;
                                    }
                                    if (globalStartTime.isEmpty) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please select start time');
                                      return null;
                                    }
                                    if (globalEndTime.isEmpty) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please select end time');
                                      return null;
                                    }
                                  }


                                  Map<String, dynamic>? body;
                                  if (selectedShareUpdate == "4") {
                                    body = {
                                      "delegateID": widget.delegates!.id,
                                      "delegateAccessType": int.parse(selectedShareUpdate!),
                                      "fromDate": convertIntoUTCFormat(globalStartDate, globalStartTime),
                                      "toDate": convertIntoUTCFormat(
                                          globalEndDate, globalEndTime)
                                    };
                                    debugPrint("IF EXECUTED ${convertIntoUTCFormat(globalStartDate, globalStartTime)}");
                                    debugPrint("IF EXECUTED ${convertIntoUTCFormat(
                                        globalEndDate, globalEndTime)}");
                                  } else {
                                    body = {
                                      "delegateID": widget.delegates!.id,
                                      "delegateAccessType": int.parse(selectedShareUpdate!),
                                    };
                                  }

                                  debugPrint("UPDATE DELEGATE BODY $body");

                                  setState(() {
                                    isUpdateBtnClicked = true;
                                  });

                                  // bool? isSyncToCloud = await getVesselDataSyncToCloud();

                            commonProvider
                                .manageDelegate(
                                context,
                                commonProvider.loginModel!.token!,
                                body,
                                scaffoldKey)
                                .then((value) {
                              if (value != null) {
                                if (value.status!) {
                                  setState(() {
                                    isUpdateBtnClicked =
                                    false;
                                  });

                                  Navigator.of(context).pop(true);
                                } else {
                                  setState(() {
                                    isUpdateBtnClicked =
                                    false;
                                  });
                                }
                              } else {
                                setState(() {
                                  isUpdateBtnClicked = false;
                                });
                              }
                            }).catchError((e) {
                              setState(() {
                                isUpdateBtnClicked = false;
                              });
                            });
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

  String convertIntoUTCFormat(DateTime? date, String? time) {
    debugPrint("SELECTED UTC Form TIME  ${time}");
    if (date != null && (time != null && time.isNotEmpty)) {
      hour = int.parse(time.split(' : ').first);
      min = int.parse(time.split(' : ').last.split(' ').first);
      ampm = time.split(' : ').last.split(' ').last;

      TimeOfDay startTime =
          TimeOfDay(hour: ampm == 'PM' ? hour + 12 : hour, minute: min);

      DateTime utcDateTime = DateTime(date.year, date.month, date.day,
          startTime.hour, startTime.minute, 00);

      debugPrint("SELECTED DATE ${date}");
      debugPrint("SELECTED DATE ${time}");
      debugPrint("SELECTED DATE ${utcDateTime}");

      return utcDateTime.toUtc().toString();
    } else {
      return '';
    }
  }

  Widget fromToDate(String title, String date) {
    return Container(
      alignment: Alignment.centerLeft,
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

    if(widget.delegates!.delegateaccessType != null || widget.delegates!.delegateaccessType!.isNotEmpty)
      {
        ShareAccessModel firstWhere = shareAccessModel.firstWhere((element) => element.value == widget.delegates!.delegateaccessType.toString());
        setState(() {
          selectedShareUpdate = firstWhere.value;
        });

        debugPrint("CUSTOM TIME TT ${selectedShareUpdate == "4"}");

        if(selectedShareUpdate == "4")
          {
            setState(() {
              isCustomTime = true;
              isCalenderVisible = true;
            });
          }
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
