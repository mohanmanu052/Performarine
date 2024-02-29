import 'package:flutter/material.dart';
import 'package:performarine/lpr_device_handler.dart';

class LprDataStream extends StatefulWidget {
  const LprDataStream({super.key});

  @override
  State<LprDataStream> createState() => _LprDataStreamState();
}

class _LprDataStreamState extends State<LprDataStream> {
  String Lprdata='No LPR Data Found';
  String? lprTransperntServiceId;
String? lprTransperntServiceIdStatus;
String? lprUartTX;
String? lprUartTxStatus;
String? connectedBluetoothDeviceName;
List<String> datList=[];
  @override
  void initState() {
    //To Listen LPR Streaming Data Updates
    LPRDeviceHandler().listenToDeviceConnectionState(
            callBackLprStreamingData: (lprSteamingData1) {
              datList.add(lprSteamingData1);
              setState(() {

              });
            },
          );
        


    
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LPR Data'),
      
      ),
      body: SafeArea(child: 

    datList.isNotEmpty?  ListView.builder(
      shrinkWrap: true,
        itemCount: datList.length,
        itemBuilder: ((context, index) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text(datList[index]));
      })):Container(
        child: Center(child: Text('No Data Found'),),
      )
      // Container(child: SingleChildScrollView(child: Center(child: Text(Lprdata.toString(),style: TextStyle(color: Colors.black,
      // fontWeight: FontWeight.w500
      // ),))),)
      ),
    );
  }
}