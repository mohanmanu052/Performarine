import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_widgets/widgets/log_level.dart';

class GetOrCreateFolder {
  String page = "get_or_create_folder";
  Future<String> getOrCreateFolderForAddVessel() async {

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

    final appDirectory = await getApplicationDocumentsDirectory();
    print('ADD V AD PATH: ${appDirectory.path}');
    loggD.d('ADD V AD PATH: ${appDirectory.path} -> $page ${DateTime.now()}');
    loggV.v('ADD V AD PATH: ${appDirectory.path} -> $page ${DateTime.now()}');
    Directory directory = Directory('${appDirectory.path}/vesselImages');
    Utils.customPrint('FOLDER PATH ${directory.path}');
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

    Directory? ourDirectory;
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    Utils.customPrint('FOLDER PATH $ourDirectory');
    loggD.d('FOLDER PATH $ourDirectory -> $page ${DateTime.now()}');
    loggV.v('FOLDER PATH $ourDirectory -> $page ${DateTime.now()}');
    if ((await ourDirectory.exists())) {
      return ourDirectory.path;
    } else {
      ourDirectory.create();
      return ourDirectory.path;
    }
  }
}
