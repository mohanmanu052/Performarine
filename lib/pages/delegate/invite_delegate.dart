import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_time_picker.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/common_widgets/widgets/vessel_info_card.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/delegate/delegates_screen.dart';
import 'package:performarine/pages/delegate/my_delegate_invites_screen.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:table_calendar/table_calendar.dart';

class InviteDelegate extends StatefulWidget {
  String? vesselID;
  InviteDelegate({super.key, this.vesselID});

  @override
  State<InviteDelegate> createState() => _InviteDelegateState();
}

class _InviteDelegateState extends State<InviteDelegate> {
  final controller = ScreenshotController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late Future<List<CreateVessel>> getVesselFuture;
  List<CreateVessel>? getVesselSyncToCloud;
  bool isCalenderVisible = false;

  CreateVessel? vesselData;
  final DatabaseService _databaseService = DatabaseService();
  DateTime firstDate = DateTime.now(),
      lastDate = DateTime(2100),
      focusedDay = DateTime.now(),
      startDate = DateTime.now(),
      globalStartDate = DateTime.now(),
      globalEndDate = DateTime.now();
  DateTime? selectedEndDate;

  Duration duration = const Duration();
  bool isCustomTime = false, isInviteDelegateBtnClicked = false;
  String startTime = '01:00 AM',
      endTime = '01:00 AM',
      endDate = '',
      selectedDuration = '24 hrs',
      startDateText = '', startDateUtc = '', endDateUtc = '', globalStartTime = '', globalEndTime = '', ampm = '';
  int calenderType = 0, hour = 0, min = 0;
  String? selectedShareUpdate;

  TextEditingController userEmailController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  late CommonProvider commonProvider;
  List<ShareAccessModel> shareAccessModel = [];

  Future<CreateVessel?>? singleVesselDetails;

