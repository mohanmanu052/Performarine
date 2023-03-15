import 'dart:io';

import 'package:performarine/analytics/get_or_create_folder.dart';

class GetFile {
  Future<String> getFile(String tripId, String fileName) async {
    String folderPath = await GetOrCreateFolder().getOrCreateFolder(tripId);

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
  }

  /*Future<List<String>> getFile(String tripId, String fileName) async {
    // List<String> folderPath = await GetOrCreateFolder().getOrCreateFolder(tripId);
     List<> folderPath = await GetOrCreateFolder().getOrCreateFolder(tripId);

    File mobileSensorDataFile = File('${folderPath[0]}/$fileName');

    File lprDataFile = File('${folderPath[1]}/$fileName');
    File sensorDataFile = File('$folderPath/$fileName');
    // return sensorDataFile.path;
    return [mobileSensorDataFile.path, lprDataFile.path];
  }*/

  int checkFileSize(File file) {
    if (file.existsSync()) {
      var bytes = file.lengthSync();
      double sizeInKB = bytes / 1024;
      return sizeInKB.toInt();
    } else {
      return -1;
    }
  }
}
