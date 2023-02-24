import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';

class CreateZip {
  Future<File> createZipFolder(BuildContext context, String tripId) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    File? zipFile;
    if (timer != null) timer!.cancel();
    Utils.customPrint('TIMER STOPPED ${ourDirectory!.path}/$tripId');
    Utils.customPrint('CREATE ZIP  ${ourDirectory!.path}/$tripId');
    final dataDir = Directory('${ourDirectory!.path}/$tripId');

    try {
      zipFile = File('${ourDirectory!.path}/$tripId.zip');

      ZipFile.createFromDirectory(
          sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
      Utils.customPrint('our path is $dataDir');
      //Utils.customPrint('DOWNLOADED FILE PATH: $downloadedFilePath');
    } catch (e) {
      Utils.customPrint('$e');
    }

    File file = File(zipFile!.path);

    return file;
  }
}
