import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/urls.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_dropdown.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../provider/common_provider.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';

import '../web_navigation/privacy_and_policy_web_view.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> countyFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> countryCodeFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> zipCodeFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> createPassFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> confirmPassFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> firstNameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> lastNameFormKey = GlobalKey<FormState>();

  late TextEditingController countryController;
  late TextEditingController countryCodeController;
  late TextEditingController zipCodeController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController createPasswordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;

  late FocusNode countryFocusNode = FocusNode();
  late FocusNode countryCodeFocusNode = FocusNode();
  late FocusNode zipCodeFocusNode = FocusNode();
  late FocusNode emailFocusNode = FocusNode();
  late FocusNode phoneFocusNode = FocusNode();
  late FocusNode createPasswordFocusNode = FocusNode();
  late FocusNode confirmPasswordFocusNode = FocusNode();
  late FocusNode firstNameFocusNode = FocusNode();
  late FocusNode lastNameFocusNode = FocusNode();

  String? selectedCountryCode, selectedCountry;

  bool validateCountryCodeWidget = false,
      isConfirmPasswordValid = false,
      isRegistrationBtnClicked = false,
      isGoogleSignInBtnClicked = false,
      isAppleSignUpBtnClicked = false;
  bool isChecked = false;

  late CommonProvider commonProvider;
  String page = "Sign_up_screen";

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();

    countryController = TextEditingController();
    countryCodeController = TextEditingController(text: "+1");
    zipCodeController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    createPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    countryController.dispose();
    countryCodeController.dispose();
    zipCodeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: Form(
            child: SingleChildScrollView(
          child: Container(
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
                SizedBox(height: displayHeight(context) * 0.03),
                commonText(
                    context: context,
                    text: 'Register',
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.043,
                    textAlign: TextAlign.start,
                    fontFamily: outfit),
                SizedBox(height: displayHeight(context) * 0.02),
                InkWell(
                  onTap: () async {
                    bool check = await Utils().check(scaffoldKey);

                    if (check) {
                      GoogleSignInAccount? googleSignInAccount;

                      if (await googleSignIn.isSignedIn()) {
                        googleSignIn.signOut();
                        googleSignInAccount = await googleSignIn.signIn();
                      } else {
                        googleSignInAccount = await googleSignIn.signIn();
                      }

                      if (googleSignInAccount == null) {
                        // TODO handle
                        setState(() {
                          isGoogleSignInBtnClicked = false;
                        });
                      } else
                      {
                        try {
                          Utils.customPrint('NAME: ${googleSignInAccount.id}');
                          Utils.customPrint(
                              'Email: ${googleSignInAccount.email}');
                          Utils.customPrint(
                              'Display Name: ${googleSignInAccount.displayName}');
                          Utils.customPrint(
                              'PhotoURL: ${googleSignInAccount.photoUrl}');
                          Utils.customPrint(
                              'ServerAuthCode: ${googleSignInAccount.serverAuthCode}');
                          Utils.customPrint(
                              'AuthHeaders: ${googleSignInAccount.authHeaders}');
                          Utils.customPrint(
                              'Google SignIn Account: ${googleSignInAccount.toString()}');

                          CustomLogger().logWithFile(Level.info,
                              "NAME: ${googleSignInAccount.id} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "Email: ${googleSignInAccount.email} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "Display Name: ${googleSignInAccount.displayName} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "PhotoURL: ${googleSignInAccount.photoUrl} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "ServerAuthCode: ${googleSignInAccount.serverAuthCode} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "AuthHeaders: ${googleSignInAccount.authHeaders} -> $page");
                          CustomLogger().logWithFile(Level.info,
                              "Google SignIn Account: ${googleSignInAccount.toString()} -> $page");

                          setState(() {
                            isGoogleSignInBtnClicked = true;
                          });

                          commonProvider
                              .registerUser(
                            context,
                            googleSignInAccount.email,
                            '',
                            "",
                            '',
                            '',
                            '',
                            '',
                            '',
                            true,
                            false,
                            googleSignInAccount.id,
                            googleSignInAccount.photoUrl ?? '',
                            scaffoldKey,
                            googleSignInAccount.displayName?.split(' ').first,
                            googleSignInAccount.displayName?.split(' ').last,
                          )
                              .then((value) {
                            setState(() {
                              isGoogleSignInBtnClicked = false;
                            });

                            if (value != null) {
                              setState(() {
                                isGoogleSignInBtnClicked = false;
                              });

                              if (value.status!) {
                                setState(() {
                                  isGoogleSignInBtnClicked = false;
                                });
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignInScreen(calledFrom: 'SignUp'),
                                      ),
                                      ModalRoute.withName(""));
                                });
                              } else {
                                setState(() {
                                  isGoogleSignInBtnClicked = false;
                                });
                              }
                            } else {
                              setState(() {
                                isGoogleSignInBtnClicked = false;
                              });
                            }
                          }).catchError((e) {
                            setState(() {
                              isGoogleSignInBtnClicked = false;
                            });
                          });
                        } catch (e) {
                          Utils.customPrint('EXE: $e');
                          CustomLogger()
                              .logWithFile(Level.error, "EXE: $e -> $page");
                          // TODO handle
                        }
                      }
                    }
                  },
                  child: isGoogleSignInBtnClicked
                      ? SizedBox(
                          height: displayHeight(context) * 0.067,
                          width: displayWidth(context) * 0.9,
                          child: Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(blueColor),
                          )),
                        )
                      : Container(
                          height: displayHeight(context) * 0.067,
                          width: displayWidth(context) * 0.9,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: authBtnColors),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              commonText(
                                  context: context,
                                  text: 'Sign Up with',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.03,
                                  textAlign: TextAlign.start,
                                  fontFamily: outfit),
                              SizedBox(width: displayWidth(context) * 0.04),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  height: displayHeight(context) * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: displayHeight(context) * 0.012),
                InkWell(
                  onTap: ()async{

                    bool check = await Utils().check(scaffoldKey);

                    if (check) {
                      User? user = await signInWithApple();

                      if (user == null) {
                        // TODO handle
                        setState(() {
                          isAppleSignUpBtnClicked = false;
                        });
                      } else
                      {
                        try {

                          Utils.customPrint('APPLE Id: ${user.uid}');
                          Utils.customPrint('APPLE NAME: ${user.displayName}');
                          Utils.customPrint('APPLE Email: ${user.email}');
                          Utils.customPrint('APPLE Display Name: ${user.displayName}');
                          Utils.customPrint('APPLE PhotoURL: ${user.photoURL}');
                          Utils.customPrint('APPLE ServerAuthCode: ${user.refreshToken}');
                          Utils.customPrint('APPLE AuthHeaders: ${user.metadata}');
                          Utils.customPrint('APPLE Apple SignIn Account: ${user.toString()}');

                          setState(() {
                            isAppleSignUpBtnClicked = true;
                          });

                          Future.delayed(Duration(seconds: 2), (){
                            setState(() {
                              isAppleSignUpBtnClicked = false;
                            });
                          });

                          debugPrint("APPLE SIGN UP FIRST NAME ${user.displayName?.split(' ').first}");
                          debugPrint("APPLE SIGN UP LAST NAME ${user.displayName?.split(' ').last}");

                          commonProvider
                              .registerUser(
                            context,
                            user.email!,
                            '',
                            "",
                            '',
                            '',
                            '',
                            '',
                            '',
                            true,
                            true,
                            user.uid,
                            user.photoURL ?? '',
                            scaffoldKey,
                            user.displayName?.split(' ').first ?? '',
                            user.displayName?.split(' ').last ?? '',
                          )
                              .then((value) {
                            setState(() {
                              isAppleSignUpBtnClicked = false;
                            });

                            if (value != null) {
                              setState(() {
                                isAppleSignUpBtnClicked = false;
                              });

                              if (value.status!) {
                                setState(() {
                                  isAppleSignUpBtnClicked = false;
                                });
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignInScreen(calledFrom: 'SignUp'),
                                      ),
                                      ModalRoute.withName(""));
                                });
                              } else {
                                setState(() {
                                  isAppleSignUpBtnClicked = false;
                                });
                              }
                            } else {
                              setState(() {
                                isAppleSignUpBtnClicked = false;
                              });
                            }
                          }).catchError((e) {
                            setState(() {
                              isAppleSignUpBtnClicked = false;
                            });
                          });
                        } catch (e) {
                          Utils.customPrint('EXE: $e');
                          CustomLogger()
                              .logWithFile(Level.error, "EXE: $e -> $page");
                          // TODO handle
                        }
                      }
                    }

                  },
                  child: isAppleSignUpBtnClicked
                    ? SizedBox(
                    height: displayHeight(context) * 0.067,
                    width: displayWidth(context) * 0.9,
                    child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(blueColor),
                        )),
                  )
                  : Container(
                    height: displayHeight(context) * 0.067,
                    width: displayWidth(context) * 0.9,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(15)),
                        color: Color(0xFF0C0C0C)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        commonText(
                            context: context,
                            text: 'Sign Up with',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.white,
                            textSize: displayWidth(context) * 0.03,
                            textAlign: TextAlign.start,
                            fontFamily: outfit),
                        SizedBox(width: displayWidth(context) * 0.04),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Image.asset(
                            'assets/images/apple_icon.png',
                            height: displayHeight(context) * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.012),
                commonText(
                    context: context,
                    text:
                        '- - - - - - - - - - - - - - - -   Or   - - - - - - - - - - - - - - - -',
                    fontWeight: FontWeight.w500,
                    textColor: blueColor,
                    textSize: displayWidth(context) * 0.035,
                    textAlign: TextAlign.start,
                    fontFamily: outfit),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: countyFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    margin: EdgeInsets.only(top: 8.0),
                    //  height: displayHeight(context) * 0.06,
                    child: CommonDropDownFormField(
                      context: context,
                      value: selectedCountry,
                      hintText: 'Select your Country',
                      labelText: '',
                      onChanged: (String value) {
                        setState(() {
                          selectedCountry = value;
                          zipCodeController.clear();
                          Utils.customPrint('country $selectedCountry');
                          CustomLogger().logWithFile(
                              Level.info, "country $selectedCountry -> $page");
                        });
                      },
                      dataSource: [
                        'USA',
                        'Canada',
                      ],
                      borderRadius: 10,
                      padding: 6,
                      textColor: Colors.black,
                      textField: 'key',
                      valueField: 'value',
                      validator: (value) {
                        if (value == null) {
                          return 'Select your Country';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.004),
                Form(
                  key: zipCodeFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: zipCodeController,
                      focusNode: zipCodeFocusNode,
                      labelText:
                          selectedCountry == 'USA' ? 'Zip Code' : 'Postal Code',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: selectedCountry == 'USA'
                          ? TextInputType.number
                          : TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: null, //selectedCountry == 'USA' ? 5 : 7,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: false,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          if (selectedCountry == 'USA') {
                            return 'Enter Zip Code';
                          } else {
                            return 'Enter Postal Code';
                          }
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info,
                            "Zip code or Postal Code $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: firstNameFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: firstNameController,
                      focusNode: firstNameFocusNode,
                      labelText: 'Enter Your First Name',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.name,
                      textCapitalization: TextCapitalization.none,
                      maxLength: 52,
                      prefixIcon: null,
                      requestFocusNode: lastNameFocusNode,
                      obscureText: false,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your First Name';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "First Name $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: lastNameFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: lastNameController,
                      focusNode: lastNameFocusNode,
                      labelText: 'Enter Your Last Name',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.name,
                      textCapitalization: TextCapitalization.none,
                      maxLength: 52,
                      prefixIcon: null,
                      requestFocusNode: emailFocusNode,
                      obscureText: false,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your Last Name';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "Last Name $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: emailFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      labelText: 'Enter Your Email',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      maxLength: 52,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: false,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
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
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger()
                            .logWithFile(Level.info, "Email $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: phoneFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: phoneController,
                      focusNode: phoneFocusNode,
                      labelText: 'Enter Phone Number',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 10,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: false,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Phone Number';
                        }
                        if (value.length > 10 || value.length < 10) {
                          return 'Enter Valid Phone Number';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "Phone Number $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: createPassFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: createPasswordController,
                      focusNode: createPasswordFocusNode,
                      labelText: 'Create Password',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 32,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: true,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        } else if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                            .hasMatch(value)) {
                          return 'Password must contain at least 8 characters and \n include : \n * At least one lowercase letter (a-z) \n '
                              '* At least one uppercase letter (A-Z) \n * At least one number (0-9) \n * At least one special character (e.g: !.@#\$&*~)';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "Create Password $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Form(
                  key: confirmPassFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocusNode,
                      labelText: 'Confirm Password',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 32,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: true,
                      onFieldSubmitted: (value) {},
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          isConfirmPasswordValid = false;
                          return 'Enter Confirm Password';
                        } else if (createPasswordController.text !=
                            confirmPasswordController.text) {
                          isConfirmPasswordValid = false;
                          return "Passwords Don\'t Match";
                        }

                        isConfirmPasswordValid = true;

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "Confirm Password $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Padding(
                  padding: EdgeInsets.only(left: displayWidth(context) * 0.04),
                  child: CircularRadioTile(
                    isChecked: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    },
                    value: isChecked,
                    title: RichText(
                      text: TextSpan(
                        text: 'By clicking on register you accept',
                        style: TextStyle(
                          fontFamily: outfit,
                          color: Colors.black,
                          fontSize: displayWidth(context) * 0.025,
                          fontWeight: FontWeight.w400,
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
                                  color: Color(0xFF42B5BF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: displayWidth(context) * 0.026)),
                          TextSpan(
                              text: ' and ',
                              style: TextStyle(
                                  fontFamily: outfit,
                                  color: Colors.black,
                                  fontSize: displayWidth(context) * 0.025)),
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
                                  color: Color(0xFF42B5BF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: displayWidth(context) * 0.026)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.02),
                isRegistrationBtnClicked
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(blueColor),
                      ))
                    : CommonButtons.getActionButton(
                        title: 'Register',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        width: displayWidth(context),
                        onTap: () async {
                          if (countyFormKey.currentState!.validate() &&
                              zipCodeFormKey.currentState!.validate() &&
                              firstNameFormKey.currentState!.validate() &&
                              lastNameFormKey.currentState!.validate() &&
                              emailFormKey.currentState!.validate() &&
                              phoneFormKey.currentState!.validate() &&
                              createPassFormKey.currentState!.validate() &&
                              confirmPassFormKey.currentState!.validate()) {
                            if (isChecked) {
                              bool check = await Utils().check(scaffoldKey);

                              if (check) {
                                setState(() {
                                  isRegistrationBtnClicked = true;
                                });

                                commonProvider
                                    .registerUser(
                                        context,
                                        emailController.text
                                            .toLowerCase()
                                            .trim(),
                                        createPasswordController.text.trim(),
                                        "+1",
                                        phoneController.text.trim(),
                                        selectedCountry!,
                                        zipCodeController.text.trim(),
                                        "",
                                        "",
                                        false,
                                        false,
                                        "",
                                        "",
                                        scaffoldKey,
                                        firstNameController.text.trim(),
                                        lastNameController.text.trim())
                                    .then((value) {
                                  setState(() {
                                    isRegistrationBtnClicked = false;
                                  });

                                  if (value != null) {
                                    setState(() {
                                      isRegistrationBtnClicked = false;
                                    });

                                    if (value.status!) {
                                      setState(() {
                                        isRegistrationBtnClicked = false;
                                      });

                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInScreen(
                                                      calledFrom: 'SignUp'),
                                            ),
                                            ModalRoute.withName(""));
                                      });
                                    }
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    isRegistrationBtnClicked = false;
                                  });
                                });
                              }
                            } else {
                              Utils.showSnackBar(context,
                                  scaffoldKey: scaffoldKey,
                                  message:
                                      "Please accept Terms and Conditions and Privacy Policy.");
                            }
                          }
                        }),
                SizedBox(
                  height: displayHeight(context) * 0.02,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                        text: 'Already Member?',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: outfit,
                            fontStyle: FontStyle.normal,
                            fontSize: displayWidth(context) * 0.032),
                        children: [
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignInScreen(calledFrom: 'SignUp'),
                                    ),
                                  );
                                },
                              text: ' Sign In',
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: outfit,
                                  fontStyle: FontStyle.normal,
                                  fontSize: displayWidth(context) * 0.035)),
                        ]),
                  ),
                ),
                SizedBox(
                  height: displayHeight(context) * 0.03,
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    try {
      /// You have to put your service id here which you can find in previous steps
      /// or in the following link: https://developer.apple.com/account/resources/identifiers/list/serviceId
      String clientID = 'com.performarine.service';

      /// Now you have to put the redirectURL which you received from Glitch Server
      /// make sure you only copy the part till "https://<GLITCH PROVIDED UNIQUE NAME>.glitch.me/"
      /// and append the following part to it "callbacks/sign_in_with_apple"
      ///
      /// It will look something like this
      /// https://<GLITCH PROVIDED UNIQUE NAME>.glitch.me/callbacks/sign_in_with_apple
      String redirectURL =
          'https://performarine.glitch.me/callbacks/sign_in_with_apple';

      /// Generates a Random String from 1-9 and A-Z characters.
      final rawNonce = generateNonce();

      /// We are convering that rawNonce into SHA256 for security purposes
      /// In our login.
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(

        /// Scopes are the values that you are requiring from
        /// Apple Server.
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: Platform.isIOS ? nonce : null,

        /// We are providing Web Authentication for Android Login,
        /// Android uses web browser based login for Apple.
        webAuthenticationOptions: Platform.isIOS
            ? null
            : WebAuthenticationOptions(
          clientId: clientID,
          redirectUri: Uri.parse(redirectURL),
        ),
      );

      final AuthCredential appleAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: Platform.isIOS ? rawNonce : null,
        accessToken: Platform.isIOS ? null : appleCredential.authorizationCode,
      );

      /// Once you are successful in generating Apple Credentials,
      /// We pass them into the Firebase function to finally sign in.
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(appleAuthCredential);

      return userCredential.user;

    } catch (e) {
      rethrow;
    }
  }
}

class CircularRadioTile extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final bool? isChecked;

  CircularRadioTile(
      {this.value, this.onChanged, this.title, this.isChecked = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged!(!value!);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isChecked! ? checkColor : Colors.transparent,
              border: Border.all(
                color: isChecked! ? Colors.transparent : Colors.grey,
                width: 2,
              ),
            ),
            child: isChecked!
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
          SizedBox(width: displayWidth(context) * 0.03),
          Expanded(child: title!),
        ],
      ),
    );
  }
}
