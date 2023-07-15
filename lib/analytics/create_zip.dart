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

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    File? zipFile;
    if (timer != null) timer!.cancel();
    Utils.customPrint('TIMER STOPPED ${ourDirectory!.path}/$tripId');
    Utils.customPrint('CREATE ZIP  ${ourDirectory!.path}/$tripId');
    loggD.d('TIMER STOPPED ${ourDirectory!.path}/$tripId -> $page ${DateTime.now()}');
    loggD.d('CREATE ZIP  ${ourDirectory!.path}/$tripId -> $page ${DateTime.now()}');
    loggV.v('TIMER STOPPED ${ourDirectory!.path}/$tripId -> $page ${DateTime.now()}');
    loggV.v('CREATE ZIP  ${ourDirectory!.path}/$tripId -> $page ${DateTime.now()}');
    final dataDir = Directory('${ourDirectory!.path}/$tripId');

    try {
      zipFile = File('${ourDirectory!.path}/$tripId.zip');

      ZipFile.createFromDirectory(
          sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
      Utils.customPrint('our path is $dataDir');
      loggD.d('our path is $dataDir -> $page ${DateTime.now()}');
      loggV.v('our path is $dataDir -> $page ${DateTime.now()}');
      //Utils.customPrint('DOWNLOADED FILE PATH: $downloadedFilePath');
    } catch (e) {
      Utils.customPrint('$e');
      loggD.d('$e -> $page ${DateTime.now()}');
      loggV.v('$e -> $page ${DateTime.now()}');
      loggE.e('$e -> $page ${DateTime.now()}');
      loggV.v('$e -> $page ${DateTime.now()}');
    }

    File file = File(zipFile!.path);

    return file;
  }
}
