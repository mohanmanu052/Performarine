import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class LPRBluetoothList extends StatefulWidget {
   LPRBluetoothList({Key? key}) : super(key: key);
  @override
  State<LPRBluetoothList> createState() => _LPRBluetoothListState();
}

class _LPRBluetoothListState extends State<LPRBluetoothList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<List<BluetoothDevice>>(
        stream: Stream.periodic(const Duration(seconds: 1))
            .asyncMap((_) => FlutterBluePlus.instance.bondedDevices),
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: snapshot.data!
              .map((d) => ListTile(
            title: Text(d.name),
            subtitle: Text(d.id.toString(),style: TextStyle(fontSize: 13),),
            trailing: StreamBuilder<BluetoothDeviceState>(
              stream: d.state,
              initialData: BluetoothDeviceState.disconnected,
              builder: (c, snapshot) {
                // if (snapshot.data ==
                //     BluetoothDeviceState.connected) {
                  return snapshot.data ==
                      BluetoothDeviceState.connected ? IconButton(
                      onPressed: (){
                        print("tapped on icon");
                      }, icon: Icon(Icons.check_circle_outline,size: 20,color: Colors.blue,)) :
                  IconButton(
                      onPressed: (){
                        d.connect(autoConnect: true);
                        print("The state is${d.state}");
                        print("tapped on icon");
                        Navigator.pop(context);
                      }, icon: Icon(Icons.link_outlined,size: 20,color: Colors.grey,));
              },
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
