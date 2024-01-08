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
import 'package:performarine/services/database_service.dart';

import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/utils/utils.dart';

class LPRDeviceHandler {
  Function(String lprTransperntServiceId)? getLprServiceId; 
Function (bool lprServiceIdStatus )? getLprServiceIdStatus;
Function(String lprUartTX)? getLPRUartTxId;
Function(bool lprUartTX)? getLPRUartTxIdStatus;


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
  BluetoothService? lprService;

  bool isRefreshList = false;
  bool isSelfDisconnected = false;




Future<Map<String,dynamic>>  getLPRConfigartion()async  {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? lprConfig = await storage.read(
        key: 'lprConfig'
    );

    if(lprConfig != null){
      Map<String, dynamic> mapOfConfig = jsonDecode(lprConfig);
      Utils.customPrint('the config map was: ${mapOfConfig}');
    return  Future.value(mapOfConfig);
      
  }else{
    return Future.value({});
  }
  
  }


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

  void listenToDeviceConnectionState({
    //Call back Functions to return the status and info related Ids And Other Things on MapScreen
    Function(String lprTransperntServiceId, String lprUartTX)?callBackLprTanspernetserviecId,
    Function(String status)?callBackLprTanspernetserviecIdStatus,
        Function(String status)?callBackLprUartTxStatus,
Function(String bluetoothDeviceName)? callBackconnectedDeviceName,
Function(String lprSteamingData)? callBackLprStreamingData,
bool isLoadLocalLprFile=false
    
     }
    
    
    
    )async {
                  File? lprFile;
  int fileIndex = 0;


        Map<String,dynamic> lpConfigValues= await    getLPRConfigartion();
final Guid? _lprUartTX;
final Guid? _lprUartRX; 
  final Guid _lprTransparentServiceUUID = Guid(lpConfigValues['lprTransparentServiceUUID']??"49535343-FE7D-4AE5-8FA9-9FAFD205E455");

         _lprUartTX = Guid( lpConfigValues['lprUartTX']?? "49535343-1E4D-4BD9-BA61-23C647249616");
  // RX Characteristic, Write and Write without response
  _lprUartRX = Guid(lpConfigValues['lprUartRX'] ??  "49535343-8841-43F4-A8D4-ECBE34729BB3");
//Asigning default callback methods to aviod null check issue while calling the function and assign the values  
  callBackLprTanspernetserviecId ??= (String lprTransperntServiceId, String lprUartTx) {
  };
    callBackLprStreamingData ??= (String lprTransperntServiceId) {
  };
callBackLprUartTxStatus ??= ( String status) {
  };
callBackconnectedDeviceName??=(String name){

};
  callBackLprTanspernetserviecIdStatus ??= (String transperntStats) {
  };

//This Function will return the LPR Transpernt ServiceId LPR UARTX ID In The Maps Screen To Show IDs Info
  callBackLprTanspernetserviecId(_lprTransparentServiceUUID.toString(),_lprUartTX.toString());



    if (connectedDevice != null) {

      bluetoothConnectionStateListener = connectedDevice!.connectionState.listen((event) async {
        if (event == BluetoothConnectionState.disconnected) {
          
DownloadTrip().closeLprFile();
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

List<BluetoothService> services =await  connectedDevice!.discoverServices();
//This Function Will Return The Connected BlueTooth Name On Map Screen
callBackconnectedDeviceName!(connectedDevice!.platformName);

    try {
    //This Will Check LprService element UUID Matches With LPRTransparentServiceUUID 
      lprService = services.singleWhere((element) =>
      element.uuid ==
          Guid('eed6d5cc-c3b2-4d7b-8c6b-7acbf7965bb6'));
          //If The Service UUID Match This Function Return The Call Back As Connected In The Maps Screen

          callBackLprTanspernetserviecIdStatus!('Connected');
    }
    //If we selected the wrong device (i.e. not the LPR) or if the service
    //is disabled for some reason....
    catch (ex){
      //Callback it will return the exception to Map Screen
      callBackLprTanspernetserviecIdStatus!(ex.toString());
      Utils.customPrint(
              'LPR Streaming Data Error: connected Device remote Str ${connectedDevice!.remoteId.str}  err : ${ex.toString()}')
      ;
    }
    //By Default LPRUARTX is setting as not connected
      callBackLprUartTxStatus!('Not Connected');
//Check is LPRUARTX value matches with the LPRService Element UUID This Will Execute only IF LPRTransparentServiceUUID Matches In The Beginig Step
//     var dataCharacteristic = lprService?.characteristics.singleWhere((element) => element.uuid == _lprUartTX);

//     dataCharacteristic?.setNotifyValue(true);
//     //This Will Listen The LPR The LPR Streaming Data
//     dataCharacteristic?.value.listen((value) {
//     //If All The Above Condition SucessFull This CallBack Will Return As LPRUARTX Status as Connected In Maps Screen
//       callBackLprUartTxStatus!('Connected');
//       if(value.isEmpty) {
//         return;
//       }
// //Decoding The Values We Are Reciving From The LPR Device
//     String  dataLine = utf8.decode(value);
//     //Saving Decoded Data On The XL
//        DownloadTrip().saveLPRData(dataLine);
//        //This Call Back Will Return Decoded Data On Maps Screen Were We can See That In Dailog 
//        callBackLprStreamingData!(dataLine);
//     });
      
        services.forEach((service) async {
            var characteristics = service.characteristics;
            String uuid = connectedDevice!.servicesList![0].uuid.toString();
            String? dataLine;
            for (BluetoothCharacteristic c in characteristics) {
              //if(c.serviceUuid==uuid){

              //if (c.serviceUuid == _lprUartTX || c.serviceUuid == _lprUartRX) {

              c.lastValueStream.listen((event) async {
                try{
                List<int> value = await c.read();

                debugPrint("LPR DATA WRITING CODE EVENT $event ");

                dataLine = utf8.decode(value);
                debugPrint("LPR DATA WRITING CODE DATA LINE $dataLine ");
                debugPrint("LPR DATA WRITING CODE VALUE $value ");

                // }
                DownloadTrip().saveLPRData(dataLine ?? '');
                }catch(err){

                }
              });
            
            }});

//Testing Purpose This Will Load Data From Sample LPRData File From Assets Production Time It will be removed
if(isLoadLocalLprFile){
      String fileContent = await rootBundle.loadString('assets/map/lpr_dummy_data.txt');
       callBackLprStreamingData!(fileContent);

}


          Utils.customPrint(
              'BLE - DEVICE GOT CONNECTED: ${connectedDevice!.remoteId.str} - $event');
        }
      });
    }
  }

