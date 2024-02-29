import 'dart:io';

import 'package:performarine/analytics/get_or_create_folder.dart';

class GetFile {
  Future<String> getFile(String tripId, String fileName) async {
    String folderPath = await GetOrCreateFolder().getOrCreateFolder(tripId);

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
  }

  Future<String> getlprFile(String tripId, String fileName) async {
    String folderPath = await GetOrCreateFolder().getOrCreateFolder(tripId);

    File lprFile = File('$folderPath/$fileName');
    return lprFile.path;
  }

 int checkLPRFileSize(File file){
      if (file.existsSync()) {
      var bytes = file.lengthSync();
      double sizeInKB = bytes / 1024;
      return sizeInKB.toInt();
    } else {
      return -1;
    }
  }

 

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