  @override
  void initState() {
    debugPrint("VESSEL ID INVITE DELEGATE SCREEN ${widget.vesselID}");
    singleVesselDetails =
        _databaseService.getVesselFromVesselID(widget.vesselID!);
    singleVesselDetails!.then((value) {
      vesselData = value;
      setState(() {});
    });

    commonProvider = context.read<CommonProvider>();

    getShareAccessData();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Screenshot(
        controller: controller,
        child: Scaffold(
            backgroundColor: backgroundColor,
            key: scaffoldKey,
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
                  text: 'Send Invite',
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
                        ? displayWidth(context) * 0.065
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
                child: Stack(children: [
//vesselSingleViewCard(context,CreateVessel(),((p0) {} ),scaffoldKey),

              Container(
                margin: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: displayHeight(context) / 7,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      if (vesselData != null)
                        Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            width: displayWidth(context),
                            //height: displayHeight(context)*0.2,

                            child: VesselinfoCard(
                              vesselData: vesselData,
                            )),
                      SizedBox(
                        height: displayHeight(context) * 0.025,
                      ),
                      commonText(
                          text: 'Invite Delegate',
                          fontWeight: FontWeight.w700,
                          textSize: displayWidth(context) * 0.045),
                      SizedBox(
                        height: displayHeight(context) * 0.025,
                      ),
                      SizedBox(
                        width: displayWidth(context) / 1.1,
                        child: Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: CommonTextField(
                              controller: userEmailController,
                              // focusNode: nameFocusNode,
                              labelText: 'Email ID',
                              hintText: '',
                              circularRadius: 20,
                              suffixText: null,
                              fillColor: dropDownBackgroundColor,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 32,
                              prefixIcon: null,
                              suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      userEmailController.clear();
                                    });
                                  },
                                  child: Icon(Icons.close)),
                              requestFocusNode: null,
                              obscureText: false,
                              onTap: () {},
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Your Email';
                                }
                                if (!EmailValidator.validate(value)) {
                                  return 'Enter Valid Email';
                                } else if (EmailValidator.validate(value)) {
                                  String emailExt = value.split('.').last;

                                  if (!['com', 'in', 'us'].contains(emailExt)) {
                                    return 'Enter Valid Email';
                                  }
                                }
                                return null;
                              },
                              onSaved: (String value) {}),
                        ),
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
                                              textSize: 12),
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
                                              color:
                                                  calenderHeaderBackgroundColor,
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
                                                  startDateText = convertIntoMonthDayYear(selectDay);
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
                                                    endDate = convertIntoMonthDayYear(selectDay);
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
                  alignment: Alignment.bottomCenter,
                  height: displayHeight(context) / 7.9,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isInviteDelegateBtnClicked
                          ? CircularProgressIndicator(
                              color: blueColor,
                            )
                          : CommonButtons.getActionButton(
                              title: 'Invite Delegate',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  if ((selectedShareUpdate ?? '').isNotEmpty) {
                                    if (commonProvider.loginModel!.userEmail!
                                            .toLowerCase() !=
                                        userEmailController.text
                                            .toLowerCase()) {
                                      if (selectedShareUpdate == '4') {
                                        if (globalStartDate.toString().isEmpty) {
                                          Utils.showSnackBar(context,
                                              scaffoldKey: scaffoldKey,
                                              message:
                                                  'Please select start date');
                                          return null;
                                        }
                                        if (globalEndDate.toString().isEmpty) {
                                          Utils.showSnackBar(context,
                                              scaffoldKey: scaffoldKey,
                                              message:
                                                  'Please select end date');
                                          return null;
                                        }
                                      }

                                      debugPrint("IF EXECUTED");
                                      Map<String, dynamic>? body;
                                      if (selectedShareUpdate == "4") {
                                        body = {
                                          "vesselID": widget.vesselID,
                                          "userEmail":
                                              userEmailController.text.trim(),
                                          "delegateAccessType":
                                              selectedShareUpdate,
                                          "fromDate": convertIntoUTCFormat(globalStartDate, globalStartTime),
                                          "toDate": convertIntoUTCFormat(globalEndDate, globalEndTime),
                                        };
                                      } else {
                                        body = {
                                          "vesselID": widget.vesselID,
                                          "userEmail":
                                              userEmailController.text.trim(),
                                          "delegateAccessType":
                                              selectedShareUpdate
                                        };
                                      }

                                      setState(() {
                                        isInviteDelegateBtnClicked = true;
                                      });
                                      bool? isSyncToCloud =
                                          await getVesselDataSyncToCloud();
                                      commonProvider
                                          .createDelegate(
                                              context,
                                              commonProvider.loginModel!.token!,
                                              body,
                                              scaffoldKey)
                                          .then((value) {
                                        if (value != null) {
                                          if (value.status!) {
                                            setState(() {
                                              isInviteDelegateBtnClicked =
                                                  false;
                                            });

                                            Navigator.of(context).pop(true);
                                          } else {
                                            setState(() {
                                              isInviteDelegateBtnClicked =
                                                  false;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            isInviteDelegateBtnClicked = false;
                                          });
                                        }
                                      }).catchError((e) {
                                        setState(() {
                                          isInviteDelegateBtnClicked = false;
                                        });
                                      });
                                    } else {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message:
                                              'You cannot send an invitation to your own account.');
                                    }
                                  } else {
                                    Utils.showSnackBar(context,
                                        scaffoldKey: scaffoldKey,
                                        message:
                                            'Please select access duration.');
                                  }
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
            ]))));
  }

  Widget radioButton(String text, bool isCustomTime1) {
    return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: Row(children: [
          Radio(
            value: text,
            groupValue: selectedDuration,
            onChanged: (value) {
              setState(() {
                if (isCustomTime1) {
                  isCustomTime = true;
                  isCalenderVisible = true;
                } else {
                  isCustomTime = false;
                  isCalenderVisible = false;
                }
                selectedDuration = value.toString();
              });
            },
          ),
          commonText(text: text, fontWeight: FontWeight.w400, textSize: 12),
        ]));
  }

  Widget fromToDate(
    String title,
    String date,
  ) {
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

  String convertIntoMonthDayYear(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);

    return dateString;
  }

  String convertIntoUTCFormat(DateTime? date, String? time) {

    if(date != null && time != null)
      {
        hour = int.parse(time.split(' : ').first);
        min = int.parse(time.split(' : ').last.split(' ').first);
        ampm = time.split(' : ').last.split(' ').last;

        TimeOfDay startTime = TimeOfDay(hour: ampm == 'PM' ? hour + 12 : hour, minute: min);

        DateTime utcDateTime = DateTime(date.year, date.month,date.day, startTime.hour, startTime.minute,00);

        debugPrint("SELECTED DATE ${date}");
        debugPrint("SELECTED DATE ${time}");
        debugPrint("SELECTED DATE ${utcDateTime}");

        return utcDateTime.toUtc().toString();
      }
    else
      {
        return '';
      }

  }

  Future<bool>? getVesselDataSyncToCloud() async {
    var vesselsSyncDetails = await _databaseService.vesselsSyncDetails();
    if (vesselsSyncDetails) {
      getVesselSyncToCloud = await _databaseService
          .syncAndSignOutVesselList()
          .catchError((onError) {});

      for (int i = 0; i < getVesselSyncToCloud!.length; i++) {
        var vesselSyncOrNot = getVesselSyncToCloud![i].isSync;
        Utils.customPrint(
            "VESSEL SUCCESS MESSAGE ${getVesselSyncToCloud![i].imageURLs}");

        if (vesselSyncOrNot == 0) {
          if (getVesselSyncToCloud![i].imageURLs != null &&
              getVesselSyncToCloud![i].imageURLs!.isNotEmpty) {
            if (getVesselSyncToCloud![i].imageURLs!.startsWith("https")) {
              getVesselSyncToCloud![i].selectedImages = [];
            } else {
              getVesselSyncToCloud![i].selectedImages = [
                File(getVesselSyncToCloud![i].imageURLs!)
              ];
            }

            Utils.customPrint(
                'VESSEL Data ${File(getVesselSyncToCloud![i].imageURLs!)}');
          } else {
            getVesselSyncToCloud![i].selectedImages = [];
          }

          await commonProvider
              .addVessel(
            context,
            getVesselSyncToCloud![i],
            commonProvider.loginModel!.userId!,
            commonProvider.loginModel!.token!,
            scaffoldKey,
          )
              .then((value) async {
            if (value!.status!) {
              await _databaseService.updateIsSyncStatus(
                  1, getVesselSyncToCloud![i].id.toString());
            } else {
              setState(() {
                //vesselErrorOccurred = true;
              });
            }
          }).catchError((error) {
            Utils.customPrint("ADD VESSEL ERROR $error");
            setState(() {
              //vesselErrorOccurred = true;
            });
          });
        } else {
          Utils.customPrint("VESSEL DATA NOT Uploaded");
        }
      }

      setState(() {});

      return Future.value(true);
    } else {
      return Future.value(false);
    }
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

class ShareAccessModel {
  String? key, value;
  ShareAccessModel(this.key, this.value);

  ShareAccessModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }
}
