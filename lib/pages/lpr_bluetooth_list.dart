import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:performarine/pages/single_lpr_device.dart';

class LPRBluetoothList extends StatefulWidget {
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setDialogSet;
  final String? connectedDeviceId;
  final Function(BluetoothDevice)? selectedBluetoothDevice;
  String? comingFrom;
  final BluetoothDevice? connectedBluetoothDevice;
  LPRBluetoothList(
      {Key? key,
        this.dialogContext,
        this.onSelected,
        this.onBluetoothConnection,
        this.connectedDeviceId,
        this.connectedBluetoothDevice,
        this.comingFrom,
        this.selectedBluetoothDevice,
        this.setDialogSet})
      : super(key: key);
  @override
  State<LPRBluetoothList> createState() => _LPRBluetoothListState();
}

class _LPRBluetoothListState extends State<LPRBluetoothList> {
  bool isConnectToDevice = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AbsorbPointer(
        absorbing: isConnectToDevice,
        child: StreamBuilder<List<ScanResult>>(
          stream: FlutterBluePlus.scanResults,
          // initialData: const [],
          builder: (c, snapshot) => Column(
            children: snapshot.data != null
                ? snapshot.data!
                .map((d) => SingleLPRDevice(
              device: d.device,
              onSelected: widget.onSelected,
              onBluetoothConnection: widget.onBluetoothConnection,
              dialogContext: widget.dialogContext,
              setSetter: widget.setDialogSet,
              comingFrom: widget.comingFrom,
              selectedBluettothDevice: widget.selectedBluetoothDevice,
              connectedDeviceId: widget.connectedDeviceId,
              connectedBluetoothDevice: widget.connectedBluetoothDevice??d.device,
              onSingleDeviceTapped: (bool value) {
                widget.setDialogSet!(() {
                  isConnectToDevice = value;
                });
              },
            ))
                .toList()
                : [],
          ),
        ),
      ),
    );
  }
}
