import 'dart:async';
import 'dart:io';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wakelock/wakelock.dart';

import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../main.dart';
import '../../models/trip.dart';
import '../../models/vessel.dart';
import '../../services/database_service.dart';
import '../bottom_navigation.dart';

class TripRecordingAnalyticsScreen extends StatefulWidget {
  final bool? tripIsRunningOrNot;
  final String? vesselId, tripId, calledFrom;
  final bool isAppKilled;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BuildContext? context;

  const TripRecordingAnalyticsScreen(
      {super.key,
      this.scaffoldKey,
      this.tripIsRunningOrNot,
      this.vesselId,
      this.tripId,
      this.isAppKilled = false,
      this.context,
      this.calledFrom = ''});

  @override
  State<TripRecordingAnalyticsScreen> createState() =>
      _TripRecordingAnalyticsScreenState();
}

class _TripRecordingAnalyticsScreenState
    extends State<TripRecordingAnalyticsScreen> {
  final controller = ScreenshotController();

  String tripDistance = '0.00',
      tripDuration = '00:00:00',
      tripSpeed = '0.0',
      tripAvgSpeed = '0.0';

  Trip? tripData;
  CreateVessel? vesselData;

  Timer? durationTimer;

  final DatabaseService _databaseService = DatabaseService();

  bool tripIsRunning = false,
      isuploadTrip = false,
      isTripEnded = false,
      isEndTripBtnClicked = false,
      isDataUpdated = false,
      isLPRReconnectButtonShown=false;

  late CommonProvider commonProvider;

  String? lprTransperntServiceId;
  String? lprTransperntServiceIdStatus;
  String? lprUartTX;
  String? lprUartTxStatus;
  String? connectedBluetoothDeviceName;
  double? avgvalue=0.0;
  double? fuelUsage=0.0;
  String? lprStreamingData = 'No Lpr Streaming Data Found';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();

    setState(() {
      tripIsRunning = widget.tripIsRunningOrNot!;
      getData();
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
      Wakelock.enable();
      if (widget.isAppKilled) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(Duration(milliseconds: 100), () {
            bool isOpened =
                sharedPreferences!.getBool("key_lat_time_dialog_open") ?? false;
            if (!isOpened) {
              showEndTripDialogBox(context);
            }
          });
        });
      }
    }
  }

  getRealTimeTripDetails() async {
    if (mounted) {
      setState(() {
        // getTripDetailsFromNoti = true;
      });
    }

    final currentTrip = await _databaseService.getTrip(widget.tripId!);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    WidgetsFlutterBinding.ensureInitialized();

    await sharedPreferences!.reload();

    durationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      // Utils.customPrint(
      //     '##TDATA updated time delay from 1 sec to 400 MS by abhi');
      tripDistance = sharedPreferences!.getString('tripDistance') ?? "0";
      tripSpeed = sharedPreferences!.getString('tripSpeed') ?? "0.0";
      tripAvgSpeed = sharedPreferences!.getString('tripAvgSpeed') ?? "0.0";

      // Utils.customPrint("TRIP ANALYTICS SPEED $tripSpeed");
      // Utils.customPrint("TRIP ANALYTICS AVG SPEED $tripAvgSpeed");

      var durationTime = DateTime.now().toUtc().difference(createdAtTime);
      tripDuration = Utils.calculateTripDuration(
          ((durationTime.inMilliseconds) ~/ 1000).toInt());

      if (mounted) {
        setState(() {
          // getTripDetailsFromNoti = true;
        });
      }
    });
