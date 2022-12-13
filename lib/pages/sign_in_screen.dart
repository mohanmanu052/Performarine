import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/zig_zag_line_widget.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lets_get_started_screen.dart';
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
    print('hello world from search . the value is $value');
  }

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();

    //emailFormFieldKey = GlobalKey<FormFieldState>();
    //passwordFormFieldKey = GlobalKey<FormFieldState>();

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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LetsGetStartedScreen(),
            ),
            ModalRoute.withName(""));
        return false;
      },
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LetsGetStartedScreen(),
                  ),
                  ModalRoute.withName(""));
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
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
                          labelText: null,
                          hintText: 'Email',
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
                            print(value);
                          }),
                      SizedBox(height: displayHeight(context) * 0.03),
                      CommonTextField(
                          // key: passwordFormFieldKey,
                          controller: passwordController,
                          focusNode: passwordFocusNode,
                          labelText: null,
                          hintText: 'Password',
                          suffixText: null,
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 32,
                          prefixIcon: null,
                          requestFocusNode: null,
                          obscureText: true,
                          onTap: () {
                            //emailFormFieldKey.currentState!.validate();
                          },
                          onFieldSubmitted: (value) {
                            // passwordFormFieldKey.currentState!.validate();
                          },
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
                            print(value);
                          }),
                      SizedBox(height: displayHeight(context) * 0.04),
                      /* commonText(
                          context: context,
                          text: 'Or sign in with Phone',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start),
                      SizedBox(height: displayHeight(context) * 0.03),
                      Row(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode:
                                        true, // optional. Shows phone code before the country name.
                                    onSelect: (Country country) {
                                      if (country == null) {
                                        setState(() {
                                          validateCountryCodeWidget = true;
                                        });
                                      } else {
                                        setState(() {
                                          validateCountryCodeWidget = false;
                                          selectedCountryCode =
                                              country.phoneCode;
                                        });
                                      }
                                    },
                                  );
                                },
                                child: Container(
                                  height: displayHeight(context) * 0.06,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        width: 1.5,
                                        color: validateCountryCodeWidget
                                            ? Colors.red.shade300
                                                .withOpacity(0.7)
                                            : Colors.grey.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: commonText(
                                        context: context,
                                        text: selectedCountryCode ?? '+ **',
                                        fontWeight: FontWeight.w500,
                                        textColor: selectedCountryCode == null
                                            ? Colors.grey
                                            : Colors.black,
                                        textSize: displayWidth(context) * 0.04,
                                        textAlign: TextAlign.start),
                                  ),
                                ),
                              ),
                              validateCountryCodeWidget
                                  ? Column(
                                      children: [
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        commonText(
                                            context: context,
                                            text: 'Select',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.red,
                                            textSize:
                                                displayWidth(context) * 0.03,
                                            textAlign: TextAlign.start),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CommonTextField(
                                controller: phoneController,
                                focusNode: phoneFocusNode,
                                labelText: 'Enter Phone Number',
                                hintText: '999 999 9999',
                                suffixText: null,
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 10,
                                prefixIcon: null,
                                requestFocusNode: null,
                                obscureText: false,
                                onTap: () {},
                                onChanged: (String value) {},
                                validator: (value) {
                                  if (isLoginByMobileNumber) {
                                    if (value!.isEmpty) {
                                      return 'Enter Mobile Number';
                                    }
                                    if (value.length > 10 ||
                                        value.length < 10) {
                                      return 'Enter Valid Mobile Number';
                                    }

                                    return null;
                                  }

                                  return null;
                                },
                                onSaved: (String value) {
                                  print(value);
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: displayHeight(context) * 0.04),*/
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
                              /* Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/apple_logo.png',
                                  height: displayHeight(context) * 0.04,
                                ),
                              ),
                              SizedBox(
                                width: displayWidth(context) * 0.045,
                              ),*/
                              isGoogleSignInBtnClicked!
                                  ? Center(child: CircularProgressIndicator())
                                  : InkWell(
                                      onTap: () async {
                                        // GoogleSignInAccount?
                                        //     googleSignInAccount;
                                        //
                                        // if (await googleSignIn.isSignedIn()) {
                                        //   googleSignIn.signOut();
                                        //   googleSignInAccount =
                                        //       await googleSignIn.signIn();
                                        // } else {
                                        //   googleSignInAccount =
                                        //       await googleSignIn.signIn();
                                        // }
                                        //
                                        // if (googleSignInAccount == null) {
                                        //   // TODO handle
                                        //   setState(() {
                                        //     isGoogleSignInBtnClicked = false;
                                        //   });
                                        // }
                                        // else {
                                        //   try {
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.id}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.email}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.displayName}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.photoUrl}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.serverAuthCode}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.authHeaders}');
                                        //     // print(
                                        //     //     'NAME: ${googleSignInAccount!.toString()}');
                                        //
                                        //     setState(() {
                                        //       isGoogleSignInBtnClicked = true;
                                        //     });
                                        //
                                        //     commonProvider
                                        //         .login(
                                        //             context,
                                        //             googleSignInAccount.email,
                                        //             "",
                                        //             true,
                                        //             googleSignInAccount.id,
                                        //             scaffoldKey)
                                        //         .then((value) {
                                        //       setState(() {
                                        //         isGoogleSignInBtnClicked =
                                        //             false;
                                        //       });
                                        //
                                        //       if (value != null) {
                                        //         if (value.status!) {
                                        //           setState(() {
                                        //             isGoogleSignInBtnClicked =
                                        //                 false;
                                        //           });
                                        //           Navigator.pushAndRemoveUntil(
                                        //               context,
                                        //               MaterialPageRoute(
                                        //                 builder: (context) =>
                                        //                     const HomePage(),
                                        //               ),
                                        //               ModalRoute.withName(""));
                                        //         }
                                        //       }
                                        //     }).catchError((e) {
                                        //       setState(() {
                                        //         isGoogleSignInBtnClicked =
                                        //             false;
                                        //       });
                                        //     });
                                        //
                                        //     //getAuthenticatedClient(context);
                                        //   } catch (e) {
                                        //     print('EXE: $e');
                                        //     // TODO handle
                                        //   }
                                        // }
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
                          ? Center(child: CircularProgressIndicator())
                          : CommonButtons.getActionButton(
                              title: 'Sign In',
                              context: context,
                              fontSize: displayWidth(context) * 0.042,
                              textColor: Colors.white,
                              buttonPrimaryColor: buttonBGColor,
                              borderColor: buttonBGColor,
                              width: displayWidth(context),
                              onTap: () {
                                /*if (isLoginByMobileNumber) {
                                  if (selectedCountryCode == null) {
                                    setState(() {
                                      validateCountryCodeWidget = true;
                                      isGoogleSignInBtnClicked = false;
                                    });
                                    return;
                                  }
                                }*/

                                /* if (!isLoginByEmailId &&
                                    !isLoginByMobileNumber) {
                                  Get.showSnackbar(GetSnackBar(
                                    message: 'Please enter valid details',
                                    duration: Duration(seconds: 2),
                                  ));
                                  return;
                                }*/

                                /*if (formKey.currentState!.validate()) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());

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
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomePage(),
                                              ),
                                              ModalRoute.withName(""));
                                        }
                                      }
                                    }).catchError((e) {
                                      setState(() {
                                        isLoginBtnClicked = false;
                                      });
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => VerifyOtpScreen(
                                                countryCode:
                                                    selectedCountryCode!,
                                                mobileNumber:
                                                    phoneController.text,
                                              )),
                                    );
                                  }
                                }*/
                              }),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      /* GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordScreen()),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Forgot Password?',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.034,
                            textAlign: TextAlign.start),
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
