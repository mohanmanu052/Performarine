import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
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

  /*Future<String> downloadTripFromApi(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripId, String url) async {
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
  }*/
}
