import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/common_size_helper.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_widgets.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/dash_rect.dart';

class CommonButtons {
  static Widget getTextButton(
      {String? title,
      BuildContext? context,
      Color? textColor,
      double? textSize,
      bool? isClickLink = false,
      FontWeight? fontWeight,
      Function()? onTap}) {
    return Column(
      children: [
        TextButton(
          onPressed: onTap,
          child: Text(
            title!,
            style: isClickLink!
                ? TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                    fontSize: textSize,
                    color: textColor,
                    fontWeight: fontWeight)
                : TextStyle(
                    fontSize: textSize,
                    color: textColor,
                    fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }

  static Widget getActionButton(
      {String? title,
      BuildContext? context,
      Color? borderColor,
      Color? textColor,
      double? fontSize,
      Function()? onTap,
      double? width,
      Color? buttonPrimaryColor}) {
    width ??= displayWidth(context!);
    borderColor ??= buttonPrimaryColor;

    return ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(buttonPrimaryColor),
            fixedSize: MaterialStateProperty.all(
                Size(width, displayHeight(context!) * 0.065)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: borderColor!),
                borderRadius: BorderRadius.circular(5.0)))),
        child: Center(
          child: commonText(
              text: title,
              context: context,
              textSize: fontSize,
              textColor: textColor,
              fontWeight: FontWeight.w500),
        ));
  }

  static Widget getDottedButton(String title, BuildContext context,
      Function() onTap, Color primaryTextColor,
      [double? height]) {
    if (height == null) {
      height = displayHeight(context) * 0.07;
    }

    return Center(
      child: Container(
        height: height,
        width: displayWidth(context) * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: DashedRect(
          color: primaryTextColor,
          strokeWidth: 1.5,
          gap: 5.0,
          onTap: onTap,
          title: title,
          primaryTextColor: primaryTextColor,
        ),
      ),
    );
  }

  static Widget getAcceptButton(
    String? title,
    BuildContext context,
    Color borderColor,
    Function()? onTap,
    double width,
    double height,
    Color backgroundColor,
    Color textColor,
    double textSize,
    Color buttonPrimaryColor,
    String orgId, {
    FontWeight fontWeight = FontWeight.bold,
  }) {
    if (width == null) {
      width = displayWidth(context) * 0.45;
    }

    if (height == null) {
      height:
      displayHeight(context) * 0.08;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: buttonPrimaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(5),
            color: buttonPrimaryColor,
          ),
          padding: EdgeInsets.all(4),
          alignment: Alignment.center,
          child: commonText(
              text: title,
              context: context,
              textSize: textSize,
              textColor: textColor,
              fontWeight: fontWeight)),
    );
  }
}
