import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:performarine/pages/single_lpr_device.dart';

class LPRBluetoothList extends StatefulWidget {
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setDialogSet;
  final String? connectedDeviceId;
  Function(String)? onConnetedCallBack;
        Function(double fuelusage)? callbackFuelUsage;
      Function(double avgValue)? callbackAvgValue;

  final Function(BluetoothDevice)? selectedBluetoothDevice;
  
  String? comingFrom;
  final BluetoothDevice? connectedBluetoothDevice;
  GlobalKey<ScaffoldState>? scafoldKey;
  Function(dynamic)? onErrCallback;

  bool? isStartTripState;
  LPRBluetoothList(
      {Key? key,
      this.callbackAvgValue,
      this.callbackFuelUsage,
        this.dialogContext,
        this.onSelected,
        this.onBluetoothConnection,
        this.connectedDeviceId,
        this.connectedBluetoothDevice,
        this.comingFrom,
        this.scafoldKey,
        this.onConnetedCallBack,
        this.onErrCallback,
        this.isStartTripState,
        this.selectedBluetoothDevice,

        this.setDialogSet})
      : super(key: key);
  @override
  State<LPRBluetoothList> createState() => _LPRBluetoothListState();
}

class _LPRBluetoothListState extends State<LPRBluetoothList> {
  bool isConnectToDevice = false;
bool isRemoteIdDevicesShown=true;

getIsRemoteIdShown()async{
      FlutterSecureStorage storage = FlutterSecureStorage();
    try{
    var data = await storage.read(key: 'enableUnNamedBLEDevices') ;
    isRemoteIdDevicesShown=bool.parse(data??'true');
  
    setState(() {
      
    });
    }catch(err){
    }


}

@override
  void initState() {
    getIsRemoteIdShown();
    // TODO: implement initState
    super.initState();
  }
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
                .map((d) {
             return isRemoteIdDevicesShown?
               SingleLPRDevice(
                isStartTripState: widget.isStartTripState,
                onerrorCallback: widget.onErrCallback,
                scafoldKey: widget.scafoldKey,
              device: d.device,
                                            callbackAvgValue: widget.callbackAvgValue,
                              callbackFuelUsage: widget.callbackFuelUsage,
                            

              onDeviceConnectedCallback: widget.onConnetedCallBack,
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
                setState(() {
                  
                });
              },
                  
    ):d.device.platformName.isNotEmpty?SingleLPRDevice(
      isStartTripState: widget.isStartTripState,
              device: d.device,
                                            callbackAvgValue: widget.callbackAvgValue,
                              callbackFuelUsage: widget.callbackFuelUsage,
                            

              onSelected: widget.onSelected,
                            onDeviceConnectedCallback: widget.onConnetedCallBack,
                            onerrorCallback: widget.onErrCallback,
scafoldKey: widget.scafoldKey,
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
                setState(() {
                  
                });
              },
                  
    ):SizedBox()
    ;
                  
                }
    )
                .toList()
                : [],
          ),
        ),
      ),
    );
  }
}
