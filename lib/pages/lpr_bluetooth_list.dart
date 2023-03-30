import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/gen/flutterblueplus.pbjson.dart';

class LPRBluetoothList extends StatefulWidget {
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  LPRBluetoothList(
      {Key? key,
      this.dialogContext,
      this.onSelected,
      this.onBluetoothConnection})
      : super(key: key);
  @override
  State<LPRBluetoothList> createState() => _LPRBluetoothListState();
}

class _LPRBluetoothListState extends State<LPRBluetoothList> {
bool isConnect = false;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.instance.scanResults,
        initialData: const [],
        builder: (c, snapshot) =>
            Column(
          children: snapshot.data != null
              ? snapshot.data!
                  .map((d) => GestureDetector(
                        onTap: () async{
                         var connectedD = d.device.connect(autoConnect: true).then((value) {
                           setState(() {
                             isConnect = true;
                             widget.onBluetoothConnection!(true);
                             widget.onSelected!(d.device.name);
                           });
                           //debugger();
                            Navigator.pop(widget.dialogContext!);
                          }).catchError((s) {
                            print('ERROR $s');
                           print('CONNECTION ${d.device.state.isBroadcast}');
                            d.device.state.listen((event) {
                              if (event == BluetoothDeviceState.connected) {
                                print('CONNECTION EVENT ${event}');
                                d.device.disconnect().then((value) {
                                  d.device.connect().then((value) {
                                    print('CONNECTION NAME ${d.device.name}');
                                    widget.onSelected!(d.device.name);
                                    widget.onBluetoothConnection!(true);
                                    Navigator.pop(
                                      widget.dialogContext!,
                                    );

                                    FlutterBluePlus.instance.stopScan();
                                  });

                                  //widget.onBluetoothConnection!(false);
                                });
                              }
                            });
                          });
                          print('ERROR CONNECTED${connectedD}');
                        },
                        child: ListTile(
                          title: Text(d.device.name),
                          subtitle: Text(
                            d.device.id.toString(),
                            style: TextStyle(fontSize: 13),
                          ),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.device.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              // if (snapshot.data ==
                              //     BluetoothDeviceState.connected) {
                              return isConnect ==
                                      true
                                  ? IconButton(
                                      onPressed: () {
                                        print("tapped on icon");
                                      },
                                      icon: Icon(
                                        Icons.check_circle_outline,
                                        size: 20,
                                        color: Colors.blue,
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
                        ),
                      ))
                  .toList()
              : [],
        ),
      ),
    );
  }
}
