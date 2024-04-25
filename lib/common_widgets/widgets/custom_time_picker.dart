import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

/// This helper widget manages the scrollable content inside a picker widget.
class CustomTimePicker extends StatefulWidget {
  Function(String time)? getTime;
  DateTime? selectedDate;
  CustomTimePicker({super.key, this.getTime, this.selectedDate});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late CommonProvider commonProvider;

  // Constants
  var hour = 01;
  var minute = 00;
  var timeFormat = "AM";
  String formattedHour = '01';
  String formattedMinute = '00';
  var minHour = 01, minMinute = 00;

  @override
  void initState() {
    super.initState();
      // hour = DateTime.now().hour > 12
      //     ? DateTime.now().hour - 12
      //     : DateTime.now().hour;
      // minHour = DateTime.now().hour > 12
      //     ? DateTime.now().hour - 12
      //     : DateTime.now().hour;
      // minute = DateTime.now().minute;
      

    // if (checkIfDateIsSame()) {
    //   hour = DateTime.now().hour > 12
    //       ? DateTime.now().hour - 12
    //       : DateTime.now().hour;
    //   minHour = DateTime.now().hour > 12
    //       ? DateTime.now().hour - 12
    //       : DateTime.now().hour;
    //   minute = DateTime.now().minute;
    //   minMinute = DateTime.now().minute;
    // } else {
    //   hour = 01;
    //   minHour = 01;
    //   minute = 00;
    //   minMinute = 00;
    // }

    // commonProvider = context.read<CommonProvider>();
    // commonProvider.resetCustomTimePicker = () {
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     setState(() {
    //       print('CHECK IF:${checkIfDateIsSame()}');
    //       print('CHECK IF:${widget.selectedDate}');
    //       if (checkIfDateIsSame()) {
    //         if (DateTime.now().hour > hour) {
    //           hour = DateTime.now().hour > 12
    //               ? DateTime.now().hour - 12
    //               : DateTime.now().hour;
    //           minHour = DateTime.now().hour > 12
    //               ? DateTime.now().hour - 12
    //               : DateTime.now().hour;
    //         } else {
    //           hour = 01;
    //           minHour = 01;
    //         }

    //         if (DateTime.now().minute > minute) {
    //           minute = DateTime.now().minute;
    //           minMinute = DateTime.now().minute;
    //         } else {
    //           minute = 00;
    //           minMinute = 00;
    //         }

    //         if (hour < 10) {
    //           formattedHour = hour.toString().padLeft(2, '0');
    //         } else {
    //           formattedHour = hour.toString();
    //         }

    //         if (minute < 10) {
    //           formattedMinute = minute.toString().padLeft(2, '0');
    //         } else {
    //           formattedMinute = minute.toString();
    //         }

    //         widget.getTime!(
    //             '$formattedHour : $formattedMinute $timeFormat');
    //       } else {
    //         hour = 01;
    //         minHour = 01;
    //         minute = 00;
    //         minMinute = 00;

    //         if (hour < 10) {
    //           formattedHour = hour.toString().padLeft(2, '0');
    //         } else {
    //           formattedHour = hour.toString();
    //         }

    //         if (minute < 10) {
    //           formattedMinute = minute.toString().padLeft(2, '0');
    //         } else {
    //           formattedMinute = minute.toString();
    //         }

    //         widget.getTime!(
    //             '$formattedHour : $formattedMinute $timeFormat');
    //       }
    //     });
    //   });
    // };
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              NumberPicker(
                minValue: 01,
                maxValue: 12,
                value: hour,
                zeroPad: true,
                infiniteLoop: true,
                itemWidth: 50,
                itemHeight: 45,
                onChanged: (value) {

                  if(value >= minHour){
                    if (value < 10) {
                      formattedHour = value.toString().padLeft(2, '0');
                    } else {
                      formattedHour = value.toString();
                    }
                    setState(() {
                      hour = value;

                      widget.getTime!(
                          '$formattedHour : $formattedMinute $timeFormat');
                    });
                  }

                },
                textStyle: const TextStyle(
                    color: colorlightBlueTimePickerUnselecetd,
                    fontSize: 16,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                decoration: const BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //       color: Colors.white,
                  //     ),
                  //     bottom: BorderSide(color: Colors.white)

                  //  ),
                ),
              ),
              Container(
                child: Text(
                  ':',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              NumberPicker(
                minValue: 00,
                maxValue: 59,
                value: minute,
                zeroPad: true,
                infiniteLoop: true,
                itemWidth: 50,
                itemHeight: 45,
                onChanged: (value) {
                  if(value >= minMinute){
                    if (value < 10) {
                      formattedMinute = value.toString().padLeft(2, '0');
                    } else {
                      formattedMinute = value.toString();
                    }

                    setState(() {
                      minute = value;
                      widget.getTime!(
                          '$formattedHour : $formattedMinute $timeFormat');
                    });
                  }
                },
                textStyle: const TextStyle(
                    color: colorlightBlueTimePickerUnselecetd,
                    fontSize: 16,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                decoration: const BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //       color: Colors.white,
                  //     ),
                  //     bottom: BorderSide(color: Colors.white)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.getTime!('$formattedHour : $formattedMinute AM');

                      setState(() {
                        timeFormat = "AM";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: timeFormat == "AM"
                            ? blueColor
                            : selectDayBackgroundColor,
                        // border: Border.all(
                        //   color: timeFormat == "AM"
                        //       ? Colors.grey
                        //       : Colors.grey.shade700,
                        // )
                      ),
                      child: commonText(
                        text: "AM",
                        fontWeight: FontWeight.w400,
                        textSize: displayWidth(context) * 0.03,
                        textColor:
                        timeFormat == "AM" ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.getTime!('$formattedHour : $formattedMinute PM');

                      setState(() {
                        timeFormat = "PM";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: timeFormat == "PM"
                            ? blueColor
                            : selectDayBackgroundColor,
                        // border: Border.all(
                        //   color: timeFormat == "PM"
                        //       ? Colors.grey
                        //       : Colors.grey.shade700,
                        // ),
                      ),
                      child: commonText(
                        text: "PM",
                        textColor:
                        timeFormat == "PM" ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w400,
                        textSize: displayWidth(context) * 0.03,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  bool checkIfDateIsSame() {
    int year = widget.selectedDate!.year;
    int month = widget.selectedDate!.month;
    int day = widget.selectedDate!.day;

    if (year == DateTime.now().year &&
        month == DateTime.now().month &&
        day == DateTime.now().day) {
      return true;
    } else {
      return false;
    }
  }
}

class EndCustomTimePicker extends StatefulWidget {
  Function(String time)? getTime;
  DateTime? selectedDate;
  EndCustomTimePicker({super.key, this.getTime, this.selectedDate});
  @override
  _EndCustomTimePickerState createState() => _EndCustomTimePickerState();
}

class _EndCustomTimePickerState extends State<EndCustomTimePicker> {
  late CommonProvider commonProvider;

  // Constants
  var hour = 01;
  var minute = 00;
  var timeFormat = "AM";
  String formattedHour = '01';
  String formattedMinute = '00';
  var minHour = 01, minMinute = 00;

  @override
  void initState() {
    super.initState();

    // if (checkIfDateIsSame()) {
    //   hour = DateTime.now().hour > 12
    //       ? DateTime.now().hour - 12
    //       : DateTime.now().hour;
    //   minHour = DateTime.now().hour > 12
    //       ? DateTime.now().hour - 12
    //       : DateTime.now().hour;
    //   minute = DateTime.now().minute;
    //   minMinute = DateTime.now().minute;
    // } else {
    //   hour = 01;
    //   minHour = 01;
    //   minute = 00;
    //   minMinute = 00;
    // }

    // commonProvider = context.read<CommonProvider>();
    // commonProvider.resetEndCustomTimePicker = () {
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     setState(() {
    //       print('CHECK IF:${checkIfDateIsSame()}');
    //       print('CHECK IF:${widget.selectedDate}');
    //       if (checkIfDateIsSame()) {
    //         if (DateTime.now().hour > hour) {
    //           hour = DateTime.now().hour > 12
    //               ? DateTime.now().hour - 12
    //               : DateTime.now().hour;
    //           minHour = DateTime.now().hour > 12
    //               ? DateTime.now().hour - 12
    //               : DateTime.now().hour;
    //         } else {
    //           hour = 01;
    //           minHour = 01;
    //         }

    //         if (DateTime.now().minute > minute) {
    //           minute = DateTime.now().minute;
    //           minMinute = DateTime.now().minute;
    //         } else {
    //           minute = 00;
    //           minMinute = 00;
    //         }

    //         if (hour < 10) {
    //           formattedHour = hour.toString().padLeft(2, '0');
    //         } else {
    //           formattedHour = hour.toString();
    //         }

    //         if (minute < 10) {
    //           formattedMinute = minute.toString().padLeft(2, '0');
    //         } else {
    //           formattedMinute = minute.toString();
    //         }

    //         widget.getTime!(
    //             '$formattedHour : $formattedMinute $timeFormat');

    //       } else {
    //         hour = 01;
    //         minHour = 01;
    //         minute = 00;
    //         minMinute = 00;

    //         if (hour < 10) {
    //           formattedHour = hour.toString().padLeft(2, '0');
    //         } else {
    //           formattedHour = hour.toString();
    //         }

    //         if (minute < 10) {
    //           formattedMinute = minute.toString().padLeft(2, '0');
    //         } else {
    //           formattedMinute = minute.toString();
    //         }

    //         widget.getTime!(
    //             '$formattedHour : $formattedMinute $timeFormat');
    //       }
    //     });
    //   });
    // };
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              NumberPicker(
                minValue: 01,
                maxValue: 12,
                value: hour,
                zeroPad: true,
                infiniteLoop: true,
                itemWidth: 50,
                itemHeight: 45,
                onChanged: (value) {
                  if(value >= minHour){
                    if (value < 10) {
                      formattedHour = value.toString().padLeft(2, '0');
                    } else {
                      formattedHour = value.toString();
                    }
                    setState(() {
                      hour = value;

                      widget.getTime!(
                          '$formattedHour : $formattedMinute $timeFormat');
                    });
                  }
                },
                textStyle: const TextStyle(
                    color: colorlightBlueTimePickerUnselecetd,
                    fontSize: 16,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                decoration: const BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //       color: Colors.white,
                  //     ),
                  //     bottom: BorderSide(color: Colors.white)

                  //  ),
                ),
              ),
              Container(
                child: Text(
                  ':',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              NumberPicker(
                minValue: 00,
                maxValue: 59,
                value: minute,
                zeroPad: true,
                infiniteLoop: true,
                itemWidth: 50,
                itemHeight: 45,
                onChanged: (value) {
                  if(value >= minMinute){
                    if (value < 10) {
                      formattedMinute = value.toString().padLeft(2, '0');
                    } else {
                      formattedMinute = value.toString();
                    }

                    setState(() {
                      minute = value;
                      widget.getTime!(
                          '$formattedHour : $formattedMinute $timeFormat');
                    });
                  }

                },
                textStyle: const TextStyle(
                    color: colorlightBlueTimePickerUnselecetd,
                    fontSize: 16,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600),
                decoration: const BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //       color: Colors.white,
                  //     ),
                  //     bottom: BorderSide(color: Colors.white)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.getTime!('$formattedHour : $formattedMinute AM');

                      setState(() {
                        timeFormat = "AM";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: timeFormat == "AM"
                            ? blueColor
                            : selectDayBackgroundColor,
                        // border: Border.all(
                        //   color: timeFormat == "AM"
                        //       ? Colors.grey
                        //       : Colors.grey.shade700,
                        // )
                      ),
                      child: commonText(
                        text: "AM",
                        fontWeight: FontWeight.w400,
                        textSize: displayWidth(context) * 0.03,
                        textColor:
                        timeFormat == "AM" ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.getTime!('$formattedHour : $formattedMinute PM');

                      setState(() {
                        timeFormat = "PM";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: timeFormat == "PM"
                            ? blueColor
                            : selectDayBackgroundColor,
                        // border: Border.all(
                        //   color: timeFormat == "PM"
                        //       ? Colors.grey
                        //       : Colors.grey.shade700,
                        // ),
                      ),
                      child: commonText(
                        text: "PM",
                        textColor:
                        timeFormat == "PM" ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w400,
                        textSize: displayWidth(context) * 0.03,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  bool checkIfDateIsSame() {
    int year = widget.selectedDate!.year;
    int month = widget.selectedDate!.month;
    int day = widget.selectedDate!.day;

    if (year == DateTime.now().year &&
        month == DateTime.now().month &&
        day == DateTime.now().day) {
      return true;
    } else {
      return false;
    }
  }
}
