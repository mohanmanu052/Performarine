import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

File? fileD;
File? fileV;
File? fileI;
File? fileE;
File? fileW;
File? fileWTF;

var loggD = Logger(level: Level.debug);
var loggE = Logger(level: Level.error);
var loggI = Logger(level: Level.info);
var loggW = Logger(level: Level.warning);
var loggWTF = Logger(level: Level.wtf);
var loggV = Logger(level: Level.verbose);

DateTime now = DateTime.now().toLocal();
String formattedDate = DateFormat('yyyy-MM-dd').format(now);

Future<void> getDirectoryForDebugLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileD = File('${directory.path}/debugLogPerformarine_$formattedDate.log');
  print("file path: $fileD");
}

Future<void> getDirectoryForErrorLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileE = File('${directory.path}/ErrorLogPerformarine_$formattedDate.log');
  print("file path: $fileE");
}

Future<void> getDirectoryForInfoLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileI = File('${directory.path}/InfoLogPerformarine_$formattedDate.log');
  print("file path: $fileI");
}

Future<void> getDirectoryForVerboseLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileV = File('${directory.path}/VerboseLogPerformarine_$formattedDate.log');
  print("file path: $fileV");
}

Future<void> getDirectoryForWarningLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileW = File('${directory.path}/WarningLogPerformarine_$formattedDate.log');
  print("file path: $fileW");
}

Future<void> getDirectoryForWTFLogRecord() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  fileWTF = File('${directory.path}/WTFLogPerformarine_$formattedDate.log');
  print("file path: $fileWTF");
}