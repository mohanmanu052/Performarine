import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import '../common_widgets/widgets/log_level.dart';

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

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

  }

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
          loggE.e('ERROR $s -> $page ${DateTime.now()}');
          loggE.e('ERROR $s -> $page ${DateTime.now()}');
          widget.device!.state.listen((event) {
            if (event == BluetoothDeviceState.connected) {
              print('CONNECTION EVENT ${event}');
              loggD.d('CONNECTION EVENT ${event} -> $page ${DateTime.now()}');
              loggV.v('CONNECTION EVENT ${event} -> $page ${DateTime.now()}');
              widget.device!.disconnect().then((value) {
                widget.device!.connect().then((value) {
                  print('CONNECTION NAME ${widget.device!.name}');
                  loggD.d('CONNECTION NAME ${widget.device!.name} -> $page ${DateTime.now()}');
                  loggV.v('CONNECTION NAME ${widget.device!.name} -> $page ${DateTime.now()}');
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
              loggE.e('ERROR CONNECTED 1212 -> $page ${DateTime.now()}');
              loggV.v('ERROR CONNECTED 1212 -> $page ${DateTime.now()}');
            }
          });
        });
        print('ERROR CONNECTED');
        print('ERROR CONNECTED FIRST');

        loggE.e('ERROR CONNECTED -> $page ${DateTime.now()}');
        loggE.e('ERROR CONNECTED FIRST -> $page ${DateTime.now()}');

        loggV.v('ERROR CONNECTED -> $page ${DateTime.now()}');
        loggV.v('ERROR CONNECTED FIRST -> $page ${DateTime.now()}');

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
