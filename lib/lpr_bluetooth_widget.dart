import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/data_recorder.dart';
import 'package:performarine/find_devices_screen.dart';

class LprBluetoothWidget extends StatefulWidget {
  const LprBluetoothWidget({Key? key}) : super(key: key);

  @override
  State<LprBluetoothWidget> createState() => _LprBluetoothWidgetState();
}

class _LprBluetoothWidgetState extends State<LprBluetoothWidget> {
  bool connectCalled = false;
  bool canLogLprData = false;
  Guid lprServiceUUId = Guid("11223344-5566-7788-9900-aabbccddeeff");
  BluetoothService? lprService;
  StringBuffer lprDataLineBuffer = StringBuffer();

  String lprDataText = "No LPR data";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 15),
          Text(getBleInfoText()),
          const SizedBox(height: 15),
          Text(lprDataText),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              /// On click of this btn will get list of bluetooth devices, from which we will select and connect one device to get LPR data.
              Expanded(
                  child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FindDevicesScreen()))
                            .then((value) => setState(() {}));
                      },
                      child: const Text("Connect to LPR"))),
              const SizedBox(
                width: 20,
              ),

              /// On click of this btn app will start listening to LPR data from selected device
              Expanded(
                  child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () {
                        misc();
                      },
                      child: const Text("Listen to Updates"))),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () {
                if (lprService != null) {
                  debugPrint(lprService?.characteristics[1].uuid.toString());
                  //TODO: We should look for the characteristic by uuid
                  var controlChar = lprService?.characteristics[1];
                  var timeNow = DateTime.now().toUtc();
                  String date =
                      "D${timeNow.month.toString().padLeft(2, '0')}/${timeNow.day.toString().padLeft(2, '0')}/${timeNow.year}";
                  String time =
                      "T${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}:${timeNow.second.toString().padLeft(2, '0')}";
                  controlChar?.write(utf8.encode(date), withoutResponse: true);
                  //Ideally we should not have to sleep.
                  //TODO: Investigate a response on the firmware side
                  sleep(const Duration(milliseconds: 500));
                  controlChar?.write(utf8.encode(time), withoutResponse: true);

                  Utils.showSnackBar(context, message: 'LPR Time Set!');
                }
              },
              child: const Text("Set LPR Time")),
        ],
      ),
    );
  }

  String getBleInfoText() {
    if (DataRecorder().getLPRDevice() == null) {
      return "No Device Selected";
    }

    var device = DataRecorder().getLPRDevice();
    return "Selected Device ${device?.name}";
  }

  /// In this function connected device is accessed and services provided by the device is accessed.
  /// Then app checks for specific service UUID with the services from device
  /// if id matches with any of the services then the characteristics from that service is accessed
  void misc() async {
    var device = DataRecorder().getLPRDevice();
    var services = await device?.discoverServices();
    services?.forEach((service) {
      if (service.uuid == lprServiceUUId) {
        debugPrint("Found");
        lprService = service;
        //There is only one for now
        //TODO: Use the GUID instead
        var dataCharacteristic = service.characteristics[0];

        dataCharacteristic.setNotifyValue(true);
        dataCharacteristic.value.listen((value) {
          if (value.isEmpty) {
            return;
          }

          //20 bytes, first 1 is control byte, last 19 text
          var bytes = Uint8List.fromList(value);

          final controlByte = value[0];

          lprDataLineBuffer
              .write(utf8.decode(bytes.getRange(1, bytes.length).toList()));

          //ETX (Dart does not support bit literals....)
          //There is package for that probably
          if (controlByte == 3) {
            DataRecorder().writeLineToLprLog(lprDataLineBuffer.toString());
            setState(() {
              lprDataText = lprDataLineBuffer.toString();
            });

            lprDataLineBuffer.clear();
          }
        });
      } else {
        print('not found');
      }
    });
  }
}
