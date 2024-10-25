import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/services/database_service.dart';

import 'analytics/get_file.dart';
import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/utils/utils.dart';

class LPRDeviceHandler {
  Function(String lprTransperntServiceId)? getLprServiceId;
  Function(bool lprServiceIdStatus)? getLprServiceIdStatus;
  Function(String lprUartTX)? getLPRUartTxId;
  Function(bool lprUartTX)? getLPRUartTxIdStatus;

  static final LPRDeviceHandler _instance = LPRDeviceHandler._internal();

  factory LPRDeviceHandler() => _instance;

  LPRDeviceHandler._internal() {
    this.context = Get.context;
  }

  LPRDeviceHandler get instance => _instance;
  bool isLPRReconnectPopupshowing = false;
bool isSilentDiscoonect=false;
bool isListeningStartTripState=false;
  BluetoothDevice? connectedDevice;
  BuildContext? context;
  VoidCallback? onDeviceDisconnectCallback;
  VoidCallback? onDeviceConnectedCallback;
  StreamSubscription<List<ScanResult>>? autoConnectStreamSubscription;
  StreamSubscription<bool>? autoConnectIsScanningStreamSubscription;
   StreamSubscription<BluetoothConnectionState>?
      bluetoothConnectionStateListener;
  BluetoothService? lprService;

  bool isRefreshList = false;
  bool isSelfDisconnected = false;

  Future<Map<String, dynamic>> getLPRConfigartion() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? lprConfig = await storage.read(key: 'lprConfig');

