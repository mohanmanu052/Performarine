import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

class SuccessfullyDeletedAccountScreen extends StatefulWidget {
  const SuccessfullyDeletedAccountScreen({super.key});

  @override
  State<SuccessfullyDeletedAccountScreen> createState() => _SuccessfullyDeletedAccountScreenState();
}

class _SuccessfullyDeletedAccountScreenState extends State<SuccessfullyDeletedAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: displayHeight(context),
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: displayHeight(context) * 0.08,
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Image.asset(
                  'assets/images/success_image.png',
                  height: displayHeight(context) * 0.25
                ),),
              SizedBox(height: displayHeight(context) * 0.02,),
              commonText(
                  context: context,
                  text: 'Your account has been\ndeleted successfully',
                  fontWeight: FontWeight.w600,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.05,
                  textAlign: TextAlign.start),
            ],
          ),
        ),
      ),
    );
  }
}
