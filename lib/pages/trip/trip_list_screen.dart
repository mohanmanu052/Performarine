import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../common_widgets/widgets/log_level.dart';
import '../../models/trip.dart';

class TripListScreen extends StatefulWidget {
  final String? vesselId, vesselName;
  final int? vesselSize;
  const TripListScreen(
      {Key? key, this.vesselId, this.vesselName, this.vesselSize})
      : super(key: key);

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  Directory? ourDirectory;
  bool isStartButton = false,
      isEndTripButton = false,
      isZipFileCreate = false,
      isSensorDataUploaded = false;

  double progress = 1.0;
  double deviceProgress = 1.0;
  double sensorProgress = 1.0;

  double progressBegin = 0.0;
  double deviceProgressBegin = 0.0;
  double sensorProgressBegin = 0.0;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Timer? timer;
  String fileName = '';
  int fileIndex = 1;
  String? latitude, longitude;
  String getTripId = '';

  String selectedVesselWeight = 'Select Current Load';

  String page = "Trip_list_screen";

  final DatabaseService _databaseService = DatabaseService();

  late Future<List<Trip>> future;

  DeviceInfo? deviceDetails;
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
    Utils.customPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
    loggD.d("deviceDetails:${deviceDetails!.toJson().toString()} -> $page ${DateTime.now()}");
    loggV.v("deviceDetails:${deviceDetails!.toJson().toString()} -> $page ${DateTime.now()}");
  }

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

    future = _databaseService.getAllTripsByVesselId(widget.vesselId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: commonText(
            context: context,
            text: 'Trips',
            fontWeight: FontWeight.w700,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.05,
            textAlign: TextAlign.start),
      ),
      body: Stack(
        children: [
          TripViewBuilder(widget.vesselId.toString()),
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
                  onTap: () {
                    locationPermissions(widget.vesselSize!, widget.vesselName!,
                        widget.vesselId!);

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
                            _gyroscopeValues = <double>[
                              event.x,
                              event.y,
                              event.z
                            ];
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
                            _magnetometerValues = <double>[
                              event.x,
                              event.y,
                              event.z
                            ];
                          });
                        },
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  TripViewBuilder(String id) {
    return FutureBuilder<List<Trip>>(
      future: future,
      builder: (context, snapshot) {
        return snapshot.data != null
            ? StatefulBuilder(
                builder: (BuildContext context, StateSetter setter) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return snapshot.data!.isNotEmpty
                          ? TripWidget(
                              scaffoldKey: scaffoldKey,
                              tripList: snapshot.data![index],
                              onTap: () async {
                                setState(() {
                                  snapshot.data![index].isEndTripClicked = true;
                                });

                                final currentTrip = await _databaseService
                                    .getTrip(snapshot.data![index].id!);

                                DateTime createdAtTime =
                                    DateTime.parse(currentTrip.createdAt!);

                                var durationTime = DateTime.now()
                                    .toUtc()
                                    .difference(createdAtTime);
                                String tripDuration =
                                    Utils.calculateTripDuration(
                                        ((durationTime.inMilliseconds) / 1000)
                                            .toInt());

                                String? tripDistance = sharedPreferences!.getString('tripDistance') ?? "0";
                                String? tripSpeed = sharedPreferences!.getString('tripSpeed') ?? "0.1";
                                String? tripAvgSpeed = sharedPreferences!.getString('tripAvgSpeed') ?? "0.1";

                                debugPrint("ERROR ERROR $tripDistance\n$tripSpeed\ntripAvgSpeed");
                                loggE.e("ERROR ERROR $tripDistance\n$tripSpeed\ntripAvgSpeed -> $page ${DateTime.now()}");
                                loggV.v("ERROR ERROR $tripDistance\n$tripSpeed\ntripAvgSpeed  -> $page ${DateTime.now()}");

                                EndTrip().endTrip(
                                    context: context,
                                    scaffoldKey: scaffoldKey,
                                    duration: tripDuration,
                                    /*IOSAvgSpeed: tripAvgSpeed,
                                    IOSpeed: tripSpeed,
                                    IOStripDistance: tripDistance,*/
                                    onEnded: () {
                                      setState(() {
                                        future = _databaseService
                                            .getAllTripsByVesselId(
                                                widget.vesselId.toString());
                                      });
                                    });
                              })
                          : commonText(
                              text: 'oops! No Trips are added yet',
                              context: context,
                              textSize: displayWidth(context) * 0.04,
                              textColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500);
                    },
                  ),
                );
              })
            : Container(
                child: commonText(
                    text: 'oops! No Trips are added yet',
                    context: context,
                    textSize: displayWidth(context) * 0.04,
                    textColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500),
              );
      },
    );
  }

  locationPermissions(int size, String vesselName, String weight) async {
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

  getBottomSheet(BuildContext context, int size, String vesselName,
      String weight, bool isLocationPermission) async {
    isStartButton = false;
    isEndTripButton = false;
    isSensorDataUploaded = false;
    isZipFileCreate = false;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    scaffoldKey.currentState!.showBottomSheet(
      (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(seconds: 5),
                            tween: Tween(begin: progressBegin, end: progress),
                            builder: (context, double value, _) {
                              return SizedBox(
                                height: 80,
                                width: 80,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey.shade200,
                                      strokeWidth: 3,
                                      color: circularProgressColor,
                                    ),
                                    Center(
                                      child: buildProgress(value, 60),
                                    )
                                  ],
                                ),
                              );
                            },
                            onEnd: () {
                              Utils.customPrint('END');
                              loggD.d('END -> $page ${DateTime.now()}');
                              loggV.v('END -> $page ${DateTime.now()}');
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
                                horizontal: displayWidth(context) * 0.15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: 'Fetching your device details',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.032,
                                    textAlign: TextAlign.start),
                                const SizedBox(
                                  width: 20,
                                ),
                                TweenAnimationBuilder(
                                    duration: const Duration(seconds: 5),
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
                                              color: circularProgressColor,
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
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: displayWidth(context) * 0.15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonText(
                                    context: context,
                                    text: 'Connecting with your Sensors',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.032,
                                    textAlign: TextAlign.start),
                                const SizedBox(
                                  width: 20,
                                ),
                                TweenAnimationBuilder(
                                    duration: const Duration(seconds: 5),
                                    tween: Tween(
                                        begin: sensorProgressBegin,
                                        end: sensorProgress),
                                    builder: (context, double value, _) {
                                      return SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              color: circularProgressColor,
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
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: displayWidth(context) * 0.15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonText(
                                    context: context,
                                    text: isLocationPermission
                                        ? 'Location permission granted'
                                        : 'Location permission is required',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.032,
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
                                                  color: Colors.red, width: 2),
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
                                        duration: const Duration(seconds: 5),
                                        tween: Tween(
                                            begin: sensorProgressBegin,
                                            end: sensorProgress),
                                        builder: (context, double value, _) {
                                          return SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: circularProgressColor,
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
                            height: 40,
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
                                          "storage/emulated/0/Download/${widget.vesselId}.zip");
                                    } else {
                                      directory =
                                          await getApplicationDocumentsDirectory();
                                    }

                                    copiedFile.copy(directory.path);

                                    Utils.customPrint(
                                        'DOES FILE EXIST: ${copiedFile.existsSync()}');
                                    loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
                                    loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

                                    if (copiedFile.existsSync()) {
                                      Utils.showSnackBar(context,
                                          scaffoldKey: scaffoldKey,
                                          message:
                                              'File downloaded successfully');
                                    }

                                    // Utils.download(context, scaffoldKey,ourDirectory!.path);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      commonText(
                                          context: context,
                                          text: 'Download File',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.038,
                                          textAlign: TextAlign.start),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            Icon(Icons.file_download_outlined),
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
                                            color: backgroundColor,
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
                                            color: backgroundColor,
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
                                                      int.parse(weightValue) ==
                                                              1
                                                          ? selectedVesselWeight =
                                                              'Empty'
                                                          : (int.parse(weightValue) ==
                                                                  2
                                                              ? selectedVesselWeight =
                                                                  'Half'
                                                              : (int.parse(
                                                                          weightValue) ==
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
                        color: Colors.red,
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
                                  bool isLocationPermitted =
                                      await Permission.location.isGranted;

                                  if (isLocationPermitted) {
                                    /// TODO Further Process
                                    await getLocationData();

                                    /// SAVED Sensor data
                                    startSensorFunctionality(stateSetter);
                                  } else {
                                    await Utils.getLocationPermission(
                                        context, scaffoldKey);
                                    bool isLocationPermitted =
                                        await Permission.location.isGranted;

                                    if (isLocationPermission) {
                                      /// TODO Further Process
                                      await getLocationData();

                                      /// SAVED Sensor data
                                      startSensorFunctionality(stateSetter);
                                    }
                                  }
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

                                      File? zipFile;
                                      if (timer != null) timer!.cancel();
                                      Utils.customPrint(
                                          'TIMER STOPPED ${ourDirectory!.path}');
                                      loggD.d('TIMER STOPPED ${ourDirectory!.path} -> $page ${DateTime.now()}');
                                      loggV.v('TIMER STOPPED ${ourDirectory!.path} -> $page ${DateTime.now()}');
                                      final dataDir =
                                          Directory(ourDirectory!.path);

                                      try {
                                        zipFile =
                                            File('${ourDirectory!.path}.zip');

                                        ZipFile.createFromDirectory(
                                            sourceDir: dataDir,
                                            zipFile: zipFile,
                                            recurseSubDirs: true);
                                        Utils.customPrint(
                                            'our path is $dataDir');
                                        loggD.d('our path is $dataDir -> $page ${DateTime.now()}');
                                        loggV.v('our path is $dataDir -> $page ${DateTime.now()}');
                                      } catch (e) {
                                        Utils.customPrint('$e');
                                        loggE.e('$e -> $page ${DateTime.now()}');
                                        loggV.v('$e -> $page ${DateTime.now()}');
                                      }

                                      File file = File(zipFile!.path);
                                      Future.delayed(Duration(seconds: 1))
                                          .then((value) {
                                        stateSetter(() {
                                          isZipFileCreate = true;
                                        });
                                      });
                                      Utils.customPrint(
                                          'FINAL PATH: ${file.path}');
                                      loggD.d('FINAL PATH: ${file.path} -> $page ${DateTime.now()}');
                                      loggV.v('FINAL PATH: ${file.path} -> $page ${DateTime.now()}');
                                      onSave(file);
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
                        if (isSensorDataUploaded) {
                          Get.back();
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

  Future<void> getLocationData() async {
    latitude = '0.0';
    longitude = '0.0';

    Utils.customPrint('LAT ${latitude}');
    Utils.customPrint('LONG ${longitude}');

    loggD.d('LAT ${latitude} -> $page ${DateTime.now()}');
    loggD.d('LONG ${longitude} -> $page ${DateTime.now()}');

    loggV.v('LAT ${latitude} -> $page ${DateTime.now()}');
    loggV.v('LONG ${longitude} -> $page ${DateTime.now()}');

    return;
  }

  startSensorFunctionality(StateSetter stateSetter) async {
    fileName = '$fileIndex.csv';

    Utils.customPrint('CREATE TRIP $fileName');
    loggD.d('CREATE TRIP $fileName -> $page ${DateTime.now()}');
    loggV.v('CREATE TRIP $fileName -> $page ${DateTime.now()}');
    Utils.customPrint(widget.vesselId.toString());
    loggD.d(widget.vesselId.toString() + ' -> $page ${DateTime.now()}');
    loggV.v(widget.vesselId.toString() + ' -> $page ${DateTime.now()}');
    writeSensorDataToFile(widget.vesselId!);
    stateSetter(() {
      isStartButton = false;
      isEndTripButton = true;
    });
  }

  void writeSensorDataToFile(String tripId) async {
    String filePath = await getFile(tripId);
    File file = File(filePath);

    int fileSize = await checkFileSize(file);

    /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
    if (fileSize >= 10) {
      Utils.customPrint('STOPPED WRITING');
      Utils.customPrint('CREATING NEW FILE');

      loggD.d('STOPPED WRITING  -> $page ${DateTime.now()}');
      loggD.d('CREATING NEW FILE -> $page ${DateTime.now()}');

      loggV.v('STOPPED WRITING  -> $page ${DateTime.now()}');
      loggV.v('CREATING NEW FILE -> $page ${DateTime.now()}');
      // if (timer != null) timer!.cancel();
      // Utils.customPrint('TIMER STOPPED');

      setState(() {
        fileIndex = fileIndex + 1;

        fileName = '$fileIndex.csv';

        Utils.customPrint('FILE NAME: $fileName');
        loggD.d('FILE NAME: $fileName -> $page ${DateTime.now()}');
        loggV.v('FILE NAME: $fileName -> $page ${DateTime.now()}');
      });
      Utils.customPrint('NEW FILE CREATED');
      loggD.d('NEW FILE CREATED -> $page ${DateTime.now()}');
      loggV.v('NEW FILE CREATED -> $page ${DateTime.now()}');

      /// STOP WRITING & CREATE NEW FILE
    } else {
      Utils.customPrint('WRITING');
      loggD.d('WRITING -> $page ${DateTime.now()}');
      loggV.v('WRITING -> $page ${DateTime.now()}');

      latitude = '0.0';
      longitude = '0.0';

      Utils.customPrint('LAT ${latitude}');
      Utils.customPrint('LONG ${longitude}');

      loggD.d('LAT ${latitude} -> $page ${DateTime.now()}');
      loggD.d('LONG ${longitude} -> $page ${DateTime.now()}');

      loggV.v('LAT ${latitude} -> $page ${DateTime.now()}');
      loggV.v('LONG ${longitude} -> $page ${DateTime.now()}');

      String acc = convertDataToString('AAC', _accelerometerValues ?? []);
      String uacc = convertDataToString('UACC', _userAccelerometerValues ?? []);
      String gyro = convertDataToString('GYRO', _gyroscopeValues ?? []);
      String mag = convertDataToString('MAG', _magnetometerValues ?? []);
      String location = '$latitude $longitude';
      String gps = convertLocationToString('GPS', location);

      String finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

      file.writeAsString('$finalString\n', mode: FileMode.append);
    }
  }

  Future<String> getFile(String tripId) async {
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
      Utils.customPrint('FILE SIZE: $sizeInMB');
      Utils.customPrint('FILE SIZE KB: $sizeInKB');
      Utils.customPrint('FINAL FILE SIZE: $finalSizeInMB');

      loggD.d('FILE SIZE: $sizeInMB -> $page ${DateTime.now()}');
      loggD.d('FILE SIZE KB: $sizeInKB -> $page ${DateTime.now()}');
      loggD.d('FINAL FILE SIZE: $finalSizeInMB -> $page ${DateTime.now()}');

      loggV.v('FILE SIZE: $sizeInMB -> $page ${DateTime.now()}');
      loggV.v('FILE SIZE KB: $sizeInKB -> $page ${DateTime.now()}');
      loggV.v('FINAL FILE SIZE: $finalSizeInMB -> $page ${DateTime.now()}');
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
    return '$type,$todayDate,$replaceAll';
  }

  Future<String> getOrCreateFolder(String tripId) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    Utils.customPrint('FOLDER PATHH $ourDirectory');
    loggD.d('FOLDER PATHH $ourDirectory -> $page ${DateTime.now()}');
    loggV.v('FOLDER PATHH $ourDirectory -> $page ${DateTime.now()}');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await ourDirectory!.exists())) {
      return ourDirectory!.path;
    } else {
      ourDirectory!.create();
      return ourDirectory!.path;
    }
  }

  Future<void> onSave(File file) async {
    final vesselName = widget.vesselName;
    final currentLoad = selectedVesselWeight;
    await fetchDeviceData();

    String latitude = '0.0';
    String longitude = '0.0';

    Utils.customPrint("current lod:$currentLoad");
    loggD.d('current lod:$currentLoad -> $page ${DateTime.now()}');
    loggV.v('current lod:$currentLoad -> $page ${DateTime.now()}');
    final String getTripId = ObjectId().toString();
    await _databaseService.insertTrip(Trip(
        id: getTripId,
        vesselId: widget.vesselId,
        vesselName: vesselName,
        currentLoad: currentLoad,
        filePath: file.path,
        isSync: 0,
        tripStatus: 0,
        createdAt: DateTime.now().toUtc().toString(),
        updatedAt: DateTime.now().toUtc().toString(),
        startPosition: [latitude, longitude].join(","),
        endPosition: [latitude, longitude].join(","),
        deviceInfo: deviceDetails!.toJson().toString()));
  }
}
