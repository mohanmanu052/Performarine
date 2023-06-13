import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        widget.setSetter!(() {
          isConnect = true;
          widget.onSingleDeviceTapped!(true);
        });

        widget.device!.connect().then((value) {}).catchError((s) {
          print('ERROR $s');
          widget.device!.state.listen((event) {
            if (event == BluetoothDeviceState.connected) {
              print('CONNECTION EVENT ${event}');
              widget.device!.disconnect().then((value) {
                widget.device!.connect().then((value) {
                  print('CONNECTION NAME ${widget.device!.name}');
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
              print('ERROR CONNECTED 1212');
            }
          });
        });
        print('ERROR CONNECTED');
        print('ERROR CONNECTED FIRST');

        widget.setSetter!(() {
          widget.onBluetoothConnection!(true);
          widget.onSelected!(
              widget.device!.name == null || widget.device!.name.isEmpty
                  ? widget.device!.id.toString()
                  : widget.device!.name);
        });
        //debugger();

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
