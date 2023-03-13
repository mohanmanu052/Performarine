import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';

class DataRecorder {
  IOSink? _phoneSensorsSink;
  IOSink? _lprSensorsSink;
  bool _canWritePhone = false;
  bool _canWriteLpr = false;
  String? logFileName;

  //TODO Remove this from here, add to the LPR Widget....
  BluetoothDevice? _lprDevice;

  DataRecorder._privateConstructor();
  static final DataRecorder _instance = DataRecorder._privateConstructor();

  factory DataRecorder() {
    return _instance;
  }

  void openLogFilesForWriting() {
    var filenameTime = DateTime.now().toUtc();

    String filename =
        '${filenameTime.year}-${filenameTime.month}-${filenameTime.day} '
        'T${filenameTime.hour}-${filenameTime.minute}-${filenameTime.second}Z';

    _openPhoneSensorsFile(filename);
    _openLprSensorsFile(filename);
  }

  void _openPhoneSensorsFile(String filename) async {
    // final dirs = await getApplicationSupportDirectory();
    // return;

    final path = await getExternalStorageDirectory();
    logFileName = filename;
    _phoneSensorsSink = File('${path?.path}/${filename.trim()}-phone.csv')
        .openWrite(mode: FileMode.append);
    //Ensure that we stop writing once the sink is closed
    _phoneSensorsSink?.done.whenComplete(() => {_canWritePhone = false});
    _canWritePhone = true;
  }

  void _openLprSensorsFile(String filename) async {
    final path = await getExternalStorageDirectory();
    _lprSensorsSink = File('${path?.path}/${filename.trim()}-lpr.csv')
        .openWrite(mode: FileMode.append);

    _lprSensorsSink?.done.whenComplete(() => {_canWriteLpr = false});
    _canWriteLpr = true;
  }

  void writeLineToPhoneLog(String dataLine) {
    if (_canWritePhone) {
      _phoneSensorsSink?.writeln(dataLine);
    }
  }

  void writeLineToLprLog(String dataLine) {
    if (_canWriteLpr) {
      _lprSensorsSink?.writeln(dataLine);
    }
  }

  void stopWriting() {
    _canWritePhone = false;
    _canWriteLpr = false;

    _phoneSensorsSink?.flush().whenComplete(() => _phoneSensorsSink?.close());
    _lprSensorsSink?.flush().whenComplete(() => _lprSensorsSink?.close());
  }

  //TODO remove from here, add to LPR Widget
  void setLPRDevice(BluetoothDevice device) {
    _lprDevice = device;
  }

  //TODO remove from here, add to LPR Widget
  BluetoothDevice? getLPRDevice() {
    return _lprDevice;
  }
}
