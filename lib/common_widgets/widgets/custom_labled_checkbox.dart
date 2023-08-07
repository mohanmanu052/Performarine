import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

enum CheckboxType {
  Parent,
  Child,
}

// Custom labeled check box on reports module
@immutable
class CustomLabeledCheckbox extends StatelessWidget {
  CustomLabeledCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.checkboxType: CheckboxType.Child,
    required this.activeColor,
  })  : assert(label != null),
        assert(checkboxType != null),
        assert(
        (checkboxType == CheckboxType.Child && value != null) ||
            checkboxType == CheckboxType.Parent,
        ),
        tristate = checkboxType == CheckboxType.Parent ? true : false;

  String label;
  bool value;
  bool tristate;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;

  void _onChanged() {
    if (value != null) {
      onChanged(!value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return InkWell(
      onTap: _onChanged,
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Row(
          children: <Widget>[
            checkboxType == CheckboxType.Parent
                ? SizedBox(width: 0)
                : SizedBox(width: displayWidth(context) * 0.08),
            Checkbox(
              tristate: tristate,
              value: value,
              onChanged: (_) {
                _onChanged();
              },
              activeColor: activeColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.04,
                  fontWeight: FontWeight.bold, color: Colors.black,fontFamily: outfit),
            )
          ],
        ),
      ),
    );
  }
}

// Custom labeled check box to select all trips on reports module
@immutable
class CustomLabeledCheckboxOne extends StatelessWidget {
  CustomLabeledCheckboxOne(
      {required this.label,
        required this.value,
        required this.onChanged,
        this.checkboxType: CheckboxType.Child,
        required this.activeColor,
        this.dateTime,
        this.tripId})
      : assert(label != null),
        assert(checkboxType != null),
        assert(
        (checkboxType == CheckboxType.Child && value != null) ||
            checkboxType == CheckboxType.Parent,
        ),
        tristate = checkboxType == CheckboxType.Parent ? true : false;

  String label;
  bool value;
  bool tristate;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;
  String? dateTime;
  String? tripId;

  void _onChanged() {
    if (value != null) {
      onChanged(!value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ListTile(
      onTap: _onChanged,
      leading: Checkbox(
        tristate: tristate,
        value: value,
        onChanged: (_) {
          _onChanged();
        },
        activeColor: activeColor,
      ),
      title: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: poppins,
            fontSize: displayWidth(context) * 0.041,
            color: blutoothDialogTxtColor),
      ),
      subtitle: Text(
        "$tripId",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: inter,
            fontSize: displayWidth(context) * 0.031,
            color: blutoothDialogTxtColor),
      ),
      trailing: Text(
        dateTime != null ? dateTime! : "",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: inter,
            fontSize: displayWidth(context) * 0.028,
            color: dateColor),
      ),
    );
  }
}

// Custom labeled check box to select all trips on reports module
@immutable
class CustomLabeledCheckboxNew extends StatelessWidget {
  CustomLabeledCheckboxNew(
      {required this.label,
        required this.value,
        required this.onChanged,
        this.checkboxType: CheckboxType.Child,
        required this.activeColor,
        this.dateTime,
        this.distance,
        this.time
      })
      : assert(label != null),
        assert(checkboxType != null),
        assert(
        (checkboxType == CheckboxType.Child && value != null) ||
            checkboxType == CheckboxType.Parent,
        ),
        tristate = checkboxType == CheckboxType.Parent ? true : false;

  String label;
  bool value;
  bool tristate;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;
  String? dateTime;
  String? distance;
  String? time;

  void _onChanged() {
    if (value != null) {
      onChanged(!value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return InkWell(
      onTap: _onChanged,
      child: Container(
        width: displayWidth(context) * 0.8,
        height: displayHeight(context) * 0.09,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: reportTripsListColor
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
           //crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Checkbox(
               tristate: tristate,
               value: value,
               onChanged: (_) {
                 _onChanged();
               },
               activeColor: activeColor,
             ),
             Image.asset(
               "assets/images/reports-boat.png",
               height: displayHeight(context) * 0.06,
               width: displayWidth(context) * 0.13,
             ),

             SizedBox(
               width: displayWidth(context) * 0.015,
             ),

             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   "$dateTime",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontFamily: outfit,
                       fontSize: displayWidth(context) * 0.032,
                       color: blutoothDialogTxtColor),
                 ),

                 SizedBox(
                   height: displayHeight(context) * 0.008,
                 ),

                 Text(
                   "Date",
                   style: TextStyle(
                       fontWeight: FontWeight.w400,
                       fontFamily: poppins,
                       fontSize: displayWidth(context) * 0.026,
                       color: blutoothDialogTxtColor),
                 ),
               ],
             ),

             SizedBox(
               width: displayWidth(context) * 0.015,
             ),

             VerticalDivider(
               indent: displayHeight(context) * 0.02,
               endIndent: displayHeight(context) * 0.02,
               width: 3,
               thickness: 1.5,
               color: Colors.black,
             ),
             SizedBox(
               width: displayWidth(context) * 0.015,
             ),

             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   "$distance",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontFamily: outfit,
                       fontSize: displayWidth(context) * 0.032,
                       color: blutoothDialogTxtColor),
                 ),

                 SizedBox(
                   height: displayHeight(context) * 0.008,
                 ),

                 Text(
                   "Distance",
                   style: TextStyle(
                       fontWeight: FontWeight.w400,
                       fontFamily: poppins,
                       fontSize: displayWidth(context) * 0.026,
                       color: blutoothDialogTxtColor),
                 ),
               ],
             ),

             SizedBox(
               width: displayWidth(context) * 0.015,
             ),

             VerticalDivider(
               indent: displayHeight(context) * 0.02,
               endIndent: displayHeight(context) * 0.02,
               width: 3,
               thickness: 1.5,
               color: Colors.black,
             ),
             SizedBox(
               width: displayWidth(context) * 0.015,
             ),

             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   "$time",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontFamily: outfit,
                       fontSize: displayWidth(context) * 0.032,
                       color: blutoothDialogTxtColor),
                 ),

                 SizedBox(
                   height: displayHeight(context) * 0.008,
                 ),

                 Text(
                   "Time",
                   style: TextStyle(
                       fontWeight: FontWeight.w400,
                       fontFamily: poppins,
                       fontSize: displayWidth(context) * 0.026,
                       color: blutoothDialogTxtColor),
                 ),
               ],
             ),

           ],
        ),
      ),
    );
  }
}