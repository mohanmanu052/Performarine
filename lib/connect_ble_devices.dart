import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:performarine/common_widgets/controller/location_controller.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'common_widgets/utils/constants.dart';
import 'common_widgets/widgets/common_widgets.dart';

class ConnectBLEDevices extends StatefulWidget {
  const ConnectBLEDevices({super.key});

  @override
  State<ConnectBLEDevices> createState() => _ConnectBLEDevicesState();
}

class _ConnectBLEDevicesState extends State<ConnectBLEDevices> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  LocationController? locationController;
  bool openedSettingsPageForPermission = false, isLocationPermitted = false, isStartButton = false,isScanningBluetooth = false,
      isLocationDialogBoxOpen = false, isBluetoothPermitted = false, isBluetoothSearching = false, isRefreshList = false, isClickedOnForgetDevice = false;

  String bluetoothName = 'LPR';

  double progress = 0.9, lprSensorProgress = 1.0, sliderMinVal = 11;

  StreamSubscription<List<ScanResult>>? autoConnectStreamSubscription;
  StreamSubscription<bool>? autoConnectIsScanningStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    locationController = context.read<LocationController>();
    checkTempPermissions();

    /*Future.delayed(Duration(milliseconds: 500), () {
      checkPermissionsAndAutoConnectToDevice(context);
    });*/

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
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
        /*title: commonText(
          context: context,
          text: '',
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textSize: displayWidth(context) * 0.045,
        ),*/
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          children: [
            SizedBox(height: displayHeight(context) * 0.05,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey)
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        FlutterBluePlus
                            .connectedDevices
                            .isEmpty
                            ? 'LPR'
                            : '${FlutterBluePlus.connectedDevices.first.platformName.isEmpty ? FlutterBluePlus.connectedDevices.first.remoteId.str : FlutterBluePlus.connectedDevices.first.platformName}',
                        textAlign:
                        TextAlign
                            .start,
                        textScaleFactor:
                        1,
                        style: TextStyle(
                            fontSize:
                            displayWidth(context) *
                                0.034,
                            color: Colors
                                .black87,
                            fontFamily:
                            outfit,
                            fontWeight:
                            FontWeight
                                .w400),
                        overflow:
                        TextOverflow
                            .ellipsis,
                        softWrap: false,
                      ),
                    ),
                    SizedBox(
                      width: displayWidth(
                          context) *
                          0.034,
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        // color: Colors.red,
                        child: TextButton(
                          style: TextButton
                              .styleFrom(
                              padding:
                              EdgeInsets
                                  .zero),
                          onPressed: () async {
                            bool
                            isNDPermDenied =
                            await Permission
                                .bluetoothConnect
                                .isPermanentlyDenied;

                            if (isNDPermDenied) {
                              showDialog(
                                  context:
                                  context,
                                  builder:
                                      (BuildContext
                                  context) {
                                    return LocationPermissionCustomDialog(
                                      isLocationDialogBox:
                                      false,
                                      text:
                                      'Allow nearby devices',
                                      subText:
                                      'Allow nearby devices to connect to the app',
                                      buttonText:
                                      'OK',
                                      buttonOnTap:
                                          () async {
                                        Get.back();
                                      },
                                    );
                                  });
                              return;
                            } else {
                              if (Platform
                                  .isIOS) {
                                dynamic isBluetoothEnable = Platform
                                    .isAndroid
                                    ? await blueIsOn()
                                    : await checkIfBluetoothIsEnabled(
                                    scaffoldKey,
                                        () {
                                      showBluetoothDialog(
                                          context);
                                    });

                                if (isBluetoothEnable !=
                                    null) {
                                  if (isBluetoothEnable) {
                                    if (Platform
                                        .isIOS) {
                                      forgetDeviceOrConnectToNewDevice();
                                      // checkAndGetLPRList(
                                      //     context);
                                      // showBluetoothListDialog(context);
                                    } else {
                                      if (await Permission
                                          .location
                                          .isPermanentlyDenied) {
                                        Utils.showSnackBar(
                                            context,
                                            scaffoldKey:
                                            scaffoldKey,
                                            message:
                                            'Location permissions are denied without permissions we are unable to start the trip');
                                        Future.delayed(
                                            Duration(seconds: 2),
                                                () async {
                                              if(!isLocationDialogBoxOpen){
                                                showLocationDailog();

                                              }
                                            });
                                      } else {
                                        if (await Permission
                                            .location
                                            .isGranted) {
                                          forgetDeviceOrConnectToNewDevice();
                                          // checkAndGetLPRList(
                                          //     context);
                                          // showBluetoothListDialog(context);
                                        } else {
                                          await Permission
                                              .location
                                              .request();
                                        }
                                      }
                                    }
                                  } else {
                                    showBluetoothDialog(
                                        context);
                                  }
                                }
                              } else {
                                bool
                                isNDPermittedOne =
                                await Permission
                                    .bluetoothConnect
                                    .isGranted;

                                if (isNDPermittedOne) {
                                  bool isBluetoothEnable = Platform
                                      .isAndroid
                                      ? await blueIsOn()
                                      : await checkIfBluetoothIsEnabled(
                                      scaffoldKey,
                                          () {
                                        showBluetoothDialog(
                                            context);
                                      });

                                  if (isBluetoothEnable) {
                                    if (Platform
                                        .isIOS) {
                                      forgetDeviceOrConnectToNewDevice();
                                      // checkAndGetLPRList(
                                      //     context);
                                      // showBluetoothListDialog(context);
                                    } else {
                                      if (await Permission
                                          .location
                                          .isPermanentlyDenied) {
                                        Utils.showSnackBar(
                                            context,
                                            scaffoldKey:
                                            scaffoldKey,
                                            message:
                                            'Location permissions are denied without permissions we are unable to start the trip');
                                        Future.delayed(
                                            Duration(seconds: 2),
                                                () async {
                                              if(!isLocationDialogBoxOpen){
                                                showLocationDailog();

                                              }
                                            });
                                      } else {
                                        if (await Permission
                                            .location
                                            .isGranted) {
                                          forgetDeviceOrConnectToNewDevice();
                                          // checkAndGetLPRList(
                                          //     context);
                                          // showBluetoothListDialog(context);
                                        } else {
                                          if (!(await Permission
                                              .location
                                              .shouldShowRequestRationale)) {
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message: 'Location permissions are denied without permissions we are unable to start the trip');
                                            Future.delayed(Duration(seconds: 2),
                                                    () async {
                                                  if(!isLocationDialogBoxOpen){
                                                    showLocationDailog();

                                                  }
                                                });
                                          } else {
                                            await Permission.location.request();
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    showBluetoothDialog(
                                        context);
                                  }
                                } else {
                                  await Permission
                                      .bluetoothConnect
                                      .request();
                                  bool
                                  isNDPermitted =
                                  await Permission
                                      .bluetoothConnect
                                      .isGranted;
                                  if (isNDPermitted) {
                                    bool isBluetoothEnable = Platform
                                        .isAndroid
                                        ? await blueIsOn()
                                        : await checkIfBluetoothIsEnabled(
                                        scaffoldKey,
                                            () {
                                          showBluetoothDialog(context);
                                        });

                                    if (isBluetoothEnable) {
                                      if (Platform
                                          .isIOS) {
                                        forgetDeviceOrConnectToNewDevice();
                                        // checkAndGetLPRList(
                                        //     context);
                                        // showBluetoothListDialog(context);
                                      } else {
                                        if (await Permission
                                            .location
                                            .isPermanentlyDenied) {
                                          Utils.showSnackBar(
                                              context,
                                              scaffoldKey: scaffoldKey,
                                              message: 'Location permissions are denied without permissions we are unable to start the trip');
                                          Future.delayed(
                                              Duration(seconds: 2),
                                                  () async {
                                                if(!isLocationDialogBoxOpen){
                                                  showLocationDailog();

                                                }
                                              });
                                        } else {
                                          if (await Permission
                                              .location
                                              .isGranted) {
                                            forgetDeviceOrConnectToNewDevice();
                                            // checkAndGetLPRList(
                                            //     context);
                                            // showBluetoothListDialog(context);
                                          } else {
                                            await Permission.location.request();
                                          }
                                        }
                                      }
                                    } else {
                                      showBluetoothDialog(
                                          context);
                                    }
                                  } else {
                                    if (await Permission
                                        .bluetoothConnect
                                        .isDenied ||
                                        await Permission
                                            .bluetoothConnect
                                            .isPermanentlyDenied) {
                                      showDialog(
                                          context:
                                          context,
                                          builder:
                                              (BuildContext context) {
                                            return LocationPermissionCustomDialog(
                                              isLocationDialogBox: false,
                                              text: 'Allow nearby devices',
                                              subText: 'Allow nearby devices to connect to the app',
                                              buttonText: 'OK',
                                              buttonOnTap: () async {
                                                Get.back();

                                                await openAppSettings();
                                              },
                                            );
                                          });
                                    }
                                  }
                                }
                              }
                            }
                          },
                          child:
                          isBluetoothSearching
                              ? SizedBox(
                              height:
                              30,
                              width: 30,
                              child:
                              CircularProgressIndicator())
                              : commonText(
                            context:
                            context,
                            text: FlutterBluePlus
                                .connectedDevices
                                .isEmpty
                                ? 'Connect to Device'
                                : 'Forget Device',
                            fontWeight:
                            FontWeight
                                .w500,
                            textColor:
                            blueColor,
                            textAlign:
                            TextAlign
                                .end,
                            textSize:
                            displayWidth(context) *
                                0.03,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkTempPermissions() async {
    this.isLocationPermitted = await Permission.locationAlways.isGranted;
    setState(() {});
  }

  checkPermissionsAndAutoConnectToDevice(BuildContext context) async {
    bool isNDPermDenied = await Permission.bluetoothConnect.isPermanentlyDenied;

    if (isNDPermDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LocationPermissionCustomDialog(
              isLocationDialogBox: false,
              text: 'Allow nearby devices',
              subText: 'Allow nearby devices to connect to the app',
              buttonText: 'OK',
              buttonOnTap: () async {
                Get.back();
              },
            );
          });
      return;
    }
    else {
      /// START
      if (Platform.isIOS) {
        // locationController?.getUserCurrentLocation(context);

        if (await Permission.locationWhenInUse.isPermanentlyDenied) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey,
              message:
              'Location permissions are denied without permissions we are unable to start the trip');
          Future.delayed(Duration(seconds: 2), () async {
            openedSettingsPageForPermission = true;
            if(!isLocationDialogBoxOpen){
              showLocationDailog();
            }
            //await openAppSettings();
          });
        } else {
          if (await Permission.locationWhenInUse.isGranted) {
            locationController!.getUserCurrentLocation(context);
            if (await Permission.locationAlways.isGranted) {
              dynamic isBluetoothEnable = Platform.isAndroid
                  ? await blueIsOn()
                  : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                showBluetoothDialog(context, autoConnect: true);
              });

              if (isBluetoothEnable != null) {
                if (isBluetoothEnable) {
                  autoConnectToDevice();
                } else {
                  Utils.customPrint('BLED - SHOWN FIRST');
                  showBluetoothDialog(context, autoConnect: true);
                }
              }
              if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                Fluttertoast.showToast(
                    msg: "Please enable GPS",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Future.delayed(Duration(seconds: 1), () async {
                  AppSettings.openAppSettings(type: AppSettingsType.location);
                  checkGPS(context);
                });
              } else {
                locationController?.getUserCurrentLocation(context);
              }
            } else if (await Permission.locationAlways.isPermanentlyDenied) {
              await Permission.locationAlways.request().then((value) async {
                dynamic isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context, autoConnect: true);
                });

                if (isBluetoothEnable != null) {
                  if (isBluetoothEnable) {
                    autoConnectToDevice();
                  } else {
                    Utils.customPrint('BLED - SHOWN FIRST');
                    showBluetoothDialog(context, autoConnect: true);
                  }
                }
                if (value == PermissionStatus.granted) {
                  locationController!.getUserCurrentLocation(context);
                }
                // else{
                //   Utils.showSnackBar(context,
                //       scaffoldKey: scaffoldKey,
                //       message:
                //       "Location permissions are denied without permissions we are unable to start the trip");
                //
                //   Future.delayed(Duration(seconds: 3), () async {
                //     await openAppSettings();
                //   });
                // }
              });
            } else {
              // await Permission.locationAlways.request();
              if (Platform.isIOS) {
                Permission.locationAlways.request();
              }
              if (await Permission.locationAlways.isGranted) {
                dynamic isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context, autoConnect: true);
                });

                if (isBluetoothEnable != null) {
                  if (isBluetoothEnable) {
                    autoConnectToDevice();
                  } else {
                    Utils.customPrint('BLED - SHOWN FIRST');
                    showBluetoothDialog(context, autoConnect: true);
                  }
                }
                if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                  Fluttertoast.showToast(
                      msg: "Please enable GPS",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);

                  Future.delayed(Duration(seconds: 1), () async {
                    AppSettings.openAppSettings(type: AppSettingsType.location);
                    checkGPS(context);
                  });
                } else {
                  locationController?.getUserCurrentLocation(context);
                }
              } else {
                ///
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    'Location permissions are denied without permissions we are unable to start the trip');
                Future.delayed(Duration(seconds: 2), () async {
                  if(!isLocationDialogBoxOpen){
                    showLocationDailog();
                  }
                  //await openAppSettings();
                });
              }
            }
          } else {
            if ((await Permission
                .locationWhenInUse.shouldShowRequestRationale)) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey,
                  message:
                  'Location permissions are denied without permissions we are unable to start the trip');
              Future.delayed(Duration(seconds: 2), () async {
                openedSettingsPageForPermission = true;
                if(!isLocationDialogBoxOpen){
                  showLocationDailog();
                }

                // await openAppSettings();
              });
            } else {
              await Permission.locationWhenInUse.request();
              if (await Permission.locationWhenInUse.isGranted) {
                locationController!.getUserCurrentLocation(context);
                print('LOC AAAAAAa');
                if (await Permission.locationAlways.isGranted) {
                  dynamic isBluetoothEnable = Platform.isAndroid
                      ? await blueIsOn()
                      : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                    showBluetoothDialog(context, autoConnect: true);
                  });

                  if (isBluetoothEnable != null) {
                    if (isBluetoothEnable) {
                      autoConnectToDevice();
                    } else {
                      Utils.customPrint('BLED - SHOWN FIRST');
                      showBluetoothDialog(context, autoConnect: true);
                    }
                  }
                  print('LOC AAAAAAa 2');
                  if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                    Fluttertoast.showToast(
                        msg: "Please enable GPS",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    Future.delayed(Duration(seconds: 1), () async {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.location);
                      checkGPS(context);
                    });
                  } else {
                    locationController?.getUserCurrentLocation(context);
                  }
                } else if (await Permission
                    .locationAlways.isPermanentlyDenied) {
                  await Permission.locationAlways.request().then((value) async {
                    dynamic isBluetoothEnable = Platform.isAndroid
                        ? await blueIsOn()
                        : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                      showBluetoothDialog(context, autoConnect: true);
                    });

                    if (isBluetoothEnable != null) {
                      if (isBluetoothEnable) {
                        autoConnectToDevice();
                      } else {
                        Utils.customPrint('BLED - SHOWN FIRST');
                        showBluetoothDialog(context, autoConnect: true);
                      }
                    }
                    if (value == PermissionStatus.granted) {
                      locationController!.getUserCurrentLocation(context);
                    }
                    // else{
                    //   Utils.showSnackBar(context,
                    //       scaffoldKey: scaffoldKey,
                    //       message:
                    //       "Location permissions are denied without permissions we are unable to start the trip");
                    //
                    //   Future.delayed(Duration(seconds: 3), () async {
                    //     await openAppSettings();
                    //   });
                    // }
                  });
                } else {
                  print('LOC AAAAAAa 4');
                  if (Platform.isIOS) {
                    Permission.locationAlways.request();
                  }

                  //  await Permission.locationAlways.request();
                  if (await Permission.locationAlways.isGranted) {
                    dynamic isBluetoothEnable = Platform.isAndroid
                        ? await blueIsOn()
                        : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                      showBluetoothDialog(context, autoConnect: true);
                    });

                    if (isBluetoothEnable != null) {
                      if (isBluetoothEnable) {
                        autoConnectToDevice();
                      } else {
                        Utils.customPrint('BLED - SHOWN FIRST');
                        showBluetoothDialog(context, autoConnect: true);
                      }
                    }
                    if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                      Fluttertoast.showToast(
                          msg: "Please enable GPS",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);

                      Future.delayed(Duration(seconds: 1), () async {
                        AppSettings.openAppSettings(
                            type: AppSettingsType.location);
                        checkGPS(context);
                      });
                    } else {
                      locationController?.getUserCurrentLocation(context);
                    }
                  } else {
                    ///
                    Utils.showSnackBar(context,
                        scaffoldKey: scaffoldKey,
                        message:
                        'Location permissions are denied without permissions we are unable to start the trip');
                    Future.delayed(Duration(seconds: 2), () async {
                      if(!isLocationDialogBoxOpen){
                        showLocationDailog();
                      }

                      // await openAppSettings();
                    });
                  }
                }
              } else {
                checkPermissionsAndAutoConnectToDevice(context);
              }
            }
          }
        }
      } else {
        bool isNDPermittedOne = await Permission.bluetoothConnect.isGranted;

        if (isNDPermittedOne) {
          if (await Permission.locationWhenInUse.isPermanentlyDenied) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey,
                message:
                'Location permissions are denied without permissions we are unable to start the trip');
            Future.delayed(Duration(seconds: 2), () async {
              openedSettingsPageForPermission = true;
              if(!isLocationDialogBoxOpen){
                showLocationDailog();
              }

              //await openAppSettings();
            });
          } else {
            if (await Permission.locationWhenInUse.isGranted) {
              if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                Fluttertoast.showToast(
                    msg: "Please enable GPS",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Future.delayed(Duration(seconds: 1), () async {
                  AppSettings.openAppSettings(type: AppSettingsType.location);
                  checkGPS(context);
                });
              } else {
                locationController?.getUserCurrentLocation(context);
              }
              bool isBluetoothEnable = Platform.isAndroid
                  ? await blueIsOn()
                  : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                showBluetoothDialog(context, autoConnect: true);
              });
              if (isBluetoothEnable) {
                autoConnectToDevice();
              } else {
                Utils.customPrint('BLED - SHOWN FIFTH');
                showBluetoothDialog(context, autoConnect: true);
              }
            } else {
              if ((await Permission
                  .locationWhenInUse.shouldShowRequestRationale)) {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    'Location permissions are denied without permissions we are unable to start the trip');
                Future.delayed(Duration(seconds: 2), () async {
                  openedSettingsPageForPermission = true;
                  if(!isLocationDialogBoxOpen){
                    showLocationDailog();
                  }

                  //await openAppSettings();
                });
              } else {
                await Permission.locationWhenInUse.request();
                if (await Permission.locationWhenInUse.isGranted) {
                  if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                    Fluttertoast.showToast(
                        msg: "Please enable GPS",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    Future.delayed(Duration(seconds: 1), () async {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.location);
                      checkGPS(context);
                    });
                  } else {
                    locationController?.getUserCurrentLocation(context);
                  }
                  bool isBluetoothEnable = Platform.isAndroid
                      ? await blueIsOn()
                      : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                    showBluetoothDialog(context, autoConnect: true);
                  });
                  if (isBluetoothEnable) {
                    autoConnectToDevice();
                  } else {
                    Utils.customPrint('BLED - SHOWN FIFTH');
                    showBluetoothDialog(context, autoConnect: true);
                  }
                } else {
                  checkPermissionsAndAutoConnectToDevice(context);
                }
              }
            }
          }
        } else {
          await Permission.bluetoothConnect.request();
          bool isNDPermitted = await Permission.bluetoothConnect.isGranted;

          if (isNDPermitted) {
            if (await Permission.locationWhenInUse.isPermanentlyDenied) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey,
                  message:
                  'Location permissions are denied without permissions we are unable to start the trip');
              Future.delayed(Duration(seconds: 2), () async {
                openedSettingsPageForPermission = true;
                if(!isLocationDialogBoxOpen){
                  showLocationDailog();
                }

                //await openAppSettings();
              });
            } else {
              if (await Permission.locationWhenInUse.isGranted) {
                if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                  Fluttertoast.showToast(
                      msg: "Please enable GPS",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);

                  Future.delayed(Duration(seconds: 1), () async {
                    AppSettings.openAppSettings(type: AppSettingsType.location);
                    checkGPS(context);
                  });
                } else {
                  locationController?.getUserCurrentLocation(context);
                }
                bool isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context, autoConnect: true);
                });
                if (isBluetoothEnable) {
                  autoConnectToDevice();
                } else {
                  Utils.customPrint('BLED - SHOWN FIFTH');
                  showBluetoothDialog(context, autoConnect: true);
                }
              } else {
                if ((await Permission
                    .locationWhenInUse.shouldShowRequestRationale)) {
                  Utils.showSnackBar(context,
                      scaffoldKey: scaffoldKey,
                      message:
                      'Location permissions are denied without permissions we are unable to start the trip');
                  Future.delayed(Duration(seconds: 2), () async {
                    openedSettingsPageForPermission = true;
                    if(!isLocationDialogBoxOpen){
                      showLocationDailog();
                    }

                    // await openAppSettings();
                  });
                } else {
                  await Permission.locationWhenInUse.request();
                  if (await Permission.locationWhenInUse.isGranted) {
                    if (!(await geo.Geolocator.isLocationServiceEnabled())) {
                      Fluttertoast.showToast(
                          msg: "Please enable GPS",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);

                      Future.delayed(Duration(seconds: 1), () async {
                        AppSettings.openAppSettings(
                            type: AppSettingsType.location);
                        checkGPS(context);
                      });
                    } else {
                      locationController?.getUserCurrentLocation(context);
                    }
                    bool isBluetoothEnable = Platform.isAndroid
                        ? await blueIsOn()
                        : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                      showBluetoothDialog(context, autoConnect: true);
                    });
                    if (isBluetoothEnable) {
                      autoConnectToDevice();
                    } else {
                      Utils.customPrint('BLED - SHOWN FIFTH');
                      showBluetoothDialog(context, autoConnect: true);
                    }
                  } else {
                    checkPermissionsAndAutoConnectToDevice(context);
                  }
                }
              }
            }
          } else {
            if (await Permission.bluetoothConnect.isDenied ||
                await Permission.bluetoothConnect.isPermanentlyDenied) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LocationPermissionCustomDialog(
                      isLocationDialogBox: false,
                      text: 'Allow nearby devices',
                      subText: 'Allow nearby devices to connect to the app',
                      buttonText: 'OK',
                      buttonOnTap: () async {
                        Get.back();

                        openedSettingsPageForPermission = true;
                        await openAppSettings();
                      },
                    );
                  });
            }
          }
        }
      }
    }
  }

  Future<bool> blueIsOn() async {
    // FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    BluetoothAdapterState adapterState =
    await FlutterBluePlus.adapterState.first;
    final isOn = adapterState == BluetoothAdapterState.on;
    // if (isOn) return true;
    //
    // await Future.delayed(const Duration(seconds: 1));
    // BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
    return isOn;
  }

  /// To enable Bluetooth
  Future<void> enableBT(bool autoConnect) async {
    if (Platform.isIOS) openedSettingsPageForPermission = true;
    BluetoothEnable.enableBluetooth.then((value) async {
      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
        if (autoConnect) {
          await Future.delayed(Duration(milliseconds: 500), () {});
          autoConnectToDevice();
        }
        Utils.customPrint(" bluetooth state$value");
      } else {
        bool isNearByDevicePermitted =
        await Permission.bluetoothConnect.isGranted;
        if (!isNearByDevicePermitted) {
          await Permission.bluetoothConnect.request();
        } else {
          await Permission.bluetooth.request();
        }
      }
    }).catchError((e) {
      Utils.customPrint("ENABLE BT$e");
    });
  }

  Future<dynamic> checkIfBluetoothIsEnabled(
      GlobalKey<ScaffoldState> scaffoldKey,
      VoidCallback showBluetoothDialog) async {
    bool isBluetoothEnabled = false;
    BluetoothAdapterState adapterState =
    await FlutterBluePlus.adapterState.first;
    bool isBLEEnabled = adapterState == BluetoothAdapterState.on;
    // bool isBLEEnabled = await flutterBluePlus!.isOn;
    Utils.customPrint('isBLEEnabled: $isBLEEnabled');

    if (isBLEEnabled) {
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if (!isGranted) {
        await Permission.bluetooth.request();
        bool isPermGranted = await Permission.bluetooth.isGranted;

        if (isPermGranted) {
          // FlutterBluePlus _flutterBlue = FlutterBluePlus();
          BluetoothAdapterState adapterState =
          await FlutterBluePlus.adapterState.first;
          final isOn = adapterState == BluetoothAdapterState.on;
          if (isOn) isBluetoothEnabled = true;

          await Future.delayed(const Duration(seconds: 1));
          BluetoothAdapterState tempAdapterState =
          await FlutterBluePlus.adapterState.first;
          isBluetoothEnabled = adapterState == BluetoothAdapterState.on;
          // isBluetoothEnabled = await FlutterBluePlus.isOn;
          if (!isBluetoothEnabled) openedSettingsPageForPermission = true;
          return isBluetoothEnabled;
        } else {
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3), () async {
            openedSettingsPageForPermission = true;
            await openAppSettings();
          });
          return null;
        }
      } else {
        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState =
        await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if (isOn) isBluetoothEnabled = true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState =
        await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        if (!isBluetoothEnabled) openedSettingsPageForPermission = true;
        return isBluetoothEnabled;
      }
    } else {
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if (!isGranted) {
        if (await Permission.bluetooth.isPermanentlyDenied) {
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3), () async {
            openedSettingsPageForPermission = true;
            await openAppSettings();
          });
          return null;
        } else {
          openedSettingsPageForPermission = true;
          await Permission.bluetooth.request();
        }
      } else {
        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState =
        await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if (isOn) isBluetoothEnabled = true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState =
        await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        if (!isBluetoothEnabled) openedSettingsPageForPermission = true;
        return isBluetoothEnabled;
      }
    }
  }

  autoConnectToDevice() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(
    //     key: 'lprDeviceId'
    // );

    Utils.customPrint("LPR DEVICE ID $lprDeviceId");
    isBluetoothSearching = true;
    setState(() {});
    // EasyLoading.show(
    //     status: 'Searching for available devices...',
    //     maskType: EasyLoadingMaskType.black);

    /// Check for already connected device.
    List<BluetoothDevice> connectedDevicesList =
        FlutterBluePlus.connectedDevices;
    Utils.customPrint("BONDED LIST $connectedDevicesList");

    if (connectedDevicesList.isEmpty) {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      List<ScanResult> streamOfScanResultList = [];

      // await Future.delayed(Duration(seconds: 4), () async {
      //   // await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      //   EasyLoading.dismiss();
      // });

      String deviceId = '';
      BluetoothDevice? connectedBluetoothDevice;

      autoConnectStreamSubscription =
          FlutterBluePlus.scanResults.listen((value) {
            Utils.customPrint('BLED - SCAN RESULT - ${value.isEmpty}');
            streamOfScanResultList = value;
          });

      autoConnectIsScanningStreamSubscription =
          FlutterBluePlus.isScanning.listen((event) {
            Utils.customPrint('BLED - IS SCANNING: $event');
            Utils.customPrint(
                'BLED - IS SCANNING: ${streamOfScanResultList.length}');
            if (!event) {
              autoConnectIsScanningStreamSubscription!.cancel();
              if (streamOfScanResultList.isNotEmpty) {
                if (lprDeviceId != null) {
                  List<ScanResult> storedDeviceIdResultList = streamOfScanResultList
                      .where(
                          (element) => element.device.remoteId.str == lprDeviceId)
                      .toList();
                  if (storedDeviceIdResultList.isNotEmpty) {
                    ScanResult r = storedDeviceIdResultList.first;
                    r.device.connect().then((value) {
                      Utils.customPrint('CONNECTED TO DEVICE BLE');
                      LPRDeviceHandler().setLPRDevice(r.device);
                      LPRDeviceHandler().setDeviceDisconnectCallback(() {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                      setState(() {});
                    }).catchError((onError) {
                      Utils.customPrint('ERROR BLE: $onError');
                    });

                    bluetoothName = r.device.platformName.isEmpty
                        ? r.device.remoteId.str
                        : r.device.platformName;
                    //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                    deviceId = r.device.remoteId.str;
                    connectedBluetoothDevice = r.device;
                    setState(() {
                      bluetoothName = r.device.platformName.isEmpty
                          ? r.device.remoteId.str
                          : r.device.platformName;
                      isBluetoothPermitted = true;
                      progress = 1.0;
                      lprSensorProgress = 1.0;
                      isStartButton = true;
                      isBluetoothSearching = false;
                    });
                    FlutterBluePlus.stopScan();
                    EasyLoading.dismiss();
                  } else {
                    List<ScanResult> lprNameResultList = streamOfScanResultList
                        .where((element) => element.device.platformName
                        .toLowerCase()
                        .contains('lpr'))
                        .toList();
                    if (lprNameResultList.isNotEmpty) {
                      ScanResult r = lprNameResultList.first;
                      r.device.connect().then((value) {
                        LPRDeviceHandler().setLPRDevice(r.device);
                        LPRDeviceHandler().setDeviceDisconnectCallback(() {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                        setState(() {});
                      });
                      bluetoothName = r.device.platformName.isEmpty
                          ? r.device.remoteId.str
                          : r.device.platformName;
                      // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                      deviceId = r.device.remoteId.str;
                      connectedBluetoothDevice = r.device;
                      setState(() {
                        bluetoothName = r.device.platformName.isEmpty
                            ? r.device.remoteId.str
                            : r.device.platformName;
                        isBluetoothPermitted = true;
                        progress = 1.0;
                        lprSensorProgress = 1.0;
                        isStartButton = true;
                        isBluetoothSearching = false;
                      });
                      FlutterBluePlus.stopScan();
                      EasyLoading.dismiss();
                    } else {
                      if (mounted) {
                        Future.delayed(Duration(seconds: 2), () {
                          EasyLoading.dismiss();
                          isBluetoothSearching = false;

                          showBluetoothListDialog(context, null, null);
                        });
                      }
                    }
                  }
                } else {
                  List<ScanResult> lprNameResultList = streamOfScanResultList
                      .where((element) =>
                      element.device.platformName.toLowerCase().contains('lpr'))
                      .toList();
                  if (lprNameResultList.isNotEmpty) {
                    ScanResult r = lprNameResultList.first;
                    r.device.connect().then((value) {
                      LPRDeviceHandler().setLPRDevice(r.device);
                      LPRDeviceHandler().setDeviceDisconnectCallback(() {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                      setState(() {});
                    });
                    bluetoothName = r.device.platformName.isEmpty
                        ? r.device.remoteId.str
                        : r.device.platformName;
                    // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                    deviceId = r.device.remoteId.str;
                    connectedBluetoothDevice = r.device;
                    setState(() {
                      bluetoothName = r.device.platformName.isEmpty
                          ? r.device.remoteId.str
                          : r.device.platformName;
                      isBluetoothPermitted = true;
                      progress = 1.0;
                      lprSensorProgress = 1.0;
                      isStartButton = true;
                      isBluetoothSearching = false;
                    });
                    FlutterBluePlus.stopScan();
                    EasyLoading.dismiss();
                  } else {
                    if (mounted) {
                      Future.delayed(Duration(seconds: 2), () {
                        EasyLoading.dismiss();
                        isBluetoothSearching = false;

                        showBluetoothListDialog(context, null, null);
                      });
                    }
                  }
                }
              } else {
                if (mounted) {
                  Future.delayed(Duration(seconds: 2), () {
                    EasyLoading.dismiss();
                    showBluetoothListDialog(context, null, null);
                  });
                }
              }
            }
          });
    } else {
      // Show snack bar -> "Connected to <device_name> device."
      Future.delayed(Duration(seconds: 4), () async {
        EasyLoading.dismiss();
      });
      setState(() {
        bluetoothName = connectedDevicesList.first.platformName.isNotEmpty
            ? connectedDevicesList.first.platformName
            : connectedDevicesList.first.remoteId.str;
      });
      LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
      LPRDeviceHandler().setDeviceDisconnectCallback(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void showLocationDailog(){
    showDialog(
        context: scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          isLocationDialogBoxOpen = true;
          return LocationPermissionCustomDialog(
              isLocationDialogBox: true,
              text: 'Always Allow Access to “Location”',
              subText:
              "To track your trip while you use other apps we need background access to your location",
              buttonText: 'Ok',
              buttonOnTap: () async {
                if(Platform.isAndroid){
                  var permission=                      await Permission.locationAlways.request();
                  if(permission.isGranted){

                  }else{
                    await openAppSettings();

                  }

                }else{
                  await openAppSettings();

                }
                Get.back();

              });
        }).then((value) {
      isLocationDialogBoxOpen = false;
    });
  }

  showBluetoothDialog(BuildContext context, {bool autoConnect = false}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(builder: (ctx, setDialogState) {
              return Container(
                width: displayWidth(context),
                height: displayHeight(context) * 0.3,
                decoration: new BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "Turn Bluetooth On",
                        style: TextStyle(
                            color: blutoothDialogTitleColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "To connect with other devices we require\n you to enable the Bluetooth",
                        style: TextStyle(
                            color: blutoothDialogTxtColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: displayWidth(context) * 0.12,
                          left: 15,
                          right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Utils.customPrint("Tapped on cancel button");
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bluetoothCancelBtnBackColor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothCancelBtnTxtColor),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Utils.customPrint("Tapped on enable Bluetooth");
                              Navigator.pop(context);
                              enableBT(autoConnect);
                              //showBluetoothListDialog(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Enable Bluetooth",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothConnectBtncolor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  checkGPS(BuildContext context) {
    StreamSubscription<geo.ServiceStatus> serviceStatusStream =
    geo.Geolocator.getServiceStatusStream()
        .listen((geo.ServiceStatus status) {
      print(status);

      if (status == geo.ServiceStatus.disabled) {
        Fluttertoast.showToast(
            msg: "Please enable GPS",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        Future.delayed(Duration(seconds: 1), () async {
          AppSettings.openAppSettings(type: AppSettingsType.location);

          if (!(await geo.Geolocator.isLocationServiceEnabled())) {
            checkGPS(context);
          } else {
            locationController!.getUserCurrentLocation(context);
          }
        });
      } else {
        Future.delayed(Duration(seconds: 2), () {
          locationController!.getUserCurrentLocation(context);
        });
      }
    });
  }

  showBluetoothListDialog(BuildContext context, String? connectedDeviceId,
      BluetoothDevice? connectedBluetoothDevice) {
    // setState(() {
    //   progress = 0.9;
    //   lprSensorProgress = 0.0;
    //   isStartButton = false;
    // });

    // checkAndGetLPRList();

    if (autoConnectStreamSubscription != null)
      autoConnectStreamSubscription!.cancel();
    if (autoConnectIsScanningStreamSubscription != null)
      autoConnectIsScanningStreamSubscription!.cancel();

    if (!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 4))
          .onError((error, stackTrace) {
        Utils.customPrint('EDEDED: $error');
      });
    }

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(builder: (ctx, setDialogState) {
                return Container(
                  width: displayWidth(context),
                  height: displayHeight(context) * 0.6,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.03,
                      ),

                      Image.asset(
                        'assets/icons/web.png',
                        width: displayWidth(context) * 0.25,
                      ),

                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),

                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: commonText(
                              context: context,
                              text: 'Available Devices',
                              fontWeight: FontWeight.w500,
                              textColor: blutoothDialogTitleColor,
                              textSize: displayWidth(context) * 0.042,
                              fontFamily: outfit)),

                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: commonText(
                              context: context,
                              text:
                              'Tap to connect with LPR Devices to track Trip Details',
                              fontWeight: FontWeight.w400,
                              textColor: Colors.grey[600],
                              textSize: displayWidth(context) * 0.032,
                              textAlign: TextAlign.center,
                              fontFamily: inter)),

                      // Implement listView for bluetooth devices
                      Expanded(
                        child: isRefreshList == true
                            ? Container(
                            width: displayWidth(context),
                            height: displayHeight(context) * 0.28,
                            child: LPRBluetoothList(
                              dialogContext: dialogContext,
                              setDialogSet: setDialogState,
                              connectedDeviceId: connectedDeviceId,
                              connectedBluetoothDevice:
                              connectedBluetoothDevice,
                              onSelected: (value) {
                                if (mounted) {
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {});
                                });
                                LPRDeviceHandler()
                                    .setDeviceDisconnectCallback(() {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  setState(() {
                                    isBluetoothPermitted = value;
                                    debugPrint(
                                        "BLUETOOTH PERMISSION CODE 1 $isBluetoothPermitted");
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {});
                                });
                                LPRDeviceHandler()
                                    .setDeviceDisconnectCallback(() {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                              },
                            ))
                            : Container(
                            width: displayWidth(context),
                            height: displayHeight(context) * 0.28,
                            child: LPRBluetoothList(
                              dialogContext: dialogContext,
                              setDialogSet: setDialogState,
                              connectedDeviceId: connectedDeviceId,
                              connectedBluetoothDevice:
                              connectedBluetoothDevice,
                              onSelected: (value) {
                                if (mounted) {
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {});
                                });
                                LPRDeviceHandler()
                                    .setDeviceDisconnectCallback(() {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                              },
                              onBluetoothConnection: (value) {
                                if (mounted) {
                                  setState(() {
                                    isBluetoothPermitted = value;
                                    debugPrint(
                                        "BLUETOOTH PERMISSION CODE 2 $isBluetoothPermitted");
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {});
                                });
                                LPRDeviceHandler()
                                    .setDeviceDisconnectCallback(() {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                });
                              },
                            )),
                      ),

                      SizedBox(
                        height: displayWidth(context) * 0.04,
                      ),

                      Container(
                        width: displayWidth(context),
                        margin:
                        EdgeInsets.only(left: 15, right: 15, bottom: 15),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Utils.customPrint("Tapped on scan button");

                                if (mounted) {
                                  /*setDialogState(() {
                                   isScanningBluetooth = true;
                                 });*/
                                }

                                FlutterBluePlus.startScan(
                                    timeout: const Duration(seconds: 2));

                                if (mounted) {
                                  Future.delayed(Duration(seconds: 2), () {
                                    /* setDialogState(() {
                                     isScanningBluetooth = false;
                                   });*/
                                  });
                                }

                                if (mounted) {
                                  setState(() {
                                    isRefreshList = true;
                                    progress = 0.9;
                                    lprSensorProgress = 0.0;
                                    isStartButton = false;
                                    bluetoothName = '';
                                  });
                                }
                              },
                              child: isScanningBluetooth
                                  ? Center(
                                child: Container(
                                    margin: EdgeInsets.only(
                                      top: displayWidth(context) * 0.02,
                                    ),
                                    width: displayWidth(context) * 0.34,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                          color: blueColor,
                                        ))),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                height: displayHeight(context) * 0.055,
                                width: displayWidth(context) / 1.6,
                                // color: HexColor(AppColors.introButtonColor),
                                child: Center(
                                    child: commonText(
                                        context: context,
                                        text: 'Scan for Devices',
                                        fontWeight: FontWeight.w500,
                                        textColor:
                                        bluetoothConnectBtncolor,
                                        textSize:
                                        displayWidth(context) * 0.04,
                                        fontFamily: outfit)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // FlutterBluePlus.instance.

                                FlutterBluePlus.stopScan();

                                setDialogState(() {
                                  isScanningBluetooth = false;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                height: displayHeight(context) * 0.055,
                                width: displayWidth(context) / 1.6,
                                // color: HexColor(AppColors.introButtonColor),
                                child: Center(
                                    child: commonText(
                                        context: context,
                                        text: 'Cancel',
                                        fontWeight: FontWeight.w500,
                                        textColor: blueColor,
                                        textSize: displayWidth(context) * 0.038,
                                        fontFamily: outfit)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }));
        }).then((value) {
      setState(() {});
      Future.delayed(Duration(microseconds: 500), () {
        isBluetoothSearching = false;
        setState(() {});
      });

      Utils.customPrint('DIALOG VALUE $value');
    });
  }

  forgetDeviceOrConnectToNewDevice() async {
    if (FlutterBluePlus.connectedDevices.isEmpty) {
      if (isClickedOnForgetDevice) {
        showBluetoothListDialog(context, null, null);
      } else {
        checkAndGetLPRList(context);
      }
    } else {
      showForgetDeviceDialog(context, forgetDeviceBtnClick: () async {
        var pref = await Utils.initSharedPreferences();

        isClickedOnForgetDevice = true;
        LPRDeviceHandler().isSelfDisconnected = true;
        Navigator.of(context).pop();
        EasyLoading.show(
            status: 'Disconnecting...', maskType: EasyLoadingMaskType.black);
        for (int i = 0; i < FlutterBluePlus.connectedDevices.length; i++) {
          await FlutterBluePlus.connectedDevices[i].disconnect().then((value) {
            LPRDeviceHandler().isSelfDisconnected = false;
            pref.setBool('device_forget', true);
          });
        }
        EasyLoading.dismiss();
        setState(() {
          bluetoothName = 'LPR';
          isBluetoothPermitted = false;
        });
        isBluetoothSearching = true;
        setState(() {});
        // EasyLoading.show(
        //     status: 'Searching for available devices...',
        //     maskType: EasyLoadingMaskType.black);
        Future.delayed(Duration(seconds: 2), () {
          showBluetoothListDialog(context, null, null);
          isBluetoothSearching = false;
          setState(() {});
          EasyLoading.dismiss();
        });
      }, onCancelClick: () {
        Navigator.of(context).pop();
      });
    }
  }

  checkAndGetLPRList(BuildContext context) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(
    //     key: 'lprDeviceId'
    // );

    Utils.customPrint("LPR DEVICE ID $lprDeviceId");

    /// TODO
    List<BluetoothDevice> connectedDevicesList =
    await FlutterBluePlus.connectedDevices;
    Utils.customPrint("BONDED LIST $connectedDevicesList");

    if (connectedDevicesList.isNotEmpty) {
      showForgetDeviceDialog(context, forgetDeviceBtnClick: () async {
        var pref = await Utils.initSharedPreferences();
        isClickedOnForgetDevice = true;
        Navigator.of(context).pop();
        EasyLoading.show(
            status: 'Disconnecting...', maskType: EasyLoadingMaskType.black);
        for (int i = 0; i < connectedDevicesList.length; i++) {
          await connectedDevicesList[i].disconnect();
          pref.setBool('device_forget', true);
        }
        EasyLoading.dismiss();
        setState(() {
          bluetoothName = 'LPR';
          isBluetoothPermitted = false;
        });
        EasyLoading.show(
            status: 'Searching for available devices...',
            maskType: EasyLoadingMaskType.black);
        Future.delayed(Duration(seconds: 2), () {
          showBluetoothListDialog(context, null, null);
          EasyLoading.dismiss();
        });
      }, onCancelClick: () {
        Navigator.of(context).pop();
      });
    } else {
      // EasyLoading.show(
      //     status: 'Searching for available devices...',
      //     maskType: EasyLoadingMaskType.black);

      isBluetoothSearching = true;
      setState(() {});
      String deviceId = '';
      BluetoothDevice? connectedBluetoothDevice;

      FlutterBluePlus.scanResults.listen((value) async {
        if (value.isNotEmpty) {
          for (int i = 0; i < value.length; i++) {
            ScanResult r = value[i];

            if (lprDeviceId != null) {
              Utils.customPrint(
                  'STORED ID: $lprDeviceId - ${r.device.remoteId.str}');
              if (r.device.remoteId.str == lprDeviceId) {
                r.device.connect().then((value) {
                  LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                  Utils.customPrint('CONNECTED TO DEVICE BLE');
                }).catchError((onError) {
                  Utils.customPrint('ERROR BLE: $onError');
                });

                bluetoothName = r.device.platformName.isEmpty
                    ? r.device.remoteId.str
                    : r.device.platformName;
                //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                if (mounted) {
                  setState(() {
                    bluetoothName = r.device.platformName.isEmpty
                        ? r.device.remoteId.str
                        : r.device.platformName;
                    isBluetoothPermitted = true;
                    progress = 1.0;
                    lprSensorProgress = 1.0;
                    isStartButton = true;
                  });
                }
                FlutterBluePlus.stopScan();
                break;
              } else {
                if (r.device.platformName.toLowerCase().contains("lpr")) {
                  r.device.connect().then((value) {
                    LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                    LPRDeviceHandler().setDeviceDisconnectCallback(() {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  });
                  bluetoothName = r.device.platformName.isEmpty
                      ? r.device.remoteId.str
                      : r.device.platformName;
                  // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                  if (mounted) {
                    setState(() {
                      bluetoothName = r.device.platformName.isEmpty
                          ? r.device.remoteId.str
                          : r.device.platformName;
                      isBluetoothPermitted = true;
                      progress = 1.0;
                      lprSensorProgress = 1.0;
                      isStartButton = true;
                    });
                  }
                  FlutterBluePlus.stopScan();
                  break;
                }
              }
            } else {
              if (r.device.platformName.toLowerCase().contains("lpr")) {
                r.device.connect().then((value) {
                  LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                });
                bluetoothName = r.device.platformName.isEmpty
                    ? r.device.remoteId.str
                    : r.device.platformName;
                //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                if (mounted) {
                  setState(() {
                    bluetoothName = r.device.platformName.isEmpty
                        ? r.device.remoteId.str
                        : r.device.platformName;
                    isBluetoothPermitted = true;
                    progress = 1.0;
                    lprSensorProgress = 1.0;
                    isStartButton = true;
                  });
                }
                FlutterBluePlus.stopScan();
                break;
              }
            }
          }
        }
      });

      FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      Future.delayed(Duration(seconds: 4), () {
        showBluetoothListDialog(context, deviceId, connectedBluetoothDevice);
        isBluetoothSearching = false;
        setState(() {});
        EasyLoading.dismiss();
      });
    }
    return;
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name.toLowerCase().contains("jbl")) {
          Utils.customPrint('FOUND DEVICE AGAIN');

          r.device.connect().catchError((e) {
            r.device.state.listen((event) {
              if (event == BluetoothDeviceState.connected) {
                r.device.disconnect().then((value) {
                  r.device.connect().catchError((e) {
                    if (mounted) {
                      setState(() {
                        isBluetoothPermitted = true;
                        progress = 1.0;
                        lprSensorProgress = 1.0;
                        isStartButton = true;
                        debugPrint(
                            "BLUETOOTH PERMISSION CODE 4 $isBluetoothPermitted");
                      });
                    }
                  });
                });
              }
            });
          });

          bluetoothName = r.device.name;

          debugPrint("SELECTED BLE NAME $bluetoothName");
          setState(() {
            isBluetoothPermitted = true;
            progress = 1.0;
            lprSensorProgress = 1.0;
            isStartButton = true;
            debugPrint("BLUETOOTH PERMISSION CODE 5 $isBluetoothPermitted");
          });
          FlutterBluePlus.stopScan();
          break;
        } else {
          r.device
              .disconnect()
              .then((value) => Utils.customPrint("is device disconnected: "));
        }
      }
    });
  }

  showForgetDeviceDialog(BuildContext context,
      {VoidCallback? forgetDeviceBtnClick, VoidCallback? onCancelClick}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.42,
                  width: MediaQuery.of(context).size.width,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              //color: Color(0xfff2fffb),
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(ctx) * 0.1,
                                width: displayWidth(ctx),
                                fit: BoxFit.contain,
                              ),
                            )),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: commonText(
                              context: context,
                              text:
                              'Would you like to disconnect from the currently connected Bluetooth device and connect to a new device?',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black87,
                              textSize: displayWidth(context) * 0.042,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                        Column(
                          children: [
                            Center(
                              child: CommonButtons.getAcceptButton(
                                  'Forget Device',
                                  context,
                                  endTripBtnColor,
                                  forgetDeviceBtnClick,
                                  displayWidth(context) / 1.5,
                                  displayHeight(context) * 0.055,
                                  primaryColor,
                                  Colors.white,
                                  displayWidth(context) * 0.036,
                                  endTripBtnColor,
                                  '',
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: CommonButtons.getAcceptButton(
                                  'Cancel',
                                  context,
                                  Colors.transparent,
                                  onCancelClick,
                                  displayWidth(context) * 0.5,
                                  displayHeight(context) * 0.05,
                                  Colors.transparent,
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                      ? Colors.white
                                      : blueColor,
                                  displayHeight(context) * 0.018,
                                  Colors.transparent,
                                  '',
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10.0,
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

}
