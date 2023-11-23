import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/services/database_service.dart';

import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/utils/utils.dart';

class LPRDeviceHandler {
  static final LPRDeviceHandler _instance = LPRDeviceHandler._internal();

  factory LPRDeviceHandler() => _instance;

  LPRDeviceHandler._internal(){
    this.context = Get.context;
  }

  LPRDeviceHandler get instance => _instance;
  bool isLPRReconnectPopupshowing=false;

  BluetoothDevice? connectedDevice;
  BuildContext? context;
  VoidCallback? onDeviceDisconnectCallback;
  StreamSubscription<List<ScanResult>>? autoConnectStreamSubscription;
  StreamSubscription<bool>? autoConnectIsScanningStreamSubscription;
  StreamSubscription<BluetoothConnectionState>? bluetoothConnectionStateListener;

  bool isRefreshList = false;
  bool isSelfDisconnected = false;

  setLPRDevice(BluetoothDevice device) async {
    this.connectedDevice = device;
    this.context = Get.context;
    var pref = await Utils.initSharedPreferences();

                             pref.setBool('device_forget',false);

    Utils.customPrint(
        'BLE - CONNECTED DEVICE: ${connectedDevice!.remoteId.str}');
    bool? isTripStarted = pref.getBool('trip_started') ?? false;
    if(isTripStarted){
      listenToDeviceConnectionState();
    }
  }

  setDeviceDisconnectCallback(VoidCallback callback){
    this.onDeviceDisconnectCallback = callback;
  }

  void listenToDeviceConnectionState()async {

    if (connectedDevice != null) {

      bluetoothConnectionStateListener = connectedDevice!.connectionState.listen((event) async {
        if (event == BluetoothConnectionState.disconnected) {

          Utils.customPrint(
              'BLE - DEVICE GOT DISCONNECTED: ${connectedDevice!.remoteId.str} - $event');

          if(bluetoothConnectionStateListener != null) bluetoothConnectionStateListener!.cancel();
          if(!isSelfDisconnected) {
                                          var pref = await Utils.initSharedPreferences();

bool getForgotStatus=pref.getBool('device_forget')??false;
bool getLprStatus= pref!.getBool('onStartTripLPRDeviceConnected')??false;
if(!getForgotStatus&&getLprStatus){
            showDeviceDisconnectedDialog(connectedDevice);
            isLPRReconnectPopupshowing=true;

}

            if(onDeviceDisconnectCallback != null) onDeviceDisconnectCallback!.call();
          }
        } else if (event == BluetoothConnectionState.connected) {
          Utils.customPrint(
              'BLE - DEVICE GOT CONNECTED: ${connectedDevice!.remoteId.str} - $event');
        }
      });
    }
  }

