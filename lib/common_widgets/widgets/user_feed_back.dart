import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

import '../utils/colors.dart';
import 'common_widgets.dart';

class UserFeedback{

  
  Widget getUserFeedback(BuildContext context,{Orientation orientation=Orientation.portrait,double bottom=0}){

    double value = Platform.isIOS ? displayHeight(context) * 0.015 : 0;

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: bottom==0?value:bottom),
      height: displayWidth(context) * 0.05,
      width: displayWidth(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: userFeedbackBtnColor,
            size:orientation==Orientation.portrait?
            
            
             displayWidth(context) * 0.035:displayWidth(context) * 0.025,
          ),

          SizedBox(
            width: displayWidth(context) * 0.02,
          ),

          commonText(
              context: context,
              text: 'Feedback',
              fontWeight: FontWeight.w300,
              textColor: userFeedbackBtnColor,
              textSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.02,
              textAlign: TextAlign.start,
            fontFamily: inter
          ),

          commonText(
              context: context,
              text: ' / Report',
              fontWeight: FontWeight.w300,
              textColor: userFeedbackBtnColor,
              textSize:orientation==Orientation.portrait? displayWidth(context) * 0.032:displayWidth(context) * 0.02,
              textAlign: TextAlign.start,
              fontFamily: inter
          )
        ],
      ),
    );
  }
}