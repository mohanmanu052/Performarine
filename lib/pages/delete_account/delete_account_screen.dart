import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/auth_new/sign_up_screen.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/delete_account/successfully_deleted_account_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/web_navigation/privacy_and_policy_web_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';


class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  TextEditingController confirmationCodeController = TextEditingController();
  FocusNode confirmationCodeFocusNode = FocusNode();

  bool isChecked = false, isValidCode = false, isAccountDeleting = false, isUploadStarted = false, isSync = false;

  String? verificationCode;

  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;

  late List<Trip> getTrip;
  late List<CreateVessel> getVesselFuture;
  late DeviceInfoPlugin deviceDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    verificationCode = generateVerificationCode();

    confirmationCodeController.addListener(_validateCode);

    commonProvider = context.read<CommonProvider>();
    deviceDetails = DeviceInfoPlugin();
  }

  @override
  void dispose() {
    confirmationCodeController.removeListener(_validateCode);
    confirmationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

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
                    buttonPrimaryColor: deleteAccountBtnColor.withOpacity(confirmationCodeController.text.isEmpty || !isValidCode || !isChecked ? 0.5 : 1.0),
                    borderColor: deleteAccountBtnColor.withOpacity(confirmationCodeController.text.isEmpty || !isValidCode || !isChecked ? 0.5 : 1.0),
                    width: displayWidth(context),
                    onTap: confirmationCodeController.text.isEmpty || !isValidCode || !isChecked
                      ? null
                        : () async {

                      bool? isTripStarted =
                      sharedPreferences!.getBool('trip_started');

                      var tripSyncDetails =
                      await _databaseService.tripSyncDetails();
                      var vesselsSyncDetails =
                      await _databaseService.vesselsSyncDetails();

                      Utils.customPrint(
                          "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");

                      if (isTripStarted != null) {
                        if (isTripStarted) {
                          Navigator.of(context).pop();

                          showEndTripDialogBox(context);
                        } else {
                          if (vesselsSyncDetails || tripSyncDetails) {
                            showDialogBox(
                                context,
                                scaffoldKey);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SuccessfullyDeletedAccountScreen(
                                      )),
                            );
                          }
                        }
                      } else {
                        if (vesselsSyncDetails || tripSyncDetails) {
                          showDialogBox(
                              context,
                              scaffoldKey,);
                        } else {
                          Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SuccessfullyDeletedAccountScreen(
                                )),
                      );
                        }
                      }
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
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        height: displayHeight(context),
        margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.05,),

                  Image.asset('assets/images/acc_delete.png', height: displayHeight(context) * 0.2,),

                  SizedBox(height: displayHeight(context) * 0.03,),

                  commonText(
                      context: context,
                      text: 'Are sure you want to delete\nyour account?',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.045,
                      textAlign: TextAlign.center),

                  SizedBox(height: displayHeight(context) * 0.015,),

                  commonText(
                      context: context,
                      text: 'This operation cannot be undone',
                      fontWeight: FontWeight.normal,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.036,
                      textAlign: TextAlign.start),

                  SizedBox(height: displayHeight(context) * 0.14,),
                ],
              ),

              Column(
                children: [
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
                          text: verificationCode,
                          fontWeight: FontWeight.normal,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.046,
                          textAlign: TextAlign.start),
                    ],
                  ),

                  SizedBox(height: displayHeight(context) * 0.02,),

                  CommonTextField(
                    controller: confirmationCodeController,
                    focusNode: confirmationCodeFocusNode,
                    labelText: 'Enter confirmation code to confirm',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 6,
                    prefixIcon: null,
                    requestFocusNode: null,
                    obscureText: false,
                    readOnly: false,
                    onTap: () {},
                    onChanged: (value) {
                      debugPrint("Length ${value.length}");
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Your Confirmation Code';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      if(value.length != 6 && value != verificationCode)
                      {
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey, message: 'Please enter valid code');
                      }
                    },

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
              )
            ],
          ),
        ),
      ),
    );
  }
  String generateVerificationCode() {
    Random random = Random();
    int code = random.nextInt(900000) + 100000; // Generates a random number between 100000 and 999999
    return code.toString();
  }

  void _validateCode() {
    setState(() {
      isValidCode = _isCodeValid(confirmationCodeController.text);
    });
    debugPrint("IS CODE VALID $isValidCode");
  }

  bool _isCodeValid(String code) {
    // Your validation logic here
    return code.length == 6 && int.tryParse(code) != null && code == verificationCode;

  }

  showEndTripDialogBox(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              //color: Color(0xfff2fffb),
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(context) * 0.1,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                  'Please end the trip which is already running',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize:
                                  displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Go to trip', context, blueColor,
                                          () async {
                                        Utils.customPrint(
                                            "Click on GO TO TRIP 1");

                                        List<String>? tripData =
                                        sharedPreferences!
                                            .getStringList('trip_data');
                                        bool? runningTrip = sharedPreferences!
                                            .getBool("trip_started");

                                        String tripId = '', vesselName = '';
                                        if (tripData != null) {
                                          tripId = tripData[0];
                                          vesselName = tripData[1];
                                        }

                                        Utils.customPrint(
                                            "Click on GO TO TRIP 2");

                                        Navigator.of(dialogContext).pop();

                                        Navigator.push(
                                          dialogContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TripRecordingScreen(
                                                    tripId: tripId,
                                                    vesselId: tripData![1],
                                                    tripIsRunningOrNot:
                                                    runningTrip,
                                                  )),
                                        );

                                        Utils.customPrint(
                                            "Click on GO TO TRIP 3");
                                      },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.02,
                                      blueColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Cancel', context, Colors.transparent,
                                        () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    primaryColor,
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.white,
                                    '',
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) {
      if (commonProvider.bottomNavIndex != 1) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp
        ]);
      }
    });
  }

  showDialogBox(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    isAccountDeleting = false;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.42,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: displayHeight(context) * 0.02,
                            ),
                            Center(
                              child: Image.asset(
                                  'assets/icons/export_img.png',
                                  //height: displayHeight(context) * 0.2,
                                  width: displayWidth(context) * 0.18),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.01,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 8.0, right: 8),
                              child: Column(
                                children: [
                                  commonText(
                                      context: context,
                                      text:
                                      'There are some vessel & trips data not sync with cloud, do you want to proceed further?',
                                      fontWeight: FontWeight.w600,
                                      textColor: Colors.black,
                                      textSize:
                                      displayWidth(context) * 0.038,
                                      textAlign: TextAlign.center,
                                      fontFamily: inter),
                                  SizedBox(
                                    height:
                                    displayHeight(context) * 0.015,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.01,
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 8.0,
                                  ),
                                  child: isAccountDeleting
                                      ? Container(
                                      height: displayHeight(context) * 0.055,
                                      child: Center(
                                          child:
                                          CircularProgressIndicator(
                                            color: blueColor,
                                          )))
                                      : Center(
                                    child:
                                    CommonButtons.getAcceptButton(
                                        'Sync & Delete',
                                        context,
                                        blueColor, () async {
                                      bool internet = await Utils()
                                          .check(scaffoldKey);

                                      if (internet) {
                                        setDialogState(() {
                                          isAccountDeleting = true;
                                        });

                                        syncAndDelete(false, context,
                                            setDialogState);
                                      }
                                    },
                                        displayWidth(context) / 1.6,
                                        displayHeight(context) * 0.055,
                                        primaryColor,
                                        Colors.white,
                                        displayHeight(context) * 0.018,
                                        blueColor,
                                        '',
                                        fontWeight:
                                        FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: CommonButtons.getAcceptButton(
                                        'Delete Account',
                                        context,
                                        Colors.transparent, () async {
                                      Navigator.of(context).pop();
                                      // TODO Delete account functionality
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SuccessfullyDeletedAccountScreen(
                                                )),
                                      );
                                    },
                                        displayWidth(context) / 1.6,
                                        displayHeight(context) * 0.055,
                                        primaryColor,
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                            ? Colors.white
                                            : blueColor,
                                        displayHeight(context) * 0.015,
                                        Colors.transparent,
                                        '',
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: displayHeight(context) * 0.01,
                            ),
                          ],
                        ),
                        Positioned(
                          right: 10,
                          top: 0,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isUploadStarted
                                  ? SizedBox()
                                  : IconButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  icon: Icon(Icons.close_rounded,
                                      color: buttonBGColor)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  syncAndDelete(bool isChangePassword, BuildContext context,
      StateSetter setDialogState) async {
    bool vesselErrorOccurred = false;
    bool tripErrorOccurred = false;

    var vesselsSyncDetails = await _databaseService.vesselsSyncDetails();
    var tripSyncDetails = await _databaseService.tripSyncDetails();

    getVesselFuture =
    await _databaseService.syncAndSignOutVesselList().catchError((onError) {
      setDialogState(() {
        isAccountDeleting = false;
        isUploadStarted = false;
      });
    });
    getTrip = await _databaseService.trips();

    Utils.customPrint("VESSEL SYNC TRIP ${getTrip.length}");
    Utils.customPrint("VESSEL SYNC TRIP $vesselsSyncDetails");
    Utils.customPrint("VESSEL SYNC TRIP $tripSyncDetails");

    if (vesselsSyncDetails) {
      for (int i = 0; i < getVesselFuture.length; i++) {
        var vesselSyncOrNot = getVesselFuture[i].isSync;
        //CustomLogger().logWithFile(Level.info, "VESSEL SYNC TRIP DISPLACEMENT  ${getVesselFuture[i].displacement}");
        Utils.customPrint(
            "VESSEL SUCCESS MESSAGE ${getVesselFuture[i].imageURLs}");
        if(getVesselFuture[i].createdBy == commonProvider.loginModel!.userId)
        {
          if (vesselSyncOrNot == 0) {
            if (getVesselFuture[i].imageURLs != null &&
                getVesselFuture[i].imageURLs!.isNotEmpty) {
              if (getVesselFuture[i].imageURLs!.startsWith("https")) {
                getVesselFuture[i].selectedImages = [];
              } else {
                getVesselFuture[i].selectedImages = [
                  File(getVesselFuture[i].imageURLs!)
                ];
              }

              Utils.customPrint(
                  'VESSEL Data ${File(getVesselFuture[i].imageURLs!)}');
            } else {
              getVesselFuture[i].selectedImages = [];
            }

            await commonProvider
                .addVessel(
                context,
                getVesselFuture[i],
                commonProvider.loginModel!.userId!,
                commonProvider.loginModel!.token!,
                scaffoldKey,
                calledFromSignOut: true)
                .then((value) async {
              if (value!.status!) {
                await _databaseService.updateIsSyncStatus(
                    1, getVesselFuture[i].id.toString());
              } else {
                setState(() {
                  vesselErrorOccurred = true;
                });
              }
            }).catchError((error) {
              Utils.customPrint("ADD VESSEL ERROR $error");

              setState(() {
                vesselErrorOccurred = true;
              });
            });
          } else {
            Utils.customPrint("VESSEL DATA NOT Uploaded");
          }
        }
      }

      Utils.customPrint("VESSEL DATA Uploaded");
    }
    if (tripSyncDetails) {
      for (int i = 0; i < getTrip.length; i++) {
        var tripSyncOrNot = getTrip[i].isSync;

        AndroidDeviceInfo? androidDeviceInfo;
        IosDeviceInfo? iosDeviceInfo;
        if (Platform.isAndroid) {
          androidDeviceInfo = await deviceDetails.androidInfo;
        } else {
          iosDeviceInfo = await deviceDetails.iosInfo;
        }

        Directory tripDir = await getApplicationDocumentsDirectory();

        var sensorInfo = await Utils().getSensorObjectWithAvailability();

        if (tripSyncOrNot == 0) {
          var queryParameters;
          queryParameters = {
            "id": getTrip[i].id,
            "load": getTrip[i].currentLoad,
            "sensorInfo": sensorInfo['sensorInfo'],
            "deviceInfo": {
              "deviceId": Platform.isAndroid ? androidDeviceInfo!.id : '',
              "model": Platform.isAndroid
                  ? androidDeviceInfo!.model
                  : iosDeviceInfo!.model,
              "version": Platform.isAndroid
                  ? androidDeviceInfo!.version.release
                  : iosDeviceInfo!.utsname.release,
              "make": Platform.isAndroid
                  ? androidDeviceInfo!.manufacturer
                  : iosDeviceInfo?.utsname.machine,
              "board": Platform.isAndroid
                  ? androidDeviceInfo!.board
                  : iosDeviceInfo!.utsname.machine,
              "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
            },
            "startPosition": getTrip[i].startPosition!.split(','),
            "endPosition": getTrip[i].endPosition!.split(','),
            "number_of_passengers": getTrip[i].numberOfPassengers,
            /*json.decode(tripData.endPosition!.toString()).cast<String>().toList()*/
            "vesselId": getTrip[i].vesselId,
            "filePath": Platform.isAndroid
                ? '/data/user/0/com.performarine.app/app_flutter/${getTrip[i].id}.zip'
                : '${tripDir.path}/${getTrip[i].id}.zip',
            "createdAt": getTrip[i].createdAt,
            "updatedAt": getTrip[i].updatedAt,
            "duration": getTrip[i].time,

            //"createdBy":'64e4b01076c86cc1877b4497',
            "distance": double.parse(getTrip[i].distance!),
            "speed": double.parse(getTrip[i].speed!),
            "avgSpeed": double.parse(getTrip[i].avgSpeed!),
            //"userID": commonProvider.loginModel!.userId!
          };

          Utils.customPrint('QQQQQQ: $queryParameters');

          await commonProvider
              .sendSensorInfo(
              context,
              commonProvider.loginModel!.token,
              File(Platform.isAndroid
                  ? '/data/user/0/com.performarine.app/app_flutter/${getTrip[i].id}.zip'
                  : '${tripDir.path}/${getTrip[i].id}.zip'),
              queryParameters,
              getTrip[i].id!,
              scaffoldKey,
              calledFromSignOut: true)
              .then((value) async {
            if (value!.status!) {
              Utils.customPrint("TRIP SUCCESS MESSAGE ${value.message}");

              await _databaseService.updateTripIsSyncStatus(
                  1, getTrip[i].id.toString());
            } else {
              Utils.customPrint("TRIP MESSAGE ${value.message}");
              setState(() {
                tripErrorOccurred = true;
              });
            }
          }).catchError((onError) {
            Utils.customPrint('DIOOOOOOOOOOOOO');

            setState(() {
              tripErrorOccurred = true;
            });
          });
        }
      }
    }

    Navigator.of(context).pop();
    // Navigator.of(context).pop();

    if (!vesselErrorOccurred && !tripErrorOccurred) {
     // TODO Delete Account Functionality
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SuccessfullyDeletedAccountScreen(
                )),
      );
      Utils.customPrint("ERROR WHILE SYNC AND SIGN OUT IF SIGN OUTT");
    } else {
      Utils.showSnackBar(context,
          scaffoldKey: scaffoldKey,
          message: 'Failed to sync data to cloud. Please try again.');

      Utils.customPrint("ERROR WHILE SYNC AND SIGN OUT ELSE");
    }
  }
}