  void showDeviceDisconnectedDialog(BluetoothDevice? previouslyConnectedDevice) {
    isSelfDisconnected = false;
    Get.dialog(
        barrierDismissible: false,
        Dialog(
          child: WillPopScope(
            onWillPop: () async => false,
            child: Container(
              height: displayHeight(Get.context!) * 0.42,
              width: MediaQuery.of(Get.context!).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 15, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: displayHeight(Get.context!) * 0.02,
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          //color: Color(0xfff2fffb),
                          child: Image.asset(
                            'assets/images/boat.gif',
                            height: displayHeight(Get.context!) * 0.1,
                            width: displayWidth(Get.context!),
                            fit: BoxFit.contain,
                          ),
                        )),
                    SizedBox(
                      height: displayHeight(Get.context!) * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: commonText(
                          context: context,
                          text:
                              'It seems like, LPR device is disconnected. Please connect again and ensure that it is connected.',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black87,
                          textSize: displayWidth(Get.context!) * 0.042,
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      height: displayHeight(Get.context!) * 0.01,
                    ),
                    Column(
                      children: [
                        Center(
                          child: CommonButtons.getAcceptButton(
                              'Re-connect', Get.context!, endTripBtnColor, () {
                            Get.back();
                            EasyLoading.show(
                                status: 'Connecting...',
                                maskType: EasyLoadingMaskType.black);
                            Utils.customPrint('BLE - PREVIOUSLY CONNECTED DEVICE: ${previouslyConnectedDevice?.remoteId.str}');
                            if (previouslyConnectedDevice != null) {
                              previouslyConnectedDevice
                                  .connect()
                              .then((value) {
                                connectedDevice = previouslyConnectedDevice;
                                            Fluttertoast.showToast(
                msg: 'Device Connected ${connectedDevice?.advName.toString()}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0
            );


                                EasyLoading.dismiss();
                                Get.back();
                                                                                                    //Navigator.pop(context!);

                              })
                                  .catchError((onError) {
                                Utils.customPrint(
                                    'BLE - CAUGHT ERROR WHILE CONNECTING TO PREVIOUSLY CONNECTED DEVICE: ${previouslyConnectedDevice.remoteId.str}');
                                EasyLoading.dismiss();
                                autoConnectToDevice();
                                //                                  Navigator.pop(context!);

                              });
                            } else {
                              autoConnectToDevice();
                            }
                          },
                              displayWidth(Get.context!) / 1.5,
                              displayHeight(Get.context!) * 0.055,
                              primaryColor,
                              Colors.white,
                              displayWidth(Get.context!) * 0.036,
                              endTripBtnColor,
                              '',
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: CommonButtons.getAcceptButton(
                              'End Trip',
                              Get.context!,
                              Colors.transparent,
                              () {
                                endTrip();
                              },
                              displayWidth(Get.context!) * 0.5,
                              displayHeight(Get.context!) * 0.05,
                              Colors.transparent,
                              Theme.of(Get.context!).brightness == Brightness.dark
                                  ? Colors.white
                                  : blueColor,
                              displayHeight(Get.context!) * 0.018,
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
            ),
          ),
        ));
  }

  autoConnectToDevice() async {
    connectedDevice = null;
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(key: 'lprDeviceId');


    Utils.customPrint("LPR DEVICE ID $lprDeviceId");

    EasyLoading.show(
        status: 'Searching for available devices...',
        maskType: EasyLoadingMaskType.black);

    /// Check for already connected device.
    List<BluetoothDevice> connectedDevicesList =
        FlutterBluePlus.connectedDevices;
    Utils.customPrint("BONDED LIST $connectedDevicesList");

    if (connectedDevicesList.isEmpty) {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      List<ScanResult> streamOfScanResultList = [];

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
                  Fluttertoast.showToast(
                      msg: "Connected to ${r.device.platformName}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  Utils.customPrint('CONNECTED TO DEVICE BLE');
                  LPRDeviceHandler().setLPRDevice(r.device);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                }).catchError((onError) {
                  Utils.customPrint('ERROR BLE: $onError');
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
                    Fluttertoast.showToast(
                        msg: "Connected to ${r.device.platformName}",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    LPRDeviceHandler().setLPRDevice(r.device);
                    deviceId = r.device.remoteId.str;
                    connectedBluetoothDevice = r.device;
                  });

                  FlutterBluePlus.stopScan();
                  EasyLoading.dismiss();
                } else {
                  Future.delayed(Duration(seconds: 2), () {
                    EasyLoading.dismiss();
                    showBluetoothListDialog(context!, null, null);
                  });
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
                  Fluttertoast.showToast(
                      msg: "Connected to ${r.device.platformName}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  LPRDeviceHandler().setLPRDevice(r.device);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                });

                FlutterBluePlus.stopScan();
                EasyLoading.dismiss();
              } else {
                Future.delayed(Duration(seconds: 2), () {
                  EasyLoading.dismiss();
                  showBluetoothListDialog(context!, null, null);
                });
              }
            }
          } else {
            Future.delayed(Duration(seconds: 2), () {
              EasyLoading.dismiss();
              showBluetoothListDialog(context!, null, null);
            });
          }
        }
      });
    } else {
      // Show snack bar -> "Connected to <device_name> device."
      Future.delayed(Duration(seconds: 4), () async {
        EasyLoading.dismiss();
      });
    }
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
                                  onSelected: (value) {},
                                  onBluetoothConnection: (value) {},
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
                                  onSelected: (value) {},
                                  onBluetoothConnection: (value) {},
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

                                FlutterBluePlus.startScan(
                                    timeout: const Duration(seconds: 2));

