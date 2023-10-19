import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

//It return custom dialog
class CustomDialog extends StatelessWidget {
  String? text, subText, positiveBtn, cancelBtn;

  Function()? positiveBtnOnTap;

  bool isPositiveBtnClick = false, isNegativeBtnClick = false;
  bool? userConfig = false, isError = false;

  dialogContent(BuildContext context) {
    return OrientationBuilder(
      builder: (context,orientation) {
        return Stack(
          children: [
            Container(
              width:orientation==Orientation.portrait? displayWidth(context):displayWidth(context)/2,
              margin: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: commonText(
                          text: text,
                          context: context,
                          textSize:orientation==Orientation.portrait? displayWidth(context) * 0.045:displayWidth(context) * 0.030,
                          textColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: commonText(
                          text: subText!,
                          context: context,
                          textSize:orientation==Orientation.portrait?  displayWidth(context) * 0.032:displayWidth(context) * 0.023,
                          textColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    isError!
                        ? SizedBox()
                        :
                        Container(
                            margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CommonButtons.getAcceptButton(
                                    positiveBtn!,
                                    context,
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.white,
                                    positiveBtnOnTap,
                                  orientation==Orientation.portrait?  displayWidth(context) * 0.5:displayWidth(context)/4,
                                  orientation==Orientation.portrait?   displayHeight(context) * 0.06:displayHeight(context) * 0.09,
                                    primaryColor,
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.white,
                                 orientation==Orientation.portrait?    displayHeight(context) * 0.018:displayHeight(context) * 0.025,
                                    blueColor,
                                    ''),
                              ],
                            ),
                          )
                  ],
                ),
              ),
            ),
            isError!
                ? SizedBox()
                : Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white, width: 1),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  CustomDialog(
      {this.text,
      this.subText,
      this.positiveBtn,
      this.positiveBtnOnTap,
      this.userConfig,
      this.cancelBtn,
      this.isError});
}
