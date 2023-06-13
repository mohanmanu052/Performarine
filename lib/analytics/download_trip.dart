import 'dart:io';
import 'package:dio/dio.dart' as d;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadTrip {
  /// To Download trip
  Future<String> downloadTrip(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripId) async {
    String downloadedZipPath = '';
    Utils.customPrint('DOWLOAD Started!!!');

    if (Platform.isAndroid) {
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
              directory =
                  Directory("storage/emulated/0/Download/${tripId}.zip");
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
    } else {
      File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

      Utils.customPrint('DIR PATH RT ${copiedFile.path}');
      Utils.customPrint('DIR PATH RT ${copiedFile.existsSync()}');

      Directory directory;

      directory = await getApplicationDocumentsDirectory();

      Directory tripsDirectory = Directory('${directory.path}/trips');

      if (!tripsDirectory.existsSync()) {
        await tripsDirectory.create();
      }

      copiedFile.copy('${directory.path}/trips/${tripId}.zip');
      downloadedZipPath = '${copiedFile.path}/trips/${tripId}.zip';

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

  /// TO Downlaod Image while fetching data from api
  Future<String> downloadImageFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String imageUrl) async {
    String cloudImagePath = '';
    d.Dio dio = d.Dio();
    Utils.customPrint('CLOUD IMAGE DOWNLOAD Started!!!');

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
          cloudImagePath = '${ourDirectory!.path}/$fileName';

          if (File(cloudImagePath).existsSync()) {
            File(cloudImagePath).deleteSync();
          }

          try {
            await dio.download(imageUrl, cloudImagePath,
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

            if (File(cloudImagePath).existsSync()) {
              File(cloudImagePath).deleteSync();
            }

            try {
              await dio.download(imageUrl, cloudImagePath,
                  onReceiveProgress: (progress, total) {});
            } on d.DioError catch (e) {
              print('DOWNLOAD EXE: ${e.error}');

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

          // Navigator.pop(context);
        }
      }
    } else {
      iosInfo = await DeviceInfoPlugin().iosInfo;

      String fileName = imageUrl.split('/').last;
      cloudImagePath = "${ourDirectory!.path}/$fileName";

      Utils.customPrint("IOS IMAGE PATH ${cloudImagePath}");

      if (File(cloudImagePath).existsSync()) {
        File(cloudImagePath).deleteSync();
      }

      try {
        await dio.download(imageUrl, cloudImagePath,
            onReceiveProgress: (progress, total) {});
      } on d.DioError catch (e) {
        print('DOWNLOAD EXE: ${e.error}');

        //Navigator.pop(context);
      } on SocketException catch (s) {
        print('DOWNLOAD EXE SOCKET EXCEPTION: $s');
      } catch (er) {
        print('DOWNLOAD EXE SOCKET EXCEPTION: $er');
      }
    }

    return cloudImagePath;
  }
}
