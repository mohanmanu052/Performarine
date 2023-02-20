import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:get/get.dart';
// import 'package:goe/providers/common_provider.dart';
// import 'package:goe/utils/colors.dart';
// import 'package:goe/widgets/custom_dialog.dart';
// import 'package:goe/widgets/location_permission_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/models/trip.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as d;

import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static DateTime? currentBackPressedTime;

  static Future<List<File>> pickCameraImages() async {
    final ImagePicker _picker = ImagePicker();
    bool _inProcess = false;

    _inProcess = true;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    CroppedFile? croppedFile;
    /*if (photo != null) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );

      _inProcess = false;
    } else {
      _inProcess = false;
    }*/

    return [new File(photo!.path)];
  }

  static Future<List<File>> pickImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    List<File> files = [];
    List<File> croppedFileList = [];
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();

      return files;
    } else {
      // User canceled the picker
      return files;
    }

    // return croppedFileList;
  }

  static void showSnackBar(BuildContext context,
      {GlobalKey<ScaffoldState>? scaffoldKey,
      String? message,
      int duration = 3,
      bool status = true}) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    final snackBar = SnackBar(
      backgroundColor: status
          ? Colors
              .blue /*Utils.convertToColor(commonProvider.globalLoginModel!.data!.configUserData![0].defaultConfig!.buttonPrimaryColor)*/
          : Colors.red,
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

  static Future<Position?> getLocationPermission(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    bool isPermissionGranted = false;

    Position? locationData;

    await Geolocator.requestPermission().then((value) async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isPermissionGranted = false;
          /*Utils.showActionSnackBar(context, scaffoldKey,
            'Location permissions are denied without permissions we are unable to start the trip',
            () {
          // OpenFile.open(directoryPath);
        });*/
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey,
              message:
                  'Location permissions are denied without permissions we are unable to start the trip');

          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isPermissionGranted = false;
        Utils.customPrint('PD');

        isPermissionGranted = await openAppSettings();
        Utils.customPrint("isPermissionGranted:$isPermissionGranted");
        /* Utils.showActionSnackBar(context, scaffoldKey,
            'Location permissions are denied without permissions we are unable to start the trip',
            () {
          // OpenFile.open(directoryPath);
        });*/
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey,
            message:
                'Location permissions are denied without permissions we are unable to start the trip');

        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    });
    return await Geolocator.getCurrentPosition();

    // try {
    //   if (await Permission.locationAlways.request().isGranted) {
    //     // if (ModalRoute.of(context)?.isCurrent != null) {
    //     //   if (ModalRoute.of(context)?.isCurrent != true) {
    //     //     // Utils.customPrint("im in the loop:$locationData");
    //     //     // Get.back();
    //     //   }
    //     // }
    //     //ModalRoute.of(context)?.isCurrent != true;
    //     isPermissionGranted = true;
    //     locationData = await Utils.getCurrentLocation();
    //     Utils.customPrint("im in the loop assigned getCurrentLocation:$locationData");
    //   } else if (
    //
    //   // await Geolocator.checkPermission().then((value) => null);
    //
    //   await Permission.locationAlways
    //       .request()
    //       .isPermanentlyDenied) {
    //     isPermissionGranted = false;
    //     Utils.customPrint('PD');
    //
    //     isPermissionGranted = await openAppSettings();
    //     Utils.customPrint("isPermissionGranted:$isPermissionGranted");
    //     /* Utils.showActionSnackBar(context, scaffoldKey,
    //         'Location permissions are denied without permissions we are unable to start the trip',
    //         () {
    //       // OpenFile.open(directoryPath);
    //     });*/
    //     Utils.showSnackBar(context,
    //         scaffoldKey: scaffoldKey,
    //         message:
    //             'Location permissions are denied without permissions we are unable to start the trip');
    //   } else if (await Permission.locationAlways.request().isDenied) {
    //     // Utils.customPrint('D');
    //     isPermissionGranted = false;
    //     /*Utils.showActionSnackBar(context, scaffoldKey,
    //         'Location permissions are denied without permissions we are unable to start the trip',
    //         () {
    //       // OpenFile.open(directoryPath);
    //     });*/
    //     Utils.showSnackBar(context,
    //         scaffoldKey: scaffoldKey,
    //         message:
    //             'Location permissions are denied without permissions we are unable to start the trip');
    //   } else {
    //     locationData = await getCurrentLocation();
    //   }
    // } catch (e) {
    //   isPermissionGranted = false;
    // }

    // return locationData;
  }

  static Future<SharedPreferences> initSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

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

  static Future<bool> getStoragePermission(BuildContext context,
      [Permission permission = Permission.storage]) async {
    bool isPermissionGranted = false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (permission == Permission.storage) {
      if (androidInfo.version.sdkInt > 32) {
        permission = Permission.photos;
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

        /*showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return LocationPermissionCustomDialog(
                headingText: 'Storage Permission Required',
                text: 'Allow Access to “Media Storage”',
                subText:
                    "To add vessels data we need access for your local storage",
                stepOne: 'Click OK to access App Info',
                stepTwo: 'Click Permissions to access Permission Info',
                stepThree: 'Select Media & Photos and change to allow access.',
                buttonText: 'Ok',
                buttonOnTap: () async {
                  isPermissionGranted = await openAppSettings();
                  Navigator.pop(context);
                },
              );
            });*/

        isPermissionGranted = await openAppSettings();
      } else if (await Permission.locationAlways.request().isDenied) {
        Utils.customPrint('D');
        isPermissionGranted = false;
        //getStoragePermission(context, scaffoldKey);

        /*showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return LocationPermissionCustomDialog(
                headingText: 'Storage Permission Required',
                text: 'Allow Access to “Media Storage”',
                subText:
                    "To add vessels data we need access for your local storage",
                stepOne: 'Click OK to access App Info',
                stepTwo: 'Click Permissions to access Permission Info',
                stepThree: 'Select Media & Photos and change to allow access.',
                buttonText: 'Ok',
                buttonOnTap: () async {
                  isPermissionGranted = await openAppSettings();
                  Navigator.pop(context);
                },
              );
            });*/
      }
    } catch (e) {
      isPermissionGranted = false;
    }

    return isPermissionGranted;
  }

  check(GlobalKey<ScaffoldState> scaffoldKey) async {
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
              positiveBtn: 'Okay',
              positiveBtnOnTap: () {
                Navigator.of(scaffoldKey.currentContext!).pop();
                //check(scaffoldKey);
              },
            );
          });
    }
    return false;
  }

  static void showActionSnackBar(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String message, Function() onTap) {
    final snackBar = new SnackBar(
      backgroundColor: Colors.blue,
      content: Row(
        children: [
          Icon(
            Icons.download_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
            message,
            softWrap: true,
            overflow: TextOverflow.clip,
          )),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(minutes: 1),
      action: SnackBarAction(
        label: 'OPEN',
        textColor: Colors.white,
        onPressed: onTap,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
                                      primaryColor,
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
                                      primaryColor,
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

  static String getCurrentTZDateTime() {
    /*var locations = tz.timeZoneDatabase.locations;
    locations.forEach((key, value) {
      Utils.customPrint('$key: $value');
    });*/
    var canada = tz.getLocation('Canada/Pacific');
    var now = tz.TZDateTime.now(canada).toUtc();
    var localNow = DateTime.now();
    Utils.customPrint(DateFormat('dd-MM-yyyy hh:mm a').format(now));

    /// TZ
    Utils.customPrint(DateFormat('dd-MM-yyyy hh:mm a').format(localNow));

    /// LOCAL
    return now.toString();
  }

  static String calculateTripDuration(int seconds) {
    Duration duration = Duration(seconds: seconds); // 00:00:00
    String twoDigit(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigit(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigit(duration.inSeconds.remainder(60));
    return "${twoDigit(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static Future<void> launchURL(String url) async {
    await launchUrl(Uri.parse(url));
    return;
  }

  static customPrint(String text) {
    kReleaseMode ? null : debugPrint('$text');
  }
}