                                Future.delayed(Duration(seconds: 2), () {
                                  /* setDialogState(() {
                                     isScanningBluetooth = false;
                                   });*/
                                });

                                isRefreshList = true;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                height: displayHeight(context) * 0.055,
                                width: displayWidth(context) / 1.6,
                                // color: HexColor(AppColors.introButtonColor),
                                child: Center(
                                    child: commonText(
                                        context: context,
                                        text: 'Scan for Devices',
                                        fontWeight: FontWeight.w500,
                                        textColor: bluetoothConnectBtncolor,
                                        textSize: displayWidth(context) * 0.04,
                                        fontFamily: outfit)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {

                                List<BluetoothDevice> connectedDeviceList = FlutterBluePlus.connectedDevices;
                                if(connectedDeviceList.isNotEmpty)
                                  {
                                    Fluttertoast.showToast(
                                        msg: "Connected to ${connectedDeviceList.first.platformName}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );

                                    FlutterBluePlus.stopScan();
                                    Navigator.pop(context);
                                  }
                                else
                                  {
                                    Navigator.pop(context);
                                    showDeviceDisconnectedDialog(null);
                                  }


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
      Utils.customPrint('DIALOG VALUE $value');
    });
  }

  endTrip() async {
    EasyLoading.show(
        status: 'Ending trip...',
        maskType: EasyLoadingMaskType.black);
    List<String>? tripData =
    sharedPreferences!
        .getStringList('trip_data');

    String tripId = '';
    if (tripData != null) {
      tripId = tripData[0];
    }

    final currentTrip =
        await DatabaseService()
        .getTrip(tripId);

    DateTime createdAtTime =
    DateTime.parse(
        currentTrip.createdAt!);

    var durationTime = DateTime.now()
        .toUtc()
        .difference(createdAtTime);
    String tripDuration =
    Utils.calculateTripDuration(
        ((durationTime
            .inMilliseconds) /
            1000)
            .toInt());

    Utils.customPrint(
        "DURATION !!!!!! $tripDuration");

    bool isSmallTrip = Utils()
        .checkIfTripDurationIsGraterThan10Seconds(
        tripDuration.split(":"));

    if (!isSmallTrip) {
      Get.back();
EasyLoading.dismiss();
      Utils().showDeleteTripDialog(
          context!, endTripBtnClick: () {
        EasyLoading.show(
            status: 'Please wait...',
            maskType:
            EasyLoadingMaskType
                .black);
        endTripMethod();
        Utils.customPrint(
            "SMALL TRIPP IDDD ${tripId}");

        Utils.customPrint(
            "SMALL TRIPP IDDD ${tripId}");

        Future.delayed(
            Duration(seconds: 1), () {
          if (!isSmallTrip) {
            Utils.customPrint(
                "SMALL TRIPP IDDD 11 ${tripId}");
            DatabaseService()
                .deleteTripFromDB(
                tripId);
          }
        });
      }, onCancelClick: () {
        endTripMethod();
      });
    } else {

      endTripMethod();
    }
  }

  endTripMethod() async {
    // Utils.customPrint("Set Dialog set ${setDialogState == null}");
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    String tripId = '';
    if (tripData != null) {
      tripId = tripData[0];
    }

    final currentTrip = await DatabaseService().getTrip(tripId);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    var durationTime = DateTime.now().toUtc().difference(createdAtTime);
    String tripDuration = Utils.calculateTripDuration(
        ((durationTime.inMilliseconds) / 1000).toInt());

    Utils.customPrint(
        'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');
    isSelfDisconnected = true;

    EndTrip().endTrip(
        context: context,
        scaffoldKey: null,
        duration: tripDuration,
        lprDeviceId: connectedDevice == null ? null : connectedDevice!.remoteId.str,
        onEnded: () async {
          connectedDevice = null;
          isSelfDisconnected = false;
          Future.delayed(Duration(seconds: 1), () {
            EasyLoading.dismiss();
            Navigator.pushAndRemoveUntil(
                context!,
                MaterialPageRoute(builder: (context) => BottomNavigation()),
                ModalRoute.withName(""));
            //Navigator.of(context).pop();
          });

          Utils.customPrint('TRIPPPPPP ENDEDDD:');
        });
  }
}
