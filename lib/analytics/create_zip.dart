import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';

import '../common_widgets/widgets/log_level.dart';

class CreateZip {
  String page = "Create_zip";

  /// To create trip zip folder
  Future<File> createZipFolder(BuildContext context, String tripId) async {

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    File? zipFile;
    if (timer != null) timer!.cancel();
    Utils.customPrint('TIMER STOPPED ${ourDirectory!.path}/$tripId');
    Utils.customPrint('CREATE ZIP  ${ourDirectory!.path}/$tripId');

    CustomLogger().logWithFile(Level.info, "TIMER STOPPED ${ourDirectory!.path}/$tripId -> $page");
    CustomLogger().logWithFile(Level.info, "CREATE ZIP  ${ourDirectory!.path}/$tripId -> $page");
    final dataDir = Directory('${ourDirectory!.path}/$tripId');

    try {
      zipFile = File('${ourDirectory!.path}/$tripId.zip');

      ZipFile.createFromDirectory(
          sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
      Utils.customPrint('our path is $dataDir');
      CustomLogger().logWithFile(Level.info, "our path is $dataDir -> $page");
      //Utils.customPrint('DOWNLOADED FILE PATH: $downloadedFilePath');
    } catch (e) {
      Utils.customPrint('$e');

      CustomLogger().logWithFile(Level.error, "$e -> $page");
    }

    File file = File(zipFile!.path);

    return file;
  }
}
