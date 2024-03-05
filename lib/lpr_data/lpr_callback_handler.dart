import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

class LPRCallbackHandler{
  static LPRCallbackHandler? _instance;

  // Private constructor
  LPRCallbackHandler._internal({
    this.callBackLprTanspernetserviecId,
    this.callBackLprTanspernetserviecIdStatus,
    this.callBackLprUartTxStatus,
    this.callBackconnectedDeviceName,
    this.callBackLprStreamingData,
  });

  // Public method to get the singleton instance
  static LPRCallbackHandler get instance {
    _instance ??= LPRCallbackHandler._internal();
    return _instance!;
  }


  // Method to reset the singleton instance if needed
  static void resetInstance() {
    _instance = null;
  }


    Function(String, String)? callBackLprTanspernetserviecId;
  Function(String)? callBackLprTanspernetserviecIdStatus;
  Function(String)? callBackLprUartTxStatus;
  Function(String)? callBackconnectedDeviceName;
  Function(String)? callBackLprStreamingData;
  VoidCallback? onDeviceDisconnectCallback;
  BluetoothService? lprService;

  BluetoothDevice? connectedDevice;
  StreamSubscription<BluetoothConnectionState>? bluetoothConnectionStateListener;

  // Expose a StreamController to broadcast the Bluetooth data
  final StreamController<String> _lprDataStreamController = StreamController<String>();
  Stream<String> get lprDataStream => _lprDataStreamController.stream;

  LPRCallbackHandler({
    this.callBackLprTanspernetserviecId,
    this.callBackLprTanspernetserviecIdStatus,
    this.callBackLprUartTxStatus,
    this.callBackconnectedDeviceName,
    this.callBackLprStreamingData,
  });

  void listenToDeviceConnectionState() async {
    // Your existing method code...
        Map<String,dynamic> lpConfigValues= await    getLPRConfigartion();
final Guid? _lprUartTX;
final Guid? _lprUartRX; 
  final Guid _lprTransparentServiceUUID = Guid(lpConfigValues['lprTransparentServiceUUID']??"49535343-FE7D-4AE5-8FA9-9FAFD205E455");

         _lprUartTX = Guid( lpConfigValues['lprUartTX']?? "49535343-1E4D-4BD9-BA61-23C647249616");
  // RX Characteristic, Write and Write without response
  _lprUartRX = Guid(lpConfigValues['lprUartRX'] ??  "49535343-8841-43F4-A8D4-ECBE34729BB3");
    if (connectedDevice != null) {
      bluetoothConnectionStateListener =
          connectedDevice!.connectionState.listen((event) async {
        if (event == BluetoothConnectionState.disconnected) {
          // if(lprFileSink!=null){
          //   lprFileSink?.close();
          // }
          
        } else if (event == BluetoothConnectionState.connected) {

List<BluetoothService> services =await  connectedDevice!.discoverServices();
//This Function Will Return The Connected BlueTooth Name On Map Screen
callBackconnectedDeviceName!(connectedDevice!.platformName);
      callBackLprUartTxStatus!('Not Connected');

    try {
    //This Will Check LprService element UUID Matches With LPRTransparentServiceUUID 
  services.forEach((element) {
                  if (element.uuid == _lprTransparentServiceUUID) {
                    lprService=element;
                              callBackLprTanspernetserviecIdStatus!('Connected');

              lprService!.characteristics.forEach((dataCharacteristic) {
               if (dataCharacteristic.uuid == _lprUartTX) {
      callBackLprUartTxStatus!('Connected');
dataCharacteristic.setNotifyValue(true);
                  //Start listening to the incoming data
                  dataCharacteristic.value.listen((event)async {
                    if (!event.isEmpty) {
                      String dataLine = utf8.decode(event);

                      debugPrint("LPR DATA WRITING CODE $dataLine ");
//Saving The Data Into The File
  //Call Back Returning the data we can use this globally
                               callBackLprStreamingData!(dataLine);


                    }
                    else{

//DownloadTrip().saveLPRData('test LPR',lprFile!,lprFileSink!);

// List<String> lines = fileContent.split('\n');

// for (String line in lines) {
//   //Utils.customPrint('Lpr file local data: $line');
//   DownloadTrip().saveLPRData(line);
//     callBackLprStreamingData!(line);


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
    catch (ex){
      //Callback it will return the exception to Map Screen
      callBackLprTanspernetserviecIdStatus!(ex.toString());
      Utils.customPrint(
              'LPR Streaming Data Error: connected Device remote Str ${connectedDevice!.remoteId.str}  err : ${ex.toString()}')
      ;
    }

//Testing Purpose This Will Load Data From Sample LPRData File From Assets Production Time It will be removed
// if(isLoadLocalLprFile){
//       String fileContent = await rootBundle.loadString('assets/map/lpr_dummy_data.txt');
//        callBackLprStreamingData!(fileContent);

// }


          Utils.customPrint(
              'BLE - DEVICE GOT CONNECTED: ${connectedDevice!.remoteId.str} - $event');
        }
      });
    }
  }

  // Dispose the stream controller to avoid memory leaks
  void dispose() {
    _lprDataStreamController.close();
  }
Future<Map<String,dynamic>>  getLPRConfigartion()async  {
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

}