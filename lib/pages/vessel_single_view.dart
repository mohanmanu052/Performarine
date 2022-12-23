import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/trip_builder.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/expansionCard.dart';
import 'package:performarine/common_widgets/widgets/status_tag.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/new_screen.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip/trip_list_screen.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/pages/tripStart.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';

class VesselSingleView extends StatefulWidget {
  CreateVessel? vessel;

  VesselSingleView({this.vessel});
  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {
  List<CreateVessel>? vessel = [];
  final DatabaseService _databaseService = DatabaseService();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // Directory? ourDirectory;
  bool isStartButton = false,
      isEndTripButton = false,
      isZipFileCreate = false,
      isSensorDataUploaded = false;

  // Timer? timer;
  String fileName = '';
  int fileIndex = 1;
  String? latitude, longitude;
  String getTripId = '';
  var uuid = Uuid();

  double progress = 1.0;
  double deviceProgress = 1.0;
  double sensorProgress = 1.0;

  double progressBegin = 0.0;
  double deviceProgressBegin = 0.0;
  double sensorProgressBegin = 0.0;

  String selectedVesselWeight = 'Select Current Load';

  bool isServiceRunning = false;
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<List<Trip>> getTripListByVesselId(String id) async {
    return await _databaseService.getAllTripsByVesselId(id);
  }

  getIfServiceIsRunning() async {
    bool data = await service.isRunning();
    print('IS SERVICE RUNNING: $data');
    setState(() {
      isServiceRunning = data;
    });
  }

  DeviceInfo? deviceDetails;

  //final DatabaseService _databaseService = DatabaseService();
  fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo;
    }
  }

  fetchDeviceData() async {
    await fetchDeviceInfo();
    // Platform.isAndroid
    //     ? androidDeviceInfo = await fetchDeviceInfo()!.androidDeviceData
    //     : iosDeviceInfo = await fetchDeviceInfo()!.androidDeviceData;
    deviceDetails = Platform.isAndroid
        ? DeviceInfo(
            board: androidDeviceInfo?.board,
            deviceId: androidDeviceInfo?.id,
            deviceType: androidDeviceInfo?.type,
            make: androidDeviceInfo?.manufacturer,
            model: androidDeviceInfo?.model,
            version: androidDeviceInfo?.version.release)
        : DeviceInfo(
            board: iosDeviceInfo?.utsname.machine,
            deviceId: '',
            deviceType: iosDeviceInfo?.utsname.machine,
            make: iosDeviceInfo?.utsname.machine,
            model: iosDeviceInfo?.model,
            version: iosDeviceInfo?.utsname.release);
    debugPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }

  Future<List<Trip>> _getTripsByID(String id) async {
    return await _databaseService.getAllTripsByVesselId(id);
  }

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  Future<void> _onDeleteTripsByVesselID(String vesselId) async {
    await _databaseService.deleteTripBasedOnVesselId(vesselId);
    setState(() {});
  }

  bool isBottomSheetOpened = false, isDataUpdated = false;

  late Future<List<Trip>> getTripsByIdFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('VESSEL SINGLE WEIGHT ${widget.vessel!.weight}');

    getTripsByIdFuture =
        _databaseService.getAllTripsByVesselId(widget.vessel!.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    // isEndTripButton?writeSensorDataToFile(getTripId):null;
    return WillPopScope(
      onWillPop: () async {
        if (isBottomSheetOpened) {
          // Navigator.pop(context);
          return false;
        } else {
          if (isDataUpdated) {
            Navigator.of(context).pop(true);
            return false;
          } else {
            Navigator.of(context).pop(false);
            return false;
          }
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "${widget.vessel!.name}",
              style: TextStyle(color: Colors.black),
            ),
            leading: IconButton(
              onPressed: () {
                if (isDataUpdated) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            )),
        body: Stack(
          children: [
            SizedBox(
              height: displayHeight(context),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // your widgets,
                    // Container(height: 900,color: Colors.red,),
                    ExpansionCard(
                        scaffoldKey,
                        widget.vessel,
                        (value) async {
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VesselFormPage(
                                vessel: widget.vessel,
                              ),
                              fullscreenDialog: true,
                            ),
                          );*/

                          var result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddNewVesselScreen(
                                isEdit: true,
                                createVessel: widget.vessel,
                              ),
                              fullscreenDialog: true,
                            ),
                          );

                          if (result != null) {
                            print('RESULT 1 ${result[0]}');
                            print('RESULT 1 ${result[1] as CreateVessel}');
                            setState(() {
                              widget.vessel = result[1] as CreateVessel?;
                              isDataUpdated = result[0];
                            });
                          }
                        },
                        (value) {},
                        (value) {
                          _onDeleteTripsByVesselID(value.id!);
                          _onVesselDelete(value);
                        },
                        false),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: ExpansionTile(
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        title: Text(
                          "Trip History:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: TripViewListing(future: getTripsByIdFuture),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
                child: CommonButtons.getActionButton(
                    title: 'Start Trip',
                    context: context,
                    fontSize: displayWidth(context) * 0.042,
                    textColor: Colors.white,
                    buttonPrimaryColor: buttonBGColor,
                    borderColor: buttonBGColor,
                    width: displayWidth(context),
                    onTap: () async {
                      /* Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => NewScreen(),
                      ));*/

                      bool tripIsRunning =
                          await _databaseService.tripIsRunning();
                      print('Trip is Running $tripIsRunning');

                      if (tripIsRunning) {
                        Utils.showSnackBar(
                          context,
                          scaffoldKey: scaffoldKey,
                          message: 'Already Trip Running',
                          duration: 3,
                        );
                        return;
                      }

                      /// Working Code
                      vessel!.add(widget.vessel!);
                      await locationPermissions(widget.vessel!.vesselSize!,
                          widget.vessel!.name!, widget.vessel!.id!);

                      /// ###

                      /*_streamSubscriptions.add(
                        accelerometerEvents.listen(
                          (AccelerometerEvent event) {
                            if (mounted) {
                              setState(() {
                                _accelerometerValues = <double>[
                                  event.x,
                                  event.y,
                                  event.z
                                ];
                              });
                            }
                          },
                        ),
                      );
                      _streamSubscriptions.add(
                        gyroscopeEvents.listen(
                          (GyroscopeEvent event) {
                            if (mounted) {
                              setState(() {
                                _gyroscopeValues = <double>[
                                  event.x,
                                  event.y,
                                  event.z
                                ];
                              });
                            }
                          },
                        ),
                      );
                      _streamSubscriptions.add(
                        userAccelerometerEvents.listen(
                          (UserAccelerometerEvent event) {
                            if (mounted) {
                              setState(() {
                                _userAccelerometerValues = <double>[
                                  event.x,
                                  event.y,
                                  event.z
                                ];
                              });
                            }
                          },
                        ),
                      );
                      _streamSubscriptions.add(
                        magnetometerEvents.listen(
                          (MagnetometerEvent event) {
                            if (mounted) {
                              setState(() {
                                _magnetometerValues = <double>[
                                  event.x,
                                  event.y,
                                  event.z
                                ];
                              });
                            }
                          },
                        ),
                      );*/
                    }),
              ),
            )
          ],
        ),
        // SingleChildScrollView(
        //   child: Column(
        //     // physics: const BouncingScrollPhysics(),
        //     children: <Widget>[
        //       ExpansionCard(
        //           widget.vessel, (value) {}, (value) {}, (value) {}, false),

        //       Container(
        //         height: 200,
        //         width: MediaQuery.of(context).size.width,
        //         child: TripBuilder(
        //           future: _getTripsByID(widget.vessel!.id.toString()),
        //         ),
        //       ),
        //
        //
        //     ],
        //   ),
        // ),
        /*bottomNavigationBar: Container(
          margin: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
          child: CommonButtons.getActionButton(
              title: 'Start Trip',
              context: context,
              fontSize: displayWidth(context) * 0.042,
              textColor: Colors.white,
              buttonPrimaryColor: buttonBGColor,
              borderColor: buttonBGColor,
              width: displayWidth(context),
              onTap: () async {
                vessel!.add(widget.vessel!);

                // print(vessel[0].vesselName);
                */ /*Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    StartTrip(vessels: vessel, context: context),
                                fullscreenDialog: true,
                              ),
                            );*/ /*

                //ToDo: @rupali: enable the start trip by adding the below code.and add the expansion tile like vessel card for trip history also.
                // locationPermissions(widget.vesselSize!, widget.vesselName!,
                //     widget.vesselId!);

                */ /*Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TripListScreen(
                      vesselId: widget.vessel!.id,
                      vesselName: widget.vessel!.name,
                      vesselSize: widget.vessel!.vesselSize,
                    ),
                    fullscreenDialog: true,
                  ),
                );*/ /*

                locationPermissions(widget.vessel!.vesselSize!,
                    widget.vessel!.name!, widget.vessel!.id!);
                // getLocationData();

                // getBottomSheet(
                //   context,
                //   size,
                //   widget.vesselName!,
                //   widget.vesselId!,
                // );
                _streamSubscriptions.add(
                  accelerometerEvents.listen(
                    (AccelerometerEvent event) {
                      setState(() {
                        _accelerometerValues = <double>[
                          event.x,
                          event.y,
                          event.z
                        ];
                      });
                    },
                  ),
                );
                _streamSubscriptions.add(
                  gyroscopeEvents.listen(
                    (GyroscopeEvent event) {
                      setState(() {
                        _gyroscopeValues = <double>[event.x, event.y, event.z];
                      });
                    },
                  ),
                );
                _streamSubscriptions.add(
                  userAccelerometerEvents.listen(
                    (UserAccelerometerEvent event) {
                      setState(() {
                        _userAccelerometerValues = <double>[
                          event.x,
                          event.y,
                          event.z
                        ];
                      });
                    },
                  ),
                );
                _streamSubscriptions.add(
                  magnetometerEvents.listen(
                    (MagnetometerEvent event) {
                      setState(() {
                        _magnetometerValues = <double>[event.x, event.y, event.z];
                      });
                    },
                  ),
                );
              }),
        ),*/
      ),
    );
  }

  locationPermissions(dynamic size, String vesselName, String weight) async {
    if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.location.isGranted;
      if (isLocationPermitted) {
        getBottomSheet(context, size, vesselName, weight, isLocationPermitted);
      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.location.isGranted;
        getBottomSheet(context, size, vesselName, weight, isLocationPermitted);
      }
    }
  }

  getBottomSheet(BuildContext context, dynamic size, String vesselName,
      String weight, bool isLocationPermission) async {
    isStartButton = false;
    isEndTripButton = false;
    isSensorDataUploaded = false;
    isZipFileCreate = false;
    isBottomSheetOpened = true;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    // initializeService();

    scaffoldKey.currentState!.showBottomSheet(
      (context) {
        return StatefulBuilder(builder:
            (BuildContext bottomSheetContext, StateSetter stateSetter) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 25, bottom: 25, left: 10, right: 10),
                height: displayHeight(context) >= 680
                    ? displayHeight(context) / 1.35
                    : displayHeight(context) / 1.25,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black,
                        blurRadius: 20.0,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isEndTripButton
                        ? Container(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Center(
                                child: Text(
                                  "Reading sensor data...",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  height: 300,
                                  width: 200,
                                  child: Lottie.asset(
                                      'assets/lottie/dataFetch.json')),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ))
                        : isZipFileCreate
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // SizedBox(height: 50,),
                                  SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: Lottie.asset(
                                          'assets/lottie/done.json')),
                                  Center(
                                    child: Text(
                                      "TripId: $getTripId",
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
                                      "Download Trip Data", context, () async {
                                    final androidInfo =
                                        await DeviceInfoPlugin().androidInfo;

                                    var isStoragePermitted =
                                        androidInfo.version.sdkInt > 32
                                            ? await Permission.photos.status
                                            : await Permission.storage.status;
                                    if (isStoragePermitted.isGranted) {
                                      //File copiedFile = File('${ourDirectory!.path}.zip');
                                      File copiedFile = File(
                                          '${ourDirectory!.path}/$getTripId.zip');

                                      print('DIR PATH R ${ourDirectory!.path}');

                                      Directory directory;

                                      if (Platform.isAndroid) {
                                        directory = Directory(
                                            "storage/emulated/0/Download/$getTripId.zip");
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
                                      await Utils.getStoragePermission(context);
                                      var isStoragePermitted =
                                          await Permission.storage.status;

                                      if (isStoragePermitted.isGranted) {
                                        File copiedFile =
                                            File('${ourDirectory!.path}.zip');

                                        Directory directory;

                                        if (Platform.isAndroid) {
                                          directory = Directory(
                                              "storage/emulated/0/Download/$getTripId.zip");
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
                                ],
                              )
                            : Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder(
                                      duration: const Duration(seconds: 2),
                                      tween: Tween(
                                          begin: progressBegin, end: progress),
                                      builder: (context, double value, _) {
                                        return SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CircularProgressIndicator(
                                                value: value,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                strokeWidth: 3,
                                                color: primaryColor,
                                              ),
                                              Center(
                                                child: buildProgress(value, 60),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      onEnd: () {
                                        debugPrint('END');
                                        stateSetter(() {
                                          isStartButton = true;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              displayWidth(context) * 0.15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                                  'Fetching your device details',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          TweenAnimationBuilder(
                                              duration:
                                                  const Duration(seconds: 2),
                                              tween: Tween(
                                                  begin: deviceProgressBegin,
                                                  end: deviceProgress),
                                              builder:
                                                  (context, double value, _) {
                                                return SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color: Colors.blue,
                                                        value: value,
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation(
                                                                Colors.green),
                                                      ),
                                                      Center(
                                                        child: subTitleProgress(
                                                            value,
                                                            displayWidth(
                                                                    context) *
                                                                0.035),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              displayWidth(context) * 0.15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                                  'Connecting with your Sensors',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          TweenAnimationBuilder(
                                              duration:
                                                  const Duration(seconds: 2),
                                              tween: Tween(
                                                  begin: sensorProgressBegin,
                                                  end: sensorProgress),
                                              builder:
                                                  (context, double value, _) {
                                                return SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color: Colors.blue,
                                                        value: value,
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation(
                                                                Colors.green),
                                                      ),
                                                      Center(
                                                        child: subTitleProgress(
                                                            value,
                                                            displayWidth(
                                                                    context) *
                                                                0.035),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              displayWidth(context) * 0.15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: isLocationPermission
                                                  ? 'Location permission granted'
                                                  : 'Location permission is required',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          !isLocationPermission
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.red,
                                                            width: 2),
                                                        shape: BoxShape.circle),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  tween: Tween(
                                                      begin:
                                                          sensorProgressBegin,
                                                      end: sensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color: Colors.blue,
                                                            value: value,
                                                            backgroundColor:
                                                                Colors.grey
                                                                    .shade200,
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                const AlwaysStoppedAnimation(
                                                                    Colors
                                                                        .green),
                                                          ),
                                                          Center(
                                                            child: subTitleProgress(
                                                                value,
                                                                displayWidth(
                                                                        context) *
                                                                    0.035),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    isZipFileCreate
                                        ? InkWell(
                                            onTap: () async {
                                              // File copiedFile = File('${ourDirectory!.path}/${getTripId}.zip');
                                              File copiedFile = File(
                                                  '${ourDirectory!.path}.zip');

                                              Directory directory;

                                              if (Platform.isAndroid) {
                                                directory = Directory(
                                                    "storage/emulated/0/Download/${widget.vessel!.id}.zip");
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

                                              // Utils.download(context, scaffoldKey,ourDirectory!.path);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                commonText(
                                                    context: context,
                                                    text: 'Download File',
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.black,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.038,
                                                    textAlign: TextAlign.start),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(Icons
                                                      .file_download_outlined),
                                                )
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    isEndTripButton
                                        ? Container()
                                        : StatefulBuilder(
                                            builder: (context,
                                                StateSetter stateSetter) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20),
                                                    child: Container(
                                                      height: displayHeight(
                                                                  context) >=
                                                              680
                                                          ? displayHeight(
                                                                  context) *
                                                              0.056
                                                          : displayHeight(
                                                                  context) *
                                                              0.07,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      color: backgroundColor,
                                                      child: InputDecorator(
                                                        decoration:
                                                            const InputDecoration(
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          0.0))),
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 5,
                                                                  bottom: 5),
                                                        ),

                                                        child: commonText(
                                                            context: context,
                                                            text: vesselName,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            textColor:
                                                                Colors.black54,
                                                            textSize:
                                                                displayWidth(
                                                                        context) *
                                                                    0.032,
                                                            textAlign: TextAlign
                                                                .start),

                                                        //Text(vesselName)
                                                        //     DropdownButtonHideUnderline(
                                                        //   child: DropdownButton<dynamic>(
                                                        //     value: null,
                                                        //     isDense: true,
                                                        //     hint:
                                                        //         Text(selectedVesselName),
                                                        //     isExpanded: true,
                                                        //     items: [
                                                        //       DropdownMenuItem(
                                                        //           value: '1',
                                                        //           child:
                                                        //               Text(vesselName)),
                                                        //     ],
                                                        //     onChanged: (newValue) {
                                                        //       stateSetter(() =>
                                                        //           selectedVesselName =
                                                        //               vesselName);
                                                        //       print(selectedVesselName);
                                                        //     },
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20,
                                                            top: 10),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      height: displayHeight(
                                                                  context) >=
                                                              680
                                                          ? displayHeight(
                                                                  context) *
                                                              0.056
                                                          : displayHeight(
                                                                  context) *
                                                              0.07,
                                                      color: backgroundColor,
                                                      child: InputDecorator(
                                                        decoration:
                                                            const InputDecoration(
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          0.0))),
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 10,
                                                                  bottom: 10),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              dynamic>(
                                                            value: null,
                                                            isDense: true,
                                                            hint: commonText(
                                                                context:
                                                                    context,
                                                                text:
                                                                    selectedVesselWeight,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                textColor: Colors
                                                                    .black54,
                                                                textSize:
                                                                    displayWidth(
                                                                            context) *
                                                                        0.032,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start),
                                                            //  Text(
                                                            //     '${selectedVesselWeight}'),
                                                            isExpanded: true,
                                                            items: [
                                                              DropdownMenuItem(
                                                                  value: '1',
                                                                  child: Text(
                                                                      'Empty')),
                                                              DropdownMenuItem(
                                                                  value: '2',
                                                                  child: Text(
                                                                      'Half')),
                                                              DropdownMenuItem(
                                                                  value: '3',
                                                                  child: Text(
                                                                      'Full')),
                                                              DropdownMenuItem(
                                                                  value: '4',
                                                                  child: Text(
                                                                      'Variable')),
                                                            ],
                                                            onChanged:
                                                                (weightValue) {
                                                              stateSetter(() {
                                                                int.parse(weightValue) ==
                                                                        1
                                                                    ? selectedVesselWeight =
                                                                        'Empty'
                                                                    : (int.parse(weightValue) ==
                                                                            2
                                                                        ? selectedVesselWeight =
                                                                            'Half'
                                                                        : (int.parse(weightValue) ==
                                                                                3
                                                                            ? selectedVesselWeight =
                                                                                'Full'
                                                                            : selectedVesselWeight =
                                                                                'Variable'));
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                  ],
                                ),
                              ),
                    SizedBox(
                      height: 50,
                      width: displayWidth(context),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: isStartButton
                            ? CommonButtons.getActionButton(
                                title: 'Start',
                                context: context,
                                fontSize: displayWidth(context) * 0.042,
                                textColor: Colors.white,
                                buttonPrimaryColor: buttonBGColor,
                                borderColor: buttonBGColor,
                                width: displayWidth(context),
                                onTap: () async {
                                  debugPrint(
                                      'SELECTED VESSEL WEIGHT $selectedVesselWeight');
                                  if (selectedVesselWeight ==
                                      'Select Current Load') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text("Please select weight"),
                                      duration: Duration(seconds: 1),
                                      backgroundColor: Colors.blue,
                                    ));
                                    return;
                                  }

                                  print('ISSSSSSSSS');

                                  bool isLocationPermitted =
                                      await Permission.location.isGranted;

                                  print('ISSSSSSSSS: $isLocationPermitted');

                                  if (isLocationPermitted) {
                                    // service.startService();

                                    final androidInfo =
                                        await DeviceInfoPlugin().androidInfo;

                                    var isStoragePermitted =
                                        androidInfo.version.sdkInt > 32
                                            ? await Permission.photos.status
                                            : await Permission.storage.status;
                                    if (isStoragePermitted.isGranted) {
                                      bool isNotificationPermitted =
                                          await Permission
                                              .notification.isGranted;

                                      if (isNotificationPermitted) {
                                        bool isServiceRunning =
                                            await service.isRunning();

                                        print('ISSSSS: $isServiceRunning');

                                        if (!isServiceRunning) {
                                          service.startService();
                                          print(
                                              'View Single: $isServiceRunning');
                                        }

                                        await Future.delayed(
                                            Duration(seconds: 3), () {});

                                        bool isServiceRunning2 =
                                            await service.isRunning();
                                        print(
                                            'View Single: $isServiceRunning2');

                                        service.invoke("onStartTrip");

                                        service.invoke("setAsForeground");

                                        getTripId = uuid.v1();

                                        service.invoke(
                                            'tripId', {'tripId': getTripId});

                                        Future.delayed(Duration(seconds: 2),
                                            () {
                                          Timer.periodic(Duration(seconds: 1),
                                              (timer) async {
                                            LocationData? locationData =
                                                await Utils
                                                    .getCurrentLocation();
                                            service.invoke('location', {
                                              'lat': locationData!.latitude,
                                              'long': locationData.longitude,
                                            });
                                          });
                                        });

                                        stateSetter(() {
                                          isStartButton = false;
                                          isEndTripButton = true;
                                        });

                                        sharedPreferences!
                                            .setBool('trip_started', true);
                                        sharedPreferences!.setStringList(
                                            'trip_data', [
                                          getTripId,
                                          widget.vessel!.id!,
                                          widget.vessel!.name!,
                                          selectedVesselWeight
                                        ]);

                                        onSave('', bottomSheetContext, true);

                                        // await Permission.storage.request();
                                      } else {
                                        await Utils.getNotificationPermission(
                                            context);
                                        bool isNotificationPermitted =
                                            await Permission
                                                .notification.isGranted;
                                        if (isNotificationPermitted) {
                                          bool isServiceRunning =
                                              await service.isRunning();

                                          print('ISSSSS: $isServiceRunning');

                                          if (!isServiceRunning) {
                                            service.startService();
                                            print(
                                                'View Single: $isServiceRunning');
                                          }

                                          await Future.delayed(
                                              Duration(seconds: 3), () {});

                                          bool isServiceRunning2 =
                                              await service.isRunning();
                                          print(
                                              'View Single: $isServiceRunning2');

                                          service.invoke("onStartTrip");

                                          service.invoke("setAsForeground");

                                          getTripId = uuid.v1();

                                          service.invoke(
                                              'tripId', {'tripId': getTripId});

                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            Timer.periodic(Duration(seconds: 1),
                                                (timer) async {
                                              LocationData? locationData =
                                                  await Utils
                                                      .getCurrentLocation();
                                              service.invoke('location', {
                                                'lat': locationData!.latitude,
                                                'long': locationData.longitude,
                                              });
                                            });
                                          });

                                          stateSetter(() {
                                            isStartButton = false;
                                            isEndTripButton = true;
                                          });

                                          sharedPreferences!
                                              .setBool('trip_started', true);
                                          sharedPreferences!.setStringList(
                                              'trip_data', [
                                            getTripId,
                                            widget.vessel!.id!,
                                            widget.vessel!.name!,
                                            selectedVesselWeight
                                          ]);

                                          onSave('', bottomSheetContext, true);

                                          // await Permission.storage.request();
                                        }
                                      }
                                    } else {
                                      await Utils.getStoragePermission(context);
                                      final androidInfo =
                                          await DeviceInfoPlugin().androidInfo;

                                      var isStoragePermitted =
                                          androidInfo.version.sdkInt > 32
                                              ? await Permission.photos.status
                                              : await Permission.storage.status;

                                      if (isStoragePermitted.isGranted) {
                                        bool isNotificationPermitted =
                                            await Permission
                                                .notification.isGranted;

                                        if (isNotificationPermitted) {
                                          bool isServiceRunning =
                                              await service.isRunning();

                                          print('ISSSSS: $isServiceRunning');

                                          if (!isServiceRunning) {
                                            service.startService();
                                            print(
                                                'View Single: $isServiceRunning');
                                          }

                                          await Future.delayed(
                                              Duration(seconds: 3), () {});

                                          bool isServiceRunning2 =
                                              await service.isRunning();
                                          print(
                                              'View Single: $isServiceRunning2');

                                          service.invoke("onStartTrip");

                                          service.invoke("setAsForeground");

                                          getTripId = uuid.v1();

                                          service.invoke(
                                              'tripId', {'tripId': getTripId});

                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            Timer.periodic(Duration(seconds: 1),
                                                (timer) async {
                                              LocationData? locationData =
                                                  await Utils
                                                      .getCurrentLocation();
                                              service.invoke('location', {
                                                'lat': locationData!.latitude,
                                                'long': locationData.longitude,
                                              });
                                            });
                                          });

                                          stateSetter(() {
                                            isStartButton = false;
                                            isEndTripButton = true;
                                          });

                                          sharedPreferences!
                                              .setBool('trip_started', true);
                                          sharedPreferences!.setStringList(
                                              'trip_data', [
                                            getTripId,
                                            widget.vessel!.id!,
                                            widget.vessel!.name!,
                                            selectedVesselWeight
                                          ]);

                                          onSave('', bottomSheetContext, true);

                                          // await Permission.storage.request();
                                        } else {
                                          await Utils.getNotificationPermission(
                                              context);
                                          bool isNotificationPermitted =
                                              await Permission
                                                  .notification.isGranted;
                                          if (isNotificationPermitted) {
                                            bool isServiceRunning =
                                                await service.isRunning();

                                            print('ISSSSS: $isServiceRunning');

                                            if (!isServiceRunning) {
                                              service.startService();
                                              print(
                                                  'View Single: $isServiceRunning');
                                            }

                                            await Future.delayed(
                                                Duration(seconds: 3), () {});

                                            bool isServiceRunning2 =
                                                await service.isRunning();
                                            print(
                                                'View Single: $isServiceRunning2');

                                            service.invoke("onStartTrip");

                                            service.invoke("setAsForeground");

                                            getTripId = uuid.v1();

                                            service.invoke('tripId',
                                                {'tripId': getTripId});

                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Timer.periodic(
                                                  Duration(seconds: 1),
                                                  (timer) async {
                                                LocationData? locationData =
                                                    await Utils
                                                        .getCurrentLocation();
                                                service.invoke('location', {
                                                  'lat': locationData!.latitude,
                                                  'long':
                                                      locationData.longitude,
                                                });
                                              });
                                            });

                                            stateSetter(() {
                                              isStartButton = false;
                                              isEndTripButton = true;
                                            });

                                            sharedPreferences!
                                                .setBool('trip_started', true);
                                            sharedPreferences!.setStringList(
                                                'trip_data', [
                                              getTripId,
                                              widget.vessel!.id!,
                                              widget.vessel!.name!,
                                              selectedVesselWeight
                                            ]);

                                            onSave(
                                                '', bottomSheetContext, true);

                                            // await Permission.storage.request();
                                          }
                                        }

                                        /*bool isServiceRunning =
                                            await service.isRunning();

                                        if (!isServiceRunning) {
                                          service.startService();
                                        }

                                        await Future.delayed(
                                            Duration(seconds: 3), () {});

                                        service.invoke("onStartTrip");

                                        service.invoke("setAsForeground");

                                        getTripId = uuid.v1();

                                        service.invoke(
                                            'tripId', {'tripId': getTripId});

                                        Future.delayed(Duration(seconds: 2),
                                            () {
                                          Timer.periodic(Duration(seconds: 1),
                                              (timer) async {
                                            LocationData? locationData =
                                                await Utils
                                                    .getCurrentLocation();
                                            service.invoke('location', {
                                              'lat': locationData!.latitude,
                                              'long': locationData.longitude,
                                            });
                                          });
                                        });

                                        stateSetter(() {
                                          isStartButton = false;
                                          isEndTripButton = true;
                                        });

                                        sharedPreferences!
                                            .setBool('trip_started', true);
                                        sharedPreferences!.setStringList(
                                            'trip_data', [
                                          getTripId,
                                          widget.vessel!.id!,
                                          widget.vessel!.name!,
                                          selectedVesselWeight
                                        ]);

                                        onSave('', bottomSheetContext, true);*/
                                      }
                                    }
                                  } else {
                                    await Utils.getLocationPermission(
                                        context, scaffoldKey);
                                    bool isLocationPermitted =
                                        await Permission.location.isGranted;

                                    if (isLocationPermitted) {
                                      // service.startService();

                                      final androidInfo =
                                          await DeviceInfoPlugin().androidInfo;

                                      var isStoragePermitted =
                                          androidInfo.version.sdkInt > 32
                                              ? await Permission.photos.status
                                              : await Permission.storage.status;
                                      if (isStoragePermitted.isGranted) {
                                        bool isNotificationPermitted =
                                            await Permission
                                                .notification.isGranted;

                                        if (isNotificationPermitted) {
                                          bool isServiceRunning =
                                              await service.isRunning();

                                          print('ISSSSS: $isServiceRunning');

                                          if (!isServiceRunning) {
                                            service.startService();
                                            print(
                                                'View Single: $isServiceRunning');
                                          }

                                          await Future.delayed(
                                              Duration(seconds: 3), () {});

                                          bool isServiceRunning2 =
                                              await service.isRunning();
                                          print(
                                              'View Single: $isServiceRunning2');

                                          service.invoke("onStartTrip");

                                          service.invoke("setAsForeground");

                                          getTripId = uuid.v1();

                                          service.invoke(
                                              'tripId', {'tripId': getTripId});

                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            Timer.periodic(Duration(seconds: 1),
                                                (timer) async {
                                              LocationData? locationData =
                                                  await Utils
                                                      .getCurrentLocation();
                                              service.invoke('location', {
                                                'lat': locationData!.latitude,
                                                'long': locationData.longitude,
                                              });
                                            });
                                          });

                                          stateSetter(() {
                                            isStartButton = false;
                                            isEndTripButton = true;
                                          });

                                          sharedPreferences!
                                              .setBool('trip_started', true);
                                          sharedPreferences!.setStringList(
                                              'trip_data', [
                                            getTripId,
                                            widget.vessel!.id!,
                                            widget.vessel!.name!,
                                            selectedVesselWeight
                                          ]);

                                          onSave('', bottomSheetContext, true);

                                          // await Permission.storage.request();
                                        } else {
                                          await Utils.getNotificationPermission(
                                              context);
                                          bool isNotificationPermitted =
                                              await Permission
                                                  .notification.isGranted;
                                          if (isNotificationPermitted) {
                                            bool isServiceRunning =
                                                await service.isRunning();

                                            print('ISSSSS: $isServiceRunning');

                                            if (!isServiceRunning) {
                                              service.startService();
                                              print(
                                                  'View Single: $isServiceRunning');
                                            }

                                            await Future.delayed(
                                                Duration(seconds: 3), () {});

                                            bool isServiceRunning2 =
                                                await service.isRunning();
                                            print(
                                                'View Single: $isServiceRunning2');

                                            service.invoke("onStartTrip");

                                            service.invoke("setAsForeground");

                                            getTripId = uuid.v1();

                                            service.invoke('tripId',
                                                {'tripId': getTripId});

                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Timer.periodic(
                                                  Duration(seconds: 1),
                                                  (timer) async {
                                                LocationData? locationData =
                                                    await Utils
                                                        .getCurrentLocation();
                                                service.invoke('location', {
                                                  'lat': locationData!.latitude,
                                                  'long':
                                                      locationData.longitude,
                                                });
                                              });
                                            });

                                            stateSetter(() {
                                              isStartButton = false;
                                              isEndTripButton = true;
                                            });

                                            sharedPreferences!
                                                .setBool('trip_started', true);
                                            sharedPreferences!.setStringList(
                                                'trip_data', [
                                              getTripId,
                                              widget.vessel!.id!,
                                              widget.vessel!.name!,
                                              selectedVesselWeight
                                            ]);

                                            onSave(
                                                '', bottomSheetContext, true);

                                            // await Permission.storage.request();
                                          }
                                        }

                                        /*bool isServiceRunning =
                                            await service.isRunning();

                                        if (!isServiceRunning) {
                                          service.startService();
                                        }

                                        await Future.delayed(
                                            Duration(seconds: 3), () {});

                                        service.invoke("onStartTrip");

                                        service.invoke("setAsForeground");

                                        getTripId = uuid.v1();

                                        service.invoke(
                                            'tripId', {'tripId': getTripId});

                                        Future.delayed(Duration(seconds: 2),
                                            () {
                                          Timer.periodic(Duration(seconds: 1),
                                              (timer) async {
                                            LocationData? locationData =
                                                await Utils
                                                    .getCurrentLocation();
                                            service.invoke('location', {
                                              'lat': locationData!.latitude,
                                              'long': locationData.longitude,
                                            });
                                          });
                                        });

                                        stateSetter(() {
                                          isStartButton = false;
                                          isEndTripButton = true;
                                        });

                                        sharedPreferences!
                                            .setBool('trip_started', true);
                                        sharedPreferences!.setStringList(
                                            'trip_data', [
                                          getTripId,
                                          widget.vessel!.id!,
                                          widget.vessel!.name!,
                                          selectedVesselWeight
                                        ]);

                                        onSave('', bottomSheetContext, true);*/

                                        // await Permission.storage.request();
                                      } else {
                                        await Utils.getStoragePermission(
                                            context);
                                        final androidInfo =
                                            await DeviceInfoPlugin()
                                                .androidInfo;

                                        var isStoragePermitted =
                                            androidInfo.version.sdkInt > 32
                                                ? await Permission.photos.status
                                                : await Permission
                                                    .storage.status;

                                        if (isStoragePermitted.isGranted) {
                                          bool isNotificationPermitted =
                                              await Permission
                                                  .notification.isGranted;

                                          if (isNotificationPermitted) {
                                            bool isServiceRunning =
                                                await service.isRunning();

                                            print('ISSSSS: $isServiceRunning');

                                            if (!isServiceRunning) {
                                              service.startService();
                                              print(
                                                  'View Single: $isServiceRunning');
                                            }

                                            await Future.delayed(
                                                Duration(seconds: 3), () {});

                                            bool isServiceRunning2 =
                                                await service.isRunning();
                                            print(
                                                'View Single: $isServiceRunning2');

                                            service.invoke("onStartTrip");

                                            service.invoke("setAsForeground");

                                            getTripId = uuid.v1();

                                            service.invoke('tripId',
                                                {'tripId': getTripId});

                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              Timer.periodic(
                                                  Duration(seconds: 1),
                                                  (timer) async {
                                                LocationData? locationData =
                                                    await Utils
                                                        .getCurrentLocation();
                                                service.invoke('location', {
                                                  'lat': locationData!.latitude,
                                                  'long':
                                                      locationData.longitude,
                                                });
                                              });
                                            });

                                            stateSetter(() {
                                              isStartButton = false;
                                              isEndTripButton = true;
                                            });

                                            sharedPreferences!
                                                .setBool('trip_started', true);
                                            sharedPreferences!.setStringList(
                                                'trip_data', [
                                              getTripId,
                                              widget.vessel!.id!,
                                              widget.vessel!.name!,
                                              selectedVesselWeight
                                            ]);

                                            onSave(
                                                '', bottomSheetContext, true);

                                            // await Permission.storage.request();
                                          } else {
                                            await Utils
                                                .getNotificationPermission(
                                                    context);
                                            bool isNotificationPermitted =
                                                await Permission
                                                    .notification.isGranted;
                                            if (isNotificationPermitted) {
                                              bool isServiceRunning =
                                                  await service.isRunning();

                                              print(
                                                  'ISSSSS: $isServiceRunning');

                                              if (!isServiceRunning) {
                                                service.startService();
                                                print(
                                                    'View Single: $isServiceRunning');
                                              }

                                              await Future.delayed(
                                                  Duration(seconds: 3), () {});

                                              bool isServiceRunning2 =
                                                  await service.isRunning();
                                              print(
                                                  'View Single: $isServiceRunning2');

                                              service.invoke("onStartTrip");

                                              service.invoke("setAsForeground");

                                              getTripId = uuid.v1();

                                              service.invoke('tripId',
                                                  {'tripId': getTripId});

                                              Future.delayed(
                                                  Duration(seconds: 2), () {
                                                Timer.periodic(
                                                    Duration(seconds: 1),
                                                    (timer) async {
                                                  LocationData? locationData =
                                                      await Utils
                                                          .getCurrentLocation();
                                                  service.invoke('location', {
                                                    'lat':
                                                        locationData!.latitude,
                                                    'long':
                                                        locationData.longitude,
                                                  });
                                                });
                                              });

                                              stateSetter(() {
                                                isStartButton = false;
                                                isEndTripButton = true;
                                              });

                                              sharedPreferences!.setBool(
                                                  'trip_started', true);
                                              sharedPreferences!.setStringList(
                                                  'trip_data', [
                                                getTripId,
                                                widget.vessel!.id!,
                                                widget.vessel!.name!,
                                                selectedVesselWeight
                                              ]);

                                              onSave(
                                                  '', bottomSheetContext, true);

                                              // await Permission.storage.request();
                                            }
                                          }

                                          /*bool isServiceRunning =
                                              await service.isRunning();

                                          if (!isServiceRunning) {
                                            service.startService();
                                          }

                                          await Future.delayed(
                                              Duration(seconds: 3), () {});

                                          service.invoke("onStartTrip");

                                          service.invoke("setAsForeground");

                                          getTripId = uuid.v1();

                                          service.invoke(
                                              'tripId', {'tripId': getTripId});

                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            Timer.periodic(Duration(seconds: 1),
                                                (timer) async {
                                              LocationData? locationData =
                                                  await Utils
                                                      .getCurrentLocation();
                                              service.invoke('location', {
                                                'lat': locationData!.latitude,
                                                'long': locationData.longitude,
                                              });
                                            });
                                          });

                                          stateSetter(() {
                                            isStartButton = false;
                                            isEndTripButton = true;
                                          });

                                          sharedPreferences!
                                              .setBool('trip_started', true);
                                          sharedPreferences!.setStringList(
                                              'trip_data', [
                                            getTripId,
                                            widget.vessel!.id!,
                                            widget.vessel!.name!,
                                            selectedVesselWeight
                                          ]);

                                          onSave('', bottomSheetContext, true);*/
                                        }
                                      }

                                      /// TODO Further Process
                                      // await getLocationData();

                                      /// SAVED Sensor data
                                      // startSensorFunctionality(stateSetter);
                                    }
                                  }
                                  // startTripService(stateSetter);
                                })
                            : isEndTripButton
                                ? CommonButtons.getActionButton(
                                    title: 'End Trip',
                                    context: context,
                                    fontSize: displayWidth(context) * 0.042,
                                    textColor: Colors.white,
                                    buttonPrimaryColor: buttonBGColor,
                                    borderColor: buttonBGColor,
                                    width: displayWidth(context),
                                    onTap: () async {
                                      // getTripId = await getTripIdFromPref();

                                      service.invoke('stopService');

                                      File? zipFile;
                                      if (timer != null) timer!.cancel();
                                      print(
                                          'TIMER STOPPED ${ourDirectory!.path}/$getTripId');
                                      final dataDir = Directory(
                                          '${ourDirectory!.path}/$getTripId');

                                      try {
                                        zipFile = File(
                                            '${ourDirectory!.path}/$getTripId.zip');

                                        ZipFile.createFromDirectory(
                                            sourceDir: dataDir,
                                            zipFile: zipFile,
                                            recurseSubDirs: true);
                                        print('our path is $dataDir');
                                      } catch (e) {
                                        print(e);
                                      }

                                      File file = File(zipFile!.path);
                                      stateSetter(() {
                                        isEndTripButton = false;
                                        isZipFileCreate = true;
                                      });
                                      Future.delayed(Duration(seconds: 1))
                                          .then((value) {
                                        stateSetter(() {
                                          isZipFileCreate = true;
                                        });
                                      });
                                      print('FINAL PATH: ${file.path}');

                                      sharedPreferences!.remove('trip_data');
                                      sharedPreferences!.remove('trip_started');

                                      await _databaseService.updateTripStatus(
                                          1,
                                          file.path,
                                          DateTime.now().toString(),
                                          getTripId);

                                      // stateSetter(() {
                                      //   isEndTripButton = false;
                                      //   isZipFileCreate = true;
                                      // });

                                      /*File file = File(zipFile!.path);
                                      Future.delayed(Duration(seconds: 1))
                                          .then((value) {
                                        stateSetter(() {
                                          isZipFileCreate = true;
                                        });
                                      });*/
                                    })
                                : isZipFileCreate
                                    ? CommonButtons.getActionButton(
                                        title: 'Trip Ended',
                                        context: context,
                                        fontSize: displayWidth(context) * 0.042,
                                        textColor: Colors.white,
                                        buttonPrimaryColor: buttonBGColor,
                                        borderColor: buttonBGColor,
                                        width: displayWidth(context),
                                        onTap: () async {
                                          if (isSensorDataUploaded) {
                                            Get.back();
                                            //setState(() {
                                            // future = commonProvider.triplListData(
                                            //     context,
                                            //     commonProvider.loginModel!.token!,
                                            //     widget.vesselId.toString(),
                                            //     scaffoldKey);
                                            //});
                                          } else {
                                            Get.back();
                                          }

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
                                    : CommonButtons.getActionButton(
                                        title: 'Cancel',
                                        context: context,
                                        fontSize: displayWidth(context) * 0.042,
                                        textColor: Colors.white,
                                        buttonPrimaryColor: buttonBGColor,
                                        borderColor: buttonBGColor,
                                        width: displayWidth(context),
                                        onTap: () {
                                          Get.back();
                                          //Navigator.of(context).pop();
                                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: backgroundColor),
                  child: IconButton(
                      onPressed: () {
                        isBottomSheetOpened = false;
                        if (isSensorDataUploaded) {
                          Get.back();
                          //setState(() {
                          // future = commonProvider.triplListData(
                          //     context,
                          //     commonProvider.loginModel!.token!,
                          //     widget.vesselId.toString(),
                          //     scaffoldKey);
                          //});
                        } else {
                          Get.back();
                        }
                      },
                      icon: Icon(Icons.close_rounded, color: buttonBGColor)),
                ),
              )
            ],
          );
        });
      },
      elevation: 4,
      enableDrag: false,
    );
  }

  buildProgress(double progress, double size) {
    return commonText(
        context: context,
        text: '${(progress * 100).toStringAsFixed(0)} %',
        fontWeight: FontWeight.w500,
        textColor: Colors.black,
        textSize: displayWidth(context) * 0.038,
        textAlign: TextAlign.start);
  }

  subTitleProgress(double progress, double size) {
    if (progress == 1) {
      return Icon(
        Icons.done,
        color: Colors.green,
        size: size,
      );
    }
  }

  Future<LocationData> getLocationData() async {
    LocationData? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);

    latitude = locationData!.latitude!.toString();
    longitude = locationData.longitude!.toString();

    debugPrint('LAT ${latitude}');
    debugPrint('LONG ${longitude}');

    return locationData;
  }

  startSensorFunctionality(StateSetter stateSetter) async {
    /*setState(() {
      getTripId = uuid.v1();
    });*/
    //onSave();
    fileName = '$fileIndex.csv';
    // String? tripId;
    // getTripId = await getTripIdFromPref();
    // print(widget.vessel!.id);
    debugPrint('tripId: $getTripId');
    stateSetter(() {
      isStartButton = false;
      isEndTripButton = true;
    });

    Trip tripStatus = await _databaseService.getTrip(getTripId);

    if (tripStatus.tripStatus == 0) {
      timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        writeSensorDataToFile(getTripId);
      });
    }
  }

  getTripIdFromPref() async {
    final pref = await Utils.initSharedPreferences();
    var tripId = pref.getString('tripId') ?? '';
    return tripId;
  }

  void writeSensorDataToFile(String tripId) async {
    String filePath = await getFile(tripId);
    File file = File(filePath);

    int fileSize = await checkFileSize(file);

    /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
    /// Now File Size is 10,00,000
    if (fileSize >= 1000000) {
      print('STOPPED WRITING');
      print('CREATING NEW FILE');
      // if (timer != null) timer!.cancel();
      // print('TIMER STOPPED');

      setState(() {
        fileIndex = fileIndex + 1;

        fileName = '$fileIndex.csv';

        // print('FILE NAME: $fileName');
      });
      print('NEW FILE CREATED');

      /// STOP WRITING & CREATE NEW FILE
    } else {
      print('WRITING');

      LocationData? locationData =
          await Utils.getLocationPermission(context, scaffoldKey);

      latitude = locationData!.latitude!.toString();
      longitude = locationData.longitude!.toString();

      debugPrint('LAT ${latitude}');
      debugPrint('LONG ${longitude}');

      String acc = convertDataToString('AAC', _accelerometerValues ?? []);
      String uacc = convertDataToString('UACC', _userAccelerometerValues ?? []);
      String gyro = convertDataToString('GYRO', _gyroscopeValues ?? []);
      String mag = convertDataToString('MAG', _magnetometerValues ?? []);
      String location = '$latitude $longitude';
      String gps = convertLocationToString('GPS', location);

      String finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

      file.writeAsString('$finalString\n', mode: FileMode.append);

      //debugPrint('finalString ${finalString}');
    }
  }

  Future<String> getFile(String tripId) async {
    debugPrint("tripId: $getTripId");
    String folderPath = await getOrCreateFolder(tripId);

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
  }

  int checkFileSize(File file) {
    if (file.existsSync()) {
      var bytes = file.lengthSync();
      double sizeInKB = bytes / 1024;
      double sizeInMB = sizeInKB / 1024;

      int finalSizeInMB = sizeInMB.toInt();
      // print('FILE SIZE: $sizeInMB');
      // print('FILE SIZE KB: $sizeInKB');
      //print('FINAL FILE SIZE: $finalSizeInMB');
      return sizeInKB.toInt();
    } else {
      return -1;
    }
  }

  String convertLocationToString(String type, String sensorData) {
    var date = DateTime.now().toUtc();
    var todayDate = date.toString().replaceAll(" ", "");
    var gps = sensorData.toString().replaceAll(" ", ",");
    return '$type,$todayDate,$gps';
  }

  String convertDataToString(String type, List<double> sensorData) {
    String? input = sensorData.toString();
    final removedBrackets = input.substring(1, input.length - 1);
    var replaceAll = removedBrackets.replaceAll(" ", "");
    var date = DateTime.now().toUtc();
    var todayDate = date.toString().replaceAll(" ", "");
    return '$type,$replaceAll,$todayDate';
  }

  Future<String> getOrCreateFolder(String tripId) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    debugPrint('FOLDER PATHH $ourDirectory');
    debugPrint('FOLDER PATHH TRIP ID $tripId');
    /* var status = await Permission.storage.status;
    if (!status.isGranted) {
      var stat = await Permission.storage.request();

    } else {}*/

    if ((await ourDirectory!.exists())) {
      return ourDirectory!.path;
    } else {
      ourDirectory!.create();
      return ourDirectory!.path;
    }
  }

  deleteFolder() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    Directory ourDirectory = Directory('${appDirectory.path}/sensor');

    if (await ourDirectory.exists()) {
      Directory('${appDirectory.path}/sensor').delete(recursive: true);
    } else {
      debugPrint('Custom Direcotry deleted');
    }
  }

  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = widget.vessel!.name;
    final currentLoad = selectedVesselWeight;
    LocationData? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);
    // await fetchDeviceInfo();
    await fetchDeviceData();

    debugPrint('hello device details: ${deviceDetails!.toJson().toString()}');
    // debugPrint(" locationData!.latitude!.toString():${ locationData!.latitude!.toString()}");
    String latitude = locationData!.latitude!.toString();
    String longitude = locationData.longitude!.toString();

    debugPrint("current lod:$currentLoad");
    debugPrint("current PATH:$file");

    /*setState(() {
      getTripId = uuid.v1();
    });*/

    debugPrint("ON SAVE FIRST INSERT :$getTripId");

    await _databaseService.insertTrip(Trip(
        id: getTripId,
        vesselId: widget.vessel!.id,
        vesselName: vesselName,
        currentLoad: currentLoad,
        filePath: file,
        isSync: 0,
        tripStatus: 0,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        lat: latitude,
        long: longitude,
        deviceInfo: deviceDetails!.toJson().toString()));

    /*if (!savingDataWhileStartService) {
      await _databaseService.updateTripStatus(1, getTripId, file);
      isZipFileCreate ? null : Navigator.pop(context);
    }*/
  }

  // @pragma('vm:entry-point')
  Future<void> onServiceStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    // startTripService();
  }

  startTripService(StateSetter stateSetter) async {
    bool isLocationPermitted = await Permission.location.isGranted;

    if (isLocationPermitted) {
      /// TODO Further Process
      await getLocationData();

      /// SAVED Sensor data
      startSensorFunctionality(stateSetter);
    } else {
      await Utils.getLocationPermission(context, scaffoldKey);
      bool isLocationPermitted = await Permission.location.isGranted;

      if (isLocationPermitted) {
        /// TODO Further Process
        await getLocationData();

        /// SAVED Sensor data
        startSensorFunctionality(stateSetter);
      }
    }
  }

  /* showAlertDialog(
      BuildContext context, String tripId, vesselId, vesselName, vesselWeight) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Trip"),
          content: Text("Do you want to end the trip?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("End"),
              onPressed: () async {
                // ServiceInstance instan = Get.find(tag: 'serviceInstance');
                FlutterBackgroundService service = FlutterBackgroundService();

                bool isServiceRunning = await service.isRunning();

                print('IS SERVICE RUNNING: $isServiceRunning');

                try {
                  service.invoke('stopService');
                  // instan.stopSelf();
                } on Exception catch (e) {
                  print('SERVICE STOP BG EXE: $e');
                }

                final appDirectory = await getApplicationDocumentsDirectory();
                ourDirectory = Directory('${appDirectory.path}');

                File? zipFile;
                if (timer != null) timer!.cancel();
                print('TIMER STOPPED ${ourDirectory!.path}/$tripId');
                final dataDir = Directory('${ourDirectory!.path}/$tripId');

                try {
                  zipFile = File('${ourDirectory!.path}/$tripId.zip');

                  ZipFile.createFromDirectory(
                      sourceDir: dataDir,
                      zipFile: zipFile,
                      recurseSubDirs: true);
                  print('our path is $dataDir');
                } catch (e) {
                  print(e);
                }

                File file = File(zipFile!.path);
                print('FINAL PATH: ${file.path}');

                sharedPreferences!.remove('trip_data');
                sharedPreferences!.remove('trip_started');

                // service.invoke('stopService');

                onSave(file.path, context, tripId, vesselId, vesselName,
                    vesselWeight);
              },
            ),
          ],
        );
      },
    );
  }*/
}