  void showDeviceDisconnectedDialog(BluetoothDevice? previouslyConnectedDevice,{int bottomNavIndex=0}) {
    isSelfDisconnected = false;
    bool isDailogShowing=true;
    Get.dialog(
        barrierDismissible: false,
        Dialog(
          child:OrientationBuilder(
  builder: (context, orientation) {
    return 
          
          
          
           WillPopScope(
            onWillPop: () async => false,
            child: Container(
              height:orientation==Orientation.portrait? displayHeight(Get.context!) * 0.42:displayHeight(Get.context!) * 0.70,
              width:orientation==Orientation.portrait? MediaQuery.of(Get.context!).size.width:MediaQuery.of(Get.context!).size.width/1.5,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding:  EdgeInsets.only(
                    left: 8.0, right: 8.0, top:orientation==Orientation.portrait? 15.0:0.0, bottom:orientation==Orientation.portrait? 15.0:0),
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
                            height:orientation==Orientation.portrait?   displayHeight(Get.context!) * 0.1:displayHeight(Get.context!) * 0.2,
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
                          textSize:orientation==Orientation.portrait?  displayWidth(Get.context!) * 0.042:displayWidth(Get.context!) * 0.023,
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      height: displayHeight(Get.context!) * 0.01,
                    ),
                    Column(
                      children: [
                        Center(
                          child: CommonButtons.getAcceptButton(
                              'Re-connect', Get.context!, endTripBtnColor, () async{
                                isDailogShowing=false;
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
                                LPRDeviceHandler().setLPRDevice(connectedDevice!);
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
                             //   Get.back();
                                                                                                    //Navigator.pop(context!);

                              })
                                  .catchError((onError) {
                                Utils.customPrint(
                                    'BLE - CAUGHT ERROR WHILE CONNECTING TO PREVIOUSLY CONNECTED DEVICE: ${previouslyConnectedDevice.remoteId.str}');
                                EasyLoading.dismiss();
                                autoConnectToDevice(isDailogShowing);
                               // Get.back();

                              });
                            } else {

                              autoConnectToDevice(isDailogShowing);
                            }
                          },
                             orientation==Orientation.portrait? displayWidth(Get.context!) / 1.5:displayWidth(Get.context!) / 3,
                          orientation==Orientation.portrait?    displayHeight(Get.context!) * 0.055:displayHeight(Get.context!) * 0.095,
                              primaryColor,
                              Colors.white,
                             orientation==Orientation.portrait?   displayWidth(Get.context!) * 0.036:displayWidth(Get.context!) * 0.023,
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
                         orientation==Orientation.portrait?     displayHeight(Get.context!) * 0.05:displayHeight(Get.context!) * 0.10,
                              Colors.transparent,
                              Theme.of(Get.context!).brightness == Brightness.dark
                                  ? Colors.white
                                  : blueColor,
                             orientation==Orientation.portrait?   displayHeight(Get.context!) * 0.018:displayHeight(Get.context!) * 0.038,
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
            ));
  }
          ),
        ));
  }

  autoConnectToDevice(bool isDailogShowing) async {
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


                                                                              Navigator.push(
                                                                          context!,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  NewTripAnalyticsScreen(
                                                                                    tripId:currentTrip!.id ,
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
}
