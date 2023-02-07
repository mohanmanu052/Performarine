import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_dropdown.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/zig_zag_line_widget.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/coming_soon_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /* GlobalKey<FormFieldState> zipCodeFormFieldKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> registrationEmailFormFieldKey =
      GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> phoneNumberFormFieldKey =
      GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> createPasswordFormFieldKey =
      GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> confirmPasswordFormFieldKey =
      GlobalKey<FormFieldState>();*/

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

    //getLocationData();
  }

  /*Future<LocationData> getLocationData() async {
    LocationData? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);

    latitude = locationData!.latitude!.toString();
    longitude = locationData.longitude!.toString();

    debugPrint('LAT ${latitude}');
    debugPrint('LONG ${longitude}');

    return locationData;
  }

  Future<bool> checkIfGPSIsEnabled() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      return true;
    } else {
      return false;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
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
                                      print('NAME: ${googleSignInAccount.id}');
                                      print(
                                          'NAME: ${googleSignInAccount.email}');
                                      print(
                                          'NAME: ${googleSignInAccount.displayName}');
                                      print(
                                          'NAME: ${googleSignInAccount.photoUrl}');
                                      print(
                                          'NAME: ${googleSignInAccount.serverAuthCode}');
                                      print(
                                          'NAME: ${googleSignInAccount.authHeaders}');
                                      print(
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
                                              isGoogleSignInBtnClicked = false;
                                            });
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SignInScreen()),
                                              );
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

                                      //getAuthenticatedClient(context);
                                    } catch (e) {
                                      print('EXE: $e');
                                      // TODO handle
                                    }
                                  }

                                  /// Above Code

                                  /*bool isGPSEnabled =
                                      await checkIfGPSIsEnabled();

                                  if (isGPSEnabled) {
                                    await getLocationData();
                                    if (selectedCountry == null) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please select country');
                                      return null;
                                    }

                                    */
                                  /*if (zipCodeController.text.isEmpty) {
                                      if (selectedCountry!.toLowerCase() ==
                                          'canada') {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please enter postal code');
                                        return null;
                                      } else {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message: 'Please enter zipcode');
                                        return null;
                                      }
                                    }*/ /*

                                    */
                                  /*if (phoneController.text.isEmpty) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message: 'Please enter phone number');
                                      return null;
                                    }*/ /*

                                    */
                                  /* if (selectedCountry!.toLowerCase() ==
                                        'canada') {
                                      bool? isCanada = hasThreeDigitsLetters(
                                          zipCodeController.text);

                                      if (zipCodeController.text.length != 7) {
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please enter a valid postal code like B3J 4B2');
                                        return null;
                                      } else if (!isCanada) {
                                        debugPrint('IS CANADA $isCanada');
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please enter a valid postal code like 92618');
                                        return null;
                                      }
                                    }*/
                                  /*

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
                                        print(
                                            'NAME: ${googleSignInAccount.id}');
                                        print(
                                            'NAME: ${googleSignInAccount.email}');
                                        print(
                                            'NAME: ${googleSignInAccount.displayName}');
                                        print(
                                            'NAME: ${googleSignInAccount.photoUrl}');
                                        print(
                                            'NAME: ${googleSignInAccount.serverAuthCode}');
                                        print(
                                            'NAME: ${googleSignInAccount.authHeaders}');
                                        print(
                                            'NAME: ${googleSignInAccount.toString()}');

                                        setState(() {
                                          isGoogleSignInBtnClicked = true;
                                        });

                                        commonProvider
                                            .registerUser(
                                                context,
                                                googleSignInAccount.email,
                                                createPasswordController.text,
                                                "+1",
                                                phoneController.text,
                                                selectedCountry!,
                                                zipCodeController.text,
                                                latitude,
                                                longitude,
                                                true,
                                                googleSignInAccount.id,
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
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignInScreen()),
                                                );
                                              });
                                            }
                                          }
                                        }).catchError((e) {
                                          setState(() {
                                            isGoogleSignInBtnClicked = false;
                                          });
                                        });

                                        //getAuthenticatedClient(context);
                                      } catch (e) {
                                        print('EXE: $e');
                                        // TODO handle
                                      }
                                    }
                                  } else {
                                    Utils.getLocationPermission(
                                        context, scaffoldKey);
                                  }*/
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.asset(
                                    'assets/images/google_logo.png',
                                    height: displayHeight(context) * 0.04,
                                  ),
                                ),
                              ),
                        /* Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/apple_logo.png',
                                height: displayHeight(context) * 0.04,
                              ),
                            ),
                            SizedBox(
                              width: displayWidth(context) * 0.045,
                            ),
                            isGoogleSignInBtnClicked
                                ? Center(child: CircularProgressIndicator())
                                : InkWell(
                                    onTap: () async {
                                      if (selectedCountry == null) {
                                        Utils.showSnackBar(
                                            scaffoldKey: scaffoldKey,
                                            message: 'Please select country');
                                        return null;
                                      }

                                      if (zipCodeController.text.isEmpty) {
                                        Utils.showSnackBar(
                                            scaffoldKey: scaffoldKey,
                                            message: 'Please enter zipcode');
                                        return null;
                                      }

                                      if (phoneController.text.isEmpty) {
                                        Utils.showSnackBar(
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please enter phone number');
                                        return null;
                                      }

                                      setState(() {
                                        isGoogleSignInBtnClicked = true;
                                      });

                                      googleSignInAccount =
                                          await googleSignIn.signIn();

                                      if (googleSignInAccount == null) {
                                        // TODO handle
                                      } else {
                                        try {
                                          print(
                                              'NAME: ${googleSignInAccount!.id}');
                                          print(
                                              'NAME: ${googleSignInAccount!.email}');
                                          print(
                                              'NAME: ${googleSignInAccount!.displayName}');
                                          print(
                                              'NAME: ${googleSignInAccount!.photoUrl}');
                                          print(
                                              'NAME: ${googleSignInAccount!.serverAuthCode}');
                                          print(
                                              'NAME: ${googleSignInAccount!.authHeaders}');
                                          print(
                                              'NAME: ${googleSignInAccount!.toString()}');

                                          commonProvider
                                              .registerUser(
                                                  googleSignInAccount!.email,
                                                  createPasswordController.text,
                                                  countryCodeController.text,
                                                  phoneController.text,
                                                  selectedCountry!,
                                                  zipCodeController.text,
                                                  latitude,
                                                  longitude,
                                                  true,
                                                  googleSignInAccount!.id,
                                                  scaffoldKey)
                                              .then((value) {
                                            setState(() {
                                              isGoogleSignInBtnClicked = false;
                                            });

                                            if (value != null) {
                                              setState(() {
                                                isGoogleSignInBtnClicked =
                                                    false;
                                              });

                                              if (value.status!) {
                                                setState(() {
                                                  isGoogleSignInBtnClicked =
                                                      false;
                                                });

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignInScreen()),
                                                );
                                              }
                                            }
                                          }).catchError((e) {
                                            setState(() {
                                              isGoogleSignInBtnClicked = false;
                                            });
                                          });

                                          //getAuthenticatedClient(context);
                                        } catch (e) {
                                          print('EXE: $e');
                                          // TODO handle
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
                        ),*/
                      ],
                    ),
                    //SizedBox(height: displayHeight(context) * 0.02),
                    SizedBox(height: displayHeight(context) * 0.035),
                    Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: CommonDropDownFormField(
                        context: context,
                        value: selectedCountry,
                        hintText: 'Country',
                        labelText: '',
                        onChanged: (String value) {
                          // formKey.currentState!.validate();

                          setState(() {
                            selectedCountry = value;

                            print('country $selectedCountry');
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
                            return 'Select country';
                          }
                          return null;
                        },
                      ),
                    ),
                    /*   CommonTextField(
                        controller: countryController,
                        focusNode: countryFocusNode,
                        labelText: 'Select Country',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 10,
                        prefixIcon: null,
                        requestFocusNode: null,
                        obscureText: false,
                        readOnly: true,
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode:
                                false, // optional. Shows phone code before the country name.
                            onSelect: (Country country) {
                              setState(() {
                                countryController.text = country.name;
                              });
                            },
                          );
                        },
                        onChanged: (String value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Select Country';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          print(value);
                        }),*/
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        //key: zipCodeFormFieldKey,
                        controller: zipCodeController,
                        focusNode: zipCodeFocusNode,
                        labelText: selectedCountry == 'USA'
                            ? 'Zip Code'
                            : 'Postal Code',
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
                        onFieldSubmitted: (value) {
                          //zipCodeFormFieldKey.currentState!.validate();
                        },
                        onTap: () {
                          //formKey.currentState!.reset();
                        },
                        onChanged: (String value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            if (selectedCountry == 'USA') {
                              return 'Enter zip code';
                            } else {
                              return 'Enter postal code';
                            }
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          print(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        //key: registrationEmailFormFieldKey,
                        controller: emailController,
                        focusNode: emailFocusNode,
                        labelText: 'Email',
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
                          print(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    /*   Row(
                      children: [
                        */ /*Column(
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
                                        selectedCountryCode = country.phoneCode;
                                      });
                                    }
                                  },
                                );
                              },
                              child: Container(
                                height: displayHeight(context) * 0.06,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      width: 1.5,
                                      color: validateCountryCodeWidget
                                          ? Colors.red.shade300.withOpacity(0.7)
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
                        ),*/ /*

                        */ /*Container(
                          height: displayHeight(context) * 0.06,
                          width: displayWidth(context) * 0.15,
                          child: CommonTextField(
                              controller: countryCodeController,
                              focusNode: countryCodeFocusNode,
                              labelText: '',
                              hintText: '',
                              suffixText: null,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.number,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 2,
                              prefixIcon: null,
                              requestFocusNode: null,
                              readOnly: true,
                              obscureText: false,
                              onTap: () {},
                              onChanged: (String value) {},
                              validator: (value) {
                                return null;
                              },
                              onSaved: (String value) {
                                print(value);
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: CommonTextField(
                              controller: phoneController,
                              focusNode: phoneFocusNode,
                              labelText: 'Enter Phone Number',
                              hintText: '9999999999',
                              suffixText: null,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.number,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 10,
                              prefixIcon: null,
                              requestFocusNode: null,
                              obscureText: false,
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
                                print(value);
                              }),
                        ),*/ /*

                        CommonTextField(
                            controller: phoneController,
                            focusNode: phoneFocusNode,
                            labelText: 'Enter Phone Number',
                            hintText: '999 999 9999',
                            suffixText: null,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.number,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 10,
                            prefixIcon: null,
                            requestFocusNode: null,
                            obscureText: false,
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
                              print(value);
                            }),
                      ],
                    ),*/
                    CommonTextField(
                        //key: phoneNumberFormFieldKey,
                        controller: phoneController,
                        focusNode: phoneFocusNode,
                        labelText: 'Enter Phone Number',
                        hintText: '9999999999',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 10,
                        prefixIcon: null,
                        requestFocusNode: null,
                        obscureText: false,
                        onFieldSubmitted: (value) {
                          //phoneNumberFormFieldKey.currentState!.validate();
                        },
                        onTap: () {
                          /*registrationEmailFormFieldKey.currentState!
                              .validate();*/
                        },
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
                          print(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        //key: createPasswordFormFieldKey,
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
                        onFieldSubmitted: (value) {
                          //createPasswordFormFieldKey.currentState!.validate();
                        },
                        onTap: () {
                          //phoneNumberFormFieldKey.currentState!.validate();
                        },
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
                          print(value);
                        }),
                    SizedBox(height: displayHeight(context) * 0.02),
                    CommonTextField(
                        //key: confirmPasswordFormFieldKey,
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
                        onFieldSubmitted: (value) {
                          //confirmPasswordFormFieldKey.currentState!.validate();
                        },
                        onTap: () {
                          //createPasswordFormFieldKey.currentState!.validate();
                        },
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
                          print(value);
                        }),
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

                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignInScreen()),
                                        );
                                      });
                                    }
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    isRegistrationBtnClicked = false;
                                  });
                                });
                              }
                            }),
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    /*  commonText(
                        context: context,
                        text:
                            'By clicking on register you accept T&C\nand Privacy Policy',
                        fontWeight: FontWeight.w400,
                        textColor: Colors.black,
                        textSize: displayWidth(context) * 0.03,
                        textAlign: TextAlign.start),*/
                    RichText(
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
                                    return ComingSoonScreen();
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
                                    return ComingSoonScreen();
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool hasThreeDigitsLetters(String s) {
    RegExp exp = RegExp(r"(^[A-Z]\d[A-Z] ?\d[A-Z]\d)");
    return exp.hasMatch(s);
  }
}
