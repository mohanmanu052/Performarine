import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static DateTime? currentBackPressedTime;

  //Select images from local photos
  static Future<List<File>> pickCameraImages() async {
    final ImagePicker _picker = ImagePicker();
    bool _inProcess = false;

    _inProcess = true;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    return [new File(photo!.path)];
  }

  // select images from gallery
  static Future<List<File>> pickImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    List<File> files = [];
    if (result != null) {
      files = result.paths.map((path) {
        return File(path!);
      }).toList();

      return files;
    } else {
      // User canceled the picker
      return files;
    }
  }


  //To display snackbar
  static void showSnackBar(BuildContext context,
      {GlobalKey<ScaffoldState>? scaffoldKey,
      String? message,
      int duration = 3,
      bool status = true}) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    debugPrint("STATUS $status");

    final snackBar = SnackBar(
      backgroundColor: status ? Colors.blue : Colors.red,
      content: Row(
        children: [
          Icon(
            status ? Icons.offline_pin : Icons.info,
            color: Colors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
            message!,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white,
            ),
          )),
        ],
      ),
      duration: Duration(seconds: duration),
      behavior: SnackBarBehavior.floating,
    );
    // scaffoldKey?.currentState?.showSnackBar(snackBar);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Trigger when user tap on back button of device
  static Future<bool> onAppExitCallBack(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    DateTime now = DateTime.now();
    if (currentBackPressedTime == null ||
        now.difference(currentBackPressedTime!) > Duration(seconds: 2)) {
      currentBackPressedTime = now;
      Utils.showSnackBar(context,
          scaffoldKey: scaffoldKey,
          message: 'Please press back again to exit',
          duration: 2);
      return Future.value(false);
    }
    return Future.value(true);
  }

  // To get user location permission
  static Future<void> getLocationPermission(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    bool isPermissionGranted = false;

    bool isGranted = await Permission.locationWhenInUse.isGranted;

    if (isGranted) {
      return;
    } else {
      PermissionStatus status = await Permission.locationWhenInUse.status;
      if (status == PermissionStatus.denied) {
        await Permission.locationWhenInUse.request();
        bool isGranted = await Permission.locationWhenInUse.isGranted;
        debugPrint("LOCATION PERMISSION $isGranted");
        if (!isGranted) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey,
              message:
                  'Location permissions are denied without permissions we are unable to start the trip');
          Future.delayed(Duration(seconds: 2), () async {
            await openAppSettings();
          });
        }
      } else if (status == PermissionStatus.permanentlyDenied) {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey,
            message:
                'Location permissions are denied without permissions we are unable to start the trip');
        Future.delayed(Duration(seconds: 2), () async {
          await openAppSettings();
        });
      }
    }

    return;
  }

  //Get an instance of shared preferences
  static Future<SharedPreferences> initSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  //Get location permission of user
  static Future<bool> getLocationPermissions(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    bool isPermissionGranted = false;
    try {
      if (await Permission.locationAlways.request().isGranted) {
        isPermissionGranted = true;
        // isPermissionGranted = await openAppSettings();
      } else if (await Permission.locationAlways
          .request()
          .isPermanentlyDenied) {
        isPermissionGranted = false;
        isPermissionGranted = await openAppSettings();
      } else if (await Permission.locationAlways.request().isDenied) {
        isPermissionGranted = false;
      }
    } catch (e) {
      isPermissionGranted = false;
    }
    return isPermissionGranted;
  }

  //To get storage permission of user
  static Future<bool> getStoragePermission(BuildContext context,
      [Permission permission = Permission.storage]) async {
    bool isPermissionGranted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (permission == Permission.storage) {
        if (androidInfo.version.sdkInt > 32) {
          permission = Permission.photos;
        }
      }
    }

    try {
      if (await permission.request().isGranted) {
        isPermissionGranted = true;
      } else if (await permission.request().isPermanentlyDenied) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          isPermissionGranted = true;
        } else {
          isPermissionGranted = false;
        }
        Utils.customPrint('PD');

        isPermissionGranted = await openAppSettings();
      } else if (await Permission.locationAlways.request().isDenied) {
        Utils.customPrint('D');
        isPermissionGranted = false;
      }
    } catch (e) {
      isPermissionGranted = false;
    }

    return isPermissionGranted;
  }
  // Check user is connected to internet or not
  Future<bool> check(GlobalKey<ScaffoldState> scaffoldKey,
      {bool userConfig = false, VoidCallback? onRetryTap}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      Utils.customPrint('No Internet');
      showDialog(
          context: scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return CustomDialog(
              text: 'No Internet',
              subText: 'Please enable your data connection to continue.',
              positiveBtn: userConfig ? 'Cancel' : 'Okay',
              cancelBtn: userConfig ? 'Don\'t Sync' : '',
              positiveBtnOnTap: () {
                Navigator.of(scaffoldKey.currentContext!).pop();
                //check(scaffoldKey);
              },
              userConfig: userConfig,
              isError: false,
            );
          });
      return false;
    }
    return false;
  }

  //To get user notification permission
  static Future<bool> getNotificationPermission(BuildContext context,
      [Permission permission = Permission.notification]) async {
    bool isPermissionGranted = false;

    /*final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (permission == Permission.notification) {
      if (androidInfo.version.sdkInt > 33) {
        permission = Permission.notification;
      }
    }*/

    try {
      if (await permission.request().isGranted) {
        isPermissionGranted = true;
      } else if (await permission.request().isPermanentlyDenied) {
        isPermissionGranted = false;
        Utils.customPrint('PD');

        isPermissionGranted = await openAppSettings();
      } else if (await Permission.notification.request().isDenied) {
        Utils.customPrint('D');
        isPermissionGranted = false;
        //getStoragePermission(context, scaffoldKey);
      }
    } catch (e) {
      isPermissionGranted = false;
    }

    return isPermissionGranted;
  }

  //End trip dialog for user confirmation to end trip
  showEndTripDialog(BuildContext context, Function() endTripBtnClick,
      Function() onCancelClick) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.24,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: commonText(
                              context: context,
                              text: 'Are you sure, you want to End the Trip?',
                              fontWeight: FontWeight.w600,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.042,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey)),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Cancel',
                                      context,
                                      Colors.transparent,
                                      onCancelClick,
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey,
                                      displayHeight(context) * 0.015,
                                      Colors.transparent,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'OK',
                                      context,
                                      buttonBGColor,
                                      endTripBtnClick,
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.015,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  //Get current time zone of Canada/Pacific
  static String getCurrentTZDateTime() {
    var canada = tz.getLocation('Canada/Pacific');
    var now = tz.TZDateTime.now(canada).toUtc();
    var localNow = DateTime.now();
    Utils.customPrint(DateFormat('dd-MM-yyyy hh:mm a').format(now));

    /// TZ
    Utils.customPrint(DateFormat('dd-MM-yyyy hh:mm a').format(localNow));

    /// LOCAL
    return now.toString();
  }

  //Calculate trip duration
  static String calculateTripDuration(int seconds) {
    Duration duration = Duration(seconds: seconds); // 00:00:00
    String twoDigit(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigit(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigit(duration.inSeconds.remainder(60));
    return "${twoDigit(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  //Launch Url from custom(side) menu
  static Future<void> launchURL(String url) async {
    await launchUrl(Uri.parse(url));
    return;
  }

  // Custom print through out the project
  static customPrint(String text) {
    // kReleaseMode ? null : debugPrint('$text');
    debugPrint('$text');
  }

  //End trip dialog for user confirmation to end trip
  showDeleteTripDialog(BuildContext context, Function() endTripBtnClick,
      Function() onCancelClick) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.24,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: commonText(
                              context: context,
                              text: 'Your trip is less than 10s going to be archive. Do you want to End the trip ?',
                              fontWeight: FontWeight.w600,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.042,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Theme.of(context).brightness ==
                                            Brightness.dark
                                            ? Colors.white
                                            : Colors.grey)),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Continue',
                                      context,
                                      Colors.transparent,
                                      onCancelClick,
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.grey,
                                      displayHeight(context) * 0.015,
                                      Colors.transparent,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'End Trip',
                                      context,
                                      buttonBGColor,
                                      endTripBtnClick,
                                      displayWidth(context) * 0.5,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.015,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  checkIfTripDurationIsGraterThan10Seconds(List<String> splittedDuration)
  {
    int hour = int.parse(splittedDuration[0]);
    int min = int.parse(splittedDuration[1]);
    int sec = int.parse(splittedDuration[2]);

    if(hour > 0)
      {
        return true;
      }
    else
      {
        if(min > 0)
          {
            return true;
          }
        else
          {
            if(sec > 10)
              {
                return true;
              }
            else
              {
                return false;
              }
          }
      }
  }
}
