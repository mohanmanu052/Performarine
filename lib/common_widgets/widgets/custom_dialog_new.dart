import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';

import '../utils/colors.dart';
import 'common_buttons.dart';

class CustomDialogNew extends StatelessWidget {
  final String? imagePath;
  final String? text;
  final VoidCallback? onPressed;

  CustomDialogNew({
     this.imagePath,
     this.text,
     this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(displayWidth(context) * 0.055),
      ),
      child: Padding(
        padding:  EdgeInsets.all(displayWidth(context) * 0.07),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: displayWidth(context) * 0.4,
                height: displayHeight(context) * 0.1,
                child: Image.asset(imagePath!)
            ),
            SizedBox(height: displayWidth(context) * 0.071),
            Text(
              text!,
              style: TextStyle(fontSize: displayWidth(context) * 0.042),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            CommonButtons.getActionButton(
                title: 'Go To Email',
                context: context,
                fontSize: displayWidth(context) * 0.044,
                textColor: Colors.white,
                buttonPrimaryColor: buttonBGColor,
                borderColor: buttonBGColor,
                width: displayWidth(context),
                onTap: onPressed,)
          ],
        ),
      ),
    );
  }
}
