import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/utils.dart';
import 'package:flutter_sqflite_example/models/breed.dart';
import 'package:flutter_sqflite_example/models/dog.dart';
import 'package:flutter_sqflite_example/services/database_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../models/device_model.dart';
import '../widgets/common_buttons.dart';
import '../widgets/common_widgets.dart';

class BreedFormPage extends StatefulWidget {
  final List<CreateVessel>? vessels;

  const BreedFormPage({Key? key, this.vessels}) : super(key: key);

  @override
  _BreedFormPageState createState() => _BreedFormPageState();
}

class _BreedFormPageState extends State<BreedFormPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final scaffoldState = GlobalKey<ScaffoldState>();
  String getTripId = 'sensorData';
  Directory? ourDirectory;
  bool isStartButton = false, isEndTripButton = false;

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
  var androidDeviceData;
  var IosDeviceData;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  Timer? timer;
  String fileName = '';
  int fileIndex = 1;
  String? latitude, longitude;

  DeviceInfo? deviceDetails;
  // String? vesselName;
  // String? vesselCurrentLoad;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _controller = new TextEditingController();

  // List<CreateVessel>? vessels;
  var items = [
    'Working a lot harder',
    'Being a lot smarter',
    'Being a self-starter',
    'Placed in charge of trading charter'
  ];
  final DatabaseService _databaseService = DatabaseService();
  Future<void> _onSave() async {
    final vesselName = _nameController.text;
    final currentLoad = _descController.text;

    await _databaseService
        .insertTrip(Breed(vesselName: vesselName, currentLoad: currentLoad));
    //Todo: @bhargava Need to navigate to create trip screen and save the sensor data and given option to download
    // Navigator.pop(context);
    locationPermissions(displaySize(context), vesselName, currentLoad,);
    // Utils.showSnackBar(context,scaffoldKey: scaffoldKey,duration: 3,message: 'Hai',status: true);
  }
  @override
  void initState() {
    fileName = '$fileIndex.csv';
    fetchDeviceInfo();
    fetchDeviceData();
    getLocationData();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
            (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
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
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
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
    super.initState();
  }
  fetchDeviceInfo() {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceData = deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      IosDeviceData = deviceInfoPlugin.iosInfo;
    }
  }
  fetchDeviceData() async {
    Platform.isAndroid
        ? androidDeviceInfo = await androidDeviceData
        : iosDeviceInfo = await IosDeviceData;
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
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      appBar: AppBar(
        title: Text('Start Trip'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField(
            //   controller: _nameController,
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //     hintText: 'Vessel Name',
            //   ),
            // ),
            // SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Vessel Name',
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    _nameController.text = value;
                  },
                  itemBuilder: (BuildContext context) {
                    List<String> data = [];
                    widget.vessels!.forEach((value) {
                      data.add(value.vesselName!.toString());
                    });
                    return data.map<PopupMenuItem<String>>((String value) {
                      return new PopupMenuItem(
                          child: new Text(value), value: value);
                    }).toList();
                  },
                ),
              ),
            ),

            SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              // maxLines: 7,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Current Load',
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 65.0,
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          onPressed: _onSave,
          child: Text(
            'Start Trip',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
  locationPermissions(Size? size, String? vesselName, String? weight) async {
    if (Platform.isAndroid) {
      bool isPermitted =
      await Utils.getLocationPermissions(context, scaffoldKey);
      print('ISPermitted: $isPermitted');
      if (isPermitted) {
        bool isGranted = await Permission.location.isGranted;
        if (isGranted) {
          getBottomSheet(context, size!, vesselName!, weight!,scaffoldKey);
        } else {
          debugPrint('OTHER ELSE');
        }
        ;
      }
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
  getBottomSheet(
      BuildContext context, Size size, String vesselName, String load,GlobalKey<ScaffoldState>? scaffoldKey) async {
    isStartButton = false;
    isEndTripButton = false;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    scaffoldState?.currentState?.showBottomSheet(
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
                                                child: subTitleProgress(value,
                                                    displayWidth(context) * 0.035),
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
                                                child: subTitleProgress(value,
                                                    displayWidth(context) * 0.035),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  commonText(
                                      context: context,
                                      text: 'Download File',
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.black,
                                      textSize: displayWidth(context) * 0.038,
                                      textAlign: TextAlign.start),
                                  InkWell(
                                    onTap: () async {
                                      File copiedFile = File(
                                          '${ourDirectory!.path}/${getTripId}.zip');

                                      Directory directory;

                                      if (Platform.isAndroid) {
                                        directory = Directory(
                                            "storage/emulated/0/Download/${getTripId}.zip");
                                      } else {
                                        directory =
                                        await getApplicationDocumentsDirectory();
                                      }

                                      copiedFile.copy(directory.path);

                                      print(
                                          'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                      // Utils.download(context, scaffoldKey,ourDirectory!.path);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                      Icon(Icons.file_download_outlined),
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
                                fontSize: displayWidth(context) * 0.042,
                                textColor: Colors.white,
                                buttonPrimaryColor: buttonBGColor,
                                borderColor: buttonBGColor,
                                width: displayWidth(context),
                                onTap: () async {
                                  fileName = '$fileIndex.csv';

                                  // _streamSubscriptions.add(
                                  //   accelerometerEvents.listen(
                                  //         (AccelerometerEvent event) {
                                  //       setState(() {
                                  //         _accelerometerValues = <double>[event.x, event.y, event.z];
                                  //       });
                                  //     },
                                  //   ),
                                  // );
                                  // _streamSubscriptions.add(
                                  //   gyroscopeEvents.listen(
                                  //         (GyroscopeEvent event) {
                                  //       setState(() {
                                  //         _gyroscopeValues = <double>[event.x, event.y, event.z];
                                  //       });
                                  //     },
                                  //   ),
                                  // );
                                  // _streamSubscriptions.add(
                                  //   userAccelerometerEvents.listen(
                                  //         (UserAccelerometerEvent event) {
                                  //       setState(() {
                                  //         _userAccelerometerValues = <double>[event.x, event.y, event.z];
                                  //       });
                                  //     },
                                  //   ),
                                  // );
                                  // _streamSubscriptions.add(
                                  //   magnetometerEvents.listen(
                                  //         (MagnetometerEvent event) {
                                  //       setState(() {
                                  //         _magnetometerValues = <double>[event.x, event.y, event.z];
                                  //       });
                                  //     },
                                  //   ),
                                  // );


                                  Future.delayed(Duration(seconds: 1), () {
                                    timer = Timer.periodic(
                                        const Duration(seconds: 1), (timer) {
                                      writeSensorDataToFile(getTripId);
                                      stateSetter(() {
                                        isStartButton = false;
                                        isEndTripButton = true;
                                      });
                                    });
                                  });
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
                                    zipFile = await File(
                                        '${ourDirectory!.path}.zip');

                                    ZipFile.createFromDirectory(
                                        sourceDir: dataDir,
                                        zipFile: zipFile,
                                        recurseSubDirs: true);
                                    print('our path is $dataDir');
                                  } catch (e) {
                                    print(e);
                                  }
                                  File file = File(zipFile!.path);
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
                            Get.back();
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

    debugPrint('FOLDER PATH $ourDirectory');
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

  Future<String> getFile(String tripId) async {
    String folderPath = await getOrCreateFolder(tripId);

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
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

      String latitude = locationData!.latitude!.toString();
      String longitude = locationData.longitude!.toString();

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

}
