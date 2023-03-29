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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<BluetoothDevice>>(
        stream: Stream.periodic(const Duration(seconds: 1))
            .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: snapshot.data != null
              ? snapshot.data!
                  .map((d) => GestureDetector(
                        onTap: () {
                          var connectedD = d.connect().then((value) {
                            //Navigator.pop(widget.dialogContext!);
                          }).catchError((s) {
                            print('ERROR $s');
                            print('CONNECTION ${d.state.isBroadcast}');
                            d.state.listen((event) {
                              if (event == BluetoothDeviceState.connected) {
                                print('CONNECTION EVENT ${event}');
                                d.disconnect().then((value) {
                                  d.connect().then((value) {
                                    print('CONNECTION NAME ${d.name}');
                                    widget.onSelected!(d.name);
                                    widget.onBluetoothConnection!(true);
                                    Navigator.pop(
                                      widget.dialogContext!,
                                    );

                                    FlutterBluePlus.instance.stopScan();
                                  });

                                  widget.onBluetoothConnection!(false);
                                });
                              }
                            });
                          });
                          print('ERROR CONNECTED${connectedD}');
                        },
                        child: ListTile(
                          title: Text(d.name),
                          subtitle: Text(
                            d.id.toString(),
                            style: TextStyle(fontSize: 13),
                          ),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              // if (snapshot.data ==
                              //     BluetoothDeviceState.connected) {
                              return snapshot.data ==
                                      FlutterBluePlus.instance.connectedDevices
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
