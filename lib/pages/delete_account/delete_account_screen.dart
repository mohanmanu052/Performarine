import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/auth_new/sign_up_screen.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/delete_account/successfully_deleted_account_screen.dart';
import 'package:performarine/pages/web_navigation/privacy_and_policy_web_view.dart';


class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: commonText(
            context: context,
            text: 'Delete Account',
            fontWeight: FontWeight.w600,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.042,
            textAlign: TextAlign.start),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                await SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomNavigation()),
                    ModalRoute.withName(""));
              },
              icon:
              Image.asset('assets/icons/performarine_appbar_icon.png'),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 17,
                vertical: 10),
            child: Column(
              children: [
                CommonButtons.getActionButton(
                    title: 'Confirm & Delete',
                    context: context,
                    fontSize: displayWidth(context) * 0.042,
                    textColor: Colors.white,
                    buttonPrimaryColor: deleteAccountBtnColor.withOpacity(emailController.text.isEmpty ? 0.5 : 1.0),
                    borderColor: deleteAccountBtnColor.withOpacity(emailController.text.isEmpty ? 0.5 : 1.0),
                    width: displayWidth(context),
                    onTap: emailController.text.isEmpty
                      ? null
                        : () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SuccessfullyDeletedAccountScreen(
                                )),
                      );
                    }),

                SizedBox(height: 10,),

                CommonButtons.getActionButton(
                    title: 'Cancel',
                    context: context,
                    fontSize: displayWidth(context) * 0.042,
                    textColor: Colors.grey,
                    buttonPrimaryColor: Color(0xFFE9EFFA),
                    borderColor: Color(0xFFE9EFFA),
                    width: displayWidth(context),
                    onTap: () async {
                    }),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
              child: Column(
                children: [

                  SizedBox(height: displayHeight(context) * 0.12,),

                  Image.asset('assets/images/acc_delete.png', height: displayHeight(context) * 0.2,),

                  SizedBox(height: displayHeight(context) * 0.05,),

                  commonText(
                      context: context,
                      text: 'Are sure you want to delete your account?',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.046,
                      textAlign: TextAlign.start),

                  SizedBox(height: displayHeight(context) * 0.01,),

                  commonText(
                      context: context,
                      text: 'This operation cannot be undone',
                      fontWeight: FontWeight.normal,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.036,
                      textAlign: TextAlign.start),

                  SizedBox(height: displayHeight(context) * 0.08,),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      commonText(
                          context: context,
                          text: 'Confirmation code ',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.046,
                          textAlign: TextAlign.start),

                      commonText(
                          context: context,
                          text: '698043',
                          fontWeight: FontWeight.normal,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.046,
                          textAlign: TextAlign.start),
                    ],
                  ),

                  SizedBox(height: displayHeight(context) * 0.02,),

                  CommonTextField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    labelText: 'Enter Your Email',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 52,
                    prefixIcon: null,
                    requestFocusNode: null,
                    obscureText: false,
                    readOnly: false,
                    onTap: () {},
                    onChanged: (value) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Your Email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Enter Valid Email';
                      } else if (EmailValidator.validate(value)) {
                        String emailExt = value.split('.').last;

                        if (!['com', 'in', 'us'].contains(emailExt)) {
                          return 'Enter Valid Email';
                        }
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {},

                  ),

                  SizedBox(height: displayHeight(context) * 0.03,),

                  Padding(
                    padding: EdgeInsets.only(left: displayWidth(context) * 0.04),
                    child: CircularRadioTile(
                      isChecked: isChecked,
                      checkConditionColor: blueColor,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      value: isChecked,
                      title: RichText(
                        text: TextSpan(
                          text: 'By clicking on confirm & delete you accept',
                          style: TextStyle(
                            fontFamily: outfit,
                            color: Colors.grey,
                            fontSize: displayWidth(context) * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: ' T&C',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return CustomWebView(
                                              url: 'https://${Urls.terms}');
                                        }));
                                  },
                                style: TextStyle(
                                    fontFamily: outfit,
                                    color: blueColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.032)),
                            TextSpan(
                                text: ' and ',
                                style: TextStyle(
                                    fontFamily: outfit,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.03)),
                            TextSpan(
                                text: 'Privacy Policy',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return CustomWebView(
                                            url: 'https://${Urls.privacy}',
                                          );
                                        }));
                                  },
                                style: TextStyle(
                                    fontFamily: outfit,
                                    color: blueColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.032)),
                            TextSpan(
                                text: ' to remove your data with us ',
                                style: TextStyle(
                                    fontFamily: outfit,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.03)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
