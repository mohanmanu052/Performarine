import 'dart:async';
import 'dart:io';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel_new/add_new_vessel_screen.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/utils/start_trip_lpr_permission.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../models/device_model.dart';
import '../bottom_navigation.dart';
import '../lpr_bluetooth_list.dart';
import '../trip_analytics.dart';

class StartTripRecordingScreen extends StatefulWidget {
  //final bool? isLocationPermitted;
  //final bool? isBluetoothConnected;
  final String calledFrom;
  final int? bottomNavIndex;
  const StartTripRecordingScreen(
      {super.key,
        this.bottomNavIndex,
        /*this.isLocationPermitted = false, this.isBluetoothConnected = false,*/ this.calledFrom =
      ''});

  @override
  State<StartTripRecordingScreen> createState() =>
      StartTripRecordingScreenState();
}

class StartTripRecordingScreenState extends State<StartTripRecordingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  GlobalKey<StartTripRecordingScreenState> tripState=GlobalKey();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<VesselDropdownItem> vesselData = [];

  VesselDropdownItem? selectedValue;

  String selectedVesselWeight = 'Select Current Load',
      getTripId = '',
      bluetoothName = 'LPR';

  int valueHolder = 1, numberOfPassengers = 1, passengerValue = 0;

  bool? isGpsOn, isLPRConnected, isBleOn;
  bool addingDataToDB = false,
      isServiceRunning = false,
      isLocationDialogBoxOpen = false,
      isStartButton = false,
      isVesselDataLoading = false,
      isBluetoothPermitted = false,
      isLocationPermitted = false,
      isRefreshList = false,
      isScanningBluetooth = false,
      isSliderDisable = false,
      isCheck = false,isOKClick = false, locationAccuracy = false;

  bool isClickedOnForgetDevice = false;

  final controller = ScreenshotController();

  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;

  String? selectedVesselName, vesselId, sliderCount = '10+';

  Timer? notiTimer;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  DeviceInfo? deviceDetails;
  late Future<List<CreateVessel>> vesselList;

  double progress = 0.9, lprSensorProgress = 1.0,
      sliderMinVal = 11;

  late AnimationController popupAnimationController;
  late TextEditingController textEditingController;
  FocusNode _focusNode = FocusNode();

  bool openedSettingsPageForPermission = false;

  StreamSubscription<List<ScanResult>>? autoConnectStreamSubscription;
  StreamSubscription<bool>? autoConnectIsScanningStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // Future.delayed(Duration(seconds: 1)).then((value) {
    //
    //   if(tripState.currentState!=null){
    //     StartTripLprPermission().locationPermissions(true, tripState, scaffoldKey, context);
    //
    //   }
    //
    // });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    WidgetsBinding.instance.addObserver(this);

    //checkAllPermission(false);

    debugPrint("SCREEN CALLED FROM ${widget.calledFrom}");

    commonProvider = context.read<CommonProvider>();
    getVesselAndTripsData();

    checkTempPermissions();
    textEditingController = TextEditingController();

    popupAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        textEditingController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textEditingController.value.text.length);
      }
    });

    Future.delayed(Duration(milliseconds: 500), (){
      checkPermissionsAndAutoConnectToDevice(context);
    });
  }

  checkPermissionsAndAutoConnectToDevice(BuildContext context) async
  {
    bool isNDPermDenied =
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
      /// START
      if(Platform.isIOS){
        dynamic isBluetoothEnable = Platform
            .isAndroid
            ? await blueIsOn()
            : await checkIfBluetoothIsEnabled(
            scaffoldKey,
                () {
              showBluetoothDialog(
                  context, autoConnect: true);
            });

        if(isBluetoothEnable != null){
          if(isBluetoothEnable){
            autoConnectToDevice();
          }
          else{
            Utils.customPrint('BLED - SHOWN FIRST');
            showBluetoothDialog(
                context, autoConnect: true);
          }
        }
      }
      else{
        bool
        isNDPermittedOne =
        await Permission
            .bluetoothConnect
            .isGranted;

        if(isNDPermittedOne){

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
                Duration(
                    seconds: 2),
                    () async {
                  openedSettingsPageForPermission = true;
                  await openAppSettings();
                });
          }
          else {
            if (await Permission
                .location
                .isGranted) {
              bool isBluetoothEnable = await blueIsOn();

              if(isBluetoothEnable){
                autoConnectToDevice();
              }
              else{
                Utils.customPrint('BLED - SHOWN SECOND');
                showBluetoothDialog(context, autoConnect: true);
              }

              // checkAndGetLPRList(
              //     context);
              // showBluetoothListDialog(context);
            }
            else {
              if ((await Permission
                  .location
                  .shouldShowRequestRationale)) {
                Utils.showSnackBar(
                    context,
                    scaffoldKey: scaffoldKey,
                    message: 'Location permissions are denied without permissions we are unable to start the trip');
                Future.delayed(
                    Duration(seconds: 2),
                        () async {
                      openedSettingsPageForPermission = true;
                      await openAppSettings();
                    });
              }
              else {
                await Permission
                    .location
                    .request();
                if(await Permission
                    .location.isGranted){
                  bool isBluetoothEnable = Platform
                      .isAndroid
                      ? await blueIsOn()
                      : await checkIfBluetoothIsEnabled(
                      scaffoldKey,
                          () {
                        showBluetoothDialog(
                            context, autoConnect: true);
                      });
                  if(isBluetoothEnable){
                    autoConnectToDevice();
                  }
                  else{
                    Utils.customPrint('BLED - SHOWN THIRD');
                    showBluetoothDialog(context, autoConnect: true);
                  }
                }
                else{
                  checkPermissionsAndAutoConnectToDevice(context);
                }
              }
            }
          }
        }
        else{
          await Permission
              .bluetoothConnect
              .request();
          bool
          isNDPermitted =
          await Permission
              .bluetoothConnect
              .isGranted;

          if(isNDPermitted){
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
                  Duration(
                      seconds: 2),
                      () async {
                    openedSettingsPageForPermission = true;
                    await openAppSettings();
                  });
            }
            else {
              if (await Permission
                  .location
                  .isGranted) {
                bool isBluetoothEnable = Platform
                    .isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(
                    scaffoldKey,
                        () {
                      showBluetoothDialog(
                          context, autoConnect: true);
                    });
                if(isBluetoothEnable){
                  autoConnectToDevice();
                }
                else{
                  Utils.customPrint('BLED - SHOWN FOURTH');
                  showBluetoothDialog(context, autoConnect: true);
                }

                // checkAndGetLPRList(
                //     context);
                // showBluetoothListDialog(context);
              }
              else {
                if ((await Permission
                    .location
                    .shouldShowRequestRationale)) {
                  Utils.showSnackBar(
                      context,
                      scaffoldKey: scaffoldKey,
                      message: 'Location permissions are denied without permissions we are unable to start the trip');
                  Future.delayed(
                      Duration(seconds: 2),
                          () async {
                        openedSettingsPageForPermission = true;
                        await openAppSettings();
                      });
                }
                else {
                  await Permission
                      .location
                      .request();
                  if(await Permission
                      .location.isGranted){
                    bool isBluetoothEnable = Platform
                        .isAndroid
                        ? await blueIsOn()
                        : await checkIfBluetoothIsEnabled(
                        scaffoldKey,
                            () {
                          showBluetoothDialog(
                              context, autoConnect: true);
                        });
                    if(isBluetoothEnable){
                      autoConnectToDevice();
                    }
                    else{
                      Utils.customPrint('BLED - SHOWN FIFTH');
                      showBluetoothDialog(context, autoConnect: true);
                    }
                  }
                  else{
                    checkPermissionsAndAutoConnectToDevice(context);
                  }
                }
              }
            }
          }
          else{
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

                        openedSettingsPageForPermission = true;
                        await openAppSettings();
                      },
                    );
                  });
            }
          }
        }
      }
      /// END




      // if (Platform
      //     .isIOS) {
      //   dynamic isBluetoothEnable = Platform
      //       .isAndroid
      //       ? await blueIsOn()
      //       : await commonProvider
      //       .checkIfBluetoothIsEnabled(
      //       scaffoldKey,
      //           () {
      //         showBluetoothDialog(
      //             context);
      //       });
      //
      //   if (isBluetoothEnable !=
      //       null) {
      //     if (isBluetoothEnable) {
      //       if (Platform
      //           .isIOS) {
      //         autoConnectToDevice();
      //         // checkAndGetLPRList(
      //         //     context);
      //         // showBluetoothListDialog(context);
      //       } else {
      //         if (await Permission
      //             .location
      //             .isPermanentlyDenied) {
      //           Utils.showSnackBar(
      //               context,
      //               scaffoldKey:
      //               scaffoldKey,
      //               message:
      //               'Location permissions are denied without permissions we are unable to start the trip');
      //           Future.delayed(
      //               Duration(
      //                   seconds: 2),
      //                   () async {
      //                 await openAppSettings();
      //               });
      //         } else {
      //           if (await Permission
      //               .location
      //               .isGranted) {
      //             autoConnectToDevice();
      //             // checkAndGetLPRList(
      //             //     context);
      //             // showBluetoothListDialog(context);
      //           } else {
      //             await Permission
      //                 .location
      //                 .request();
      //           }
      //         }
      //       }
      //     } else {
      //       showBluetoothDialog(
      //           context);
      //     }
      //   }
      // }
      // else {
      //   bool
      //   isNDPermittedOne =
      //   await Permission
      //       .bluetoothConnect
      //       .isGranted;
      //
      //   if (isNDPermittedOne) {
      //     bool isBluetoothEnable = Platform
      //         .isAndroid
      //         ? await blueIsOn()
      //         : await commonProvider
      //         .checkIfBluetoothIsEnabled(
      //         scaffoldKey,
      //             () {
      //           showBluetoothDialog(
      //               context);
      //         });
      //
      //     if (isBluetoothEnable) {
      //       if (Platform
      //           .isIOS) {
      //         autoConnectToDevice();
      //         // checkAndGetLPRList(
      //         //     context);
      //         // showBluetoothListDialog(context);
      //       } else {
      //         if (await Permission
      //             .location
      //             .isPermanentlyDenied) {
      //           Utils.showSnackBar(
      //               context,
      //               scaffoldKey:
      //               scaffoldKey,
      //               message:
      //               'Location permissions are denied without permissions we are unable to start the trip');
      //           Future.delayed(
      //               Duration(
      //                   seconds: 2),
      //                   () async {
      //                 await openAppSettings();
      //               });
      //         }
      //         else {
      //
      //           if (await Permission
      //               .location
      //               .isGranted) {
      //             autoConnectToDevice();
      //             // checkAndGetLPRList(
      //             //     context);
      //             // showBluetoothListDialog(context);
      //           }
      //           else {
      //             if (!(await Permission
      //                 .location
      //                 .shouldShowRequestRationale)) {
      //               Utils.showSnackBar(
      //                   context,
      //                   scaffoldKey: scaffoldKey,
      //                   message: 'Location permissions are denied without permissions we are unable to start the trip');
      //               Future.delayed(
      //                   Duration(seconds: 2),
      //                       () async {
      //                     await openAppSettings();
      //                   });
      //             } else {
      //               await Permission
      //                   .location
      //                   .request();
      //             }
      //           }
      //         }
      //       }
      //     } else {
      //       showBluetoothDialog(
      //           context);
      //     }
      //   }
      //   else {
      //     await Permission
      //         .bluetoothConnect
      //         .request();
      //     bool
      //     isNDPermitted =
      //     await Permission
      //         .bluetoothConnect
      //         .isGranted;
      //     if (isNDPermitted) {
      //       bool isBluetoothEnable = Platform
      //           .isAndroid
      //           ? await blueIsOn()
      //           : await commonProvider.checkIfBluetoothIsEnabled(
      //           scaffoldKey,
      //               () {
      //             showBluetoothDialog(
      //                 context);
      //           });
      //
      //       if (isBluetoothEnable) {
      //         if (Platform
      //             .isIOS) {
      //           autoConnectToDevice();
      //           // checkAndGetLPRList(
      //           //     context);
      //           // showBluetoothListDialog(context);
      //         } else {
      //           if (await Permission
      //               .location
      //               .isPermanentlyDenied) {
      //             Utils.showSnackBar(
      //                 context,
      //                 scaffoldKey:
      //                 scaffoldKey,
      //                 message:
      //                 'Location permissions are denied without permissions we are unable to start the trip');
      //             Future.delayed(
      //                 Duration(seconds: 2),
      //                     () async {
      //                   await openAppSettings();
      //                 });
      //           } else {
      //             if (await Permission
      //                 .location
      //                 .isGranted) {
      //               autoConnectToDevice();
      //               // checkAndGetLPRList(
      //               //     context);
      //               // showBluetoothListDialog(context);
      //             } else {
      //               await Permission
      //                   .location
      //                   .request();
      //               if (await Permission
      //                   .location
      //                   .isGranted){
      //                 autoConnectToDevice();
      //               }
      //             }
      //           }
      //         }
      //       } else {
      //         showBluetoothDialog(
      //             context);
      //       }
      //     } else {
      //       if (await Permission
      //           .bluetoothConnect
      //           .isDenied ||
      //           await Permission
      //               .bluetoothConnect
      //               .isPermanentlyDenied) {
      //         showDialog(
      //             context:
      //             context,
      //             builder:
      //                 (BuildContext
      //             context) {
      //               return LocationPermissionCustomDialog(
      //                 isLocationDialogBox:
      //                 false,
      //                 text:
      //                 'Allow nearby devices',
      //                 subText:
      //                 'Allow nearby devices to connect to the app',
      //                 buttonText:
      //                 'OK',
      //                 buttonOnTap:
      //                     () async {
      //                   Get.back();
      //
      //                   await openAppSettings();
      //                 },
      //               );
      //             });
      //       }
      //     }
      //   }
      // }
    }
  }

  autoConnectToDevice() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(
    //     key: 'lprDeviceId'
    // );

    Utils.customPrint("LPR DEVICE ID $lprDeviceId");

    EasyLoading.show(
        status: 'Searching for available devices...',
        maskType: EasyLoadingMaskType.black);

    /// Check for already connected device.
    List<BluetoothDevice> connectedDevicesList = FlutterBluePlus.connectedDevices;
    Utils.customPrint("BONDED LIST $connectedDevicesList");

    if(connectedDevicesList.isEmpty){

      FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      List<ScanResult> streamOfScanResultList = [];

      // await Future.delayed(Duration(seconds: 4), () async {
      //   // await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      //   EasyLoading.dismiss();
      // });

      String deviceId = '';
      BluetoothDevice? connectedBluetoothDevice;

      autoConnectStreamSubscription = FlutterBluePlus.scanResults.listen((value) {
        Utils.customPrint('BLED - SCAN RESULT - ${value.isEmpty}');
        streamOfScanResultList = value;
      });

      autoConnectIsScanningStreamSubscription = FlutterBluePlus.isScanning.listen((event) {
        Utils.customPrint('BLED - IS SCANNING: $event');
        Utils.customPrint('BLED - IS SCANNING: ${streamOfScanResultList.length}');
        if(!event){
          autoConnectIsScanningStreamSubscription!.cancel();
          if(streamOfScanResultList.isNotEmpty){

            if(lprDeviceId != null){
              List<ScanResult> storedDeviceIdResultList = streamOfScanResultList.where((element) => element.device.remoteId.str == lprDeviceId).toList();
              if(storedDeviceIdResultList.isNotEmpty){
                ScanResult r = storedDeviceIdResultList.first;
                r.device.connect().then((value) {
                  Utils.customPrint('CONNECTED TO DEVICE BLE');
                  LPRDeviceHandler().setLPRDevice(r.device);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if(mounted){
                      setState(() {

                      });
                    }
                  });
                  setState(() {

                  });
                }).catchError((onError){
                  Utils.customPrint('ERROR BLE: $onError');
                });

                bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                setState(() {
                  bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                  isBluetoothPermitted = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.stopScan();
                EasyLoading.dismiss();
              }
              else{
                List<ScanResult> lprNameResultList = streamOfScanResultList.where((element) => element.device.platformName.toLowerCase().contains('lpr')).toList();
                if(lprNameResultList.isNotEmpty){
                  ScanResult r = lprNameResultList.first;
                  r.device.connect().then((value) {
                    LPRDeviceHandler().setLPRDevice(r.device);
                    LPRDeviceHandler().setDeviceDisconnectCallback(() {
                      if(mounted){
                        setState(() {

                        });
                      }
                    });
                    setState(() {

                    });
                  });
                  bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                  // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                  setState(() {
                    bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                    isBluetoothPermitted = true;
                    progress = 1.0;
                    lprSensorProgress = 1.0;
                    isStartButton = true;
                  });
                  FlutterBluePlus.stopScan();
                  EasyLoading.dismiss();
                }
                else{
                  if (mounted){
                    Future.delayed(Duration(seconds: 2), (){
                      EasyLoading.dismiss();
                      showBluetoothListDialog(context, null, null);
                    });
                  }
                }
              }
            }
            else{
              List<ScanResult> lprNameResultList = streamOfScanResultList.where((element) => element.device.platformName.toLowerCase().contains('lpr')).toList();
              if(lprNameResultList.isNotEmpty){
                ScanResult r = lprNameResultList.first;
                r.device.connect().then((value) {
                  LPRDeviceHandler().setLPRDevice(r.device);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if(mounted){
                      setState(() {

                      });
                    }
                  });
                  setState(() {

                  });
                });
                bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                setState(() {
                  bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                  isBluetoothPermitted = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.stopScan();
                EasyLoading.dismiss();
              }
              else{
                if (mounted){
                  Future.delayed(Duration(seconds: 2), (){
                    EasyLoading.dismiss();
                    showBluetoothListDialog(context, null, null);
                  });
                }
              }
            }



            // for (int i = 0; i < streamOfScanResultList.length; i++) {
            //   ScanResult r = streamOfScanResultList[i];
            //
            //   if(lprDeviceId != null)
            //   {
            //     Utils.customPrint('STORED ID: $lprDeviceId - ${r.device.remoteId.str}');
            //     if(r.device.remoteId.str == lprDeviceId)
            //     {
            //       r.device.connect().then((value) {
            //         Utils.customPrint('CONNECTED TO DEVICE BLE');
            //       }).catchError((onError){
            //         Utils.customPrint('ERROR BLE: $onError');
            //       });
            //
            //       bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //       //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
            //       deviceId = r.device.remoteId.str;
            //       connectedBluetoothDevice = r.device;
            //       setState(() {
            //         bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //         isBluetoothPermitted = true;
            //         progress = 1.0;
            //         lprSensorProgress = 1.0;
            //         isStartButton = true;
            //       });
            //       FlutterBluePlus.stopScan();
            //       EasyLoading.dismiss();
            //       break;
            //     }
            //     else
            //     {
            //       if (r.device.platformName.toLowerCase().contains("lpr")) {
            //         r.device.connect().then((value) {});
            //         bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //         // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
            //         deviceId = r.device.remoteId.str;
            //         connectedBluetoothDevice = r.device;
            //         setState(() {
            //           bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //           isBluetoothPermitted = true;
            //           progress = 1.0;
            //           lprSensorProgress = 1.0;
            //           isStartButton = true;
            //         });
            //         FlutterBluePlus.stopScan();
            //         EasyLoading.dismiss();
            //         break;
            //       }
            //       else{
            //         if(mounted){
            //           Future.delayed(Duration(seconds: 2), (){
            //             EasyLoading.dismiss();
            //             showBluetoothListDialog(context, null, null);
            //           });
            //
            //         }
            //
            //       }
            //     }
            //   }
            //   else
            //   {
            //     Utils.customPrint('BLED - ELSE COND');
            //     if (r.device.platformName.toLowerCase().contains("lpr")) {
            //       r.device.connect().then((value) {});
            //       bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //       //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
            //       deviceId = r.device.remoteId.str;
            //       connectedBluetoothDevice = r.device;
            //       setState(() {
            //         bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
            //         isBluetoothPermitted = true;
            //         progress = 1.0;
            //         lprSensorProgress = 1.0;
            //         isStartButton = true;
            //       });
            //       FlutterBluePlus.stopScan();
            //       EasyLoading.dismiss();
            //       break;
            //     }
            //     else{
            //       if(mounted){
            //         Future.delayed(Duration(seconds: 2), (){
            //           EasyLoading.dismiss();
            //           showBluetoothListDialog(context, null, null);
            //         });
            //       }
            //     }
            //   }
            // }

          }
          else{
            if (mounted){
              Future.delayed(Duration(seconds: 2), (){
                EasyLoading.dismiss();
                showBluetoothListDialog(context, null, null);
              });
            }
          }

        }
      });
    }
    else{
      // Show snack bar -> "Connected to <device_name> device."
      Future.delayed(Duration(seconds: 4), () async {
        EasyLoading.dismiss();
      });
      setState(() {
        bluetoothName = connectedDevicesList.first.platformName.isNotEmpty ? connectedDevicesList.first.platformName : connectedDevicesList.first.remoteId.str;
      });
      LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
      LPRDeviceHandler().setDeviceDisconnectCallback(() {
        if(mounted){
          setState(() {

          });
        }
      });
    }
  }

  forgetDeviceOrConnectToNewDevice() async{
    if(FlutterBluePlus.connectedDevices.isEmpty){
      if(isClickedOnForgetDevice){
        showBluetoothListDialog(context, null, null);
      }
      else{
        checkAndGetLPRList(context);
      }
    }
    else{
      showForgetDeviceDialog(
          context,
          forgetDeviceBtnClick: () async {
            isClickedOnForgetDevice = true;
            LPRDeviceHandler().isSelfDisconnected = true;
            Navigator.of(context).pop();
            EasyLoading.show(
                status: 'Disconnecting...',
                maskType: EasyLoadingMaskType.black);
            for(int i = 0; i < FlutterBluePlus.connectedDevices.length; i++){
              await FlutterBluePlus.connectedDevices[i].disconnect().then((value) {
                LPRDeviceHandler().isSelfDisconnected = false;
              });
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
          },
          onCancelClick: (){
            Navigator.of(context).pop();
          }
      );

    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(widget.bottomNavIndex==1){

    }
    popupAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        checkTempPermissions();
        checkIfAlreadyConnectedToLPRDevice();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: WillPopScope(
        key: tripState,
        onWillPop: ()async{
          if(commonProvider.bottomNavIndex==1){
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,

            ]);

          }


          return true;

        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () async {
                  if(commonProvider.bottomNavIndex==1){
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,

                    ]);

                  }

                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              title: commonText(
                context: context,
                text: 'Start Trip Recording',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.045,
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: ()async {
                      await    SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,]);

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavigation()),
                          ModalRoute.withName("")).then((value) =>        SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]));
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
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                child: Column(
                  children: [
                    Container(
                      height: displayHeight(context) * 0.4,
                      width: displayWidth(context),
                      child: Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(56.704173, 11.543808),
                              minZoom: 12,
                              maxZoom: 14,
                              bounds: LatLngBounds(
                                LatLng(56.7378, 11.6644),
                                LatLng(56.6877, 11.5089),
                              ),
                            ),
                            children: [
                              TileLayer(
                                tileProvider: AssetTileProvider(),
                                maxZoom: 14,
                                urlTemplate:
                                'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    isVesselDataLoading
                        ? Container(
                      height: displayHeight(context) * 0.1,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              blueColor),
                        ),
                      ),
                    )
                        : Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xffECF3F9)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                  context: context,
                                  text: 'Pre Departure Checklist',
                                  fontWeight: FontWeight.w600,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.038,
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.008,
                                ),
                                InkWell(
                                  onTap: (){
                                    if(vesselData.isEmpty)
                                    {
                                      addNewVesselDialogBox(context);
                                    }
                                  },
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<VesselDropdownItem>(
                                      isExpanded: true,
                                      hint: Text(
                                        'Select Vessel',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .brightness ==
                                                Brightness.dark
                                                ? "Select Vessel" ==
                                                'User SubRole'
                                                ? Colors.black54
                                                : Colors.white
                                                : Colors.black54,
                                            fontSize:
                                            displayWidth(context) * 0.032,
                                            fontFamily: outfit,
                                            fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: selectedValue,
                                      items: vesselData.map((item) {
                                        return DropdownMenuItem<
                                            VesselDropdownItem>(
                                          value: item,
                                          child: Text(
                                            item.name!,
                                            style: TextStyle(
                                                fontSize:
                                                displayWidth(context) *
                                                    0.032,
                                                color: Theme.of(context)
                                                    .brightness ==
                                                    Brightness.dark
                                                    ? "Select Vessel" ==
                                                    'User SubRole'
                                                    ? Colors.black
                                                    : Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (item) {
                                        Utils.customPrint(
                                            "id is: ${item?.id} ");
                                        CustomLogger().logWithFile(Level.info,
                                            "id is: ${item?.id}-> $page");
                                        setState(() {
                                          selectedValue = item;
                                          vesselId = item!.id;
                                          selectedVesselName = item.name;
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(
                                        height: displayHeight(context) * 0.06,
                                        width: displayWidth(context) * 0.9,
                                        padding: EdgeInsets.only(
                                            left: 14, right: 14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                          color: Color(0xffE6E9F0),
                                        ),
                                      ),
                                      iconStyleData: IconStyleData(
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                        iconSize:
                                        displayHeight(context) * 0.03,
                                        iconEnabledColor: Colors.black,
                                        iconDisabledColor: Colors.grey,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight:
                                        displayHeight(context) * 0.25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          // color: backgroundColor,
                                        ),
                                        offset: const Offset(0, 0),
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(20),
                                          thickness: MaterialStateProperty
                                              .all<double>(6),
                                          thumbVisibility:
                                          MaterialStateProperty.all<bool>(
                                              true),
                                        ),
                                      ),
                                      menuItemStyleData:
                                      const MenuItemStyleData(
                                        padding: EdgeInsets.only(
                                            left: 18, right: 18, top: 8, bottom: 8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.02,
                                ),
                                commonText(
                                  context: context,
                                  text: 'Number of Passengers',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.034,
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.008,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Container(
                                            height: displayHeight(context) *
                                                0.06,
                                            width: !isSliderDisable
                                                ? displayWidth(context) *
                                                0.78
                                                : displayWidth(context) *
                                                0.5,
                                            child: FlutterSlider(
                                              values: [
                                                // 10
                                                numberOfPassengers
                                                    .toDouble()
                                              ],
                                              max: sliderMinVal,
                                              min: 1,
                                              trackBar: FlutterSliderTrackBar(
                                                  activeTrackBarHeight: 4.5,
                                                  inactiveTrackBarHeight:
                                                  4.5,
                                                  activeTrackBar:
                                                  BoxDecoration(
                                                      color: Color(
                                                          0xff2663DB))),
                                              tooltip: FlutterSliderTooltip(
                                                  custom: (value) {
                                                    debugPrint("NUMBER OF PASS 1 $value");
                                                    String data = value.toInt().toString();
                                                    numberOfPassengers = value.toInt();
                                                    return Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical:
                                                          displayHeight(
                                                              context) *
                                                              0.02),
                                                      child: commonText(
                                                        context: context,
                                                        text:
                                                        '$data',
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        textColor:
                                                        Colors.black,
                                                        textSize:
                                                        displayWidth(
                                                            context) *
                                                            0.028,
                                                      ),
                                                    );
                                                  },
                                                  alwaysShowTooltip: true,
                                                  positionOffset:
                                                  FlutterSliderTooltipPositionOffset(
                                                      top: -15)),
                                              handlerWidth: 15,
                                              handlerHeight: 15,
                                              // onDragStarted: (int value,dynamic val,dynamic val1){
                                              //   FocusScope.of(context).requestFocus(FocusNode());
                                              // },
                                              onDragging: (int value,dynamic val,dynamic val1){
                                                // setState(() {
                                                //   isSliderDisable = false;
                                                // });
                                                //val != 11 ? passengerValue = val.toInt() : val;
                                                passengerValue = val == 11 ? (val.toInt() - 1) : val.toInt();
                                                print("On dragging: value: $value, val: $val, val1: $val1");
                                                numberOfPassengers = passengerValue;
                                                textEditingController.text = (passengerValue).toString();

                                                if(val == sliderMinVal){
                                                  if(mounted){

                                                    setState(() {
                                                      isCheck = true;
                                                      isSliderDisable =
                                                      true;
                                                      popupAnimationController
                                                          .forward()
                                                          .then((value) {
                                                        _focusNode
                                                            .requestFocus();

                                                      }

                                                      );
                                                    });
                                                  }
                                                }
                                                textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: textEditingController.value.text.length);
                                              },
                                              handler: FlutterSliderHandler(
                                                  child: Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                        Color(0xff2663DB)),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: isSliderDisable
                                              ? displayWidth(context) * 0.5
                                              : displayWidth(context) * 0.82,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 5),
                                                child: commonText(
                                                  context: context,
                                                  text: '01',
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  textColor: Colors.black,
                                                  textSize: displayWidth(
                                                      context) *
                                                      0.028,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 0),
                                                child: commonText(
                                                  context: context,
                                                  text: sliderCount,
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  textColor: Colors.black,
                                                  textSize: displayWidth(
                                                      context) *
                                                      0.028,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    isSliderDisable
                                        ? textFieldPopUp()
                                        : Container(
                                      width: 0,
                                      height: 0,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.02,
                                ),
                                Container(
                                  margin:
                                  EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                        context: context,
                                        text: 'Sensor Information',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.black,
                                        textSize:
                                        displayWidth(context) * 0.034,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0, top: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/location.png',
                                                      height: displayHeight(
                                                          context) *
                                                          0.04,
                                                      width: displayWidth(
                                                          context) *
                                                          0.07,
                                                    ),
                                                    SizedBox(
                                                      width: displayWidth(
                                                          context) *
                                                          0.04,
                                                    ),
                                                    commonText(
                                                      context: context,
                                                      text: 'GPS Signal',
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      textColor:
                                                      Colors.black45,
                                                      textSize:
                                                      displayWidth(
                                                          context) *
                                                          0.034,
                                                    ),
                                                  ],
                                                ),
                                                commonText(
                                                  context: context,
                                                  text: isLocationPermitted
                                                      ? 'OK'
                                                      : 'No Connected',
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  textColor:
                                                  isLocationPermitted
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  textSize: displayWidth(
                                                      context) *
                                                      0.03,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                              displayHeight(context) *
                                                  0.007,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/icons/lpr.png',
                                                        height: displayHeight(
                                                            context) *
                                                            0.04,
                                                        width: displayWidth(
                                                            context) *
                                                            0.07,
                                                      ),
                                                      SizedBox(
                                                        width: displayWidth(
                                                            context) *
                                                            0.034,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          FlutterBluePlus.connectedDevices.isEmpty
                                                              ? 'LPR'
                                                              : '${FlutterBluePlus.connectedDevices.first.platformName.isEmpty
                                                                ? FlutterBluePlus.connectedDevices.first.remoteId.str
                                                                : FlutterBluePlus.connectedDevices.first.platformName}',
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
                                                                  .black45,
                                                              fontFamily:
                                                              outfit,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          softWrap:
                                                          false,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  // color: Colors.red,
                                                  child: TextButton(
                                                    style: TextButton
                                                        .styleFrom(
                                                        padding:
                                                        EdgeInsets
                                                            .zero),
                                                    onPressed: () async {

                                                      bool isNDPermDenied =
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
                                                                      Duration(
                                                                          seconds: 2),
                                                                          () async {
                                                                        await openAppSettings();
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
                                                                      Duration(
                                                                          seconds: 2),
                                                                          () async {
                                                                        await openAppSettings();
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
                                                                      Utils.showSnackBar(
                                                                          context,
                                                                          scaffoldKey: scaffoldKey,
                                                                          message: 'Location permissions are denied without permissions we are unable to start the trip');
                                                                      Future.delayed(
                                                                          Duration(seconds: 2),
                                                                              () async {
                                                                            await openAppSettings();
                                                                          });
                                                                    } else {
                                                                      await Permission
                                                                          .location
                                                                          .request();
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
                                                                          await openAppSettings();
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
                                                    child: commonText(
                                                      context: context,
                                                      text:
                                                      FlutterBluePlus.connectedDevices.isEmpty ?  'Connect to Device' : 'Forget Device',
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      textColor: blueColor,
                                                      textAlign:
                                                      TextAlign.end,
                                                      textSize:
                                                      displayWidth(
                                                          context) *
                                                          0.03,
                                                    ),
                                                  ),
                                                ),
                                                /*commonText(
                                                context: context,
                                                text: isBluetoothPermitted
                                                    ? 'Connected'
                                                    : 'Disconnected',
                                                fontWeight:
                                                FontWeight.w500,
                                                textColor:
                                                isBluetoothPermitted
                                                    ? Colors.green
                                                    : Colors.red,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.03,
                                              ),*/
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                              displayHeight(context) *
                                                  0.007,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/ble.png',
                                                      height: displayHeight(
                                                          context) *
                                                          0.04,
                                                      width: displayWidth(
                                                          context) *
                                                          0.06,
                                                    ),
                                                    SizedBox(
                                                      width: displayWidth(
                                                          context) *
                                                          0.04,
                                                    ),
                                                    commonText(
                                                      context: context,
                                                      text: 'Wireless NMEA',
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      textColor:
                                                      Colors.black45,
                                                      textSize:
                                                      displayWidth(
                                                          context) *
                                                          0.034,
                                                    ),
                                                  ],
                                                ),
                                                commonText(
                                                  context: context,
                                                  text: 'Not Configured',
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  textColor: Colors.amber,
                                                  textSize: displayWidth(
                                                      context) *
                                                      0.03,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: displayHeight(context) * 0.03,
                                ),
                                addingDataToDB
                                    ? Center(
                                    child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                            blueColor)))
                                    : Container(
                                  child: CommonButtons
                                      .getRichTextActionButton(
                                    icon: Image.asset(
                                      'assets/icons/start_btn.png',
                                      height: displayHeight(context) *
                                          0.055,
                                      width: displayWidth(context) *
                                          0.12,
                                    ),
                                    title: 'Start Trip',
                                    context: context,
                                    fontSize:
                                    displayWidth(context) * 0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor: blueColor,
                                    borderColor: blueColor,
                                    width: displayWidth(context),
                                    onTap: () async {

                                      if(vesselData.isEmpty)
                                      {
                                        addNewVesselDialogBox(context);
                                      }
                                      else{

                                        if (selectedValue == null) {
                                          Utils.customPrint(
                                              'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            behavior: SnackBarBehavior
                                                .floating,
                                            content: Text(
                                                "Please select vessel"),
                                            duration:
                                            Duration(seconds: 1),
                                            backgroundColor:
                                            Colors.blue,
                                          ));
                                          return;
                                        }
                                        if (isCheck) {
                                          if (textEditingController
                                              .text.isEmpty || !isOKClick) {
                                            ScaffoldMessenger.of(
                                                context)
                                                .showSnackBar(SnackBar(
                                              behavior: SnackBarBehavior
                                                  .floating,
                                              content: Text(
                                                  isOKClick ? "Please Enter Number of Passengers and Submit" : "Please Submit Number of Passengers"),
                                              duration:
                                              Duration(seconds: 1),
                                              backgroundColor:
                                              Colors.blue,
                                            ));
                                            return;
                                          }

                                          if (int.parse(
                                              textEditingController
                                                  .text) >
                                              11) {
                                            sliderMinVal = numberOfPassengers.toDouble();
                                            sliderCount = '$numberOfPassengers+';
                                            isSliderDisable = false;
                                          } else {
                                            sliderMinVal = 11;
                                            sliderCount = '10+';
                                            isSliderDisable = false;
                                          }
                                        }

                                        Utils.customPrint(
                                            'SELECTED VESSEL WEIGHT $selectedVesselWeight');

                                        checkAllPermission(true);

                                      }

                                      List<BluetoothDevice> connectedDeviceList = FlutterBluePlus.connectedDevices;
                                      final FlutterSecureStorage storage = FlutterSecureStorage();
                                      if(connectedDeviceList.isNotEmpty)
                                        {
                                          sharedPreferences!.setBool('onStartTripLPRDeviceConnected', true);
                                        }
                                      else
                                        {
                                          sharedPreferences!.setBool('onStartTripLPRDeviceConnected', false);
                                        }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: displayWidth(context) * 0.01,
                                bottom: displayWidth(context) * 0.01,
                              ),
                              child: GestureDetector(
                                  onTap: () async {
                                    final image =
                                    await controller.capture();
                                    await    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitUp,]);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FeedbackReport(
                                                  imagePath:
                                                  image.toString(),
                                                  uIntList: image,
                                                )));
                                  },
                                  child: UserFeedback()
                                      .getUserFeedback(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFieldPopUp() {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: popupAnimationController,
          curve: Interval(0.0, 1.0, curve: Curves.elasticOut)),
      child: Center(
        child: Container(
          width: displayWidth(context) * 0.25,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 6,bottom: 4),
                    child: TextFormField(
                      focusNode: _focusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: MediaQuery.of(context).size.width * 0.035),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 12),
                          border: InputBorder.none),
                      controller: textEditingController,
                      onFieldSubmitted: (String value) {
                        if(int.parse(textEditingController.text.trim().isEmpty ? '1' : textEditingController.text.trim()) != 0 )
                        {
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                        else
                        {
                          textEditingController.clear();
                        }

                        // popupAnimationController.reset();
                      },
                      onEditingComplete: (){
                        if(int.parse(textEditingController.text.trim().isEmpty ? '1' : textEditingController.text.trim()) != 0 )
                        {
                          // setState(() {
                          //textEditingController.text.isNotEmpty ? numberOfPassengers = int.parse(textEditingController.text) : numberOfPassengers = passengerValue;
                          if(textEditingController.text.isEmpty){
                            setState(() {
                              numberOfPassengers = passengerValue > 10 ? 10 : passengerValue;
                              sliderMinVal = 11;
                              sliderCount = '10+';
                            });
                          }else if(int.parse(textEditingController.text) < 11){
                            numberOfPassengers = int.parse(textEditingController.text);
                            sliderMinVal = 11;
                          }else if(int.parse(textEditingController.text) < 1000){
                            numberOfPassengers = int.parse(textEditingController.text);

                            if(numberOfPassengers.toString().length == 3)
                            {
                              sliderMinVal = (numberOfPassengers.toDouble()) > 999 ? numberOfPassengers.toDouble() : numberOfPassengers.toDouble();
                            }
                            else
                            {
                              sliderMinVal = numberOfPassengers.toDouble();
                            }

                            //sliderMinVal = 999;
                            sliderCount = '$numberOfPassengers+';
                          }
                          //});
                        }
                        else
                        {
                          textEditingController.clear();
                        }
                      },
                      onChanged: (String value) {
                        print("value is: $value");
                        if (value.length == 3) {
                          if(int.parse(value) != 0)
                          {
                            setState(() {
                              numberOfPassengers =
                                  int.parse(textEditingController.text);

                              if(numberOfPassengers.toString().length == 3)
                              {
                                sliderMinVal = (numberOfPassengers.toDouble()) > 999 ? numberOfPassengers.toDouble() : numberOfPassengers.toDouble();
                              }
                              else
                              {
                                sliderMinVal = numberOfPassengers.toDouble();
                              }
                              //sliderMinVal = 999;
                              sliderCount = '$numberOfPassengers+';
                            });
                            FocusScope.of(context).requestFocus(new FocusNode());
                          }
                        }
                        /*  else if(value.length == 2){
                             setState(() {
                               numberOfPassengers = int.parse(textEditingController.text);
                               sliderMinVal = 11;
                               sliderCount = '1';
                             });
                        }  */
                        else if(value.length == 0){
                          setState(() {
                            numberOfPassengers = passengerValue > 10 ? 10 : passengerValue;
                            /*if(numberOfPassengers.toString().length == 3)
                             {
                               sliderMinVal = numberOfPassengers.toDouble() + 20;
                             }
                             else
                             {
                               sliderMinVal = numberOfPassengers.toDouble() + 4;
                             }
                             //sliderMinVal = 999;
                             sliderCount = '$numberOfPassengers+';*/
                            sliderMinVal = 11;
                            sliderCount = '10+';
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  //width: displayWidth(context) * 0.08,
                  height: displayHeight(context) * 0.04,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(null),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      backgroundColor: MaterialStateProperty.all(blueColor),
                      textStyle: MaterialStateProperty.all(
                          TextStyle(color: Colors.blue)),
                      shape: MaterialStateProperty.all(
                          new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                    onPressed: () {
                      if(int.parse(textEditingController.text.trim().isEmpty ? '1' : textEditingController.text.trim()) != 0)
                      {
                        setState(() {
                          isOKClick = true;
                          if (textEditingController.text.isEmpty) {

                            sliderMinVal = 11;

                            numberOfPassengers = passengerValue > 10 ? 10 : passengerValue;

                            sliderCount = '10+';
                            isSliderDisable = false;
                            isCheck = false;

                          } else if(textEditingController.text.isNotEmpty && int.parse(textEditingController.text) > 11){

                            numberOfPassengers =
                                int.parse(textEditingController.text);

                            if (numberOfPassengers.toString().length == 3) {
                              sliderMinVal = (numberOfPassengers.toDouble()) > 999 ? numberOfPassengers.toDouble() : numberOfPassengers.toDouble();
                            } else {
                              sliderMinVal = numberOfPassengers.toDouble();
                            }
                            //sliderMinVal = numberOfPassengers.toDouble();
                            sliderCount = '$numberOfPassengers+';
                            isSliderDisable = false;

                          } else if (textEditingController.text.isNotEmpty &&
                              int.parse(textEditingController.text) < 11) {

                            sliderMinVal = 11;
                            sliderCount = '10+';
                            isSliderDisable = false;
                            numberOfPassengers =
                                int.parse(textEditingController.text);
                          }
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());

                        kReleaseMode
                            ? null
                            : debugPrint(
                            'Number of passengers $numberOfPassengers');

                        // popupAnimationController.reset();
                      }
                      else
                      {
                        textEditingController.clear();
                      }
                    },
                    child: Image.asset('assets/icons/done_icon.png', height: displayHeight(context) * 0.02,),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  checkAllPermission(bool tripRecordingStarted) async {
    if (mounted) {
      bool? isTripStarted = sharedPreferences!.getBool('trip_started');

      if (isTripStarted != null) {
        if (isTripStarted) {
          List<String>? tripData =
          sharedPreferences!.getStringList('trip_data');
          Trip tripDetails = await _databaseService.getTrip(tripData![0]);

          if (isTripStarted) {
            showDialogBox(context);
            return;
          }
        }
      }

      bool isLocationPermitted = await Permission.locationAlways.isGranted;

      if (isLocationPermitted) {
        bool isNDPermDenied =
        await Permission.bluetoothConnect.isPermanentlyDenied;

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
        } else {
          if (Platform.isIOS) {
            dynamic isBluetoothEnable = Platform.isAndroid
                ? await blueIsOn()
                : await checkIfBluetoothIsEnabled(scaffoldKey,
                    () {
                  showBluetoothDialog(context);
                });

            if (isBluetoothEnable != null) {
              if (isBluetoothEnable) {
                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                showBluetoothDialog(context);
              }
            }
          } else {
            bool isNDPermittedOne = await Permission.bluetoothConnect.isGranted;

            if (isNDPermittedOne) {
              bool isBluetoothEnable = Platform.isAndroid
                  ? await blueIsOn()
                  : await checkIfBluetoothIsEnabled(scaffoldKey,
                      () {
                    showBluetoothDialog(context);
                  });

              if (isBluetoothEnable) {
                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                showBluetoothDialog(context);
              }
            } else {
              await Permission.bluetoothConnect.request();
              bool isNDPermitted = await Permission.bluetoothConnect.isGranted;
              if (isNDPermitted) {
                bool isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context);
                });

                if (isBluetoothEnable) {
                  // vessel!.add(widget.vessel!);
                  await locationPermissions(tripRecordingStarted);
                } else {
                  showBluetoothDialog(context);
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
      else {
        /// WIU
        bool isWIULocationPermitted =
        await Permission.locationWhenInUse.isGranted;

        if (!isWIULocationPermitted) {
          await Utils.getLocationPermission(context, scaffoldKey);

          if (Platform.isAndroid) {
            if (!(await Permission
                .locationWhenInUse.shouldShowRequestRationale)) {
              Utils.customPrint(
                  'XXXXX@@@ ${await Permission.locationWhenInUse.shouldShowRequestRationale}');

              // if (await Permission.locationWhenInUse.isDenied ||
              //     await Permission.locationWhenInUse.isPermanentlyDenied) {
              //   await openAppSettings();
              // }

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
                        Get.back();

                        await openAppSettings();
                      },
                    );
                  }).then((value) {
                isLocationDialogBoxOpen = false;
              });
            }
          }
          else {
            await Permission.locationAlways.request();

            bool isGranted = await Permission.locationAlways.isGranted;

            if (!isGranted) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey,
                  message:
                  '"Always Allow" location permissions are denied, without permissions we are unable to start the trip');
            }
          }
        }
        else {
          bool isLocationPermitted = await Permission.locationAlways.isGranted;
          if (isLocationPermitted) {
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

                        await openAppSettings();
                      },
                    );
                  });
              return;
            }
            else {
              bool isNDPermitted = await Permission.bluetoothConnect.isGranted;

              if (isNDPermitted) {
                bool isBluetoothEnable = Platform.isAndroid
                    ? await blueIsOn()
                    : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                  showBluetoothDialog(context);
                });

                if (isBluetoothEnable) {
                  // vessel!.add(widget.vessel!);
                  await locationPermissions(tripRecordingStarted);
                } else {
                  showBluetoothDialog(context);
                }
              } else {
                await Permission.bluetoothConnect.request();
                bool isNDPermitted =
                await Permission.bluetoothConnect.isGranted;
                if (isNDPermitted) {
                  bool isBluetoothEnable = Platform.isAndroid
                      ? await blueIsOn()
                      : await checkIfBluetoothIsEnabled(scaffoldKey, () {
                    showBluetoothDialog(context);
                  });

                  if (isBluetoothEnable) {
                    // vessel!.add(widget.vessel!);
                    await locationPermissions(tripRecordingStarted);
                  } else {
                    showBluetoothDialog(context);
                  }
                }
              }
            }
          } else if (await Permission.locationAlways.isPermanentlyDenied) {
            if (Platform.isIOS) {
              Permission.locationAlways.request();

              PermissionStatus status = await Permission.locationAlways
                  .request()
                  .catchError((onError) {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    "Location permissions are denied without permissions we are unable to start the trip");

                Future.delayed(Duration(seconds: 3), () async {
                  await openAppSettings();
                });
                return PermissionStatus.denied;
              });

              if (status == PermissionStatus.denied ||
                  status == PermissionStatus.permanentlyDenied) {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    "Location permissions are denied without permissions we are unable to start the trip");

                Future.delayed(Duration(seconds: 3), () async {
                  await openAppSettings();
                });
              }
            } else {
              if (!isLocationDialogBoxOpen) {
                Utils.customPrint("ELSE CONDITION");

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
                          Get.back();

                          await openAppSettings();
                        },
                      );
                    }).then((value) {
                  isLocationDialogBoxOpen = false;
                });
              }
            }
          } else {
            if (Platform.isIOS) {
              await Permission.locationAlways.request();

              bool isLocationAlwaysPermitted =
              await Permission.locationAlways.isGranted;

              Utils.customPrint('IOS PERMISSION GIVEN OUTSIDE');

              if (isLocationAlwaysPermitted) {
                Utils.customPrint('IOS PERMISSION GIVEN 1');

                // vessel!.add(widget.vessel!);
                await locationPermissions(tripRecordingStarted);
              } else {
                Utils.showSnackBar(context,
                    scaffoldKey: scaffoldKey,
                    message:
                    'Location permissions are denied without permissions we are unable to start the trip');

                Future.delayed(Duration(seconds: 3), () async {
                  await openAppSettings();
                });
              }
            } else {
              if (!isLocationDialogBoxOpen) {
                Utils.customPrint("ELSE CONDITION");

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
                            Get.back();
                            await openAppSettings();
                          }

                      );
                    }).then((value) {
                  isLocationDialogBoxOpen = false;
                });
              }
            }
          }
        }
        // return;
      }
    }
  }

  checkTempPermissions() async {
    this.isLocationPermitted = await Permission.locationAlways.isGranted;
    setState(() {});
  }

  checkIfAlreadyConnectedToLPRDevice(){
    if(openedSettingsPageForPermission){
      openedSettingsPageForPermission = false;
      Utils.customPrint('BLED - BACKGROUND');
      List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
      if(connectedDevices.isEmpty){
        checkPermissionsAndAutoConnectToDevice(context);
      }
    }

  }

  //To get all vessels
  getVesselAndTripsData() async {
    setState(() {
      isVesselDataLoading = true;
    });

    List<CreateVessel> localVesselList =
    await _databaseService.vessels().catchError((onError) {
      setState(() {
        isVesselDataLoading = false;
      });
    });
    vesselData = List<VesselDropdownItem>.from(localVesselList
        .map((vessel) => VesselDropdownItem(id: vessel.id, name: vessel.name)));
    setState(() {
      isVesselDataLoading = false;
    });
    debugPrint("VESSEL LIST LENGTH${vesselData.isEmpty}");
    return;

  }

  Future<bool> blueIsOn() async {
    // FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
    final isOn = adapterState == BluetoothAdapterState.on;
    // if (isOn) return true;
    //
    // await Future.delayed(const Duration(seconds: 1));
    // BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
    return isOn;
  }


  /// To enable Bluetooth
  Future<void> enableBT(bool autoConnect) async {
    if(Platform.isIOS) openedSettingsPageForPermission = true;
    BluetoothEnable.enableBluetooth.then((value) async {
      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
        if(autoConnect){
          await Future.delayed(Duration(milliseconds: 500), (){});
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

  Future<dynamic> checkIfBluetoothIsEnabled(GlobalKey<ScaffoldState> scaffoldKey, VoidCallback showBluetoothDialog) async{

    bool isBluetoothEnabled = false;
    BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
    bool isBLEEnabled = adapterState == BluetoothAdapterState.on;
    // bool isBLEEnabled = await flutterBluePlus!.isOn;
    Utils.customPrint('isBLEEnabled: $isBLEEnabled');

    if(isBLEEnabled){
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if(!isGranted){
        await Permission.bluetooth.request();
        bool isPermGranted = await Permission.bluetooth.isGranted;

        if(isPermGranted){

          // FlutterBluePlus _flutterBlue = FlutterBluePlus();
          BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
          final isOn = adapterState == BluetoothAdapterState.on;
          if(isOn) isBluetoothEnabled =  true;

          await Future.delayed(const Duration(seconds: 1));
          BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
          isBluetoothEnabled = adapterState == BluetoothAdapterState.on;
          // isBluetoothEnabled = await FlutterBluePlus.isOn;
          if(!isBluetoothEnabled) openedSettingsPageForPermission = true;
          return isBluetoothEnabled;
        }
        else{
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3),
                  () async {
                    openedSettingsPageForPermission = true;
                await openAppSettings();
              });
          return null;
        }
      }
      else{

        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if(isOn) isBluetoothEnabled =  true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        if(!isBluetoothEnabled) openedSettingsPageForPermission = true;
        return isBluetoothEnabled;
      }
    }
    else{
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if(!isGranted){
        if(await Permission.bluetooth.isPermanentlyDenied){
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3),
                  () async {
                    openedSettingsPageForPermission = true;
                await openAppSettings();
              });
          return null;
        }
        else{
          openedSettingsPageForPermission = true;
          await Permission.bluetooth.request();
        }
      }
      else{
        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if(isOn) isBluetoothEnabled =  true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        if(!isBluetoothEnabled) openedSettingsPageForPermission = true;
        return isBluetoothEnabled;
      }
    }
  }

  /// It will save data to local database when trip is start
  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = selectedVesselName;
    final currentLoad = selectedVesselWeight;

    String? latitude, longitude;

    geo.Position currentPosition = await geo.Geolocator.getCurrentPosition();

    if(currentPosition != null)
    {
      latitude = currentPosition.latitude.toString();
      longitude = currentPosition.longitude.toString();
    }

    await fetchDeviceData();

    debugPrint("NUMBER OF PASS 4 $numberOfPassengers");

    try {
      await _databaseService.insertTrip(Trip(
        id: getTripId,
        vesselId: vesselId,
        vesselName: selectedVesselName,
        currentLoad: 'Empty',
        numberOfPassengers: numberOfPassengers,
        filePath: file,
        isSync: 0,
        isCloud: 0,
        tripStatus: 0,
        createdAt: Utils.getCurrentTZDateTime(),
        updatedAt: Utils.getCurrentTZDateTime(),
        startPosition: [latitude, longitude].join(","),
        endPosition: [latitude, longitude].join(","),
        deviceInfo: deviceDetails!.toJson().toString(),
      ));
    } on Exception catch (e) {
      Utils.customPrint('ON SAVE EXE: $e');
    }
    return;
  }

  /// It will start trip and called startBGLocatorTrip function from StartTrip.dart file
  startWritingDataToDB(BuildContext bottomSheetContext) async {
    Utils.customPrint('ISSSSS XXXXXXX: $isServiceRunning');

    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LocationPermissionCustomDialog(
              isLocationDialogBox: false,
              isGPSDaialogBox: true,
              text: 'Allow access to GPS',
              subText: 'Please enable GPS to continue.',
              buttonText: 'OK',
              buttonOnTap: () async {
                Get.back();

                // AppSettings.openAppSettings(type: AppSettingsType.location);
              },
            );
          });
      return;
    }

    setState(() {
      addingDataToDB = true;
    });

    getTripId = ObjectId().toString();

    flutterLocalNotificationsPlugin
        .show(
      776,
      '',
      'Trip is in progress',
      NotificationDetails(
          android: AndroidNotificationDetails(
              'performarine_trip_$getTripId', '$getTripId',
              channelDescription: 'Description',
              importance: Importance.max,
              priority: Priority.high),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            subtitle: '',
          )),
    )
        .catchError((onError) {
      Utils.customPrint('IOS NOTI ERROR: $onError');
    });

    await onSave('', bottomSheetContext, true);

    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data',
        [getTripId, vesselId!, selectedVesselName!, selectedVesselWeight]);

    // LPRDeviceHandler().listenToDeviceConnectionState();

    // if(!await loc.Location().serviceEnabled()){
    //   loc.Location().requestService();
    //
    //   // StreamSubscription<geo.ServiceStatus> serviceStatusStream = geo.Geolocator.getServiceStatusStream().listen(
    //   //         (geo.ServiceStatus status) {
    //   //       print(status);
    //   //       if(status == geo.ServiceStatus.disabled){
    //   //         loc.Location().requestService();
    //   //       }
    //   //     });
    // }
    // else{
    //   // StreamSubscription<geo.ServiceStatus> serviceStatusStream = geo.Geolocator.getServiceStatusStream().listen(
    //   //         (geo.ServiceStatus status) {
    //   //       print(status);
    //   //       if(status == geo.ServiceStatus.disabled){
    //   //         loc.Location().requestService();
    //   //       }
    //   //     });
    // }

    await initPlatformStateBGL();

    //await tripIsRunningOrNot();

    addingDataToDB = false;
    isStartButton = false;

    bool? runningTrip = sharedPreferences!.getBool("trip_started");

    if (runningTrip!) {
      List<String>? tripData = sharedPreferences!.getStringList('trip_data');
      final tripDetails = await _databaseService.getTrip(tripData![0]);

      print('CALLED FROM: ${widget.calledFrom}');
      await    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,]);

      var result = Navigator.pushReplacement(
        scaffoldKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => TripRecordingScreen(
                tripId: tripDetails.id,
                vesselName: tripDetails.vesselName,
                vesselId: tripData[1],
                tripIsRunningOrNot: runningTrip,
                calledFrom: widget.calledFrom)),
      );

      if (result != null) {
        Utils.customPrint('VESSEL SINGLE VIEW RESULT $result');
      }
    }
    return;
  }

  /// It will initialize background_locator_2
  Future<void> initPlatformStateBGL() async {
    Utils.customPrint('Initializing...');
    await BackgroundLocator.initialize();
    Utils.customPrint('Initialization done');

    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 1,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: '',
                notificationMsg: 'Trip is in progress',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)))
        .then((value) async {
      StartTrip().startBGLocatorTrip(getTripId, DateTime.now());

      notiTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
        var activeNotifications = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

        if (activeNotifications != null && activeNotifications.isNotEmpty) {
          if (activeNotifications[0].channelId == 'app.yukams/locator_plugin' ||
              activeNotifications[0].channelId ==
                  'performarine_trip_$getTripId-3') {
            Utils.customPrint("CHANNEL ID MATCH");
            Utils.customPrint("CHANNEL ID MATCH: ${activeNotifications[0].id}");

            await flutterLocalNotificationsPlugin.cancel(776);

            if (notiTimer != null) {
              notiTimer!.cancel();
            }
          }
        }
      });
    });
  }

  showDialogBox(BuildContext context) {
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
                                  'There is a trip in progress from another Vessel. Please end the trip and come back here',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black87,
                                  textSize: displayWidth(context) * 0.038,
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
                                        Utils.customPrint("Click on GO TO TRIP 1");

                                        List<String>? tripData = sharedPreferences!
                                            .getStringList('trip_data');
                                        bool? runningTrip = sharedPreferences!
                                            .getBool("trip_started");

                                        String tripId = '', vesselName = '';
                                        if (tripData != null) {
                                          tripId = tripData[0];
                                          vesselName = tripData[1];
                                        }

                                        Utils.customPrint("Click on GO TO TRIP 2");

                                        Navigator.of(dialogContext).pop();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TripRecordingScreen(
                                                      tripId: tripId,
                                                      vesselId: tripData![1],
                                                      vesselName: tripData[2],
                                                      tripIsRunningOrNot:
                                                      runningTrip)),
                                        ).then((value) =>

                                            SystemChrome.setPreferredOrientations([
                                              DeviceOrientation.portraitUp,])
                                        );

                                        Utils.customPrint("Click on GO TO TRIP 3");
                                      },
                                      displayWidth(context) * 0.65,
                                      displayHeight(context) * 0.054,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.2,
                                      blueColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Ok go back', context, Colors.transparent,
                                        () {
                                      Navigator.of(context).pop();
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

  /// To get device details
  fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo;
    }
  }

  /// To fetch device data
  fetchDeviceData() async {
    await fetchDeviceInfo();

    deviceDetails = Platform.isAndroid
        ? DeviceInfo(
        board: androidDeviceInfo?.board,
        deviceId: androidDeviceInfo?.id,
        deviceType: androidDeviceInfo?.type,
        make: androidDeviceInfo?.manufacturer,
        model: androidDeviceInfo?.model,
        version: androidDeviceInfo?.version.release)
        : DeviceInfo(
        board: iosDeviceInfo?.utsname.machine,
        deviceId: '',
        deviceType: iosDeviceInfo?.utsname.machine,
        make: iosDeviceInfo?.utsname.machine,
        model: iosDeviceInfo?.model,
        version: iosDeviceInfo?.utsname.release);
    Utils.customPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }

  checkAndGetLPRList(BuildContext context) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(
    //     key: 'lprDeviceId'
    // );

    Utils.customPrint("LPR DEVICE ID $lprDeviceId");

    /// TODO
    List<BluetoothDevice> connectedDevicesList = await FlutterBluePlus.connectedDevices;
    Utils.customPrint("BONDED LIST $connectedDevicesList");

    if(connectedDevicesList.isNotEmpty){
      showForgetDeviceDialog(
          context,
          forgetDeviceBtnClick: () async {
            isClickedOnForgetDevice = true;
            Navigator.of(context).pop();
            EasyLoading.show(
                status: 'Disconnecting...',
                maskType: EasyLoadingMaskType.black);
            for(int i = 0; i < connectedDevicesList.length; i++){
              await connectedDevicesList[i].disconnect();
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
          },
          onCancelClick: (){
            Navigator.of(context).pop();
          }
      );
    }
    else{
      EasyLoading.show(
          status: 'Searching for available devices...',
          maskType: EasyLoadingMaskType.black);
      String deviceId = '';
      BluetoothDevice? connectedBluetoothDevice;

      FlutterBluePlus.scanResults.listen((value) async {
        if(value.isNotEmpty){
          for (int i = 0; i < value.length; i++) {
            ScanResult r = value[i];

            if(lprDeviceId != null)
            {
              Utils.customPrint('STORED ID: $lprDeviceId - ${r.device.remoteId.str}');
              if(r.device.remoteId.str == lprDeviceId)
              {
                r.device.connect().then((value) {
                  LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if(mounted){
                      setState(() {

                      });
                    }
                  });
                  Utils.customPrint('CONNECTED TO DEVICE BLE');
                }).catchError((onError){
                  Utils.customPrint('ERROR BLE: $onError');
                });


                bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                if(mounted){
                  setState(() {
                    bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                    isBluetoothPermitted = true;
                    progress = 1.0;
                    lprSensorProgress = 1.0;
                    isStartButton = true;
                  });
                }
                FlutterBluePlus.stopScan();
                break;
              }
              else
              {
                if (r.device.platformName.toLowerCase().contains("lpr")) {
                  r.device.connect().then((value) {
                    LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                    LPRDeviceHandler().setDeviceDisconnectCallback(() {
                      if(mounted){
                        setState(() {

                        });
                      }
                    });
                  });
                  bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                  // await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                  if(mounted){
                    setState(() {
                      bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
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
            else
            {
              if (r.device.platformName.toLowerCase().contains("lpr")) {
                r.device.connect().then((value) {
                  LPRDeviceHandler().setLPRDevice(connectedDevicesList.first);
                  LPRDeviceHandler().setDeviceDisconnectCallback(() {
                    if(mounted){
                      setState(() {

                      });
                    }
                  });
                });
                bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
                //await storage.write(key: 'lprDeviceId', value: r.device.remoteId.str);
                deviceId = r.device.remoteId.str;
                connectedBluetoothDevice = r.device;
                if(mounted){
                  setState(() {
                    bluetoothName = r.device.platformName.isEmpty ? r.device.remoteId.str : r.device.platformName;
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

      FlutterBluePlus
          .startScan(timeout: Duration(seconds: 4));

      Future.delayed(Duration(seconds: 4), () {
        showBluetoothListDialog(context, deviceId, connectedBluetoothDevice);
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

  /// Check location permission
  locationPermissions(bool isTripRecordingStarted) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(
    //     key: 'lprDeviceId'
    // );

    Utils.customPrint("LPR DEVICE ID $lprDeviceId");
    if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        // FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
        // FlutterBluePlus.scanResults.listen((results) async {
        //   for (ScanResult r in results) {
        //     if(lprDeviceId != null)
        //     {
        //       if(r.device.id.id == lprDeviceId)
        //       {
        //         Utils.customPrint('FOUND DEVICE AGAIN');
        //
        //         r.device.connect().catchError((e) {
        //           r.device.state.listen((event) {
        //             if (event == BluetoothDeviceState.connected) {
        //               r.device.disconnect().then((value) {
        //                 r.device.connect().catchError((e) {
        //                   if (mounted) {
        //                     setState(() {
        //                       isBluetoothPermitted = true;
        //                       progress = 1.0;
        //                       lprSensorProgress = 1.0;
        //                       isStartButton = true;
        //                       debugPrint(
        //                           "BLUETOOTH PERMISSION CODE 6 $isBluetoothPermitted");
        //                     });
        //                   }
        //                 });
        //               });
        //             }
        //           });
        //         });
        //
        //         bluetoothName = r.device.name;
        //         if(mounted){
        //           setState(() {
        //             isBluetoothPermitted = true;
        //             progress = 1.0;
        //             lprSensorProgress = 1.0;
        //             isStartButton = true;
        //             debugPrint("BLUETOOTH PERMISSION CODE 7 $isBluetoothPermitted");
        //           });
        //         }
        //         FlutterBluePlus.stopScan();
        //         break;
        //       }
        //     }
        //     else
        //     {
        //
        //     }
        //   }
        // });

        setState(() {
          this.isLocationPermitted = isLocationPermitted;
        });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

        /* Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
          isLocationPermitted: isLocationPermitted,
          isBluetoothConnected: isBluetoothConnected,
          calledFrom: 'bottom_nav',)));*/
      } else {
        final FlutterSecureStorage storage = FlutterSecureStorage();
        var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
        // var lprDeviceId = await storage.read(
        //     key: 'lprDeviceId'
        // );

        Utils.customPrint("LPR DEVICE ID $lprDeviceId");

        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          // FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
          // FlutterBluePlus.scanResults.listen((results) async {
          //   for (ScanResult r in results) {
          //     if(lprDeviceId != null)
          //     {
          //       r.device.connect().catchError((e) {
          //         r.device.state.listen((event) {
          //           if (event == BluetoothDeviceState.connected) {
          //             r.device.disconnect().then((value) {
          //               r.device.connect().catchError((e) {
          //                 if (mounted) {
          //                   setState(() {
          //                     isBluetoothPermitted = true;
          //                     progress = 1.0;
          //                     lprSensorProgress = 1.0;
          //                     isStartButton = true;
          //                     debugPrint(
          //                         "BLUETOOTH PERMISSION CODE 8 $isBluetoothPermitted");
          //                   });
          //                 }
          //               });
          //             });
          //           }
          //         });
          //       });
          //
          //       bluetoothName = r.device.name;
          //       setState(() {
          //         isBluetoothPermitted = true;
          //         progress = 1.0;
          //         lprSensorProgress = 1.0;
          //         isStartButton = true;
          //         debugPrint(
          //             "BLUETOOTH PERMISSION CODE 9 $isBluetoothPermitted");
          //       });
          //       FlutterBluePlus.stopScan();
          //       break;
          //     }
          //     else
          //     {
          //       if (r.device.name.toLowerCase().contains("lpr")) {
          //         r.device.connect().catchError((e) {
          //           r.device.state.listen((event) {
          //             if (event == BluetoothDeviceState.connected) {
          //               r.device.disconnect().then((value) {
          //                 r.device.connect().catchError((e) {
          //                   if (mounted) {
          //                     setState(() {
          //                       isBluetoothPermitted = true;
          //                       progress = 1.0;
          //                       lprSensorProgress = 1.0;
          //                       isStartButton = true;
          //                       debugPrint(
          //                           "BLUETOOTH PERMISSION CODE 8 $isBluetoothPermitted");
          //                     });
          //                   }
          //                 });
          //               });
          //             }
          //           });
          //         });
          //
          //         bluetoothName = r.device.name;
          //         //await storage.write(key: 'lprDeviceId', value: r.device.id.id);
          //         setState(() {
          //           isBluetoothPermitted = true;
          //           progress = 1.0;
          //           lprSensorProgress = 1.0;
          //           isStartButton = true;
          //           debugPrint(
          //               "BLUETOOTH PERMISSION CODE 9 $isBluetoothPermitted");
          //         });
          //         FlutterBluePlus.stopScan();
          //         break;
          //       } else {
          //         r.device.disconnect().then(
          //                 (value) => Utils.customPrint("is device disconnected: "));
          //       }
          //     }
          //   }
          // });

          setState(() {
            this.isLocationPermitted = isLocationPermitted;
          });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

          /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,
              calledFrom: 'bottom_nav')));*/
        }
      }
    }
    else {
      final FlutterSecureStorage storage = FlutterSecureStorage();
      var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
      // var lprDeviceId = await storage.read(
      //     key: 'lprDeviceId'
      // );

      Utils.customPrint("LPR DEVICE ID $lprDeviceId");

      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        // FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
        // FlutterBluePlus.scanResults.listen((results) async {
        //   for (ScanResult r in results) {
        //     if(lprDeviceId != null)
        //     {
        //       if(r.device.id.id == lprDeviceId)
        //       {
        //         {
        //           Utils.customPrint('FOUND DEVICE AGAIN');
        //
        //           r.device.connect().catchError((e) {
        //             r.device.state.listen((event) {
        //               if (event == BluetoothDeviceState.connected) {
        //                 r.device.disconnect().then((value) {
        //                   r.device.connect().catchError((e) {
        //                     if (mounted) {
        //                       setState(() {
        //                         isBluetoothPermitted = true;
        //                         progress = 1.0;
        //                         lprSensorProgress = 1.0;
        //                         isStartButton = true;
        //                         debugPrint(
        //                             "BLUETOOTH PERMISSION CODE 10 $isBluetoothPermitted");
        //                       });
        //                     }
        //                   });
        //                 });
        //               }
        //             });
        //           });
        //
        //           bluetoothName = r.device.name;
        //           setState(() {
        //             isBluetoothPermitted = true;
        //             progress = 1.0;
        //             lprSensorProgress = 1.0;
        //             isStartButton = true;
        //             debugPrint(
        //                 "BLUETOOTH PERMISSION CODE 11 $isBluetoothPermitted");
        //           });
        //           FlutterBluePlus.stopScan();
        //           break;
        //         }
        //       }
        //     }
        //     else
        //     {
        //       if (r.device.name.toLowerCase().contains("lpr")) {
        //         Utils.customPrint('FOUND DEVICE AGAIN');
        //
        //         r.device.connect().catchError((e) {
        //           r.device.state.listen((event) {
        //             if (event == BluetoothDeviceState.connected) {
        //               r.device.disconnect().then((value) {
        //                 r.device.connect().catchError((e) {
        //                   if (mounted) {
        //                     setState(() {
        //                       isBluetoothPermitted = true;
        //                       progress = 1.0;
        //                       lprSensorProgress = 1.0;
        //                       isStartButton = true;
        //                       debugPrint(
        //                           "BLUETOOTH PERMISSION CODE 10 $isBluetoothPermitted");
        //                     });
        //                   }
        //                 });
        //               });
        //             }
        //           });
        //         });
        //
        //         bluetoothName = r.device.name;
        //         //await storage.write(key: 'lprDeviceId', value: r.device.id.id);
        //         setState(() {
        //           isBluetoothPermitted = true;
        //           progress = 1.0;
        //           lprSensorProgress = 1.0;
        //           isStartButton = true;
        //           debugPrint(
        //               "BLUETOOTH PERMISSION CODE 11 $isBluetoothPermitted");
        //         });
        //         FlutterBluePlus.stopScan();
        //         break;
        //       } else {
        //         r.device.disconnect().then(
        //                 (value) => Utils.customPrint("is device disconnected: "));
        //       }
        //     }
        //   }
        // });

        setState(() {
          this.isLocationPermitted = isLocationPermitted;
        });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

        /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
            isLocationPermitted: isLocationPermitted,
            isBluetoothConnected: isBluetoothConnected,
            calledFrom: 'bottom_nav')));*/
      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          // FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
          // FlutterBluePlus.scanResults.listen((results) async {
          //   for (ScanResult r in results) {
          //     if (r.device.name.toLowerCase().contains("lpr")) {
          //       r.device.connect().catchError((e) {
          //         r.device.state.listen((event) {
          //           if (event == BluetoothDeviceState.connected) {
          //             r.device.disconnect().then((value) {
          //               r.device.connect().catchError((e) {
          //                 if (mounted) {
          //                   setState(() {
          //                     isBluetoothPermitted = true;
          //                     progress = 1.0;
          //                     lprSensorProgress = 1.0;
          //                     isStartButton = true;
          //                     debugPrint(
          //                         "BLUETOOTH PERMISSION CODE 12 $isBluetoothPermitted");
          //                   });
          //                 }
          //               });
          //             });
          //           }
          //         });
          //       });
          //
          //       bluetoothName = r.device.name;
          //       setState(() {
          //         isBluetoothPermitted = true;
          //         progress = 1.0;
          //         lprSensorProgress = 1.0;
          //         isStartButton = true;
          //         debugPrint(
          //             "BLUETOOTH PERMISSION CODE 13 $isBluetoothPermitted");
          //       });
          //       FlutterBluePlus.stopScan();
          //       break;
          //     } else {
          //       r.device.disconnect().then(
          //               (value) => Utils.customPrint("is device disconnected: "));
          //     }
          //   }
          // });

          setState(() {
            this.isLocationPermitted = isLocationPermitted;
          });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

          /*Navigator.push(context, MaterialPageRoute(builder: (context) => StartTripRecordingScreen(
              isLocationPermitted: isLocationPermitted,
              isBluetoothConnected: isBluetoothConnected,
              calledFrom: 'bottom_nav'
          )));*/
        }
      }
    }
  }

  showBluetoothListDialog(BuildContext context, String? connectedDeviceId, BluetoothDevice? connectedBluetoothDevice) {
    // setState(() {
    //   progress = 0.9;
    //   lprSensorProgress = 0.0;
    //   isStartButton = false;
    // });

    // checkAndGetLPRList();

    if(autoConnectStreamSubscription != null) autoConnectStreamSubscription!.cancel();
    if(autoConnectIsScanningStreamSubscription != null) autoConnectIsScanningStreamSubscription!.cancel();

    if(!FlutterBluePlus.isScanningNow){
      FlutterBluePlus
          .startScan(timeout: Duration(seconds: 4)).onError((error, stackTrace) {
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
                              connectedBluetoothDevice: connectedBluetoothDevice,
                              onSelected: (value) {
                                if (mounted) {
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), (){
                                  setState(() {

                                  });
                                });
                                LPRDeviceHandler().setDeviceDisconnectCallback((){
                                  if(mounted){
                                    setState(() {

                                    });
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
                                Future.delayed(Duration(seconds: 1), (){
                                  setState(() {

                                  });
                                });
                                LPRDeviceHandler().setDeviceDisconnectCallback((){
                                  if(mounted){
                                    setState(() {

                                    });
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
                              connectedBluetoothDevice: connectedBluetoothDevice,
                              onSelected: (value) {
                                if (mounted) {
                                  setState(() {
                                    bluetoothName = value;
                                  });
                                }
                                Future.delayed(Duration(seconds: 1), (){
                                  setState(() {

                                  });
                                });
                                LPRDeviceHandler().setDeviceDisconnectCallback((){
                                  if(mounted){
                                    setState(() {

                                    });
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
                                Future.delayed(Duration(seconds: 1), (){
                                  setState(() {

                                  });
                                });
                                LPRDeviceHandler().setDeviceDisconnectCallback((){
                                  if(mounted){
                                    setState(() {

                                    });
                                  }
                                });
                              },
                            )),
                      ),

                     SizedBox(height: displayWidth(context) * 0.04,),

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
                                 margin: EdgeInsets.only(top: displayWidth(context) * 0.02,),
                                   width: displayWidth(context) * 0.34,
                                   child: Center(
                                       child:
                                       CircularProgressIndicator(color: blueColor,))),
                             )
                                 : Container(
                               decoration: BoxDecoration(
                                 color: blueColor,
                                 borderRadius: BorderRadius.all(
                                     Radius.circular(8)),
                               ),
                               height: displayHeight(context) * 0.055,
                               width : displayWidth(context) / 1.6,
                               // color: HexColor(AppColors.introButtonColor),
                               child: Center(
                                 child: commonText(
                                  context: context,
                                  text: 'Scan for Devices',
                                  fontWeight: FontWeight.w500,
                                  textColor: bluetoothConnectBtncolor,
                                  textSize: displayWidth(context) * 0.04,
                                  fontFamily: outfit)
                               ),
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
      setState(() {
      });
      Future.delayed(Duration(microseconds: 500), (){
        setState(() {
        });
      });

      Utils.customPrint('DIALOG VALUE $value');
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

  addNewVesselDialogBox(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: commonText(
                              context: context,
                              text:
                              'No vessel available, Please add vessel to continue',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black87,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.center),
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
                                      'Add Vessel', context, blueColor,
                                          () async {
                                        Navigator.of(context).pop();
                                        await    SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,]);

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddNewVesselPage(calledFrom: 'startTripRecording',)));
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
                                height: 8.0,
                              ),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Cancel', context, Colors.transparent,
                                        () {
                                      Navigator.of(context).pop();
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
        });
  }
}

class VesselDropdownItem {
  final String? id;
  final String? name;

  VesselDropdownItem({this.id, this.name});
}