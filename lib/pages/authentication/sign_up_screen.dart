import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_dropdown.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/zig_zag_line_widget.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/coming_soon_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

import '../web_navigation/privacy_and_policy_web_view.dart';
import '../web_navigation/terms_and_condition_web_view.dart';

//Sign up page
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController countryController;
  late TextEditingController countryCodeController;
  late TextEditingController zipCodeController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController createPasswordController;
  late TextEditingController confirmPasswordController;

  late FocusNode countryFocusNode = FocusNode();
  late FocusNode countryCodeFocusNode = FocusNode();
  late FocusNode zipCodeFocusNode = FocusNode();
  late FocusNode emailFocusNode = FocusNode();
  late FocusNode phoneFocusNode = FocusNode();
  late FocusNode createPasswordFocusNode = FocusNode();
  late FocusNode confirmPasswordFocusNode = FocusNode();

  String? selectedCountryCode, selectedCountry, latitude, longitude;

  bool validateCountryCodeWidget = false,
      isConfirmPasswordValid = false,
      isRegistrationBtnClicked = false,
      isGoogleSignInBtnClicked = false;
  bool isChecked = false;

  late CommonProvider commonProvider;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();

    countryController = TextEditingController();
    countryCodeController = TextEditingController(text: "+1");
    zipCodeController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    createPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: commonBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        centerTitle: true,
        title: commonText(
            context: context,
            text: 'Register',
            fontWeight: FontWeight.w600,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.05,
            textAlign: TextAlign.start),
      ),
      body: Stack(
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/registration_img.png',
                height: displayHeight(context) * 0.65,
              )),
          Positioned(
              right: 0,
              top: displayHeight(context) * 0.06,
              child: const ZigZagLineWidget()),
          Positioned(
              left: 0,
              bottom: displayHeight(context) * 0.06,
              child: const ZigZagLineWidget()),
          Container(
            height: displayHeight(context),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                //autovalidate: _autoValidate
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: displayHeight(context) * 0.06),
                    Row(
                      children: [
                        commonText(
                            context: context,
                            text: 'Sign Up with',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                            textAlign: TextAlign.start),
                        SizedBox(width: displayWidth(context) * 0.04),
                        isGoogleSignInBtnClicked
                            ? Center(
                                child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    circularProgressColor),
                              ))
                            : InkWell(
                                onTap: () async {
                                  bool check = await Utils().check(scaffoldKey);

                                  if (check) {
                                    GoogleSignInAccount? googleSignInAccount;

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
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.id}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.email}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.displayName}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.photoUrl}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.serverAuthCode}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.authHeaders}');
                                        Utils.customPrint(
                                            'NAME: ${googleSignInAccount.toString()}');

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
                                                googleSignInAccount.id,
                                                googleSignInAccount.photoUrl ??
                                                    '',
                                                scaffoldKey)
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
                                                isGoogleSignInBtnClicked =
                                                    false;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 2), () {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SignInScreen(),
                                                    ),
                                                    ModalRoute.withName(""));
// <<<<<<< Report-code-merge
// =======

