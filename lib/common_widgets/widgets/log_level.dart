import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

File? mainFile;

DateTime now = DateTime.now().toLocal();
String formattedDate = DateFormat('yyyy-MM-dd').format(now);

class CustomLogger{
  static final CustomLogger _instance = CustomLogger._internal();
  factory CustomLogger() => _instance;

  CustomLogger._internal();

  void logWithFile(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) async {
    if (level == Level.nothing) {
      throw ArgumentError('Log events cannot have Level.nothing');
    }

    var logEvent = LogEvent(level, message, error, stackTrace);

    var output = formatLogMessage(logEvent);
    await writeToLogFile(output,logEvent);

  }

  String formatLogMessage(LogEvent logEvent) {
    return '${logEvent.level.name}: ${logEvent.message}';
  }

  Future<void> writeToLogFile(String logMessage,LogEvent logEvent) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    mainFile = File('${directory.path}/performarinelogs_$formattedDate.log');
    Utils.customPrint("file path: $mainFile");
    if(logLevel == "info"){
      if(logEvent.level.name == "info"){
        await mainFile?.writeAsString(logMessage + '\n', mode: FileMode.append);
      }
    }else if(logLevel == "debug"){
      if(logEvent.level.name == "info" || logEvent.level.name == "debug"){
        await mainFile?.writeAsString(logMessage + '\n', mode: FileMode.append);
      }
    }else if(logLevel == "warning"){
      if(logEvent.level.name == "info" || logEvent.level.name == "debug" || logEvent.level.name == "debug"){
        await mainFile?.writeAsString(logMessage + '\n', mode: FileMode.append);
      }
    }else if(logLevel == "error"){
      if(logEvent.level.name == "info" || logEvent.level.name == "debug" || logEvent.level.name == "warning" || logEvent.level.name == "error"){
        await mainFile?.writeAsString(logMessage + '\n', mode: FileMode.append);
      }
    }else if(logLevel == "verbose"){
      if(logEvent.level.name == "info" || logEvent.level.name == "debug" || logEvent.level.name == "warning" || logEvent.level.name == "error" || logEvent.level.name == "error"){
        await mainFile?.writeAsString(logMessage + '\n', mode: FileMode.append);
      }
    }

  }
}

void extractLogsFromFile(File inputFile, File outputFile, List<String> logLevels) {
  final inputLines = inputFile.readAsLinesSync();
  outputFile.writeAsStringSync('');

  final extractedLines = inputLines.where((line) {
    for (final level in logLevels) {
      if (line.toLowerCase().contains(level.toLowerCase())) {
        return true;
      }
    }
    return false;
  }).toList();

  outputFile.writeAsStringSync(extractedLines.join('\n'));
}