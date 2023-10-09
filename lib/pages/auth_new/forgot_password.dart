import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../provider/common_provider.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  late CommonProvider commonProvider;
  bool? isBtnClick = false,isLinkSuccess = false;

  String page = "forgot_password";

  @override
  void initState() {
    super.initState();
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();
    emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              height: displayHeight(context),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.1),
                  Container(
                    width: displayWidth(context) * 0.36,
                    height: displayHeight(context) * 0.14,
                    child: Image.asset(
                      'assets/images/performarine_logo.png',
                    ),
                  ),
                  SizedBox(height: displayHeight(context) * 0.05),
                  commonText(
                      context: context,
                      text: 'Forgot Password',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.0425,
                      textAlign: TextAlign.start),

                  SizedBox(height: displayHeight(context) * 0.025),

                  CommonTextField(
                    //key: emailFormFieldKey,
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
                      onFieldSubmitted: (value) {
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Email $value -> $page");
                      }),

                  SizedBox(height: displayHeight(context) * 0.035),

                  isBtnClick! ? SizedBox(
                    height : displayHeight(context) * 0.065,
                    child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              blueColor),
                        )),
                  )
                      :   CommonButtons.getActionButton(
                      title: 'Send Reset Password Link',
                      context: context,
                      fontSize: displayWidth(context) * 0.044,
                      textColor: Colors.white,
                      buttonPrimaryColor: blueColor,
                      borderColor: blueColor,
                      width: displayWidth(context),
                      onTap: () async {
                        if(formKey.currentState!.validate()){
                          FocusManager.instance.primaryFocus?.unfocus();

                          bool check = await Utils().check(scaffoldKey);
                          if(check){
                            setState(() {
                              isLinkSuccess = false;
                              isBtnClick = true;
                            });
                            commonProvider.forgotPassword(context, emailController.text.toLowerCase().trim(), scaffoldKey).then((value){
                              if(value != null && value.status!){
                                setState(() {
                                  isBtnClick = false;
                                });
                                Utils.customPrint("status code of forgot password: ${value.statusCode}");
                                CustomLogger().logWithFile(Level.info, "status code of forgot password: ${value.statusCode} -> $page");

                                if(value.statusCode == 200){
                                  CustomLogger().logWithFile(Level.info, "User navigating to Sign in Screen -> $page");
                                  setState(() {
                                    isLinkSuccess = true;
                                  });

                                  Future.delayed(Duration(seconds: 3), (){
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SignInScreen(calledFrom: 'forgotPassword',),
                                        ),
                                        ModalRoute.withName(""));
                                  });
                                }
                              } else{
                                setState(() {
                                  isBtnClick = false;
                                });
                              }
                            }).catchError((e){
                              setState(() {
                                isBtnClick = false;
                              });
                            });
                          } else{
                            setState(() {
                              isBtnClick = false;
                            });
                          }
                        }
                      }),

                  SizedBox(
                    height: displayHeight(context) * 0.11,
                  ),

                  isLinkSuccess! ?  Column(
                    children: [
                      Container(
                        height: displayHeight(context) * 0.08,
                        decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        child: Image.asset(
                          'assets/images/success_image.png',
                          height: displayHeight(context) * 0.25,
                        ),),

                      SizedBox(
                        height: displayHeight(context) * 0.03,
                      ),

                      commonText(
                          context: context,
                          text: 'Reset Link sent successfully!',
                          fontWeight: FontWeight.w500,
                          textColor: blueColor,
                          textSize: displayWidth(context) * 0.032,
                          textAlign: TextAlign.start),
                    ],
                  ) : SizedBox(
                    height: displayHeight(context) * 0.12,
                  ),

                  SizedBox(
                    height: displayHeight(context) * 0.12,
                  ),

                  Center(
                    child: RichText(
                      text: TextSpan(
                          text: 'Already Member?',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontFamily: poppins,
                              fontStyle: FontStyle.normal,
                              fontSize: displayWidth(context) * 0.032),
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignInScreen(calledFrom: 'forgotPassword',),
                                        ),
                                        ModalRoute.withName(""));
                                  },
                                text: ' Sign In',
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontStyle: FontStyle.normal,
                                    fontSize: displayWidth(context) * 0.035)),
                          ]),
                    ),
                  ),

                ],
              ),
            )
        ),
      ),
    );
  }
}
