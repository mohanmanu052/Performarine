import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class GetOrCreateFolder {
  Future<String> getOrCreateFolderForAddVessel() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    Directory directory = Directory('${appDirectory.path}/vesselImages');
    Utils.customPrint('FOLDER PATH $directory');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await directory.exists())) {
      return directory.path;
    } else {
      directory.create();
      return directory.path;
    }
  }

  Future<String> getOrCreateFolder(String tripId) async {
    Directory? ourDirectory;
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    Utils.customPrint('FOLDER PATH $ourDirectory');
    if ((await ourDirectory.exists())) {
      return ourDirectory.path;
    } else {
      ourDirectory.create();
      return ourDirectory.path;
    }
  }

  /*Future<List<String>> getOrCreateFolder(String tripId) async {
    Directory? ourDirectory;
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    Utils.customPrint('FOLDER PATH $ourDirectory');
    if ((await ourDirectory.exists())) {
      //Directory mobileDir = Directory('${ourDirectory.path}/mobile-$tripId');
      //Directory lprDir = Directory('${ourDirectory.path}/lpr-$tripId');

      if ((await mobileDir.exists()) && (await lprDir.exists())) {
        return [mobileDir.path, lprDir.path];
      } else {
        await mobileDir.create();
        await lprDir.create();
        return [mobileDir.path, lprDir.path];
      } //return ourDirectory.path;
    } else {
      await ourDirectory.create();

      Directory mobileDir = Directory('${ourDirectory.path}/mobile-$tripId');
      Directory lprDir = Directory('${ourDirectory.path}/lpr-$tripId');

      if ((await mobileDir.exists()) && (await lprDir.exists())) {
        return [mobileDir.path, lprDir.path];
      } else {
        await mobileDir.create();
        await lprDir.create();
        return [mobileDir.path, lprDir.path];
      }
      //return ourDirectory.path;
    }
  }*/
}
