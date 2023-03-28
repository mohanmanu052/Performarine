import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/find_devices_screen.dart';

import 'data_recorder.dart';

class LprBluetoothWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  LprBluetoothWidget({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  State<LprBluetoothWidget> createState() => _LprBluetoothWidgetState();
}

class _LprBluetoothWidgetState extends State<LprBluetoothWidget> {
  //RN 4870 Transparent UART service ID
  final Guid _lprTransparentServiceUUID =
      Guid("49535343-FE7D-4AE5-8FA9-9FAFD205E455");
  // TX Characteristic, Notify, Write and Write without response
  final Guid _lprUartTX = Guid("49535343-1E4D-4BD9-BA61-23C647249616");
  // RX Characteristic, Write and Write without response
  final Guid _lprUartRX = Guid("49535343-8841-43F4-A8D4-ECBE34729BB3");

  bool connectCalled = false;
  bool canLogLprData = false;
  BluetoothService? lprService;

  String lprDataText = "No LPR data";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const SizedBox(height: 15),
            Text(getBleInfoText()),
            const SizedBox(height: 15),
            Text(lprDataText),
            const SizedBox(height: 15),
            Row(
              children: <Widget>[
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
                                      const FindDevicesScreen())).then(
                              (value) =>
                                  {selectUARTService(), setState(() {})});
                        },
                        child: const Text("Connect to LPR"))),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: ElevatedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: () {
                          listenToLPRUpdates();
                        },
                        child: const Text("Listen to Updates"))),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  updateLprTime();
                },
                child: const Text("Set LPR Time")),
          ],
        ),
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

  Future<bool> selectUARTService() async {
    var device = DataRecorder().getLPRDevice();
    var services = await device?.discoverServices();

    try {
      lprService = services?.singleWhere(
          (element) => element.uuid == _lprTransparentServiceUUID);
    }
    //If we selected the wrong device (i.e. not the LPR) or if the service
    //is disabled for some reason....
    catch (ex) {
      return false;
    }
    return true;
  }

  bool listenToLPRUpdates() {
    if (lprService == null) {
      return false;
    }

    var dataCharacteristic = lprService!.characteristics
        .singleWhere((element) => element.uuid == _lprUartTX);

    dataCharacteristic.setNotifyValue(true);
    dataCharacteristic.value.listen((value) {
      if (value.isEmpty) {
        return;
      }

      var dataLine = utf8.decode(value);
      DataRecorder().writeLineToLprLog(dataLine);
      setState(() {
        lprDataText = dataLine;
      });
    });

    return true;
  }

  bool updateLprTime() {
    if (lprService == null) {
      return false;
    }

    var controlCharacteristic = lprService!.characteristics
        .singleWhere((element) => element.uuid == _lprUartRX);

    var timeNow = DateTime.now().toUtc();
    String date =
        "D${timeNow.month.toString().padLeft(2, '0')}/${timeNow.day.toString().padLeft(2, '0')}/${timeNow.year}";
    String time =
        "T${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}:${timeNow.second.toString().padLeft(2, '0')}";

    String dateTime =
        "T${timeNow.month.toString().padLeft(2, '0')}/${timeNow.day.toString().padLeft(2, '0')}/${timeNow.year} "
        "${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}:${timeNow.second.toString().padLeft(2, '0')}\n";

    controlCharacteristic.write(utf8.encode(dateTime), withoutResponse: true);
    // showToast('LPR Time Set!');

    Utils.showSnackBar(
      context,
      scaffoldKey: widget.scaffoldKey,
      message: 'LPR Time Set!',
    );

    return true;
  }
}
