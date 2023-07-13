

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';

import '../utils/colors.dart';
import 'common_widgets.dart';

class UserFeedback{
  
  Widget getUserFeedback(BuildContext context){
    return Container(
      height: displayWidth(context) * 0.05,
      width: displayWidth(context),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: userFeedbackBtnColor,
            size: displayWidth(context) * 0.04,
          ),

          SizedBox(
            width: displayWidth(context) * 0.02,
          ),

          commonText(
              context: context,
              text: 'Feedback',
              fontWeight: FontWeight.w300,
              textColor: userFeedbackBtnColor,
              textSize: displayWidth(context) * 0.038,
              textAlign: TextAlign.start),

          commonText(
              context: context,
              text: ' / Report',
              fontWeight: FontWeight.w300,
              textColor: userFeedbackBtnColor,
              textSize: displayWidth(context) * 0.038,
              textAlign: TextAlign.start)
        ],
      ),
    );
  }
}