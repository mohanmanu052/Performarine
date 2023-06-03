import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/zig_zag_line_widget.dart';
import 'package:performarine/pages/authentication/sign_up_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lets_get_started_screen.dart';
import 'package:performarine/pages/sync_data_cloud_to_mobile_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //GlobalKey<FormFieldState> emailFormFieldKey = GlobalKey<FormFieldState>();
  //GlobalKey<FormFieldState> passwordFormFieldKey = GlobalKey<FormFieldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();

  String? selectedCountryCode;

  bool validateCountryCodeWidget = false,
      isLoginByEmailId = true,
      isLoginByMobileNumber = false;
  bool? isLoginBtnClicked = false, isGoogleSignInBtnClicked = false;

  late CommonProvider commonProvider;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Timer? searchOnStoppedTyping;

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
        () => searchOnStoppedTyping = new Timer(duration, () => search(value)));
  }

  search(value) {
    Utils.customPrint('hello world from search . the value is $value');
  }

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();

    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        setState(() {
          isLoginByEmailId = true;
          isLoginByMobileNumber = false;
          phoneController.clear();
          selectedCountryCode = null;
        });
      }
    });

    phoneController.addListener(() {
      if (phoneController.text.isNotEmpty || selectedCountryCode != null) {
        setState(() {
          isLoginByEmailId = false;
          isLoginByMobileNumber = true;
          emailController.clear();
          passwordController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: commonBackgroundColor,
        /*leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();

            */ /*Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LetsGetStartedScreen(),
                ),
                ModalRoute.withName(""));*/ /*
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),*/
        centerTitle: true,
        title: commonText(
            context: context,
            text: 'Sign In',
            fontWeight: FontWeight.w600,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.05,
            textAlign: TextAlign.start),
      ),
      body: Stack(
        children: [
          Positioned(
              left: 0,
              bottom: displayHeight(context) * 0.06,
              child: ZigZagLineWidget()),
          Form(
            key: formKey,
            //autovalidateMode: AutovalidateMode.,
            child: Container(
              height: displayHeight(context),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: displayHeight(context) * 0.08),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      child: Image.asset(
                        'assets/images/sign_in_img.png',
                      ),
                    ),
                    SizedBox(height: displayHeight(context) * 0.08),
                    CommonTextField(
                        //key: emailFormFieldKey,
                        controller: emailController,
                        focusNode: emailFocusNode,
                        labelText: 'Email',
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
                            return 'Enter email';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          //emailFormFieldKey.currentState!.validate();
                          /* FocusScope.of(context)
                              .requestFocus(passwordFocusNode);*/
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.03),
                    CommonTextField(
                        // key: passwordFormFieldKey,
                        controller: passwordController,
                        focusNode: passwordFocusNode,
                        labelText: 'Password',
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
                            return 'Invalid password';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        commonText(
                            context: context,
                            text: 'Sign In with',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                            textAlign: TextAlign.start),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            isGoogleSignInBtnClicked!
                                ? Center(
                                    child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        circularProgressColor),
                                  ))
                                : InkWell(
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
                                                  /*Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomePage(),
                                                    ),
                                                    ModalRoute.withName(""));*/
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'assets/images/google_logo.png',
                                        height: displayHeight(context) * 0.04,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: displayHeight(context) * 0.04),
                    isLoginBtnClicked!
                        ? Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                circularProgressColor),
                          ))
                        : CommonButtons.getActionButton(
                            title: 'Sign In',
                            context: context,
                            fontSize: displayWidth(context) * 0.042,
                            textColor: Colors.white,
                            buttonPrimaryColor: buttonBGColor,
                            borderColor: buttonBGColor,
                            width: displayWidth(context),
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                bool check = await Utils().check(scaffoldKey);

                                Utils.customPrint("NETWORK $check");

                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                if (check) {
                                  setState(() {
                                    isLoginBtnClicked = true;
                                  });

                                  if (isLoginByEmailId) {
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
                                          /*Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage(),
                                            ),
                                            ModalRoute.withName(""));*/

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
                    SizedBox(
                      height: displayHeight(context) * 0.02,
                    ),
                    RichText(
                      text: TextSpan(
                          text: 'Don’t have an account?',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: poppins,
                              fontStyle: FontStyle.normal,
                              fontSize: displayWidth(context) * 0.032),
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SignUpScreen();
                                    }));
                                  },
                                text: ' SignUp',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: poppins,
                                    fontStyle: FontStyle.normal,
                                    fontSize: displayWidth(context) * 0.035)),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
