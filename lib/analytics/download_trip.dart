import 'dart:io';
import 'package:dio/dio.dart' as d;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_widgets/widgets/log_level.dart';

class DownloadTrip {
  String page = "Download_trip";
  /// To Download trip
  Future<String> downloadTrip(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripId) async {

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

    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
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

    String downloadedZipPath = '';
    Utils.customPrint('DOWLOAD Started!!!');
    loggD.d('DOWLOAD Started!!! -> $page ${DateTime.now()}');
    loggV.v('DOWLOAD Started!!! -> $page ${DateTime.now()}');

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      var isStoragePermitted;
      if (androidInfo.version.sdkInt < 29) {
        isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

          Utils.customPrint('DIR PATH R ${ourDirectory!.path}');
          loggD.d('DIR PATH R ${ourDirectory!.path} -> $page ${DateTime.now()}');
          loggV.v('DIR PATH R ${ourDirectory!.path} -> $page ${DateTime.now()}');

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory("storage/emulated/0/Download/${tripId}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          copiedFile.copy(directory.path);
          downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
          loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
          loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

          if (copiedFile.existsSync()) {
            Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
            loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
            loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
            Utils.showSnackBar(
              context,
              scaffoldKey: scaffoldKey,
              message: 'File downloaded successfully',
            );
          }
        } else {
          await Utils.getStoragePermission(context);
          var isStoragePermitted = await Permission.storage.status;

          if (isStoragePermitted.isGranted) {
            File copiedFile = File('${ourDirectory!.path}.zip');

            Directory directory;

            if (Platform.isAndroid) {
              directory =
                  Directory("storage/emulated/0/Download/${tripId}.zip");
            } else {
              directory = await getApplicationDocumentsDirectory();
            }

            copiedFile.copy(directory.path);
            downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

            Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
            loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
            loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

            if (copiedFile.existsSync()) {
              Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
              loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
              loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
              Utils.showSnackBar(
                context,
                scaffoldKey: scaffoldKey,
                message: 'File downloaded successfully',
              );
            }
          }
        }
      } else {
        //File copiedFile = File('${ourDirectory!.path}.zip');
        File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

        Utils.customPrint('DIR PATH RT ${copiedFile.path}');
        Utils.customPrint('DIR PATH RT ${copiedFile.existsSync()}');
        loggD.d('DIR PATH RT ${copiedFile.path} -> $page ${DateTime.now()}');
        loggD.d('DIR PATH RT ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
        loggV.v('DIR PATH RT ${copiedFile.path} -> $page ${DateTime.now()}');
        loggV.v('DIR PATH RT ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory("storage/emulated/0/Download/${tripId}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);
        downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
        loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
        loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

        if (copiedFile.existsSync()) {
          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
          loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
          loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
          Utils.showSnackBar(
            context,
            scaffoldKey: scaffoldKey,
            message: 'File downloaded successfully',
          );
        }
      }
    } else {
      File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

      Utils.customPrint('DIR PATH RT ${copiedFile.path}');
      Utils.customPrint('DIR PATH RT ${copiedFile.existsSync()}');
      loggD.d('DIR PATH RT ${copiedFile.path} -> $page ${DateTime.now()}');
      loggD.d('DIR PATH RT ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
      loggV.v('DIR PATH RT ${copiedFile.path} -> $page ${DateTime.now()}');
      loggV.v('DIR PATH RT ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

      Directory directory;

      directory = await getApplicationDocumentsDirectory();

      Directory tripsDirectory = Directory('${directory.path}/trips');

      if (!tripsDirectory.existsSync()) {
        await tripsDirectory.create();
      }

      copiedFile.copy('${directory.path}/trips/${tripId}.zip');
      downloadedZipPath = '${copiedFile.path}/trips/${tripId}.zip';

      Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
      loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
      loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');

      if (copiedFile.existsSync()) {
        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
        loggD.d('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
        loggV.v('DOES FILE EXIST: ${copiedFile.existsSync()} -> $page ${DateTime.now()}');
        Utils.showSnackBar(
          context,
          scaffoldKey: scaffoldKey,
          message: 'File downloaded successfully',
        );
      }
    }

    return downloadedZipPath;
  }

  /// TO Downlaod Image while fetching data from api
  Future<String> downloadImageFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String imageUrl) async {

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

    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
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

    String cloudImagePath = '';
    d.Dio dio = d.Dio();
    Utils.customPrint('CLOUD IMAGE DOWNLOAD Started!!!');
    loggD.d('CLOUD IMAGE DOWNLOAD Started!!! -> $page ${DateTime.now()}');
    loggV.v('CLOUD IMAGE DOWNLOAD Started!!! -> $page ${DateTime.now()}');

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    final androidInfo, iosInfo;
    var isStoragePermitted;
    if (Platform.isAndroid) {
      androidInfo = await DeviceInfoPlugin().androidInfo;

      String fileName = imageUrl.split('/').last;

      if (androidInfo.version.sdkInt < 29) {
        isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          Utils.customPrint('DIR PATH R ${ourDirectory!.path}');
          loggD.d('DIR PATH R ${ourDirectory!.path} -> $page ${DateTime.now()}');
          loggV.v('DIR PATH R ${ourDirectory!.path} -> $page ${DateTime.now()}');
          cloudImagePath = '${ourDirectory!.path}/$fileName';

          if (File(cloudImagePath).existsSync()) {
            File(cloudImagePath).deleteSync();
          }

          try {
            await dio.download(imageUrl, cloudImagePath,
                onReceiveProgress: (progress, total) {});
          } on d.DioError catch (e) {
            print('DOWNLOAD EXE: ${e.error}');
            loggD.d('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
            loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
            loggE.e('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
            loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');

            Navigator.pop(context);
          }
        } else {
          await Utils.getStoragePermission(context);
          var isStoragePermitted = await Permission.storage.status;

          if (isStoragePermitted.isGranted) {
            cloudImagePath = "${ourDirectory!.path}/$fileName";

            if (File(cloudImagePath).existsSync()) {
              File(cloudImagePath).deleteSync();
            }

            try {
              await dio.download(imageUrl, cloudImagePath,
                  onReceiveProgress: (progress, total) {});
            } on d.DioError catch (e) {
              print('DOWNLOAD EXE: ${e.error}');
              loggD.d('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
              loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
              loggE.e('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
              loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');

              Navigator.pop(context);
            }
          }
        }
      } else {
        cloudImagePath = "${ourDirectory!.path}/$fileName";

        if (File(cloudImagePath).existsSync()) {
          File(cloudImagePath).deleteSync();
        }

        try {
          await dio.download(imageUrl, cloudImagePath,
              onReceiveProgress: (progress, total) {});
        } on d.DioError catch (e) {
          print('DOWNLOAD EXE: ${e.error}');
          print('DOWNLOAD EXE: ${e.error}');
          loggD.d('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
          loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
          loggE.e('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
          loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');

          // Navigator.pop(context);
        }
      }
    } else {
      iosInfo = await DeviceInfoPlugin().iosInfo;

      String fileName = imageUrl.split('/').last;
      cloudImagePath = "${ourDirectory!.path}/$fileName";

      Utils.customPrint("IOS IMAGE PATH ${cloudImagePath}");
      loggD.d("IOS IMAGE PATH ${cloudImagePath} -> $page ${DateTime.now()}");
      loggV.v("IOS IMAGE PATH ${cloudImagePath} -> $page ${DateTime.now()}");
      loggE.e("IOS IMAGE PATH ${cloudImagePath} -> $page ${DateTime.now()}");
      loggV.v("IOS IMAGE PATH ${cloudImagePath} -> $page ${DateTime.now()}");

      if (File(cloudImagePath).existsSync()) {
        File(cloudImagePath).deleteSync();
      }

      try {
        await dio.download(imageUrl, cloudImagePath,
            onReceiveProgress: (progress, total) {});
      } on d.DioError catch (e) {
        print('DOWNLOAD EXE: ${e.error}');
        loggD.d('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
        loggE.e('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE: ${e.error} -> $page ${DateTime.now()}');

        //Navigator.pop(context);
      } on SocketException catch (s) {
        print('DOWNLOAD EXE SOCKET EXCEPTION: $s');
        loggD.d('DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page ${DateTime.now()}');
        loggE.e('DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page ${DateTime.now()}');
      } catch (er) {
        print('DOWNLOAD EXE SOCKET EXCEPTION: $er');
        loggD.d('DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page ${DateTime.now()}');
        loggE.e('DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page ${DateTime.now()}');
        loggV.v('DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page ${DateTime.now()}');
      }
    }

    return cloudImagePath;
  }
}
