import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/gen/flutterblueplus.pbjson.dart';
import 'package:performarine/pages/single_lpr_device.dart';

class LPRBluetoothList extends StatefulWidget {
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setDialogSet;
  LPRBluetoothList(
      {Key? key,
      this.dialogContext,
      this.onSelected,
      this.onBluetoothConnection,
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
          stream: FlutterBluePlus.instance.scanResults,
          initialData: const [],
          builder: (c, snapshot) => Column(
            children: snapshot.data != null
                ? snapshot.data!
                    .map((d) => SingleLPRDevice(
                          device: d.device,
                          onSelected: widget.onSelected,
                          onBluetoothConnection: widget.onBluetoothConnection,
                          dialogContext: widget.dialogContext,
                          setSetter: widget.setDialogSet,
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
