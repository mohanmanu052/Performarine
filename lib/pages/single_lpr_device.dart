import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import '../common_widgets/widgets/log_level.dart';

import '../common_widgets/utils/utils.dart';

class SingleLPRDevice extends StatefulWidget {
  final BluetoothDevice? device;
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setSetter;
  final Function(bool)? onSingleDeviceTapped;
  const SingleLPRDevice(
      {Key? key,
      this.device,
      this.dialogContext,
      this.onSelected,
      this.onBluetoothConnection,
      this.setSetter,
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
          widget.onSingleDeviceTapped!(true);
        });

        widget.device!.connect().then((value) {}).catchError((s) {

          Utils.customPrint('ERROR $s');
          CustomLogger().logWithFile(Level.error, "ERROR $s-> $page");
          widget.device!.state.listen((event) {
            if (event == BluetoothDeviceState.connected) {
          Utils.customPrint('CONNECTION EVENT ${event}');
              CustomLogger().logWithFile(Level.info, "CONNECTION EVENT ${event}-> $page");
              widget.device!.disconnect().then((value) {
                widget.device!.connect().then((value) {
          Utils.customPrint('CONNECTION NAME ${widget.device!.name}');
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

            Utils.customPrint('ERROR CONNECTED 1212');
              CustomLogger().logWithFile(Level.error, "ERROR CONNECTED 1212-> $page");
            }
          });
        });
        CustomLogger().logWithFile(Level.error, "ERROR CONNECTED-> $page");
        CustomLogger().logWithFile(Level.error, "ERROR CONNECTED FIRST-> $page");
        Utils.customPrint('ERROR CONNECTED');
        Utils.customPrint('ERROR CONNECTED FIRST');

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
      title: Text(widget.device!.name),
      subtitle: Text(
        widget.device!.id.toString(),
        style: TextStyle(fontSize: 13),
      ),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: widget.device!.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          // if (snapshot.data ==
          //     BluetoothDeviceState.connected) {
          return isConnect
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ))
              : IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.link_outlined,
                    size: 20,
                    color: Colors.grey,
                  ));
        },
      ),
    );
  }
}
