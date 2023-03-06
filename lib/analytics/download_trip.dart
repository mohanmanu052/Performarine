import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart' as d;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadTrip {
  Future<String> downloadTrip(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripId) async {
    String downloadedZipPath = '';
    Utils.customPrint('DOWLOAD Started!!!');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted;
    if (androidInfo.version.sdkInt < 29) {
      isStoragePermitted = await Permission.storage.status;

      if (isStoragePermitted.isGranted) {
        File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

        Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory("storage/emulated/0/Download/${tripId}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);
        downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

        if (copiedFile.existsSync()) {
          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
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
            directory = Directory("storage/emulated/0/Download/${tripId}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          copiedFile.copy(directory.path);
          downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

          if (copiedFile.existsSync()) {
            Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
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

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory("storage/emulated/0/Download/${tripId}.zip");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      copiedFile.copy(directory.path);
      downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

      Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

      if (copiedFile.existsSync()) {
        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
        Utils.showSnackBar(
          context,
          scaffoldKey: scaffoldKey,
          message: 'File downloaded successfully',
        );
      }
    }

    return downloadedZipPath;
  }

  Future<String> downloadImageFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String imageUrl) async {
    String cloudImagePath = '';
    Response resp;
    d.Dio dio = d.Dio();
    Utils.customPrint('CLOUD IMAGE DOWNLOAD Started!!!');

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted;
    String fileName = imageUrl.split('/').last;
    if (androidInfo.version.sdkInt < 29) {
      isStoragePermitted = await Permission.storage.status;

      if (isStoragePermitted.isGranted) {
        Utils.customPrint('DIR PATH R ${ourDirectory!.path}');
        cloudImagePath = '${ourDirectory!.path}/$fileName';

        if (File(cloudImagePath).existsSync()) {
          File(cloudImagePath).deleteSync();
        }

        try {
          dio.download(imageUrl, cloudImagePath,
              onReceiveProgress: (progress, total) {});
        } on d.DioError catch (e) {
          print('DOWNLOAD EXE: ${e.error}');

          Navigator.pop(context);
        }
      } else {
        await Utils.getStoragePermission(context);
        var isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          cloudImagePath = "${ourDirectory!.path}/$fileName";

          try {
            dio.download(imageUrl, cloudImagePath,
                onReceiveProgress: (progress, total) {});
          } on d.DioError catch (e) {
            print('DOWNLOAD EXE: ${e.error}');

            Navigator.pop(context);
          }
        }
      }
    } else {
      cloudImagePath = "${ourDirectory!.path}/$fileName";

      try {
        dio.download(imageUrl, cloudImagePath,
            onReceiveProgress: (progress, total) {});
      } on d.DioError catch (e) {
        print('DOWNLOAD EXE: ${e.error}');

        Navigator.pop(context);
      }
    }
    return cloudImagePath;
  }

  /*Future<String> downloadImageFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String imageUrl) async {
    bool isPermissionGranted = await Utils.getStoragePermission(context);
    print('IS PERMISSION GRANTED: $isPermissionGranted');

    Directory directory;

    directory = await getApplicationDocumentsDirectory();

    if (isPermissionGranted) {
      bool doesExist = await directory.exists();
      print(doesExist);

      print('FILE URL: $imageUrl');
      print('DOWNLOAD DIRECTORY PATH: ${directory.path}');

      //showLoaderDialog(context);
    }

    Response resp;
    d.Dio dio = d.Dio();

    String fileName = imageUrl.split('/').last;
    print('FILE NAME: $fileName');
    String name = '${Random().nextInt(9999).toString()}${fileName.trim()}';

    String directoryPath = '${directory.path}/$name';
    print('DOWNLOAD DIRECTORY PATH WITH FILENAME: $directoryPath');

      try {
      dio.download(imageUrl, directoryPath,
          onReceiveProgress: (progress, total) {
        // pr.update(progress: double.parse(((progress/total)*100).toStringAsFixed(0)));

        if (progress == total) {
             if(pr.isShowing()) pr.hide();
              pr.update(progress: 0.0);
          Navigator.pop(context);

          Utils.showActionSnackBar(
              context, scaffoldKey, 'File located at: $directoryPath');
        }
      });
    } on d.DioError catch (e) {
      print('DOWNLOAD EXE: ${e.error}');

      Navigator.pop(context);
    }

    // pr.update(progress: 0.0);

    return directoryPath;
  }*/
}
