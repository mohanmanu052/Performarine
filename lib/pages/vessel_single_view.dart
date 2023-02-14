import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart'
    as locationAcc;
import 'package:get/get.dart';
// import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/expansionCard.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class VesselSingleView extends StatefulWidget {
  CreateVessel? vessel;
  bool? isCalledFromSuccessScreen;

  VesselSingleView({this.vessel, this.isCalledFromSuccessScreen = false});
  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {
  List<CreateVessel>? vessel = [];
  final DatabaseService _databaseService = DatabaseService();
  GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();

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
      isSensorDataUploaded = false,
      addingDataToDB = false,
      isLocationDialogBoxOpen = false,
      tripIsEnded = false;

  // Timer? timer;
  Timer? locationTimer;
  String fileName = '';
  int fileIndex = 1;
  String? latitude, longitude;
  String getTripId = '';
  var uuid = Uuid();

  double progress = 1.0;
  double deviceProgress = 1.0;
  double sensorProgress = 1.0;
  double accSensorProgress = 1.0;
  double uaccSensorProgress = 1.0;
  double gyroSensorProgress = 1.0;
  double magnSensorProgress = 1.0;

  double progressBegin = 0.0;
  double deviceProgressBegin = 0.0;
  double sensorProgressBegin = 0.0;
  double accSensorProgressBegin = 0.0;
  double uaccSensorProgressBegin = 0.0;
  double gyroSensorProgressBegin = 0.0;
  double magnSensorProgressBegin = 0.0;

  String selectedVesselWeight = 'Select Current Load';

  bool isServiceRunning = false;
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<List<Trip>> getTripListByVesselId(String id) async {
    return await _databaseService.getAllTripsByVesselId(id);
  }

  Position? location;

  List<String> sensorDataTable = ['ACC', 'UACC', 'GYRO', 'MAGN'];

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

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  Future<void> _onDeleteTripsByVesselID(String vesselId) async {
    await _databaseService.deleteTripBasedOnVesselId(vesselId);
    setState(() {});
  }

  bool isBottomSheetOpened = false,
      isDataUpdated = false,
      tripIsRunning = false,
      isCheckingPermission = false,
      isTripEndedOrNot = false;

  late CommonProvider commonProvider;

  bool? gyroscopeAvailable,
      accelerometerAvailable,
      magnetometerAvailable,
      userAccelerometerAvailable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tripIsRunningOrNot();

    commonProvider = context.read<CommonProvider>();

    print('VESSEL Image ${isTripEndedOrNot}');

    checkSensorAvailabelOrNot();
  }

  getRunningTripDetails() async {
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');
    Trip tripDetails = await _databaseService.getTrip(tripData![0]);
    if (tripIsRunning)
      debugPrint('VESSEL SINGLE VIEW TRIP ID ${tripDetails.id}');

    if (tripIsRunning) {
      if (tripDetails.vesselId != widget.vessel!.id) {
        setState(() {
          tripIsRunning = false;
        });
      }
    }
  }

  checkSensorAvailabelOrNot() async {
    gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);
  }

  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      print('Trip is Running $tripIsRunning');

      if (tripIsRunning) {
        getRunningTripDetails();
      }

      if (!tripIsRunning) {
        setState(() {
          isTripEndedOrNot = false;
        });
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('yyyyy');
        if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
          print('zzzzzz');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              ModalRoute.withName(""));

          return false;
        } else {
          print('hhhhh');

          Navigator.of(context).pop(true);
          return false;
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
            onPressed: () async {
              await tripIsRunningOrNot();

              if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    ModalRoute.withName(""));
              } else {
                Navigator.of(context).pop(true);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/images/home.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
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
                    /*Card(
                      child: ExpansionTile(
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        title: Text(
                          "VESSEL ANALYTICS",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: vesselAnalytics(context))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),*/
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
                            child: TripViewListing(
                              scaffoldKey: scaffoldKey,
                              vesselId: widget.vessel!.id,
                              onTripEnded: () async {
                                debugPrint('SINGLE VIEW TRIP END');
                                await tripIsRunningOrNot();
                                setState(() {
                                  tripIsEnded = true;
                                });
                              },
                            ),
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
                child: tripIsRunning
                    ? isTripEndedOrNot
                        ? Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                circularProgressColor),
                          ))
                        : CommonButtons.getActionButton(
                            title: 'End Trip',
                            context: context,
                            fontSize: displayWidth(context) * 0.042,
                            textColor: Colors.white,
                            buttonPrimaryColor: buttonBGColor,
                            borderColor: buttonBGColor,
                            width: displayWidth(context),
                            onTap: () async {
                              print('time stamp:' +
                                  DateTime.now().toUtc().toString());
                              Utils().showEndTripDialog(context, () async {
                                setState(() {
                                  isTripEndedOrNot = true;
                                });

                                Navigator.of(context).pop();

                                print(
                                    'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

                                CreateTrip().endTrip(
                                    context: context,
                                    scaffoldKey: scaffoldKey,
                                    onEnded: () async {
                                      print('TRIPPPPPP ENDEDDD:');
                                      setState(() {
                                        isEndTripButton = false;
                                        tripIsEnded = true;
                                        // isZipFileCreate = true;
                                      });
                                      await tripIsRunningOrNot();
                                    });
                              }, () {
                                Navigator.of(context).pop();
                              });
                            })
                    : CommonButtons.getActionButton(
                        title: 'Start Trip',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: buttonBGColor,
                        borderColor: buttonBGColor,
                        width: displayWidth(context),
                        onTap: () async {
                          bool? isTripStarted =
                              sharedPreferences!.getBool('trip_started');

                          if (isTripStarted != null) {
                            if (isTripStarted) {
                              List<String>? tripData =
                                  sharedPreferences!.getStringList('trip_data');
                              Trip tripDetails =
                                  await _databaseService.getTrip(tripData![0]);

                              if (tripDetails.vesselId != widget.vessel!.id) {
                                showDialogBox();
                                return;
                              }
                            }
                          }

                          bool isLocationPermitted =
                              await Permission.locationAlways.isGranted;

                          if (isLocationPermitted) {
                            vessel!.add(widget.vessel!);
                            await locationPermissions(
                                widget.vessel!.vesselSize!,
                                widget.vessel!.name!,
                                widget.vessel!.id!);
                          } else {
                            /// WIU
                            bool isWIULocationPermitted =
                                await Permission.locationWhenInUse.isGranted;

                            if (!isWIULocationPermitted) {
                              await Utils.getLocationPermission(
                                  context, scaffoldKey);
                            }
                            /*setState(() {
                                  isLocationDialogBoxOpen = true;
                                });*/
                            bool isLocationPermitted =
                                await Permission.locationAlways.isGranted;
                            if (isLocationPermitted) {
                              /*setState(() {
                                    isLocationDialogBoxOpen = false;
                                  });*/
                              vessel!.add(widget.vessel!);
                              await locationPermissions(
                                  widget.vessel!.vesselSize!,
                                  widget.vessel!.name!,
                                  widget.vessel!.id!);
                            } else {
                              /*setState(() {
                                    isLocationDialogBoxOpen = false;
                                  });*/

                              if (!isLocationDialogBoxOpen) {
                                showDialog(
                                    context: scaffoldKey.currentContext!,
                                    builder: (BuildContext context) {
                                      isLocationDialogBoxOpen = true;
                                      return LocationPermissionCustomDialog(
                                        text:
                                            'Always Allow Access to “Location”',
                                        subText:
                                            "To track your trip while you use other apps we need background access to your location",
                                        buttonText: 'Ok',
                                        buttonOnTap: () async {
                                          //Navigator.pop(context);

                                          Get.back();

                                          /* var status = await Permission
                                            .locationWhenInUse.status;

                                        if (status ==
                                            PermissionStatus.granted) {
                                          Permission.locationAlways.request();
                                        }*/

                                          //  AppSettings.openLocationSettings(asAnotherTask: true);
                                          await openAppSettings();
                                          // Navigator.pop(context);
                                          // await Geolocator.openAppSettings();
                                        },
                                      );
                                    }).then((value) {
                                  isLocationDialogBoxOpen = false;
                                });
                              }
                              // await Permission.locationAlways.request();
                            }
                          }
                        }),
              ),
            )
          ],
        ),
      ),
    );
  }

  locationPermissions(dynamic size, String vesselName, String weight) async {
    if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        getBottomSheet(context, size, vesselName, weight, isLocationPermitted);
      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          getBottomSheet(
              context, size, vesselName, weight, isLocationPermitted);
        }
      }
    }
  }

  getBottomSheet(BuildContext context, dynamic size, String vesselName,
      String weight, bool isLocationPermission) async {
    isStartButton = false;
    isEndTripButton = false;
    isSensorDataUploaded = false;
    isZipFileCreate = false;
    addingDataToDB = false;
    selectedVesselWeight = 'Select Current Load';
    isBottomSheetOpened = true;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');
    double tripDistance = 0.0;
    int tripDuration = 0;
    String tripSpeed = '0.0';

    // initializeService();

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            if (!addingDataToDB) {
              print('gggg');
              Navigator.pop(context);
              return false;
            } else {
              print('rrr');
              return false;
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent.withOpacity(0.0),
            extendBody: false,
            key: _modelScaffoldKey,
            resizeToAvoidBottomInset: true,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(builder:
                  (BuildContext bottomSheetContext, StateSetter stateSetter) {
                /*service.on('tripAnalyticsData').listen((event) {
                  tripDistance = event!['tripDistance'];
                  tripDuration = event['tripDuration'];
                  tripSpeed = event['tripSpeed'].toString();

                  if (isBottomSheetOpened) {
                    if (mounted) stateSetter(() {});
                  }
                });*/
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
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
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /*isEndTripButton
                              ? Container(
                                  child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            commonText(
                                                context: context,
                                                text: Utils.calculateTripDuration(
                                                    (tripDuration / 1000)
                                                        .toInt()),
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
                                                text: '$tripSpeed nm/h',
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
                                                text:
                                                    '${tripDistance.toStringAsFixed(2)}m',
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
                                                '${ourDirectory!.path}/$getTripId.zip');

                                            print(
                                                'DIR PATH R ${ourDirectory!.path}');

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
                                  : */
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder(
                                  duration: const Duration(seconds: 3),
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
                                            color: Colors.green,
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
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                          context: context,
                                          text: 'Fetching your device details',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      TweenAnimationBuilder(
                                          duration: const Duration(seconds: 3),
                                          tween: Tween(
                                              begin: deviceProgressBegin,
                                              end: deviceProgress),
                                          builder: (context, double value, _) {
                                            return SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color:
                                                        circularProgressColor,
                                                    value: value,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                            Colors.green),
                                                  ),
                                                  Center(
                                                    child: subTitleProgress(
                                                        value,
                                                        displayWidth(context) *
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
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                                      seconds: 3),
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
                                                            color:
                                                                circularProgressColor,
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
                                      isLocationPermission
                                          ? SizedBox()
                                          : commonText(
                                              context: context,
                                              text: 'Permission Denied!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Accelerometer sensor',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          accelerometerAvailable!
                                              ? TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  tween: Tween(
                                                      begin:
                                                          accSensorProgressBegin,
                                                      end: accSensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color:
                                                                circularProgressColor,
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
                                                  })
                                              : SizedBox(
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
                                                ),
                                        ],
                                      ),
                                      accelerometerAvailable!
                                          ? Container()
                                          : commonText(
                                              context: context,
                                              text:
                                                  'We are unable to connect sensor!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'User Accelerometer Sensor',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          userAccelerometerAvailable!
                                              ? TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  tween: Tween(
                                                      begin:
                                                          uaccSensorProgressBegin,
                                                      end: uaccSensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color:
                                                                circularProgressColor,
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
                                                  })
                                              : SizedBox(
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
                                                ),
                                        ],
                                      ),
                                      userAccelerometerAvailable!
                                          ? Container()
                                          : commonText(
                                              context: context,
                                              text:
                                                  'We are unable to connect sensor!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Gyroscope',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          gyroscopeAvailable!
                                              ? TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  tween: Tween(
                                                      begin:
                                                          gyroSensorProgressBegin,
                                                      end: gyroSensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color:
                                                                circularProgressColor,
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
                                                  })
                                              : SizedBox(
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
                                                ),
                                        ],
                                      ),
                                      gyroscopeAvailable!
                                          ? Container()
                                          : commonText(
                                              context: context,
                                              text:
                                                  'We are unable to connect sensor!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Magnetometer',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          magnetometerAvailable!
                                              ? TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  tween: Tween(
                                                      begin:
                                                          magnSensorProgressBegin,
                                                      end: magnSensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color:
                                                                circularProgressColor,
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
                                                  })
                                              : SizedBox(
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
                                                ),
                                        ],
                                      ),
                                      magnetometerAvailable!
                                          ? Container()
                                          : commonText(
                                              context: context,
                                              text:
                                                  'We are unable to connect sensor!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                isZipFileCreate
                                    ? InkWell(
                                        onTap: () async {
                                          // File copiedFile = File('${ourDirectory!.path}/${getTripId}.zip');
                                          File copiedFile =
                                              File('${ourDirectory!.path}.zip');

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
                                              child: Icon(
                                                  Icons.file_download_outlined),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                const SizedBox(
                                  height: 40,
                                ),
                                StatefulBuilder(
                                  builder: (context, StateSetter stateSetter) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Container(
                                            height: displayHeight(context) >=
                                                    680
                                                ? displayHeight(context) * 0.056
                                                : displayHeight(context) * 0.07,
                                            alignment: Alignment.centerLeft,
                                            color: Color(0xFFECF3F9),
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                enabledBorder: InputBorder.none,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                0.0))),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5,
                                                    bottom: 5),
                                              ),

                                              child: commonText(
                                                  context: context,
                                                  text: vesselName,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black54,
                                                  textSize:
                                                      displayWidth(context) *
                                                          0.032,
                                                  textAlign: TextAlign.start),

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
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: displayHeight(context) >=
                                                    680
                                                ? displayHeight(context) * 0.056
                                                : displayHeight(context) * 0.07,
                                            color: Color(0xFFECF3F9),
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                enabledBorder: InputBorder.none,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                0.0))),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 10,
                                                    bottom: 10),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<dynamic>(
                                                  value: null,
                                                  isDense: true,
                                                  hint: commonText(
                                                      context: context,
                                                      text:
                                                          selectedVesselWeight,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: Colors.black54,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.032,
                                                      textAlign:
                                                          TextAlign.start),
                                                  //  Text(
                                                  //     '${selectedVesselWeight}'),
                                                  isExpanded: true,
                                                  items: [
                                                    DropdownMenuItem(
                                                        value: '1',
                                                        child: Text('Empty')),
                                                    DropdownMenuItem(
                                                        value: '2',
                                                        child: Text('Half')),
                                                    DropdownMenuItem(
                                                        value: '3',
                                                        child: Text('Full')),
                                                    DropdownMenuItem(
                                                        value: '4',
                                                        child:
                                                            Text('Variable')),
                                                  ],
                                                  onChanged: (weightValue) {
                                                    stateSetter(() {
                                                      if (int.parse(
                                                              weightValue) ==
                                                          1) {
                                                        selectedVesselWeight =
                                                            'Empty';
                                                      } else if (int.parse(
                                                              weightValue) ==
                                                          2) {
                                                        selectedVesselWeight =
                                                            'Half';
                                                      } else if (int.parse(
                                                              weightValue) ==
                                                          3) {
                                                        selectedVesselWeight =
                                                            'Full';
                                                      } else {
                                                        selectedVesselWeight =
                                                            'Variable';
                                                      }
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
                            //height: 50,
                            width: displayWidth(context),
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 17,
                                  right: 17,
                                  bottom:
                                      isStartButton || isEndTripButton ? 8 : 2),
                              child: isStartButton
                                  ? addingDataToDB
                                      ? Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      circularProgressColor)))
                                      : CommonButtons.getActionButton(
                                          title: 'Start',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.042,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: buttonBGColor,
                                          borderColor: buttonBGColor,
                                          width: displayWidth(context),
                                          onTap: () async {
                                            debugPrint(
                                                'SELECTED VESSEL WEIGHT $selectedVesselWeight');
                                            if (selectedVesselWeight ==
                                                'Select Current Load') {
                                              debugPrint(
                                                  'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Text(
                                                    "Please select current load"),
                                                duration: Duration(seconds: 1),
                                                backgroundColor: Colors.blue,
                                              ));
                                              return;
                                            }

                                            bool isLocationPermitted =
                                                await Permission
                                                    .location.isGranted;

                                            if (isLocationPermitted) {
                                              stateSetter(() {
                                                isLocationPermission = true;
                                              });

                                              final androidInfo =
                                                  await DeviceInfoPlugin()
                                                      .androidInfo;

                                              if (androidInfo.version.sdkInt <
                                                  29) {
                                                var isStoragePermitted =
                                                    await Permission
                                                        .storage.status;
                                                if (isStoragePermitted
                                                    .isGranted) {
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;

                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  } else {
                                                    await Utils
                                                        .getNotificationPermission(
                                                            context);
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;
                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    }
                                                  }
                                                } else {
                                                  await Utils
                                                      .getStoragePermission(
                                                          context);
                                                  final androidInfo =
                                                      await DeviceInfoPlugin()
                                                          .androidInfo;

                                                  var isStoragePermitted =
                                                      await Permission
                                                          .storage.status;

                                                  if (isStoragePermitted
                                                      .isGranted) {
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;

                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    } else {
                                                      await Utils
                                                          .getNotificationPermission(
                                                              context);
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;
                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      }
                                                    }
                                                  }
                                                }
                                              } else {
                                                bool isNotificationPermitted =
                                                    await Permission
                                                        .notification.isGranted;

                                                if (isNotificationPermitted) {
                                                  startWritingDataToDB(
                                                      bottomSheetContext,
                                                      stateSetter);
                                                } else {
                                                  await Utils
                                                      .getNotificationPermission(
                                                          context);
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;
                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  }
                                                }
                                              }
                                            } else {
                                              await Utils.getLocationPermission(
                                                  context, scaffoldKey);
                                              bool isLocationPermitted =
                                                  await Permission
                                                      .location.isGranted;

                                              if (isLocationPermitted) {
                                                stateSetter(() {
                                                  isLocationPermission = true;
                                                });
                                                // service.startService();

                                                final androidInfo =
                                                    await DeviceInfoPlugin()
                                                        .androidInfo;

                                                if (androidInfo.version.sdkInt <
                                                    29) {
                                                  var isStoragePermitted =
                                                      await Permission
                                                          .storage.status;
                                                  if (isStoragePermitted
                                                      .isGranted) {
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;

                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    } else {
                                                      await Utils
                                                          .getNotificationPermission(
                                                              context);
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;
                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      }
                                                    }
                                                  } else {
                                                    await Utils
                                                        .getStoragePermission(
                                                            context);
                                                    final androidInfo =
                                                        await DeviceInfoPlugin()
                                                            .androidInfo;

                                                    var isStoragePermitted =
                                                        await Permission
                                                            .storage.status;

                                                    if (isStoragePermitted
                                                        .isGranted) {
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;

                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      } else {
                                                        await Utils
                                                            .getNotificationPermission(
                                                                context);
                                                        bool
                                                            isNotificationPermitted =
                                                            await Permission
                                                                .notification
                                                                .isGranted;
                                                        if (isNotificationPermitted) {
                                                          startWritingDataToDB(
                                                              bottomSheetContext,
                                                              stateSetter);
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;

                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  } else {
                                                    await Utils
                                                        .getNotificationPermission(
                                                            context);
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;
                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    }
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
                                  /*: isEndTripButton
                                      ? addingDataToDB
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          circularProgressColor)))
                                          : CommonButtons.getActionButton(
                                              title: 'End Trip ',
                                              context: context,
                                              fontSize:
                                                  displayWidth(context) * 0.042,
                                              textColor: Colors.white,
                                              buttonPrimaryColor: buttonBGColor,
                                              borderColor: buttonBGColor,
                                              width: displayWidth(context),
                                              onTap: () async {
                                                stateSetter(() {
                                                  addingDataToDB = true;
                                                });

                                                CreateTrip().endTrip(
                                                    context: context,
                                                    scaffoldKey: scaffoldKey,
                                                    onEnded: () {
                                                      Future.delayed(Duration(
                                                              seconds: 3))
                                                          .then((value) {
                                                        if (mounted) {
                                                          stateSetter(() {
                                                            addingDataToDB =
                                                                false;
                                                            isEndTripButton =
                                                                false;
                                                            isZipFileCreate =
                                                                true;
                                                          });
                                                        }
                                                      });
                                                    });
                                              })
                                      : isZipFileCreate
                                          ? CommonButtons.getActionButton(
                                              title: 'Trip Ended',
                                              context: context,
                                              fontSize:
                                                  displayWidth(context) * 0.042,
                                              textColor: Colors.white,
                                              buttonPrimaryColor: buttonBGColor,
                                              borderColor: buttonBGColor,
                                              width: displayWidth(context),
                                              onTap: () async {
                                                await tripIsRunningOrNot();

                                                commonProvider.getTripsCount();

                                                final androidInfo =
                                                    await DeviceInfoPlugin()
                                                        .androidInfo;

                                                var isStoragePermitted =
                                                    androidInfo.version.sdkInt >
                                                            32
                                                        ? await Permission
                                                            .photos.status
                                                        : await Permission
                                                            .storage.status;
                                                if (isStoragePermitted
                                                    .isGranted) {
                                                  //File copiedFile = File('${ourDirectory!.path}.zip');
                                                  File copiedFile = File(
                                                      '${ourDirectory!.path}/$getTripId.zip');

                                                  print(
                                                      'DIR PATH R ${ourDirectory!.path}');

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
                                                    // Utils.showSnackBar(context,
                                                    //     scaffoldKey: scaffoldKey,
                                                    //     message:
                                                    //     'File downloaded successfully');
                                                  }
                                                } else {
                                                  await Utils
                                                      .getStoragePermission(
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
                                                          "storage/emulated/0/Download/$getTripId.zip");
                                                    } else {
                                                      directory =
                                                          await getApplicationDocumentsDirectory();
                                                    }

                                                    copiedFile
                                                        .copy(directory.path);

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

                                                Get.back();

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

                                                */ /*File file = File(zipFile!.path);
                                                Future.delayed(Duration(seconds: 1))
                                                    .then((value) {
                                                  stateSetter(() {
                                                    isZipFileCreate = true;
                                                  });
                                                });*/ /*
                                              })*/
                                  : Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: CommonButtons.getActionButton(
                                          title: 'Cancel',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.042,
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
                          ),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: addingDataToDB
                            ? SizedBox()
                            : Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: backgroundColor),
                                child: IconButton(
                                    onPressed: () async {
                                      isBottomSheetOpened = false;
                                      await tripIsRunningOrNot();
                                      setState(() {
                                        widget.vessel!.id = widget.vessel!.id;
                                      });

                                      // Get.back();

                                      stateSetter(() {
                                        addingDataToDB = false;
                                      });

                                      Navigator.of(bottomSheetContext).pop();
                                      /*if (isSensorDataUploaded) {

                                  //setState(() {
                                  // future = commonProvider.triplListData(
                                  //     context,
                                  //     commonProvider.loginModel!.token!,
                                  //     widget.vesselId.toString(),
                                  //     scaffoldKey);
                                  //});
                                } else {
                                  Get.back();
                                }*/
                                    },
                                    icon: Icon(Icons.close_rounded,
                                        color: buttonBGColor)),
                              ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
      elevation: 4,
      enableDrag: false,
    ).then((value) async {
      await tripIsRunningOrNot();
      print('BACK PRESSED');
      isBottomSheetOpened = false;
      /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => VesselSingleView(
                  vessel: widget.vessel,
                  isCalledFromSuccessScreen: widget.isCalledFromSuccessScreen,
                )),
      );*/

      addingDataToDB = false;
      isStartButton = false;
      isEndTripButton = true;

      if (tripIsRunning) {
        List<String>? tripData = sharedPreferences!.getStringList('trip_data');
        final tripDetails = await _databaseService.getTrip(tripData![0]);

        Navigator.pushReplacement(
          scaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => TripAnalyticsScreen(
                    tripId: tripDetails.id,
                    vesselId: widget.vessel!.id,
                    tripIsRunningOrNot: tripIsRunning,
                  )),
        );
      }
    });
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

  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = widget.vessel!.name;
    final currentLoad = selectedVesselWeight;
    Position? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);
    await fetchDeviceData();

    debugPrint('hello device details: ${deviceDetails!.toJson().toString()}');
    // debugPrint(" locationData!.latitude!.toString():${ locationData!.latitude!.toString()}");
    String latitude = locationData!.latitude.toString();
    String longitude = locationData.longitude.toString();

    debugPrint("current lod:$currentLoad");
    debugPrint("current PATH:$file");

    debugPrint("ON SAVE FIRST INSERT :$getTripId");

    try {
      await _databaseService.insertTrip(Trip(
          id: getTripId,
          vesselId: widget.vessel!.id,
          vesselName: vesselName,
          currentLoad: currentLoad,
          filePath: file,
          isSync: 0,
          tripStatus: 0,
          createdAt: Utils.getCurrentTZDateTime(),
          updatedAt: Utils.getCurrentTZDateTime(),
          startPosition: json.encode([latitude, longitude]),
          endPosition: json.encode([latitude, longitude]),
          deviceInfo: deviceDetails!.toJson().toString()));
    } on Exception catch (e) {
      print('ON SAVE EXE: $e');
    }
    return;
  }

  startWritingDataToDB(
      BuildContext bottomSheetContext, StateSetter stateSetter) async {
    bool isServiceRunning = await service.isRunning();

    print('ISSSSS XXXXXXX: $isServiceRunning');

    stateSetter(() {
      addingDataToDB = true;
    });

    if (!isServiceRunning) {
      await service.startService();
      // initializeService();
      print('View Single: $isServiceRunning');
    }

    getTripId = ObjectId().toString();

    await onSave('', bottomSheetContext, true);

    await Future.delayed(Duration(seconds: 4), () {
      print('Future delayed duration Ended');
    });

    // await tripIsRunningOrNot();

    service.invoke(
        'tripId', {'tripId': getTripId, 'vesselName': widget.vessel!.name});

    service.invoke("setAsForeground");

    service.invoke("onStartTrip");

    /*locationTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      Position? locationData = await Utils.getCurrentLocation();

      // location = Location();
      //
      // location!.onLocationChanged.listen((LocationData currentLocation) {
      //   print("${currentLocation.latitude} : ${currentLocation.longitude}");
      //   setState(() {
      //     locationData = currentLocation;
      //   });
      // });

      service.invoke('location', {
        'lat': locationData.latitude,
        'long': locationData.longitude,
      });
      // print(
      //     'SINGLE VIEW LAT LONG ${locationData.latitude} ${locationData.longitude}');
    });*/

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data', [
      getTripId,
      widget.vessel!.id!,
      widget.vessel!.name!,
      selectedVesselWeight
    ]);

    await tripIsRunningOrNot();

    Navigator.pop(bottomSheetContext);

    // Navigator.pushReplacement(
    //   scaffoldKey.currentContext!,
    //   MaterialPageRoute(
    //       builder: (context) => TripAnalyticsScreen(
    //             tripList: tripDetails,
    //             vessel: widget.vessel,
    //             tripIsRunningOrNot: tripIsRunning,
    //           )),
    // );
  }

  showDialogBox() {
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
                  height: displayHeight(context) * 0.3,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                      'There is a trip in progress from another vessel. Please end that trip and come back here.',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Center(
                          child: CommonButtons.getAcceptButton(
                              'OK', context, primaryColor, () async {
                            Navigator.of(context).pop();
                          },
                              displayWidth(context) * 0.4,
                              displayHeight(context) * 0.05,
                              primaryColor,
                              Colors.white,
                              displayHeight(context) * 0.018,
                              buttonBGColor,
                              '',
                              fontWeight: FontWeight.w500),
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
        });
  }
}
