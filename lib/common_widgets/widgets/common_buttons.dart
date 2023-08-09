import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/dash_rect.dart';

class CommonButtons {

  //Custom action button
  static Widget getRichTextActionButton(
      {String? title,
      BuildContext? context,
      Color? borderColor,
      Color? textColor,
      double? fontSize,
      Function()? onTap,
      Widget? icon,
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
                borderRadius: BorderRadius.circular(10.0)))),
        child: Center(
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Container(child: icon),
                ),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 6),
                    child: commonText(
                        text: title,
                        context: context,
                        textSize: fontSize,
                        textColor: textColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Action button
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

  //custom button along with dots
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

  //Upload Vessel Image along with dots
  static Widget uploadVesselImage(String title, BuildContext context,
      Function() onTap, Color primaryTextColor,
      [double? height]) {
    if (height == null) {
      height = displayHeight(context) * 0.22;
    }

    return Center(
      child: Container(
        height: height,
        width: displayWidth(context) * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFECF3F9),
        ),
        child: DashedRectToUploadImage(
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

  //custom button with id
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
    FontWeight fontWeight = FontWeight.bold,String fontFamily = outfit
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
            border: Border.all(color: borderColor, width: 1.5),
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
              fontWeight: fontWeight,fontFamily: fontFamily
          )),
    );
  }

  static Widget getTextActionButton(
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
}
