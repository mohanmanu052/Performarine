import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

class TripAnalyticsScreen extends StatefulWidget {
  Trip? tripList;
  final CreateVessel? vessel;
  final bool? tripIsRunningOrNot;
  TripAnalyticsScreen(
      {Key? key, this.tripList, this.vessel, this.tripIsRunningOrNot})
      : super(key: key);

  @override
  State<TripAnalyticsScreen> createState() => _TripAnalyticsScreenState();
}

class _TripAnalyticsScreenState extends State<TripAnalyticsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  List<CreateVessel> getVesselById = [];
  Trip? tripData;

  bool tripIsRunning = false;

  int tripDistance = 0;
  int tripDuration = 0;
  String tripSpeed = '0.0';

  FlutterBackgroundService service = FlutterBackgroundService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getVesselDataById();
    sharedPreferences!.remove('sp_key_called_from_noti');

    setState(() {
      tripData = widget.tripList;
      tripIsRunning = widget.tripIsRunningOrNot!;
    });

    if (tripIsRunning) {
      getRealTimeTripDetails();
    }
  }

  getRealTimeTripDetails() async {
    service.on('tripAnalyticsData').listen((event) {
      tripDistance = event!['tripDistance'];
      tripDuration = event['tripDuration'];
      tripSpeed = event['tripSpeed'];

      if (mounted) setState(() {});
    });
  }

  getVesselDataById() async {
    getVesselById = await _databaseService
        .getVesselNameByID(widget.tripList!.vesselId.toString());

    debugPrint('VESSEL DATA ${getVesselById[0].name}');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xfff2fffb),
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xfff2fffb),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              // Navigator.of(context).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: 'Trip Id - ${widget.tripList!.id}',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.032,
          ),
          //backgroundColor: Colors.white,
        ),
        body: Container(
          //margin: EdgeInsets.symmetric(horizontal: 17),
          child: Stack(
            children: [
              SizedBox(
                height: displayHeight(context),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      commonText(
                        context: context,
                        text: '${widget.vessel!.name}',
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black87,
                        textSize: displayWidth(context) * 0.045,
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      dashboardRichText(
                          modelName: '${widget.vessel!.model}',
                          builderName: '${widget.vessel!.builderName}',
                          context: context,
                          color: Colors.grey),
                      SizedBox(
                        height: displayHeight(context) * 0.01,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.vessel!.imageURLs == null ||
                                  widget.vessel!.imageURLs!.isEmpty ||
                                  widget.vessel!.imageURLs == 'string'
                              ? Stack(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/images/vessel_default_img.png',
                                        height: displayHeight(context) * 0.22,
                                        width: displayWidth(context),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    /*Image.asset(
                                                      'assets/images/shadow_img.png',
                                                      height: displayHeight(context) * 0.22,
                                                      width: displayWidth(context),
                                                      fit: BoxFit.cover,
                                                    ),*/

                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: Container(
                                          height: displayHeight(context) * 0.14,
                                          width: displayWidth(context),
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 50,
                                                spreadRadius: 5,
                                                offset: const Offset(0, 50))
                                          ]),
                                        ))
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      height: displayHeight(context) * 0.22,
                                      width: displayWidth(context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: FileImage(
                                              File(widget.vessel!.imageURLs!)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: Container(
                                          height: displayHeight(context) * 0.14,
                                          width: displayWidth(context),
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 50,
                                                spreadRadius: 5,
                                                offset: const Offset(0, 50))
                                          ]),
                                        ))
                                  ],
                                )),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: displayHeight(context) / 1.8,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50))),
                    child: Container(
                      margin: EdgeInsets.only(top: 40, left: 17, right: 17),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: displayWidth(context),
                                padding: widget.vessel!.engineType!
                                            .toLowerCase() ==
                                        'combustion'
                                    ? EdgeInsets.symmetric(horizontal: 50)
                                    : widget.vessel!.engineType!
                                                .toLowerCase() ==
                                            'electric'
                                        ? EdgeInsets.symmetric(horizontal: 0)
                                        : EdgeInsets.symmetric(horizontal: 16),
                                //color: Colors.red,
                                child: widget.vessel!.engineType!
                                            .toLowerCase() ==
                                        'combustion'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                  'assets/images/fuel.png',
                                                  width: displayWidth(context) *
                                                      0.04,
                                                  color: Colors.black),
                                              SizedBox(
                                                width: displayWidth(context) *
                                                    0.018,
                                              ),
                                              commonText(
                                                  context: context,
                                                  text:
                                                      '${widget.vessel!.fuelCapacity} gal',
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black,
                                                  textSize:
                                                      displayWidth(context) *
                                                          0.038,
                                                  textAlign: TextAlign.start),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                  widget.vessel!.engineType!
                                                              .toLowerCase() ==
                                                          'hybrid'
                                                      ? 'assets/images/hybrid_engine.png'
                                                      : widget.vessel!
                                                                  .engineType!
                                                                  .toLowerCase() ==
                                                              'electric'
                                                          ? 'assets/images/electric_engine.png'
                                                          : 'assets/images/combustion_engine.png',
                                                  width: displayWidth(context) *
                                                      0.07,
                                                  color: Colors.black),
                                              SizedBox(
                                                width: displayWidth(context) *
                                                    0.02,
                                              ),
                                              Text(
                                                widget.vessel!.engineType!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                    fontSize:
                                                        displayWidth(context) *
                                                            0.038,
                                                    fontFamily: poppins),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : widget.vessel!.engineType!
                                                .toLowerCase() ==
                                            'electric'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      'assets/images/battery.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.04,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                          '${widget.vessel!.batteryCapacity} kw',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: Colors.black,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.038,
                                                      textAlign:
                                                          TextAlign.start),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      widget.vessel!.engineType!
                                                                  .toLowerCase() ==
                                                              'hybrid'
                                                          ? 'assets/images/hybrid_engine.png'
                                                          : widget.vessel!
                                                                      .engineType!
                                                                      .toLowerCase() ==
                                                                  'electric'
                                                              ? 'assets/images/electric_engine.png'
                                                              : 'assets/images/combustion_engine.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.07,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.02,
                                                  ),
                                                  Text(
                                                    widget.vessel!.engineType!,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.038,
                                                        fontFamily: poppins),
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      'assets/images/fuel.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.07,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                          '${widget.vessel!.fuelCapacity} gal',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: Colors.black,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.038,
                                                      textAlign:
                                                          TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      'assets/images/battery.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.045,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.02,
                                                  ),
                                                  commonText(
                                                      context: context,
                                                      text:
                                                          '${widget.vessel!.batteryCapacity} kw',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: Colors.black,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.038,
                                                      textAlign:
                                                          TextAlign.start),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      widget.vessel!.engineType!
                                                                  .toLowerCase() ==
                                                              'hybrid'
                                                          ? 'assets/images/hybrid_engine.png'
                                                          : widget.vessel!
                                                                      .engineType!
                                                                      .toLowerCase() ==
                                                                  'electric'
                                                              ? 'assets/images/electric_engine.png'
                                                              : 'assets/images/combustion_engine.png',
                                                      width: displayWidth(
                                                              context) *
                                                          0.08,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    width:
                                                        displayWidth(context) *
                                                            0.018,
                                                  ),
                                                  Text(
                                                    widget.vessel!.engineType!,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.038,
                                                        fontFamily: poppins),
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.04,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      commonText(
                                          context: context,
                                          text: tripIsRunning
                                              ? Utils.calculateTripDuration(
                                                  (tripDuration / 1000).toInt())
                                              : '${widget.tripList!.time}',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.036,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Time',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                  Container(
                                      width: 1,
                                      height: displayHeight(context) * 0.05,
                                      color: Colors.grey),
                                  Column(
                                    children: [
                                      commonText(
                                          context: context,
                                          text: tripIsRunning
                                              ? '${tripSpeed.toString()} nm/h'
                                              : '${widget.tripList!.speed}',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.036,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Speed',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                  Container(
                                      width: 1,
                                      height: displayHeight(context) * 0.05,
                                      color: Colors.grey),
                                  Column(
                                    children: [
                                      commonText(
                                          context: context,
                                          text: tripIsRunning
                                              ? '${tripDistance.toStringAsFixed(2)} m'
                                              : '${widget.tripList!.distance} m',
                                          fontWeight: FontWeight.w600,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.036,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Distance',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.grey,
                                          textSize:
                                              displayWidth(context) * 0.026,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            left: 10,
                            child: tripIsRunning
                                ? CommonButtons.getActionButton(
                                    title: 'End Trip',
                                    context: context,
                                    fontSize: displayWidth(context) * 0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor: buttonBGColor,
                                    borderColor: buttonBGColor,
                                    width: displayWidth(context),
                                    onTap: () async {
                                      Utils().showEndTripDialog(context,
                                          () async {
                                        CreateTrip().endTrip(
                                            context: context,
                                            scaffoldKey: scaffoldKey,
                                            onEnded: () async {
                                              setState(() {
                                                tripIsRunning = false;
                                              });
                                              Trip tripDetails =
                                                  await _databaseService
                                                      .getTrip(
                                                          widget.tripList!.id!);
                                              setState(() {
                                                widget.tripList = tripDetails;
                                              });
                                              Navigator.pop(context);
                                            });
                                      }, () {
                                        Navigator.pop(context);
                                      });
                                    })
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // SizedBox(height: 50,),
                                      /*SizedBox(
                                          height: 300,
                                          width: 300,
                                          child: Lottie.asset(
                                              'assets/lottie/done.json')),*/
                                      Center(
                                        child: Text(
                                          "Trip Id: ${widget.tripList!.id}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: Text(
                                          "Trip Ended Successfully!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                      ),
                                      Center(
                                        child: Text(
                                          "Do you want to download the trip data?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 50,),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      CommonButtons.getDottedButton(
                                          "Download Trip Data", context,
                                          () async {
                                        final androidInfo =
                                            await DeviceInfoPlugin()
                                                .androidInfo;

                                        var isStoragePermitted =
                                            androidInfo.version.sdkInt > 32
                                                ? await Permission.photos.status
                                                : await Permission
                                                    .storage.status;
                                        if (isStoragePermitted.isGranted) {
                                          //File copiedFile = File('${ourDirectory!.path}.zip');
                                          File copiedFile = File(
                                              '${ourDirectory!.path}/${widget.tripList!.id}.zip');

                                          print(
                                              'DIR PATH R ${ourDirectory!.path}');

                                          Directory directory;

                                          if (Platform.isAndroid) {
                                            directory = Directory(
                                                "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                          } else {
                                            directory =
                                                await getApplicationDocumentsDirectory();
                                          }

                                          copiedFile.copy(directory.path);

                                          print(
                                              'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                          if (copiedFile.existsSync()) {
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                    'File downloaded successfully');
                                          }
                                        } else {
                                          await Utils.getStoragePermission(
                                              context);
                                          var isStoragePermitted =
                                              await Permission.storage.status;

                                          if (isStoragePermitted.isGranted) {
                                            File copiedFile = File(
                                                '${ourDirectory!.path}.zip');

                                            Directory directory;

                                            if (Platform.isAndroid) {
                                              directory = Directory(
                                                  "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                            } else {
                                              directory =
                                                  await getApplicationDocumentsDirectory();
                                            }

                                            copiedFile.copy(directory.path);

                                            print(
                                                'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                            if (copiedFile.existsSync()) {
                                              Utils.showSnackBar(context,
                                                  scaffoldKey: scaffoldKey,
                                                  message:
                                                      'File downloaded successfully');
                                            }
                                          }
                                        }
                                      }, primaryColor),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      CommonButtons.getActionButton(
                                          title: 'Trip Ended',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.042,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: buttonBGColor,
                                          borderColor: buttonBGColor,
                                          width: displayWidth(context),
                                          onTap: () async {
                                            final androidInfo =
                                                await DeviceInfoPlugin()
                                                    .androidInfo;

                                            var isStoragePermitted =
                                                androidInfo.version.sdkInt > 32
                                                    ? await Permission
                                                        .photos.status
                                                    : await Permission
                                                        .storage.status;
                                            if (isStoragePermitted.isGranted) {
                                              //File copiedFile = File('${ourDirectory!.path}.zip');
                                              File copiedFile = File(
                                                  '${ourDirectory!.path}/${widget.tripList!.id}.zip');

                                              print(
                                                  'DIR PATH R ${ourDirectory!.path}');

                                              Directory directory;

                                              if (Platform.isAndroid) {
                                                directory = Directory(
                                                    "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                              } else {
                                                directory =
                                                    await getApplicationDocumentsDirectory();
                                              }

                                              copiedFile.copy(directory.path);

                                              print(
                                                  'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                              if (copiedFile.existsSync()) {
                                                // Utils.showSnackBar(context,
                                                //     scaffoldKey: scaffoldKey,
                                                //     message:
                                                //     'File downloaded successfully');
                                              }
                                            } else {
                                              await Utils.getStoragePermission(
                                                  context);
                                              var isStoragePermitted =
                                                  await Permission
                                                      .storage.status;

                                              if (isStoragePermitted
                                                  .isGranted) {
                                                File copiedFile = File(
                                                    '${ourDirectory!.path}.zip');

                                                Directory directory;

                                                if (Platform.isAndroid) {
                                                  directory = Directory(
                                                      "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                                } else {
                                                  directory =
                                                      await getApplicationDocumentsDirectory();
                                                }

                                                copiedFile.copy(directory.path);

                                                print(
                                                    'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                                if (copiedFile.existsSync()) {
                                                  // Utils.showSnackBar(context,
                                                  //     scaffoldKey: scaffoldKey,
                                                  //     message:
                                                  //     'File downloaded successfully');
                                                }
                                              }
                                            }

                                            // Get.back();

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage()),
                                            );

                                            // getTripId = await getTripIdFromPref();

                                            // File? zipFile;
                                            // if (timer != null) timer!.cancel();
                                            // print(
                                            //     'TIMER STOPPED ${ourDirectory!.path}');
                                            // final dataDir =
                                            // Directory(ourDirectory!.path);
                                            //
                                            // try {
                                            //   zipFile =
                                            //       File('${ourDirectory!.path}.zip');
                                            //
                                            //   ZipFile.createFromDirectory(
                                            //       sourceDir: dataDir,
                                            //       zipFile: zipFile,
                                            //       recurseSubDirs: true);
                                            //   print('our path is $dataDir');
                                            // } catch (e) {
                                            //   print(e);
                                            // }
                                            //
                                            // File file = File(zipFile!.path);
                                            // Future.delayed(Duration(seconds: 1))
                                            //     .then((value) {
                                            //   stateSetter(() {
                                            //     isZipFileCreate = true;
                                            //   });
                                            // });
                                            // print('FINAL PATH: ${file.path}');
                                            // onSave(file);

                                            /*File file = File(zipFile!.path);
                                              Future.delayed(Duration(seconds: 1))
                                                  .then((value) {
                                                stateSetter(() {
                                                  isZipFileCreate = true;
                                                });
                                              });*/
                                          })
                                    ],
                                  ),
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
