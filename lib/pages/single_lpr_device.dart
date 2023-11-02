import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/widgets/log_level.dart';

import '../common_widgets/utils/utils.dart';

class SingleLPRDevice extends StatefulWidget {
  final BluetoothDevice? device;
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setSetter;
  final Function(bool)? onSingleDeviceTapped;
  String? connectedDeviceId;
  SingleLPRDevice(
      {Key? key,
      this.device,
      this.dialogContext,
      this.onSelected,
      this.onBluetoothConnection,
      this.setSetter,
        this.connectedDeviceId,
      this.onSingleDeviceTapped})
      : super(key: key);

  @override
  State<SingleLPRDevice> createState() => _SingleLPRDeviceState();
}

class _SingleLPRDeviceState extends State<SingleLPRDevice> {
  bool isConnect = false;
  DateTime? connectDeviceClickTime;
  String page = "single_lpr_device";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      onTap: () async {
        widget.setSetter!(() {
          isConnect = true;
          widget.connectedDeviceId = widget.device!.id.id;
          widget.onSingleDeviceTapped!(true);
        });

        widget.device!.connect().then((value) {}).catchError((s) {

          CustomLogger().logWithFile(Level.error, "ERROR $s-> $page");
          widget.device!.state.listen((event) {
            if (event == BluetoothDeviceState.connected) {
              CustomLogger().logWithFile(Level.info, "CONNECTION EVENT ${event}-> $page");
              widget.device!.disconnect().then((value) {
                widget.device!.connect().then((value) {
                  CustomLogger().logWithFile(Level.info, "CONNECTION NAME ${widget.device!.name}-> $page");
                  widget.onSelected!(
                      widget.device!.name == null || widget.device!.name.isEmpty
                          ? widget.device!.id.toString()
                          : widget.device!.name);
                  widget.onBluetoothConnection!(true);


                  Navigator.pop(
                    widget.dialogContext!,
                  );
                  widget.setSetter!(() {
                    isConnect = false;
                    widget.onSingleDeviceTapped!(false);
                  });
                  FlutterBluePlus.instance.stopScan();
                });
              });
            } else {

              CustomLogger().logWithFile(Level.error, "ERROR CONNECTED 1212-> $page");
            }
          });
        });
        CustomLogger().logWithFile(Level.error, "ERROR CONNECTED-> $page");
        CustomLogger().logWithFile(Level.error, "ERROR CONNECTED FIRST-> $page");

        widget.setSetter!(() {
          widget.onBluetoothConnection!(true);
          widget.onSelected!(
              widget.device!.name == null || widget.device!.name.isEmpty
                  ? widget.device!.id.toString()
                  : widget.device!.name);
        });

        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            widget.setSetter!(() {
              isConnect = false;
              widget.onSingleDeviceTapped!(false);
            });
          }
          Navigator.pop(widget.dialogContext!);
        });
      },
      title: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: commonText(
            context: context,
            text: widget.device!.name,
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.036,
            textAlign: TextAlign.start,
        fontFamily: inter),
      ),
      subtitle: commonText(
          context: context,
          text: widget.device!.id.toString(),
          fontWeight: FontWeight.w500,
          textColor: Colors.black54,
          textSize: displayWidth(context) * 0.032,
          textAlign: TextAlign.start,
          fontFamily: inter),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: widget.device!.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          // if (snapshot.data ==
          //     BluetoothDeviceState.connected) {
          return widget.connectedDeviceId == widget.device!.id.id
              ? commonText(
                  context: context,
                  text: 'Connected',
                  fontWeight: FontWeight.w400,
                  textColor: Colors.green,
                  textSize: displayWidth(context) * 0.032,
                  textAlign: TextAlign.start,
                  fontFamily: inter)
              : commonText(
                  context: context,
                  text: 'Tap to connect',
                  fontWeight: FontWeight.w400,
                  textColor: blueColor,
                  textSize: displayWidth(context) * 0.032,
                  textAlign: TextAlign.start,
                  fontFamily: inter);
        },
      ),
    );
  }
}
