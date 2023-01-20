import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

class LocationPermissionCustomDialog extends StatelessWidget {
  String? text, subText, buttonText;

  Function()? buttonOnTap;

  bool isPositiveBtnClick = false, isNegativeBtnClick = false;

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: displayWidth(context),
          height: displayHeight(context) * 0.75,
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10.0, left: 10, right: 10),
                        child: commonText(
                            text: 'Location Permission Required',
                            context: context,
                            textSize: displayWidth(context) * 0.045,
                            textColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.blueAccent,
                            fontWeight: FontWeight.w600),
                      ),
                      Center(
                        child: Container(
                          child: Image.asset(
                            'assets/images/location_permission.png',
                            height: displayHeight(context) * 0.18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: commonText(
                            text: text,
                            context: context,
                            textSize: displayWidth(context) * 0.04,
                            textColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10, right: 10),
                        child: commonText(
                            text: subText!,
                            context: context,
                            textSize: displayWidth(context) * 0.03,
                            textColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Click',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                                fontSize: displayWidth(context) * 0.032),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' OK',
                                recognizer: TapGestureRecognizer()
                                /*..onTap = () async {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SignUpScreen();
                                      }));
                                    }*/
                                ,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              ),
                              TextSpan(
                                text: ' to access App Info',
                                recognizer: TapGestureRecognizer(),
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Click',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                                fontSize: displayWidth(context) * 0.032),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Permissions',
                                recognizer: TapGestureRecognizer()
                                /*..onTap = () async {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SignUpScreen();
                                      }));
                                    }*/
                                ,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              ),
                              TextSpan(
                                text: ' to access Permission Info',
                                recognizer: TapGestureRecognizer(),
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Select',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                                fontSize: displayWidth(context) * 0.032),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Location/GPS',
                                recognizer: TapGestureRecognizer()
                                /*..onTap = () async {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SignUpScreen();
                                      }));
                                    }*/
                                ,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              ),
                              TextSpan(
                                text: ' and change to allow all the time.',
                                recognizer: TapGestureRecognizer(),
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.032),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CommonButtons.getAcceptButton(
                          buttonText!,
                          context,
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey,
                          buttonOnTap!,
                          displayWidth(context) * 0.5,
                          displayHeight(context) * 0.06,
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.grey,
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.white,
                          displayHeight(context) * 0.018,
                          buttonBGColor,
                          ''),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
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

  LocationPermissionCustomDialog({
    this.text,
    this.subText,
    this.buttonText,
    this.buttonOnTap,
  });
}