    if (lprConfig != null) {
      Map<String, dynamic> mapOfConfig = jsonDecode(lprConfig);
      Utils.customPrint('the config map was: ${mapOfConfig}');
      return Future.value(mapOfConfig);
    } else {
      return Future.value({});
    }
  }

  setLPRDevice(BluetoothDevice device) async {
    this.connectedDevice = device;
    this.context = Get.context;
    var pref = await Utils.initSharedPreferences();
    pref.setBool('device_forget', false);

    // Utils.customPrint(
    //     'BLE - CONNECTED DEVICE: ${connectedDevice!.remoteId.str}');
    bool? isTripStarted = pref.getBool('trip_started') ?? false;
    if (isTripStarted) {
      listenToDeviceConnectionState();
    }
  }

  setDeviceDisconnectCallback(VoidCallback callback) {
    this.onDeviceDisconnectCallback = callback;
  }
  setDeviceConnectCallBack(VoidCallback callback){
    this.onDeviceConnectedCallback=callback;
  }

  void listenToDeviceConnectionState(
      {
      //Call back Functions to return the status and info related Ids And Other Things on MapScreen
      Function(String lprTransperntServiceId, String lprUartTX)?
          callBackLprTanspernetserviecId,
      Function(String status)? callBackLprTanspernetserviecIdStatus,
      Function(String status)? callBackLprUartTxStatus,
      Function(String bluetoothDeviceName)? callBackconnectedDeviceName,
      Function(String lprSteamingData)? callBackLprStreamingData,
      //bool isListeningStartTripState=false,
      bool isLoadLocalLprFile = false}) async {
    File? lprFile;
    int fileIndex = 0;

    Map<String, dynamic> lpConfigValues = await getLPRConfigartion();
    final Guid? _lprUartTX;
    final Guid? _lprUartRX;
    final Guid _lprTransparentServiceUUID = Guid(
        lpConfigValues['lprTransparentServiceUUID'] ??
            "49535343-FE7D-4AE5-8FA9-9FAFD205E455");

    _lprUartTX = Guid(
        lpConfigValues['lprUartTX'] ?? "49535343-1E4D-4BD9-BA61-23C647249616");
    // RX Characteristic, Write and Write without response
    _lprUartRX = Guid(
        lpConfigValues['lprUartRX'] ?? "49535343-8841-43F4-A8D4-ECBE34729BB3");
//Asigning default callback methods to aviod null check issue while calling the function and assign the values
    callBackLprTanspernetserviecId ??=
        (String lprTransperntServiceId, String lprUartTx) {};
    callBackLprStreamingData ??= (String lprTransperntServiceId) {};
    callBackLprUartTxStatus ??= (String status) {};
    callBackconnectedDeviceName ??= (String name) {};
    callBackLprTanspernetserviecIdStatus ??= (String transperntStats) {};

//This Function will return the LPR Transpernt ServiceId LPR UARTX ID In The Maps Screen To Show IDs Info
    callBackLprTanspernetserviecId(
        _lprTransparentServiceUUID.toString(), _lprUartTX.toString());
    String fileContent =
        await rootBundle.loadString('assets/map/lpr_dummy_data.txt');

    String? lprFileName;
    IOSink? lprFileSink;
    String tripId = '';

if(bluetoothConnectionStateListener!=null){
  bluetoothConnectionStateListener?.cancel();
}
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');
    if (tripData != null) {
      tripId = tripData[0];
    }

    if (connectedDevice != null) {
      bluetoothConnectionStateListener =
          connectedDevice!.connectionState.listen((event) async {

        if (event == BluetoothConnectionState.disconnected) {

          // if(lprFileSink!=null){
          //   lprFileSink?.close();
          // }
// if(isListeningStartTripState){



// }
          Utils.customPrint(
              'BLE - DEVICE GOT DISCONNECTED: ${connectedDevice!.remoteId.str} - $event');

          if (bluetoothConnectionStateListener != null)
            bluetoothConnectionStateListener!.cancel();
          if (!isSelfDisconnected) {
            var pref = await Utils.initSharedPreferences();

            bool getForgotStatus = pref.getBool('device_forget') ?? false;
            bool getLprStatus =
                pref.getBool('onStartTripLPRDeviceConnected') ?? false;
                if(isListeningStartTripState&&!isSilentDiscoonect){
                //  print('111111111111111111111111111');
                showDeviceDisconnectedDialog(connectedDevice,callBackconnectedDeviceName: callBackconnectedDeviceName,isListeningStartTripState: isListeningStartTripState);
              isLPRReconnectPopupshowing = true;

                }

            if (!getForgotStatus && getLprStatus&&!isSilentDiscoonect) {
if(!isLPRReconnectPopupshowing){

              showDeviceDisconnectedDialog(connectedDevice,callBackconnectedDeviceName: callBackconnectedDeviceName,isListeningStartTripState: isListeningStartTripState);
          
                                        isLPRReconnectPopupshowing = true;

}

            }

            if (onDeviceDisconnectCallback != null)
              onDeviceDisconnectCallback!.call();
          }
        } else if (event == BluetoothConnectionState.connected&&!isListeningStartTripState) {
//Setting the lprfile name
//        lprFileName = 'lpr_$fileIndex.csv';
//        //Getting The Path Of the File
//       String lprFilePath = await GetFile().getlprFile(tripId, lprFileName!);
//       //Creating the file
// lprFile=  File(lprFilePath);
//   //Opening the stream to push data (Opening the file)
// lprFileSink = lprFile?.openWrite(mode: FileMode.append);

          List<BluetoothService> services =
              await connectedDevice!.discoverServices();
//This Function Will Return The Connected BlueTooth Name On Map Screen
          callBackconnectedDeviceName!(connectedDevice!.platformName);
          callBackLprUartTxStatus!('Not Connected');
    String lprFileName = 'lpr_$fileIndex.csv';
        String lprFilePath = await GetFile().getlprFile(tripId, lprFileName);
      //  File file = File(filePath);
        File lprFile = File(lprFilePath);

          try {
            //This Will Check LprService element UUID Matches With LPRTransparentServiceUUID
            services.forEach((element) {
              if (element.uuid == _lprTransparentServiceUUID) {
                lprService = element;
                callBackLprTanspernetserviecIdStatus!('Connected');
                lprService!.characteristics.forEach((dataCharacteristic) {
                  if (dataCharacteristic.uuid == _lprUartTX) {
                    callBackLprUartTxStatus!('Connected');
                    dataCharacteristic.setNotifyValue(true);
                    //Start listening to the incoming data
                    dataCharacteristic.value.listen((event) async {
                      if (!event.isEmpty) {

                        String dataLine = utf8.decode(event);                       
                        // saveToFileInDownloads('$dataLine\n',tripId,0);



                        debugPrint("LPR DATA WRITING CODE $dataLine ");
//Saving The Data Into The File
                        DownloadTrip().saveLPRData(dataLine,lprFile);
                        //Call Back Returning the data we can use this globally
                        callBackLprStreamingData!(dataLine);
                      } else {
//DownloadTrip().saveLPRData('test LPR',lprFile!,lprFileSink!);


//   final lines = LineSplitter().convert(fileContent);
//  var stream= Stream<String>.fromIterable(lines);
//  stream.listen((data){
// saveToFileInDownloads(data,tripId,0);
//   Utils.customPrint('Lpr file local data: $data');

//   DownloadTrip().saveLPRData(data,lprFile);

 //});

// for (String line in lines) {
//   //Utils.customPrint('Lpr file local data: $line');
//   DownloadTrip().saveLPRData(line,lprFile);
//     //callBackLprStreamingData!(line);

// }
                      }
                    });
                 }
                });
             }
            });
            // lprService = services.singleWhere((element) =>
            // element.uuid ==
            //     Guid('eed6d5cc-c3b2-4d7b-8c6b-7acbf7965bb6'));
            //If The Service UUID Match This Function Return The Call Back As Connected In The Maps Screen
          }
          //If we selected the wrong device (i.e. not the LPR) or if the service
          //is disabled for some reason....
          catch (ex) {
            //Callback it will return the exception to Map Screen
            callBackLprTanspernetserviecIdStatus!(ex.toString());
            Utils.customPrint(
                'LPR Streaming Data Error: connected Device remote Str ${connectedDevice!.remoteId.str}  err : ${ex.toString()}');
          }

//Testing Purpose This Will Load Data From Sample LPRData File From Assets Production Time It will be removed
          if (isLoadLocalLprFile) {
            String fileContent =
                await rootBundle.loadString('assets/map/lpr_dummy_data.txt');
            callBackLprStreamingData!(fileContent);
          }

          Utils.customPrint(
              'BLE - DEVICE GOT CONNECTED 1: ${connectedDevice!.remoteId.str} - $event');
        }
      });
    }
  }

  void showDeviceDisconnectedDialog(BluetoothDevice? previouslyConnectedDevice,
      {int bottomNavIndex = 0, bool isNavigateToMaps = false,Function? callBackconnectedDeviceName, bool? isListeningStartTripState}) {
    isSelfDisconnected = false;
    bool isDailogShowing = true;
    Get.dialog(
        barrierDismissible: false,
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: OrientationBuilder(builder: (context, orientation) {
            return WillPopScope(
                onWillPop: () async => false,
                child: Container(
                  height: orientation == Orientation.portrait
                      ? displayHeight(Get.context!) * 0.45
                      : displayHeight(Get.context!) * 0.70,
                  width: orientation == Orientation.portrait
                      ? MediaQuery.of(Get.context!).size.width
                      : MediaQuery.of(Get.context!).size.width / 1.5,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: orientation == Orientation.portrait ? 15.0 : 0.0,
                        bottom: orientation == Orientation.portrait ? 15.0 : 0),
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
                                height: orientation == Orientation.portrait
                                    ? displayHeight(Get.context!) * 0.1
                                    : displayHeight(Get.context!) * 0.2,
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
                              textSize: orientation == Orientation.portrait
                                  ? displayWidth(Get.context!) * 0.042
                                  : displayWidth(Get.context!) * 0.023,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Column(
                          children: [
                            Center(
                              child: CommonButtons.getAcceptButton(
                                  'Continue Without LPR', Get.context!, blueColor,
                                  () {
                                    isLPRReconnectPopupshowing=false;
                                    Navigator.pop(context);

                               // endTrip();
                              },
                                  orientation == Orientation.portrait
                                      ? displayWidth(Get.context!) / 1.5
                                      : displayWidth(Get.context!) / 3,
                                  orientation == Orientation.portrait
                                      ? displayHeight(Get.context!) * 0.055
                                      : displayHeight(Get.context!) * 0.095,
                                  primaryColor,
                                  Colors.white,
                                  orientation == Orientation.portrait
                                      ? displayWidth(Get.context!) * 0.036
                                      : displayWidth(Get.context!) * 0.023,
                                  blueColor,
                                  '',
                                  fontWeight: FontWeight.w500

                                  // displayWidth(Get.context!) * 0.5,
                                  // orientation == Orientation.portrait
                                  //     ? displayHeight(Get.context!) * 0.05
                                  //     : displayHeight(Get.context!) * 0.10,
                                  // Colors.transparent,
                                  // Theme.of(Get.context!).brightness ==
                                  //         Brightness.dark
                                  //     ? Colors.white
                                  //     : blueColor,
                                  // orientation == Orientation.portrait
                                  //     ? displayHeight(Get.context!) * 0.018
                                  //     : displayHeight(Get.context!) * 0.038,
                                  // Colors.transparent,
                                  // '',
                                  // fontWeight: FontWeight.w500,

                                  ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: CommonButtons.getAcceptButton('Re-connect',
                                  Get.context!, Colors.transparent, () async {
                                isDailogShowing = false;
                                Get.back();
                                isLPRReconnectPopupshowing=false;
                                EasyLoading.show(
                                    status: 'Connecting...',
                                    maskType: EasyLoadingMaskType.black);
                                Utils.customPrint(
                                    'BLE - PREVIOUSLY CONNECTED DEVICE: ${previouslyConnectedDevice?.remoteId.str}');
                                if (previouslyConnectedDevice != null) {
                                  previouslyConnectedDevice
                                      .connect()
                                      .then((value) {
                                    connectedDevice = previouslyConnectedDevice;

                                    LPRDeviceHandler()
                                        .setLPRDevice(connectedDevice!);
                                        if(isListeningStartTripState??false){
                                          isListeningStartTripState=true;
LPRDeviceHandler()
                                        .listenToDeviceConnectionState(callBackconnectedDeviceName: (data){
                                        });
                                        }
                                        if(callBackconnectedDeviceName!=null){
                                        callBackconnectedDeviceName(connectedDevice?.name);

                                        }
                                                    if (onDeviceConnectedCallback != null){
              onDeviceConnectedCallback?.call();
          }

                                       // setDeviceConnectCallBack();
                                    Fluttertoast.showToast(
                                        msg:
                                            'Device Connected ${connectedDevice?.localName.toString()}',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0);

                                    EasyLoading.dismiss();
                                    bool? runningTrip = sharedPreferences!
                                        .getBool("trip_started");
                                    List<String>? tripData = sharedPreferences!
                                        .getStringList('trip_data');

                                    if (isNavigateToMaps) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TripRecordingScreen(
                                                      bottomNavIndex:
                                                          bottomNavIndex,
                                                      calledFrom: 'bottom_nav',
                                                      tripId: tripData![0],
                                                      vesselId: tripData[1],
                                                      vesselName: tripData[2],
                                                      tripIsRunningOrNot:
                                                          runningTrip)));
                                    }

                                    //   Get.back();
                                    //Navigator.pop(context!);
                                  }).catchError((onError) {
                                    Utils.customPrint(
                                        'BLE - CAUGHT ERROR WHILE CONNECTING TO PREVIOUSLY CONNECTED DEVICE: ${previouslyConnectedDevice.remoteId.str}');
                                    EasyLoading.dismiss();
                                    autoConnectToDevice(isDailogShowing,
                                        isMapScreenNavigation:
                                            isNavigateToMaps,
                                            callBackconnectedDeviceName: callBackconnectedDeviceName
                                            );
                                    // Get.back();
                                  });
                                } else {

                                  autoConnectToDevice(isDailogShowing,
                                      isMapScreenNavigation: isNavigateToMaps,
                                      callBackconnectedDeviceName: callBackconnectedDeviceName
                                      );
                                }
                              },
                                  displayWidth(Get.context!) * 0.65,
                                  orientation == Orientation.portrait
                                      ? displayHeight(Get.context!) * 0.054
                                      : displayHeight(Get.context!) * 0.10,
                                  Colors.transparent,
                                  Theme.of(Get.context!).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : blueColor,
                                  orientation == Orientation.portrait
                                      ? displayHeight(Get.context!) * 0.018
                                      : displayHeight(Get.context!) * 0.038,
                                  Colors.transparent,
                                  '',
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          }),
        ));
  }

  autoConnectToDevice(bool isDailogShowing,
      {bool isMapScreenNavigation = false,Function? callBackconnectedDeviceName}) async {
    connectedDevice = null;
    final FlutterSecureStorage storage = FlutterSecureStorage();
    var lprDeviceId = sharedPreferences!.getString('lprDeviceId');
    // var lprDeviceId = await storage.read(key: 'lprDeviceId');
// if(isDailogShowing){
//   Get.back();
// }

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
                r.device.connectionState.first.then((state) {
                                   // r.device.connectionState.first.then((state) {
                    if (state == BluetoothConnectionState.connected) {
                  Fluttertoast.showToast(
                      msg: "Connected to ${r.device.platformName}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Utils.customPrint('CONNECTED TO DEVICE BLE');
                  LPRDeviceHandler().setLPRDevice(r.device);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                  List<String>? tripData =
                      sharedPreferences!.getStringList('trip_data');
                  bool? runningTrip =
                      sharedPreferences!.getBool("trip_started");
if(tripData!=null&&tripData.isNotEmpty){
                  Navigator.push(
                    context!,
                    MaterialPageRoute(
                        builder: (context) => TripRecordingScreen(
                            tripId: tripData![0],
                            calledFrom: 'bottom_nav',
                            vesselId: tripData![1],
                            vesselName: tripData[2],
                            tripIsRunningOrNot: runningTrip)),
                  );
}

                    }else{
                                      FlutterBluePlus.stopScan();
                EasyLoading.dismiss();

                                          showBluetoothListDialog(context!, null, null,
                        isMapScreenNavigation: isMapScreenNavigation,
                        callbackConnectedDeviceName: callBackconnectedDeviceName
                        );

                    }
                    
                    
                    //});
                }).catchError((onError) {
                  Utils.customPrint('ERROR BLE: $onError');
                });

                // FlutterBluePlus.stopScan();
                // EasyLoading.dismiss();
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
                        fontSize: 16.0);
                    LPRDeviceHandler().setLPRDevice(r.device);
                    deviceId = r.device.remoteId.str;
                    connectedBluetoothDevice = r.device;
                  });

                  FlutterBluePlus.stopScan();
                  EasyLoading.dismiss();
                } else {
                  Future.delayed(Duration(seconds: 2), () {
                    EasyLoading.dismiss();
                    showBluetoothListDialog(context!, null, null,
                        isMapScreenNavigation: isMapScreenNavigation,
                        callbackConnectedDeviceName: callBackconnectedDeviceName
                        );
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
                      fontSize: 16.0);
                  LPRDeviceHandler().setLPRDevice(r.device);
                  deviceId = r.device.remoteId.str;
                  connectedBluetoothDevice = r.device;
                });

                FlutterBluePlus.stopScan();
                EasyLoading.dismiss();
              } else {
                Future.delayed(Duration(seconds: 2), () {
                  EasyLoading.dismiss();
                  // if(isLPRReconnectPopupshowing){
                  //   Get.back();
                  //   isLPRReconnectPopupshowing=false;
                  // }

                  showBluetoothListDialog(context!, null, null,
                      isMapScreenNavigation: isMapScreenNavigation,
                                              callbackConnectedDeviceName: callBackconnectedDeviceName
);
                });
              }
            }
          } else {
            Future.delayed(Duration(seconds: 2), () {
              EasyLoading.dismiss();

              showBluetoothListDialog(context!, null, null,
                  isMapScreenNavigation: isMapScreenNavigation,
                                          callbackConnectedDeviceName: callBackconnectedDeviceName

                  );
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
      BluetoothDevice? connectedBluetoothDevice,
      {bool isMapScreenNavigation = false,Function? callbackConnectedDeviceName,bool isTripNavigate=true}) {
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
                                                                            onConnetedCallBack: (value) {
                                                                                                                                  if (onDeviceConnectedCallback != null){

                                                                                                                                                  Fluttertoast.showToast(
                                      msg:
                                          "Connected to ${value}",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,

                                      fontSize: 16.0);

                                                                                                                                  
          



                                                                                                                                    
              onDeviceConnectedCallback!.call();

              
          }


                                        
                                      },
                                      onErrCallback: (data){
                                        
                                      },

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
                                      onConnetedCallBack: (value) {
                                                                                                                                                                                if (onDeviceConnectedCallback != null){
              onDeviceConnectedCallback!.call();


              Fluttertoast.showToast(
                                      msg:
                                          "Connected to ${value}",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
          }


                                      },
                                      onErrCallback: (data){

                                      },
                                  onSelected: (value) {},
                                  onBluetoothConnection: (value) {
                                    List<String>? tripData = sharedPreferences!
                                        .getStringList('trip_data');
                                    bool? runningTrip = sharedPreferences!
                                        .getBool("trip_started");

                                    Navigator.pop(context);
if(isTripNavigate){
                                    if(tripData!=null&&tripData.isNotEmpty){

                                    Navigator.push(
                                      dialogContext,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TripRecordingScreen(
                                                  tripId: tripData![0],
                                                  calledFrom: 'bottom_nav',
                                                  vesselId: tripData[1],
                                                  vesselName: tripData[2],
                                                  tripIsRunningOrNot:
                                                      runningTrip)),
                                    );
                                    }
                                  }},
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

                                  FlutterBluePlus.isScanning.listen((event) {
                                    if (event) {
                                      // if (mounted&&_builderKey.currentState!=null) {
                                      //   setDialogState(() {
                                      //     isScanningBluetooth = true;
                                      //   });
                                      // }
                                    }
                                    else
                                      {
                                        // if (mounted&&_builderKey.currentState!=null) {
                                        //   setDialogState(() {
                                        //     isScanningBluetooth = false;
                                        //   });
                                        //}
                                      }
                                  });

                                  if (!FlutterBluePlus.isScanningNow) {
                                    FlutterBluePlus.startScan(
                                        timeout: const Duration(seconds: 2));
                                  }

                                  if (FlutterBluePlus.isScanningNow) {
                                    debugPrint(
                                        "ALREADY SCANNING PLEASE WAIT !!!");
                                  }

                                  // if (mounted) {
                                  //   Future.delayed(Duration(seconds: 2), () {
                                  //     /* setDialogState(() {
                                  //    isScanningBluetooth = false;
                                  //  });*/
                                  //   });
                                  // }
isRefreshList=true;
                                  // if (mounted) {
                                  //   setState(() {
                                  //     isRefreshList = true;
                                  //     progress = 0.9;
                                  //     lprSensorProgress = 0.0;
                                  //     isStartButton = false;
                                  //     bluetoothName = '';
                                  //   });
                                  // }
                                
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
                                List<BluetoothDevice> connectedDeviceList =
                                    FlutterBluePlus.connectedDevices;
                                if (connectedDeviceList.isNotEmpty) {

                                  Fluttertoast.showToast(
                                      msg:
                                          "Connected to ${connectedDeviceList.first.platformName}",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  FlutterBluePlus.stopScan();
                                  Navigator.pop(context);
                                } else {

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
        status: 'Ending trip...', maskType: EasyLoadingMaskType.black);
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

    Utils.customPrint("DURATION !!!!!! $tripDuration");

    bool isSmallTrip = Utils()
        .checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));

    if (!isSmallTrip) {
      Get.back();
      EasyLoading.dismiss();
      Utils().showDeleteTripDialog(context!, endTripBtnClick: () {
        EasyLoading.show(
            status: 'Please wait...', maskType: EasyLoadingMaskType.black);
        endTripMethod();
        Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

        Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

        Future.delayed(Duration(seconds: 1), () {
          if (!isSmallTrip) {
            Utils.customPrint("SMALL TRIPP IDDD 11 ${tripId}");
            DatabaseService().deleteTripFromDB(tripId);
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
        lprDeviceId:
            connectedDevice == null ? null : connectedDevice!.remoteId.str,
        onEnded: () async {
          connectedDevice = null;
          isSelfDisconnected = false;
          Future.delayed(Duration(seconds: 1), () {
            EasyLoading.dismiss();

            Navigator.push(
                context!,
                MaterialPageRoute(
                    builder: (context) => NewTripAnalyticsScreen(
                          tripId: currentTrip!.id,
                          vesselId: currentTrip?.vesselId,
                          calledFrom: 'End Trip',
                        )));

            // Navigator.pushAndRemoveUntil(
            //     context!,
            //     MaterialPageRoute(builder: (context) => BottomNavigation()),
            //     ModalRoute.withName(""));
            //Navigator.of(context).pop();
          });

          Utils.customPrint('TRIPPPPPP ENDEDDD:');
        });
  }

//Testing Purpose Write LPR  Raw Data Into Downloads Folder File For Testing Purpose Method  Should Not Go Into Production 
  IOSink? _fileSink;

Future<void> saveToFileInDownloads(
    String data, String tripId, int fileIndex) async {
  try {
    if (_fileSink == null) {
        Directory downloadsDirectory;

        if (Platform.isAndroid) {
          downloadsDirectory = Directory("storage/emulated/0/Download/");
        } else {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }

      String fileName = "lpr_$tripId$fileIndex.txt";
      File file = File("${downloadsDirectory.path}/$fileName");

      // Open the file for writing (append mode)
      _fileSink = file.openWrite(mode: FileMode.append);
      debugPrint("File opened: ${file.path}");
    }

    // Write the data to the file
    _fileSink!.writeln(data);

    debugPrint("Data saved: $data");
  } catch (e) {
    debugPrint("Failed to write to file: $e");
  }
}

Future<void> closeFile() async {
  if (_fileSink != null) {
    await _fileSink!.flush();
    await _fileSink!.close();
    _fileSink = null;
    debugPrint("File closed.");
  }
}

}
