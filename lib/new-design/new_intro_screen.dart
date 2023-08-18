import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'package:performarine/pages/auth/sign_up_screen.dart';
import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/widgets/common_buttons.dart';
import '../common_widgets/widgets/common_widgets.dart';

class NewIntroScreen extends StatefulWidget {
  const NewIntroScreen({super.key});

  @override
  State<NewIntroScreen> createState() => _NewIntroScreenState();
}

class _NewIntroScreenState extends State<NewIntroScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: displayHeight(context),
        width: displayWidth(context) ,
        child: Stack(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/icons/background_img.png',
                  height: displayHeight(context),
                  width: displayWidth(context),
                  fit: BoxFit.cover,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: displayHeight(context) * 0.34,
                      width: displayWidth(context),
                      padding: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color:
                            Colors.black.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 70))
                      ]),
                    ))
              ],
            ),

            Positioned(
                top: displayHeight(context) * 0.1,
                right: 0,
                left: 0,
                child: Image.asset('assets/icons/app_icon.png', width: displayWidth(context) * 0.2, height: displayHeight(context) * 0.12)),

            Positioned(
                right: 0,
                left: 0,
                bottom: displayHeight(context) * 0.03,
                child:Container(
                  margin: EdgeInsets.symmetric(horizontal: displayWidth(context)* 0.1),
                  height: displayHeight(context) < 700 ? displayHeight(context) * 0.38 : displayHeight(context) * 0.34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: displayWidth(context) * 0.07, vertical: displayHeight(context) * 0.018),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            commonText(
                                context: context,
                                text: 'Improving marine intelligence and ecosystem health.',
                                fontWeight: FontWeight.w700,
                                textColor: Colors.white,
                                textSize:
                                displayWidth(context) * 0.058,
                                textAlign: TextAlign.start),
                            SizedBox(height: displayHeight(context) * 0.01,),
                            commonText(
                                context: context,
                                text: 'We do this through electric boat propulsion kits, utilization of boat batteries as dynamic energy storage for power grids, and data collection.',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.white,
                                textSize:
                                displayWidth(context) * 0.034,
                                textAlign: TextAlign.start),
                            SizedBox(height: displayHeight(context) * 0.01,),
                            CommonButtons.getActionButton(
                              title: 'Sign Up as New User',
                              context: context,
                              fontSize: displayWidth(context) * 0.036,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              width: displayWidth(context),
                              height: displayHeight(context) * 0.055,
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>  SignUpScreen()),
                                );
                              },),
                           // SizedBox(height: displayHeight(context) * 0.01,),
                          ],
                        ),

                        RichText(
                          text: TextSpan(
                            text: 'Already a member ?',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                    Brightness.dark
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                                fontSize: displayWidth(context) * 0.03),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Sign In',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>  SignInScreen()),
                                    );
                                  },
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontSize: displayWidth(context) * 0.034),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            )

          ],
        ),
      ),
    );
  }

}
