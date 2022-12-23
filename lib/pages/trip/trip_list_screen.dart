import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/trip/trip_widget.dart';
import 'package:performarine/services/database_service.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';

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
  FlutterBackgroundService service = FlutterBackgroundService();

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

  final DatabaseService _databaseService = DatabaseService();

  late Future<List<Trip>> future;

  Future<List<Trip>> getTripListByVesselId(String id) async {
    return await _databaseService.getAllTripsByVesselId(id);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
            onTap: () {
              locationPermissions(
                  widget.vesselSize!, widget.vesselName!, widget.vesselId!);
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return snapshot.data!.isNotEmpty
                          ? TripWidget(
                              tripList: snapshot.data![index],
                              onTap: () async {
                                bool isServiceRunning =
                                    await service.isRunning();

                                print('IS SERVICE RUNNING: $isServiceRunning');

                                try {
                                  service.invoke('stopService');
                                  // instan.stopSelf();
                                } on Exception catch (e) {
                                  print('SERVICE STOP BG EXE: $e');
                                }

                                File? zipFile;
                                if (timer != null) timer!.cancel();
                                print(
                                    'TIMER STOPPED ${ourDirectory!.path}/${snapshot.data![index].id}');
                                final dataDir = Directory(
                                    '${ourDirectory!.path}/${snapshot.data![index].id}');

                                try {
                                  zipFile = File(
                                      '${ourDirectory!.path}/${snapshot.data![index].id}.zip');

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

                                await _databaseService.updateTripStatus(
                                    1,
                                    file.path,
                                    DateTime.now().toString(),
                                    snapshot.data![index].id!);

                                sharedPreferences!.remove('trip_data');

                                setState(() {
                                  future =
                                      _databaseService.getAllTripsByVesselId(
                                          widget.vesselId.toString());
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
                                              color: Colors.blue,
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
                                              color: Colors.blue,
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
                                                  color: Colors.blue,
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
                                      print(
                                          'TIMER STOPPED ${ourDirectory!.path}');
                                      final dataDir =
                                          Directory(ourDirectory!.path);

                                      try {
                                        zipFile =
                                            File('${ourDirectory!.path}.zip');

                                        ZipFile.createFromDirectory(
                                            sourceDir: dataDir,
                                            zipFile: zipFile,
                                            recurseSubDirs: true);
                                        print('our path is $dataDir');
                                      } catch (e) {
                                        print(e);
                                      }

                                      File file = File(zipFile!.path);
                                      Future.delayed(Duration(seconds: 1))
                                          .then((value) {
                                        stateSetter(() {
                                          isZipFileCreate = true;
                                        });
                                      });
                                      print('FINAL PATH: ${file.path}');
                                      onSave(file);

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
      /*shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),*/
      enableDrag: false,
    );

    /*return Get.bottomSheet(StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
      return Container(
        padding:
            const EdgeInsets.only(top: 25, bottom: 25, left: 10, right: 10),
        height: displayHeight(context) / 1.5,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      duration: const Duration(seconds: 5),
                      tween: Tween(begin: 0.0, end: 1.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, double value, _) {
                              return SizedBox(
                                height: 20,
                                width: 20,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.blue,
                                      value: value,
                                      backgroundColor: Colors.grey.shade200,
                                      strokeWidth: 2,
                                      valueColor: const AlwaysStoppedAnimation(
                                          Colors.green),
                                    ),
                                    Center(
                                      child: subTitleProgress(
                                          value, displayWidth(context) * 0.035),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, double value, _) {
                              return SizedBox(
                                height: 20,
                                width: 20,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.blue,
                                      value: value,
                                      backgroundColor: Colors.grey.shade200,
                                      strokeWidth: 2,
                                      valueColor: const AlwaysStoppedAnimation(
                                          Colors.green),
                                    ),
                                    Center(
                                      child: subTitleProgress(
                                          value, displayWidth(context) * 0.035),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
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
                          onTap: () {
                            fileName = '$fileIndex.csv';

                            Future.delayed(Duration(seconds: 1), () {
                              timer = Timer.periodic(const Duration(seconds: 1),
                                  (timer) {
                                writeSensorDataToFile();
                              });
                            });
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
                            //Navigator.of(context).pop();
                          }),
                ),
              )
            ],
          ),
        ),
      );
    }),
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        enableDrag: false,
        isScrollControlled: true);*/
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
    fileName = '$fileIndex.csv';

    debugPrint('CREATE TRIP $fileName');

    String? tripId;
    //getTripId = await getTripIdFromPref();
    print(widget.vesselId);
    writeSensorDataToFile(widget.vesselId!);
    stateSetter(() {
      isStartButton = false;
      isEndTripButton = true;
    });
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
    if (fileSize >= 10) {
      print('STOPPED WRITING');
      print('CREATING NEW FILE');
      // if (timer != null) timer!.cancel();
      // print('TIMER STOPPED');

      setState(() {
        fileIndex = fileIndex + 1;

        fileName = '$fileIndex.csv';

        print('FILE NAME: $fileName');
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

      // debugPrint('DATE ${finalString}');
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
      print('FILE SIZE: $sizeInMB');
      print('FILE SIZE KB: $sizeInKB');
      print('FINAL FILE SIZE: $finalSizeInMB');
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

    debugPrint('FOLDER PATHH $ourDirectory');
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

  deleteFolder() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    Directory ourDirectory = Directory('${appDirectory.path}/sensor');

    if (await ourDirectory.exists()) {
      Directory('${appDirectory.path}/sensor').delete(recursive: true);
    } else {
      debugPrint('Custom Direcotry deleted');
    }
  }

  Future<void> onSave(File file) async {
    final vesselName = widget.vesselName;
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
    var uuid = Uuid();
    final String getTripId = uuid.v1();
    await _databaseService.insertTrip(Trip(
        id: getTripId,
        vesselId: widget.vesselId,
        vesselName: vesselName,
        currentLoad: currentLoad,
        filePath: file.path,
        isSync: 0,
        tripStatus: 0,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        lat: latitude,
        long: longitude,
        deviceInfo: deviceDetails!.toJson().toString()));

    /*if (Platform.isAndroid) {
      bool isPermitted =
          await Utils.getLocationPermissions(context, scaffoldKey);
      print('ISPermitted: $isPermitted');
      if (isPermitted) {
        bool isGranted = await Permission.location.isGranted;
        // onPressed: () {
        isGranted
            ? showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter stateSetter) {
                    return Stack(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
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
                                        debugPrint('END here');
                                        stateSetter(() {
                                          isStartButton = true;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                const Duration(seconds: 5),
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                const Duration(seconds: 5),
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
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    isEndTripButton
                                        ? Row(
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
                                              InkWell(
                                                onTap: () async {
                                                  File copiedFile = File(
                                                      '${ourDirectory!.path}/$getTripId.zip');

                                                  Directory directory;

                                                  if (Platform.isAndroid) {
                                                    directory = Directory(
                                                        '${ourDirectory!.path}/$getTripId.zip');
                                                  } else {
                                                    directory =
                                                        await getApplicationDocumentsDirectory();
                                                  }

                                                  copiedFile
                                                      .copy(directory.path);

                                                  print(
                                                      'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                                  // Utils.download(context, scaffoldKey,ourDirectory!.path);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(Icons
                                                      .file_download_outlined),
                                                ),
                                              )
                                            ],
                                          )
                                        : SizedBox(),
                                    const SizedBox(
                                      height: 40,
                                    ),
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
                                          fontSize:
                                              displayWidth(context) * 0.042,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: buttonBGColor,
                                          borderColor: buttonBGColor,
                                          width: displayWidth(context),
                                          onTap: () async {
                                            setState(() {
                                              isStartButton = false;
                                              isEndTripButton = true;
                                            });

                                            fileName = '$fileIndex.csv';
                                            Future.delayed(Duration(seconds: 1),
                                                () {
                                              timer = Timer.periodic(
                                                  const Duration(seconds: 1),
                                                  (timer) {
                                                _streamSubscriptions.add(
                                                  accelerometerEvents.listen(
                                                    (AccelerometerEvent event) {
                                                      setState(() {
                                                        _accelerometerValues =
                                                            <double>[
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
                                                        _gyroscopeValues =
                                                            <double>[
                                                          event.x,
                                                          event.y,
                                                          event.z
                                                        ];
                                                      });
                                                    },
                                                  ),
                                                );
                                                _streamSubscriptions.add(
                                                  userAccelerometerEvents
                                                      .listen(
                                                    (UserAccelerometerEvent
                                                        event) {
                                                      setState(() {
                                                        _userAccelerometerValues =
                                                            <double>[
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
                                                        _magnetometerValues =
                                                            <double>[
                                                          event.x,
                                                          event.y,
                                                          event.z
                                                        ];
                                                      });
                                                    },
                                                  ),
                                                );

                                                writeSensorDataToFile(
                                                    getTripId);
                                              });
                                            });
                                          })
                                      : isEndTripButton
                                          ? CommonButtons.getActionButton(
                                              title: 'End Trip',
                                              context: context,
                                              fontSize:
                                                  displayWidth(context) * 0.042,
                                              textColor: Colors.white,
                                              buttonPrimaryColor: buttonBGColor,
                                              borderColor: buttonBGColor,
                                              width: displayWidth(context),
                                              onTap: () async {
                                                // getTripId = await getTripIdFromPref();
                                                stateSetter(() {
                                                  isEndTripButton = false;
                                                });

                                                File? zipFile;
                                                if (timer != null)
                                                  timer!.cancel();
                                                print(
                                                    'TIMER STOPPED ${ourDirectory!.path}');
                                                final dataDir = Directory(
                                                    ourDirectory!.path);

                                                try {
                                                  zipFile = File(
                                                      '${ourDirectory!.path}.zip');

                                                  ZipFile.createFromDirectory(
                                                      sourceDir: dataDir,
                                                      zipFile: zipFile,
                                                      recurseSubDirs: true);
                                                  print('our path is $dataDir');
                                                  Get.back();
                                                } catch (e) {
                                                  print('EXEEE: $e');
                                                }
                                                File file = File(zipFile!.path);
                                                print(
                                                    'FINAL PATH: ${file.path}');
                                                // onSave(file);
                                              })
                                          : CommonButtons.getActionButton(
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
                                                Navigator.of(context).pop();
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
                                  Get.back();
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.close_rounded,
                                    color: buttonBGColor)),
                          ),
                        )
                      ],
                    );
                  });
                })
            : Container();
      }

      // Navigator.pop(context);
    }*/
  }
}
