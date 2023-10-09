import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:performarine/new-design/new_intro_screen.dart';
import 'package:performarine/pages/auth_new/sign_up_screen.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../provider/common_provider.dart';
import 'package:performarine/pages/auth_new/forgot_password.dart';

import '../sync_data_cloud_to_mobile_screen.dart';

class SignInScreen extends StatefulWidget {
  final String calledFrom;
  const SignInScreen({Key? key, this.calledFrom = ''}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  String? currentVersion;

  bool? isLoginBtnClicked = false,
      isGoogleSignInBtnClicked = false,
      isChecked = false,
      isLoginByEmailId = true;

  late CommonProvider commonProvider;
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
            SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();

    getVersion();
    // commonProvider.checkIfBluetoothIsEnabled(scaffoldKey);

    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        setState(() {
          isLoginByEmailId = true;
        });
      }
    });
    super.initState();
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = Platform.isAndroid ? packageInfo.version : '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }


  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: ()async
      {
        if(widget.calledFrom != null)
        {
          if(widget.calledFrom.isNotEmpty || widget.calledFrom == '')
          {
            if(widget.calledFrom == 'SignUp' || widget.calledFrom == 'sideMenu' || widget.calledFrom == 'HomePage' || widget.calledFrom == 'ResetPassword' || widget.calledFrom == 'forgotPassword')
            {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => NewIntroScreen()),
                  ModalRoute.withName(""));
            }
            else
            {
              Navigator.of(context).pop();
            }
          }
          else
          {
             Navigator.of(context).pop();
          }
          return false;
        }
        else
        {
          Navigator.of(context).pop();
          return false;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                    text: 'New User?',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: outfit,
                        fontStyle: FontStyle.normal,
                        fontSize: displayWidth(context) * 0.034),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ));
                            },
                          text: ' Sign Up',
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: outfit,
                              fontStyle: FontStyle.normal,
                              fontSize: displayWidth(context) * 0.035)),
                    ]),
              ),
            ),
            SizedBox(height: displayHeight(context) * 0.007),
            commonText(
                text: currentVersion,
                context: context,
                textSize: displayWidth(context) * 0.03,
                textColor: Colors.black54,
                fontWeight: FontWeight.w400),
            SizedBox(
              height: displayHeight(context) * 0.03,
            ),
          ],
        ),
        body: Center(
          child: Form(
            key: formKey,
              //autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                height: displayHeight(context),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
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
                          text: 'Sign In',
                          fontWeight: FontWeight.bold,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.043,
                          textAlign: TextAlign.start,
                        fontFamily: outfit
                      ),
                      SizedBox(height: displayHeight(context) * 0.02),
                      isGoogleSignInBtnClicked!
                          ? Container(
                            height: displayHeight(context) * 0.067,
                            width: displayWidth(context) * 0.1,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    blueColor),
                              ),
                            ),
                          ) :
                      GestureDetector(
                        onTap: () async {
                          bool check =
                          await Utils().check(scaffoldKey);
                          if (check) {
                            GoogleSignInAccount?
                            googleSignInAccount;

                            if (await googleSignIn.isSignedIn()) {
                              googleSignIn.signOut();
                              googleSignInAccount =
                              await googleSignIn.signIn();
                            } else {
                              googleSignInAccount =
                              await googleSignIn.signIn();
                            }

                            if (googleSignInAccount == null) {
                              // TODO handle
                              setState(() {
                                isGoogleSignInBtnClicked = false;
                              });
                              return null;
                            } else {
                              try {
                                setState(() {
                                  isGoogleSignInBtnClicked = true;
                                });

                                commonProvider
                                    .login(
                                    context,
                                    googleSignInAccount.email,
                                    //'paccoretesting@gmail.com',
                                    "",
                                    true,
                                    googleSignInAccount.id,
                                    //'114993051138200889304',
                                    scaffoldKey)
                                    .then((value) async {
                                  setState(() {
                                    isGoogleSignInBtnClicked =
                                    false;
                                  });

                                  if (value != null) {
                                    if (value.status!) {
                                      setState(() {
                                        isGoogleSignInBtnClicked =
                                        false;
                                      });
                                      var bool = await Utils()
                                          .check(scaffoldKey);

                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SyncDataCloudToMobileScreen(),
                                          ),
                                          ModalRoute.withName(""));
                                    }
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    isGoogleSignInBtnClicked =
                                    false;
                                  });
                                });
                              } catch (e) {
                                Utils.customPrint('EXE: $e');
                                // TODO handle
                              }
                            }
                          }
                        },
                        child: Container(
                          height: displayHeight(context) * 0.067,
                          width: displayWidth(context) * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: authBtnColors
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              commonText(
                                  context: context,
                                  text: 'Sign In with',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.034,
                                  textAlign: TextAlign.start,
                                  fontFamily: outfit
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  height: displayHeight(context) * 0.035,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: displayHeight(context) * 0.02),
                      commonText(
                          context: context,
                          text: '- - - - - - - - - - - - - - - -   Or   - - - - - - - - - - - - - - - -',
                          fontWeight: FontWeight.w500,
                          textColor: blueColor,
                          textSize: displayWidth(context) * 0.035,
                          textAlign: TextAlign.start,
                          fontFamily: outfit
                      ),
                      SizedBox(height: displayHeight(context) * 0.02),
                      Form(
                        key: emailFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: CommonTextField(
                          //key: emailFormFieldKey,
                            controller: emailController,
                            focusNode: emailFocusNode,
                            labelText: 'Enter Your Email',
                            hintText: '',
                            suffixText: null,
                            textInputAction: TextInputAction.next,
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
                            }),
                      ),
                      SizedBox(height: displayHeight(context) * 0.012),
                      Form(
                        key: passwordFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: CommonTextField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            labelText: 'Enter Password',
                            hintText: '',
                            suffixText: null,
                            textInputAction: TextInputAction.done,
                            textInputType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 32,
                            prefixIcon: null,
                            requestFocusNode: null,
                            obscureText: true,
                            onTap: () {},
                            onFieldSubmitted: (value) {},
                            onChanged: (String value) {},
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Password';
                              } else if (!RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                                  .hasMatch(value)) {
                                return 'Invalid Password';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              Utils.customPrint(value);
                            }),
                      ),
                      SizedBox(height: displayHeight(context) * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          TextButton(
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return ForgotPassword();
                                    }));
                              }, child: commonText(
                              context: context,
                              text: 'Forgot Password?',
                              fontWeight: FontWeight.w500,
                              textColor: blueColor,
                              textSize: displayWidth(context) * 0.034,
                              textAlign: TextAlign.start,
                              fontFamily: outfit
                          )),

                          isLoginBtnClicked!
                              ? Container(
                            width: displayWidth(context) * 0.45,
                                child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      blueColor),
                                )),
                              )
                              : CommonButtons.getActionButton(
                              title: 'Sign In',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              width: displayWidth(context) * 0.45,
                              onTap: () async {

                                if (emailFormKey.currentState!.validate() && passwordFormKey.currentState!.validate()) {
                                  bool check = await Utils().check(scaffoldKey);

                                  Utils.customPrint("NETWORK $check");

                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());

                                  if (check) {
                                    setState(() {
                                      isLoginBtnClicked = true;
                                    });

                                    if (isLoginByEmailId!) {
                                      commonProvider
                                          .login(
                                          context,
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                          false,
                                          "",
                                          scaffoldKey)
                                          .then((value) {
                                        setState(() {
                                          isLoginBtnClicked = false;
                                        });

                                        if (value != null) {
                                          if (value.status!) {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SyncDataCloudToMobileScreen(),
                                                ),
                                                ModalRoute.withName(""));
                                          }
                                        }
                                      }).catchError((e) {
                                        setState(() {
                                          isLoginBtnClicked = false;
                                        });
                                      });
                                    } else {}
                                  }

                                }
                              }),
                        ],
                      ),

                      SizedBox(height: displayHeight(context) * 0.02),

                    ],
                  ),
                ),
              )
          ),
        ),
      ),
    );
  }
}
