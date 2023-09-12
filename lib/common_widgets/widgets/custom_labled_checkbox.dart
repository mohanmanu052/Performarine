import 'dart:io';

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
        this.orientation,
        this.imageUrl,
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
  String? imageUrl;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;
  String? dateTime;
  String? distance;
  String? time;
  Orientation? orientation;

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
        width: displayWidth(context)/1.2,
        height:orientation==Orientation.portrait? displayHeight(context) * 0.09:displayHeight(context) * 0.19,
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

Container(
                 height:orientation==Orientation.portrait? displayHeight(context) * 0.06:displayHeight(context) * 0.11,
               width:orientation==Orientation.portrait? displayWidth(context) * 0.13:displayWidth(context) * 0.12,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
                      image: imageUrl!=null&&imageUrl!.isNotEmpty?
                      DecorationImage(  
                        fit: BoxFit.cover,
                      
                          image:
                          FileImage(
                          File(imageUrl??''))):                     
                            DecorationImage(
                            fit: BoxFit.cover,
                            image:AssetImage("assets/images/vessel_default_img.png",)


                      
                      
                      
                  ),
                )),


            //  Image.asset(
            //    "assets/images/reports-boat.png",
            //    height:orientation==Orientation.portrait? displayHeight(context) * 0.06:displayHeight(context) * 0.10,
            //    width:orientation==Orientation.portrait? displayWidth(context) * 0.13:displayWidth(context) * 0.15,
            //  ),

             SizedBox(
               width: 10,
             ),

             SizedBox(
              width: displayWidth(context)/5.3,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "$dateTime",
                     style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontFamily: outfit,
                         fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.022,
                         color: blutoothDialogTxtColor),
                   ),
             
                   SizedBox(
                     height: displayHeight(context) * 0.005,
                   ),
             
                   Text(
                     "Date",
                     style: TextStyle(
                         fontWeight: FontWeight.w400,
                         fontFamily: poppins,
                         fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.026:displayWidth(context) * 0.018,
                         color: filterByTripTxtColor),
                   ),
                 ],
               ),
             ),

             SizedBox(
               width: 5,
             ),

             VerticalDivider(
               indent: displayHeight(context) * 0.024,
               endIndent: displayHeight(context) * 0.024,
               width: 3,
               thickness: 1.3,
               color: Colors.black,
             ),
             SizedBox(
               width: 8,
             ),


             SizedBox(
              width: displayWidth(context) /8.1,

               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "$distance",
                     style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontFamily: outfit,
                         fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.022,
                         color: blutoothDialogTxtColor),
                   ),
             
                   SizedBox(
                     height: displayHeight(context) * 0.005,
                   ),
             
                   Text(
                     "Distance",
                     style: TextStyle(
                         fontWeight: FontWeight.w400,
                         fontFamily: poppins,
                         fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.026:displayWidth(context) * 0.018,
                         color: filterByTripTxtColor),
                   ),
                 ],
               ),
             ),

             SizedBox(
               width: 8,
             ),

             VerticalDivider(
               indent: displayHeight(context) * 0.024,
               endIndent: displayHeight(context) * 0.024,
               width: 3,
               thickness: 1.3,
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
                       fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.022,
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
                       fontSize:orientation==Orientation.portrait? displayWidth(context) * 0.026:displayWidth(context) * 0.018,
                       color: filterByTripTxtColor),
                 ),
               ],
             ),

           ],
        ),
      ),
    );
  }
}