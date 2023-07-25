import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_widgets/widgets/log_level.dart';

class GetOrCreateFolder {
  String page = "get_or_create_folder";
  Future<String> getOrCreateFolderForAddVessel() async {

    final appDirectory = await getApplicationDocumentsDirectory();

    Utils.customPrint('ADD V AD PATH: ${appDirectory.path}');
    CustomLogger().logWithFile(Level.info, "ADD V AD PATH: ${appDirectory.path} -> $page");
    Directory directory = Directory('${appDirectory.path}/vesselImages');
    Utils.customPrint('FOLDER PATH ${directory.path}');
    CustomLogger().logWithFile(Level.info, "FOLDER PATH ${directory.path} -> $page");
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
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
    CustomLogger().logWithFile(Level.info, "FOLDER PATH $ourDirectory -> $page");
    if ((await ourDirectory.exists())) {
      return ourDirectory.path;
    } else {
      ourDirectory.create();
      return ourDirectory.path;
    }
  }
}