LPRDeviceHandler().isListeningStartTripState=false;
                                      LPRDeviceHandler().setDeviceConnectCallBack((){
if(mounted){
  connectedBluetoothDeviceName='Connected to ${LPRDeviceHandler().connectedDevice?.localName}';
setState(() {
    
  });
}});

                                      LPRDeviceHandler().setDeviceDisconnectCallback((){

                                        connectedBluetoothDeviceName='Re-Connect LPR';
if(mounted){
  setState(() {
    
  });
}});


    LPRDeviceHandler().listenToDeviceConnectionState(
    //  isListeningStartTripState: false,
    
      callBackLprTanspernetserviecId:
          (String lprTransperntServiceId1, String lprUartTX1) {
        lprTransperntServiceId = lprTransperntServiceId1;
        lprUartTX = lprUartTX1;
      },
      callBackconnectedDeviceName: (bluetoothDeviceName1) {
        connectedBluetoothDeviceName ='Connected to $bluetoothDeviceName1';
        setState(() {
          
        });
      },
      callBackLprTanspernetserviecIdStatus: (String status) {
        lprTransperntServiceIdStatus = status;
      },
      callBackLprUartTxStatus: (status) {
        lprUartTxStatus = status;
      },
      callBackLprStreamingData: (lprSteamingData1) {
        lprStreamingData = lprSteamingData1;
      },

      callbackAvgValue: (avgValue) {
        avgvalue=avgValue;
        
      },callbackFuelUsage: (fuelusage) {
        fuelUsage=fuelusage;
        
      },
      
    );

  }

  getData() async {
    final DatabaseService _databaseService = DatabaseService();
    final tripDetails = await _databaseService.getTrip(widget.tripId!);

    List<CreateVessel> vesselDetails =
        await _databaseService.getVesselNameByID(widget.vesselId!);
   var sharePref=await   Utils.initSharedPreferences();
isLPRReconnectButtonShown=sharePref.getBool('onStartTripLPRDeviceConnected')??false;

    setState(() {
      tripData = tripDetails;
      vesselData = vesselDetails[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Screenshot(
      controller: controller,
      child: Container(
        margin: EdgeInsets.only(left: 17, right: 17, top: 0, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: displayHeight(context) * 0.05,
                ),
                Container(
                  width: displayWidth(context),
                  height: displayHeight(context) * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffECF3F9)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10),
                    child: 
                    LPRDeviceHandler().connectedDevice?.isConnected??false?
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
fit: FlexFit.tight,
                          flex: 1,
                          
                          child: commonText(
                            context: context,
                            text: 'Fuel\n Usage',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                        ),
                        SizedBox(
                          width: displayWidth(context) * 0.01,
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.11,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: displayWidth(context)*0.18,
                                    child: commonText(
                                      context: context,
                                      text: fuelUsage.toString(),
                                      fontWeight: FontWeight.w700,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: displayWidth(context) * 0.03,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          commonText(
                                            context: context,
                                            text: '\dL/h',
                                            fontWeight: FontWeight.w700,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.055,
                                          ),
                                          Icon(
                                          fuelUsage!>avgvalue!?Icons.arrow_upward_outlined:fuelUsage!<avgvalue!?  Icons.arrow_downward_outlined:Icons.horizontal_rule_outlined,
                                            color: fuelUsage!>avgvalue!?Colors.red:fuelUsage!<avgvalue!? Colors.green:Colors.black,
                                            size: displayHeight(context) * 0.04,
                                          )
                                        ],
                                      ),
                                      commonText(
                                      
                                        context: context,
                                        text: 'Per hour',
                                        fontWeight: FontWeight.w400,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.03,
                                        textAlign: TextAlign.left
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.002,
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Image.asset(
                            'assets/icons/fuel_cost_img.png',
                            height: displayHeight(context) * 0.05,
                            width: displayWidth(context)*0.3,
                          ),
                        ),
                      ],
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                                                Flexible(
fit: FlexFit.tight,
                          flex: 1,
                          
                          child: commonText(
                            context: context,
                            text: 'Fuel\n Usage',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                        ),

Flexible(
  flex: 3,
fit: FlexFit.tight,
  child: commonText(
    text: "No Data",
    textSize: 18,
    fontWeight: FontWeight.bold
  
  ),
),
Flexible(
  flex: 2,
  fit: FlexFit.tight,
  child: Image.asset(
                              'assets/icons/fuel_cost_img.png',
                              height: displayHeight(context) * 0.05,
                              width: displayWidth(context)*0.3,
                            ),
),
                        
                      ]
                      
                    )
                   )
                ),
                SizedBox(
                  height: displayHeight(context) * 0.015,
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: displayWidth(context) * 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffECF3F9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonText(
                            context: context,
                            text: 'Distance',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          Text(
                            tripDistance,
                            style: TextStyle(
                              fontSize: displayWidth(context) * 0.06,
                              fontFamily: outfit,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          commonText(
                            context: context,
                            text: 'Nautical Miles',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: displayWidth(context) * 0.03,
                    ),
                    Container(
                      width: displayWidth(context) * 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffECF3F9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonText(
                            context: context,
                            text: 'Current Speed',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          Text(
                            tripSpeed,
                            style: TextStyle(
                              fontSize: displayWidth(context) * 0.06,
                              fontFamily: outfit,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),

                          /*commonText(
                            context: context,
                            text: tripSpeed,
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.06,
                          ),*/

                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          commonText(
                            context: context,
                            text: speedKnot,
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: displayHeight(context) * 0.015,
                ),
                Row(
                  children: [
                    Container(
                      width: displayWidth(context) * 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffECF3F9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonText(
                            context: context,
                            text: 'Total Time',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          Text(
                            tripDuration,
                            style: TextStyle(
                              fontSize: displayWidth(context) * 0.06,
                              fontFamily: outfit,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),

                          /* commonText(
                            context: context,
                            text: tripDuration,
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.06,
                          ),*/

                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          commonText(
                            context: context,
                            text: 'hh:mm:ss',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: displayWidth(context) * 0.03,
                    ),
                    Container(
                      width: displayWidth(context) * 0.43,
                      height: displayHeight(context) * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffECF3F9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonText(
                            context: context,
                            text: 'CO2 Emission',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          commonText(
                            context: context,
                            text: '6.3',
                            fontWeight: FontWeight.w700,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.06,
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.005,
                          ),
                          commonText(
                            context: context,
                            text: 'Kgs',
                            fontWeight: FontWeight.w400,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

SizedBox(height: 20,),

Visibility(
  visible: isLPRReconnectButtonShown,
  child: 
  
  
  CommonButtons.getAcceptButton(connectedBluetoothDeviceName??'Re-Connect LPR', context, 
  borderRadius: 15,
  fontWeight: FontWeight.w400,
  blueColor, (){
if(LPRDeviceHandler().
          connectedDevice!=null&& LPRDeviceHandler().
          connectedDevice!.isConnected){
                                  Fluttertoast.showToast(
                                      msg:
                                          "Device already connected to ${LPRDeviceHandler().connectedDevice?.localName}",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);


          }else{
    LPRDeviceHandler().showBluetoothListDialog(context, null, null,isTripNavigate: false,
    isStartTripState: false,
    callbackAvgValue: (avgValue) {
      avgvalue=avgValue;
    },callbackFuelUsage: (fuelusage) {
      fuelUsage=fuelusage;
    },

    callbackConnectedDeviceName: (){




    });
          }
  }, displayWidth(context) / 1.6, displayHeight(context) * 0.065, backgroundColor, connectedBluetoothDeviceName!=null&&connectedBluetoothDeviceName!.isNotEmpty&&connectedBluetoothDeviceName!='Re-Connect LPR'?Colors.black:Colors.white, 14,connectedBluetoothDeviceName!=null&&connectedBluetoothDeviceName!.isNotEmpty&&connectedBluetoothDeviceName!='Re-Connect LPR'?Colors.white: blueColor, '')
  
  
  )

              ],
            ),
            Column(
              children: [
                isTripEnded
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(blueColor),
                      ))
                    : CommonButtons.getRichTextActionButton(
                        icon: Image.asset(
                          'assets/icons/end_btn.png',
                          height: displayHeight(context) * 0.05,
                          width: displayWidth(context) * 0.1,
                        ),
                        title: 'Stop Trip',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: endTripBtnColor,
                        borderColor: endTripBtnColor,
                        width: displayWidth(context),
                        onTap: () async {

                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);

                          Utils.customPrint(
                              "END TRIP CURRENT TIME ${DateTime.now()}");

                          bool isSmallTrip = Utils()
                              .checkIfTripDurationIsGraterThan10Seconds(
                                  tripDuration.split(":"));

                          Utils.customPrint(
                              "SMALL TRIPP IDDD bool$isSmallTrip");

                          if (!isSmallTrip) {
                            Utils().showDeleteTripDialog(context,
                                endTripBtnClick: () {
                                  LPRDeviceHandler().isSilentDiscoonect=true;
                              endTrip(isTripDeleted: true);

                              Utils.customPrint(
                                  "SMALL TRIPP IDDD ${tripData!.id!}");

                              int value = Platform.isAndroid ? 1 : 0;

                              Future.delayed(Duration(seconds: value), () {
                                if (!isSmallTrip) {
                                  Utils.customPrint(
                                      "SMALL TRIPP IDDD ${tripData!.id!}");
                                  DatabaseService()
                                      .deleteTripFromDB(tripData!.id!);

                                  if (widget.calledFrom == 'bottom_nav') {
                                    Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()),
                                            ModalRoute.withName(""))
                                        .then((value) => SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                            ]));
                                    ;
                                  } else if (widget.calledFrom ==
                                      'VesselSingleView') {
                                    Navigator.of(context).pop(true);
                                  } else if (widget.calledFrom == 'tripList') {
                                    Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation(
                                                      tabIndex: commonProvider
                                                          .bottomNavIndex,
                                                    )),
                                            ModalRoute.withName(""))
                                        .then((value) => SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                            ]));
                                    ;
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()),
                                            ModalRoute.withName(""))
                                        .then((value) => SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                            ]));
                                    ;
                                  }
                                }
                              });
                            }, onCancelClick: () {
                              Navigator.pop(context);
                            });
                          } else {
                            Utils().showEndTripDialog(context, () async {
                              endTrip();
                            }, () {
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
                SizedBox(
                  height: displayHeight(context) * 0.04,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  endTrip({bool isTripDeleted = false}) {
    if (durationTimer != null) {
      durationTimer!.cancel();
    }

    setState(() {
      isTripEnded = true;
    });

    Navigator.pop(context);

    Utils.customPrint("TRIP DURATION WHILE END TRIP $tripDuration");

    EndTrip().endTrip(
        context: context,
        scaffoldKey: widget.scaffoldKey,
        duration: tripDuration,
        IOSAvgSpeed: tripAvgSpeed,
        IOSpeed: tripSpeed,
        IOStripDistance: tripDistance,
        onEnded: () async {
          if (mounted) {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);

            setState(() {
              tripIsRunning = false;
              isTripEnded = false;
            });
          }

          if (!isTripDeleted) {
            Trip tripDetails = await _databaseService.getTrip(tripData!.id!);

            setState(() {
              tripData = tripDetails;
            });
          }

          isDataUpdated = true;

          if (!isTripDeleted) {
            if (widget.calledFrom == 'bottom_nav') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewTripAnalyticsScreen(
                            tripId: tripData?.id,
                            //tripData: tripData,
                            vesselId: tripData?.vesselId,
                            calledFrom: 'End Trip',
                          )));

              //         Navigator.pushAndRemoveUntil(
              //             context,
              //             MaterialPageRoute(builder: (context) => BottomNavigation()),
              //             ModalRoute.withName("")).then((value) =>                                         SystemChrome.setPreferredOrientations([
              // DeviceOrientation.portraitUp,])
              // );;
            } else if (widget.calledFrom == 'VesselSingleView') {
              Navigator.of(context).pop(true);
            } else if (widget.calledFrom == 'tripList') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewTripAnalyticsScreen(
                            tripId: tripData?.id,
                            //tripData: tripData,
                            vesselId: tripData?.vesselId,
                            calledFrom: 'End Trip',
                          )));

              //         Navigator.pushAndRemoveUntil(
              //             context,
              //             MaterialPageRoute(builder: (context) => BottomNavigation(
              //               tabIndex: commonProvider.bottomNavIndex,
              //             )),
              //             ModalRoute.withName("")).then((value) =>                                         SystemChrome.setPreferredOrientations([
              // DeviceOrientation.portraitUp,])
              // );;
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewTripAnalyticsScreen(
                            tripId: tripData?.id,
                            //tripData: tripData,
                            vesselId: tripData?.vesselId,
                            calledFrom: 'End Trip',
                          )));

              //         Navigator.pushAndRemoveUntil(
              //             context,
              //             MaterialPageRoute(builder: (context) => BottomNavigation()),
              //             ModalRoute.withName("")).then((value) =>                                         SystemChrome.setPreferredOrientations([
              // DeviceOrientation.portraitUp,])
              // );;
            }
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  showEndTripDialogBox(BuildContext context) {
    if (sharedPreferences != null) {
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              //color: Color(0xfff2fffb),
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(context) * 0.1,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text: lastTimeUsedText,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: isEndTripBtnClicked
                                    ? CircularProgressIndicator(
                                        color: blueColor,
                                      )
                                    : CommonButtons.getAcceptButton(
                                        'End Trip', context, Colors.transparent,
                                        () async {

                                          await SystemChrome.setPreferredOrientations([
                                            DeviceOrientation.portraitUp,
                                          ]);

                                          Utils.customPrint(
                                              "END TRIP CURRENT TIME ${DateTime.now()}");

                                          bool isSmallTrip = Utils()
                                              .checkIfTripDurationIsGraterThan10Seconds(
                                              tripDuration.split(":"));

                                          Utils.customPrint(
                                              "SMALL TRIPP IDDD bool$isSmallTrip");

                                          if (!isSmallTrip) {
                                            Utils().showDeleteTripDialog(context,
                                                endTripBtnClick: () {
                                                  endTrip(isTripDeleted: true);

                                                  Utils.customPrint(
                                                      "SMALL TRIPP IDDD ${tripData!.id!}");

                                                  int value = Platform.isAndroid ? 1 : 0;

                                                  Future.delayed(Duration(seconds: value), () {
                                                    if (!isSmallTrip) {
                                                      Utils.customPrint(
                                                          "SMALL TRIPP IDDD ${tripData!.id!}");
                                                      DatabaseService()
                                                          .deleteTripFromDB(tripData!.id!);

                                                      if (widget.calledFrom == 'bottom_nav') {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BottomNavigation()),
                                                            ModalRoute.withName(""))
                                                            .then((value) => SystemChrome
                                                            .setPreferredOrientations([
                                                          DeviceOrientation.portraitUp,
                                                        ]));
                                                        ;
                                                      } else if (widget.calledFrom ==
                                                          'VesselSingleView') {
                                                        Navigator.of(context).pop(true);
                                                      } else if (widget.calledFrom == 'tripList') {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BottomNavigation(
                                                                      tabIndex: commonProvider
                                                                          .bottomNavIndex,
                                                                    )),
                                                            ModalRoute.withName(""))
                                                            .then((value) => SystemChrome
                                                            .setPreferredOrientations([
                                                          DeviceOrientation.portraitUp,
                                                        ]));
                                                        ;
                                                      } else {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BottomNavigation()),
                                                            ModalRoute.withName(""))
                                                            .then((value) => SystemChrome
                                                            .setPreferredOrientations([
                                                          DeviceOrientation.portraitUp,
                                                        ]));
                                                        ;
                                                      }
                                                    }
                                                  });
                                                }, onCancelClick: () {
                                                  Navigator.pop(context);
                                                });
                                          } else {
                                            endTrip();
                                          }
                                        },
                                        displayWidth(context) * 0.65,
                                        displayHeight(context) * 0.054,
                                        primaryColor,
                                        Colors.white,
                                        displayHeight(context) * 0.02,
                                        endTripBtnColor,
                                        '',
                                        fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Continue Trip',
                                    context,
                                    Colors.transparent, () async {
                                  bool? runningTrip = sharedPreferences!
                                      .getBool("trip_started");

                                  final _isRunning = await BackgroundLocator();

                                  Utils.customPrint(
                                      'INTRO TRIP IS RUNNING 1212 $_isRunning');

                                  List<String>? tripData = sharedPreferences!
                                      .getStringList('trip_data');

                                  reInitializeService();

                                  StartTrip().startBGLocatorTrip(
                                      tripData![0], DateTime.now(), true);

                                  final isRunning2 = await BackgroundLocator
                                      .isServiceRunning();

                                  Utils.customPrint(
                                      'INTRO TRIP IS RUNNING 22222 $isRunning2');
                                  Navigator.of(context).pop();
                                  /*Navigator.push(
                                            dialogContext,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TripRecordingScreen(
                                                      //bottomNavIndex: _bottomNavIndex,
                                                        tripId: tripData[0],
                                                        vesselId: tripData![1],
                                                        vesselName: tripData[2],
                                                        tripIsRunningOrNot:
                                                            runningTrip)));*/
                                },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    Colors.transparent,
                                    blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.transparent,
                                    '',
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) {});
  }

  /// Reinitialized service after user killed app while trip is running
  reInitializeService() async {
    await BackgroundLocator.initialize();

    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 1,
            distanceFilter: 0,
            //client: bglas.LocationClient.android,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Trip is in progress',
                notificationMsg: '',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}
