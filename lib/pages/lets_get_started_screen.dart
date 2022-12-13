import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/pages/sign_in_screen.dart';

class LetsGetStartedScreen extends StatefulWidget {
  const LetsGetStartedScreen({Key? key}) : super(key: key);

  @override
  State<LetsGetStartedScreen> createState() => _LetsGetStartedScreenState();
}

class _LetsGetStartedScreenState extends State<LetsGetStartedScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      body: SizedBox(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/intro_bg_img.png',
              height: size.height,
              width: size.width,
              fit: BoxFit.cover,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: displayHeight(context) * 0.15,
                          // width: displayWidth(context) * 0.3,
                        ),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.15,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CommonButtons.getActionButton(
                          title: 'Sign In',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: letsGetStartedButtonColor,
                          borderColor: letsGetStartedButtonColor,
                          width: displayWidth(context) / 1.4,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                            );
                          }),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      CommonButtons.getActionButton(
                          title: 'Register',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: letsGetStartedButtonColor,
                          borderColor: letsGetStartedButtonColor,
                          width: displayWidth(context) / 1.4,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());

                            /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const RegistrationScreen()),
                                );*/
                          }),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