// >>>>>>> Bug_loc_reports
                                              });
                                            } else {
                                              setState(() {
                                                isGoogleSignInBtnClicked =
                                                    false;
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
                                        // TODO handle
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: displayHeight(context) * 0.04,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: displayHeight(context) * 0.035),
                    Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: CommonDropDownFormField(
                        context: context,
                        value: selectedCountry,
                        hintText: 'Country\*',
                        labelText: '',
                        onChanged: (String value) {
                          setState(() {
                            selectedCountry = value;

                            Utils.customPrint('country $selectedCountry');
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
                            return 'Select Country';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        controller: zipCodeController,
                        focusNode: zipCodeFocusNode,
                        labelText: selectedCountry == 'USA'
                            ? 'Zip Code\*'
                            : 'Postal Code\*',
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
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        //key: registrationEmailFormFieldKey,
                        controller: emailController,
                        focusNode: emailFocusNode,
                        labelText: 'Email\*',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        maxLength: 52,
                        prefixIcon: null,
                        requestFocusNode: null,
                        obscureText: false,
                        onFieldSubmitted: (value) {
                          /*registrationEmailFormFieldKey.currentState!
                              .validate();*/
                        },
                        onTap: () {
                          //zipCodeFormFieldKey.currentState!.validate();
                        },
                        onChanged: (String value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Enter Valid Email';
                          } else if (EmailValidator.validate(value)) {
                            String emailExt = value.split('.').last;

                            if (!['com', 'in', 'us'].contains(emailExt)) {
                              return 'Enter valid email';
                            }
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        controller: phoneController,
                        focusNode: phoneFocusNode,
                        labelText: 'Enter Phone Number\*',
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
                            return 'Enter Mobile Number';
                          }
                          if (value.length > 10 || value.length < 10) {
                            return 'Enter Valid Mobile Number';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        controller: createPasswordController,
                        focusNode: createPasswordFocusNode,
                        labelText: 'Create Password\*',
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
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        labelText: 'Confirm Password\*',
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
                            return "Passwords don\'t match";
                          }

                          isConfirmPasswordValid = true;

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.03),
                    CircularRadioTile(
                      isChecked: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = !isChecked;
                        });},
                      value: isChecked,
                      title: RichText(
                        text: TextSpan(
                          text: 'By clicking on register you accept',
                          style: TextStyle(
                            fontFamily: poppins,
                            color: Colors.black,
                            fontSize: displayWidth(context) * 0.03,
                            fontWeight: FontWeight.w400,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: ' T&C',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return TermsAndConditionsWebView();
                                        }));
                                  },
                                style: TextStyle(
                                    fontFamily: poppins,
                                    color: Color(0xFF42B5BF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.032)),
                            TextSpan(
                                text: '\nand ',
                                style: TextStyle(
                                    fontFamily: poppins,
                                    color: Colors.black,
                                    fontSize: displayWidth(context) * 0.03)),
                            TextSpan(
                                text: ' Privacy Policy',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return PrivacyAndPolicyWebView();
                                        }));
                                  },
                                style: TextStyle(
                                    fontFamily: poppins,
                                    color: Color(0xFF42B5BF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: displayWidth(context) * 0.032)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: displayHeight(context) * 0.03),
                    isRegistrationBtnClicked
                        ? Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                circularProgressColor),
                          ))
                        : CommonButtons.getActionButton(
                            title: 'Register',
                            context: context,
                            fontSize: displayWidth(context) * 0.042,
                            textColor: Colors.white,
                            buttonPrimaryColor: buttonBGColor,
                            borderColor: buttonBGColor,
                            width: displayWidth(context),
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                if(isChecked){
                                  bool check = await Utils().check(scaffoldKey);

                                  if (check) {
                                    setState(() {
                                      isRegistrationBtnClicked = true;
                                    });

                                    commonProvider
                                        .registerUser(
                                        context,
                                        emailController.text,
                                        createPasswordController.text,
                                        "+1",
                                        phoneController.text,
                                        selectedCountry!,
                                        zipCodeController.text,
                                        "",
                                        "",
                                        false,
                                        "",
                                        "",
                                        scaffoldKey)
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

                                          Future.delayed(Duration(seconds: 2),
                                                  () {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SignInScreen(),
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
                                } else{
                                  Utils.showSnackBar(context,
                                      scaffoldKey: scaffoldKey, message: "Please accept Terms and Conditions and Privacy Policy.");
                                }

                              }
                            }),
                    SizedBox(
                      height: displayHeight(context) * 0.02,
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                            text: 'Already have an account?',
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
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignInScreen(),
                                          ),
                                          ModalRoute.withName(""));
                                    },
                                  text: ' Sign In',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: poppins,
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
            ),
          ),
        ],
      ),
    );
  }

}


class CircularRadioTile extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final bool? isChecked;

   CircularRadioTile({
     this.value,
     this.onChanged,
     this.title,
    this.isChecked = false
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged!(!value!);
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
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
              size: 16,
            )
                : null,
          ),
          SizedBox(width: 16),
          Expanded(child: title!),
        ],
      ),
    );
  }
}
