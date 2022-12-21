import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../main.dart';

// bool? isSatrt;
// Timer? timer;
// Directory? ourDirectory;

class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  String text = "Stop Service";
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Timer? timer1;
  String fileName = '';
  int fileIndex = 1;

  FlutterBackgroundService service = FlutterBackgroundService();
  bool isRunning = false;

  @override
  void initState() {
    super.initState();

    getIfServiceIsRunning();

    fileName = '$fileIndex.csv';

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
  }

  getIfServiceIsRunning() async {
    bool data = await service.isRunning();
    print('IS RUNNING: $data');
    setState(() {
      isRunning = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
              onPressed: () {
                deleteFolder();
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Text(
                      'Accelerometer: $_accelerometerValues',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Text(
                      'UserAccelerometer: $_accelerometerValues',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Gyroscope: $_gyroscopeValues',
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Magnetometer: $_magnetometerValues',
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            width: size.width,
            height: 40,
            child: ElevatedButton(
                onPressed: () async {
                  if (isRunning) {
                    service.invoke("stopService");
                    text = 'Stop Service';

                    isStart = true;
                    if (timer != null) timer!.cancel();
                    print('TIMER STOPPED ${ourDirectory?.path ?? ''}');
                    final dataDir = Directory(ourDirectory?.path ?? '');
                    try {
                      final zipFile =
                          File('${ourDirectory?.path ?? ''}/sensor.zip');
                      ZipFile.createFromDirectory(
                          sourceDir: dataDir,
                          zipFile: zipFile,
                          recurseSubDirs: true);
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    isStart = false;
                    text = 'Start Service';

                    service.startService();
                    // service.invoke('noti_data', {});
                  }

                  getIfServiceIsRunning();
                  setState(() {});
                },
                child: Text(!isRunning ? 'Start Trip' : 'End Trip')),
          ),
          ElevatedButton(
              onPressed: () async {
                File copiedFile = File('${ourDirectory!.path}/sensor.zip');

                Directory directory;

                if (Platform.isAndroid) {
                  directory =
                      Directory("storage/emulated/0/Download/sensor.zip");
                  print(directory);
                } else {
                  directory = await getApplicationDocumentsDirectory();
                }

                await copiedFile.copy(directory.path);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Download sucessfully')));
              },
              child: const Text('Download Data'))
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String convertDataToString(String type, List<double> sensorData) {
    String? input = sensorData.toString();
    final removedBrackets = input.substring(1, input.length - 1);
    var replaceAll = removedBrackets.replaceAll(" ", "");
    return '$type,$replaceAll';
  }

  Future<String> getOrCreateFolder() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/sensor');

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

  Future<String> getFile() async {
    String folderPath = await getOrCreateFolder();

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
  }

  void writeSensorDataToFile() async {
    String filePath = await getFile();
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
      String acc = convertDataToString('AAC', _accelerometerValues!);
      String uacc = convertDataToString('UACC', _userAccelerometerValues!);
      String gyro = convertDataToString('GYRO', _gyroscopeValues!);
      String mag = convertDataToString('MAG', _magnetometerValues!);
      String finalString = '$acc\n$uacc\n$gyro\n$mag';

      file.writeAsString('$finalString\n', mode: FileMode.append);
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

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
