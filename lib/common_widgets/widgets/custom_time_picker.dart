import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

/// This helper widget manages the scrollable content inside a picker widget.
class CustomTimePicker extends StatefulWidget {
  Function(String time)? getTime; 
CustomTimePicker({this.getTime});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}
class _CustomTimePickerState extends State<CustomTimePicker> {
  // Constants
  var hour = 01;
  var minute = 00;
  var timeFormat = "AM";
  String formattedHour='01';
  String formattedMinute='00';
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
    
        Container(
         // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10)),
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
                  if(value<10){
                    formattedHour=value.toString().padLeft(2,'0');
                  }else{
                    formattedHour=value.toString();
                  }
                  setState(() {
                    hour=value;

                   widget. getTime!('$formattedHour : $formattedMinute $timeFormat');
                  });
                },
                textStyle:
                    const TextStyle(color: colorlightBlueTimePickerUnselecetd, fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600
                    ),
                selectedTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 24,
                    
                                        fontFamily: outfit,
                    fontWeight: FontWeight.w600
                    

                    ),
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
child: Text(':',
style: TextStyle(
  fontSize: 22,
  color: Colors.black,
  fontWeight: FontWeight.bold
),

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
                                    if(value<10){
                    formattedMinute=value.toString().padLeft(2,'0');
                  }else{
                    formattedMinute=value.toString();
                  }

                  setState(() {
                    minute = value;
                   widget. getTime!('$formattedHour : $formattedMinute $timeFormat');
                  });
                },
                textStyle:
                    const TextStyle(color: colorlightBlueTimePickerUnselecetd, fontSize: 20,
                    fontFamily: outfit,
                    fontWeight: FontWeight.w600
                    
                    ),
                selectedTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 24,
                                        fontFamily: outfit,
                    fontWeight: FontWeight.w600
                    

                    
                    ),
                decoration: const BoxDecoration(
                  // border: Border(
                  //     top: BorderSide(
                  //       color: Colors.white,
                  //     ),
                  //     bottom: BorderSide(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                                         widget. getTime!('$formattedHour : $formattedMinute AM');

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
                      child:  commonText(
                      text:  "AM",
                        fontWeight: FontWeight.w400,
                        textSize: 13,
                        textColor: timeFormat == "AM"
                              ? Colors.white
                              : Colors.black ,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                                         widget. getTime!('$formattedHour : $formattedMinute PM');

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
                      text:  "PM",
textColor:timeFormat == "PM"
                              ? Colors.white
                              : Colors.black ,
                        fontWeight: FontWeight.w400,
                        textSize: 13,
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

}