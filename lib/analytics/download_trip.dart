import 'dart:io';
import 'package:dio/dio.dart' as d;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/get_file.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_widgets/widgets/log_level.dart';

class DownloadTrip {
  String page = "Download_trip";
  /// To Download trip
  IOSink? lprFileSink;
  int fileIndex = 0;

  Future<String> downloadTrip(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripId) async {

    String downloadedZipPath = '';
    Utils.customPrint('DOWLOAD Started!!!');
    CustomLogger().logWithFile(Level.info, "DOWLOAD Started!!! -> $page");

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      var isStoragePermitted;
      if (androidInfo.version.sdkInt < 29) {
        isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

          Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

          CustomLogger().logWithFile(Level.info, "DIR PATH R ${ourDirectory!.path} -> $page");

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory("storage/emulated/0/Download/${tripId}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          copiedFile.copy(directory.path);
          downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
          CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");

          if (copiedFile.existsSync()) {
            Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
            CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");
            Utils.showSnackBar(
              context,
              scaffoldKey: scaffoldKey,
              message: 'File Downloaded Successfully',
            );
          }
        } else {
          await Utils.getStoragePermission(context);
          var isStoragePermitted = await Permission.storage.status;

          if (isStoragePermitted.isGranted) {
            File copiedFile = File('${ourDirectory!.path}.zip');

            Directory directory;

            if (Platform.isAndroid) {
              directory =
                  Directory("storage/emulated/0/Download/${tripId}.zip");
            } else {
              directory = await getApplicationDocumentsDirectory();
            }

            copiedFile.copy(directory.path);
            downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

            Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
            CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");

            if (copiedFile.existsSync()) {
              Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
              CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");
              Utils.showSnackBar(
                context,
                scaffoldKey: scaffoldKey,
                message: 'File Downloaded Successfully',
              );
            }
          }
        }
      } else {
        File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

        Utils.customPrint('DIR PATH RT ${copiedFile.path}');
        Utils.customPrint('DIR PATH RT ${copiedFile.existsSync()}');
        CustomLogger().logWithFile(Level.info, "DIR PATH RT ${copiedFile.path} -> $page");
        CustomLogger().logWithFile(Level.info, "DIR PATH RT ${copiedFile.existsSync()} -> $page");

        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory("storage/emulated/0/Download/${tripId}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);
        downloadedZipPath = "storage/emulated/0/Download/${tripId}.zip";

        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
        CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");


        if (copiedFile.existsSync()) {
          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
          CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");
          Utils.showSnackBar(
            context,
            scaffoldKey: scaffoldKey,
            message: 'File Downloaded Successfully',
          );
        }
      }
    } else {
      File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

      Utils.customPrint('DIR PATH RT ${copiedFile.path}');
      Utils.customPrint('DIR PATH RT ${copiedFile.existsSync()}');
      CustomLogger().logWithFile(Level.info, "DIR PATH RT ${copiedFile.path} -> $page");
      CustomLogger().logWithFile(Level.info, "DIR PATH RT ${copiedFile.existsSync()} -> $page");

      Directory directory;

      directory = await getApplicationDocumentsDirectory();

      Directory tripsDirectory = Directory('${directory.path}/trips');

      if (!tripsDirectory.existsSync()) {
        await tripsDirectory.create();
      }

      copiedFile.copy('${directory.path}/trips/${tripId}.zip');
      downloadedZipPath = '${copiedFile.path}/trips/${tripId}.zip';

      Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
      CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");

      if (copiedFile.existsSync()) {
        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');
        CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");
        Utils.showSnackBar(
          context,
          scaffoldKey: scaffoldKey,
          message: 'File Downloaded Successfully',
        );
      }
    }

    return downloadedZipPath;
  }

  /// TO Downlaod Image while fetching data from api
  Future<String> downloadImageFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String imageUrl) async {

    String cloudImagePath = '';
    d.Dio dio = d.Dio();
    Utils.customPrint('CLOUD IMAGE DOWNLOAD Started!!!');
    CustomLogger().logWithFile(Level.info, "CLOUD IMAGE DOWNLOAD Started!!! -> $page");

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    final androidInfo, iosInfo;
    var isStoragePermitted;
    if (Platform.isAndroid) {
      androidInfo = await DeviceInfoPlugin().androidInfo;

      String fileName = imageUrl.split('/').last.length > 30
          ? '${imageUrl.split('/').last.split('-').first}.${imageUrl.split('/').last.split('.').last}'
          : imageUrl.split('/').last;

      if (androidInfo.version.sdkInt < 29) {
        isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          Utils.customPrint('DIR PATH R ${ourDirectory!.path}');
          CustomLogger().logWithFile(Level.info, "DIR PATH R ${ourDirectory!.path} -> $page");
          cloudImagePath = '${ourDirectory!.path}/$fileName';

          if (File(cloudImagePath).existsSync()) {
            File(cloudImagePath).deleteSync();
          }

          try {
            await dio.download(imageUrl, cloudImagePath,
                onReceiveProgress: (progress, total) {});
          } on d.DioError catch (e) {
        Utils.customPrint('DOWNLOAD EXE: ${e.error}');
            CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");


            Navigator.pop(context);
          }
        } else {
          await Utils.getStoragePermission(context);
          var isStoragePermitted = await Permission.storage.status;

          if (isStoragePermitted.isGranted) {
            cloudImagePath = "${ourDirectory!.path}/$fileName";

            if (File(cloudImagePath).existsSync()) {
              File(cloudImagePath).deleteSync();
            }

            try {
              await dio.download(imageUrl, cloudImagePath,
                  onReceiveProgress: (progress, total) {});
            } on d.DioError catch (e) {
              Utils.customPrint('DOWNLOAD EXE: ${e.error}');
              CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");

              Navigator.pop(context);
            }
          }
        }
      } else {
        cloudImagePath = "${ourDirectory!.path}/$fileName";

        if (File(cloudImagePath).existsSync()) {
          File(cloudImagePath).deleteSync();
        }

        try {
          await dio.download(imageUrl, cloudImagePath,
              onReceiveProgress: (progress, total) {});
        } on d.DioError catch (e) {
          Utils.customPrint('DOWNLOAD EXE: ${e.error}');
          CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");
        }
      }
    } else {
      iosInfo = await DeviceInfoPlugin().iosInfo;

      String fileName = imageUrl.split('/').last;
      cloudImagePath = "${ourDirectory!.path}/$fileName";

      Utils.customPrint("IOS IMAGE PATH ${cloudImagePath}");
      CustomLogger().logWithFile(Level.info, "IOS IMAGE PATH ${cloudImagePath}-> $page");

      if (File(cloudImagePath).existsSync()) {
        File(cloudImagePath).deleteSync();
      }

      try {
        await dio.download(imageUrl, cloudImagePath,
            onReceiveProgress: (progress, total) {});
      } on d.DioError catch (e) {

    Utils.customPrint('DOWNLOAD EXE: ${e.error}');
        CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");

      } on SocketException catch (s) {

    Utils.customPrint('DOWNLOAD EXE SOCKET EXCEPTION: $s');
        CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page");
      } catch (er) {
    Utils.customPrint('DOWNLOAD EXE SOCKET EXCEPTION: $er');
        CustomLogger().logWithFile(Level.error, "DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page");
      }
    }

    return cloudImagePath;
  }

  Future<String> downloadTripFromCloud(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, String tripUrl, CommonProvider commonProvider) async {
    String cloudTripPath = '';
    d.Dio dio = d.Dio();
    Utils.customPrint('CLOUD TRIP DOWNLOAD Started!!!');
    CustomLogger()
        .logWithFile(Level.info, "CLOUD TRIP DOWNLOAD Started!!! -> $page");

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    final androidInfo, iosInfo;
    var isStoragePermitted;

    if (Platform.isAndroid) {
      androidInfo = await DeviceInfoPlugin().androidInfo;

      String fileName = tripUrl.split('/').last;

      if (androidInfo.version.sdkInt < 29) {
        isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          Utils.customPrint('DIR PATH R ${ourDirectory!.path}');
          CustomLogger().logWithFile(
              Level.info, "DIR PATH R ${ourDirectory!.path} -> $page");

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory("storage/emulated/0/Download/${fileName}");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          cloudTripPath = directory.path;

          if (File(cloudTripPath).existsSync()) {
            File(cloudTripPath).deleteSync();
          }

          try {
            await dio.download(tripUrl, cloudTripPath,
                onReceiveProgress: (progress, total) {}).then((value) {
              commonProvider.downloadTripProgressBar(false);
              Utils.showSnackBar(
                context,
                scaffoldKey: scaffoldKey,
                message: 'File Downloaded Successfully',
              );
            });
          } on d.DioError catch (e) {
            commonProvider.downloadTripProgressBar(false);
            Utils.customPrint('DOWNLOAD EXE: ${e.error}');
            CustomLogger()
                .logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");

            Navigator.pop(context);
          }
        } else {
          await Utils.getStoragePermission(context);
          var isStoragePermitted = await Permission.storage.status;

          if (isStoragePermitted.isGranted) {
            Directory directory;

            if (Platform.isAndroid) {
              directory = Directory("storage/emulated/0/Download/${fileName}");
            } else {
              directory = await getApplicationDocumentsDirectory();
            }

            cloudTripPath = directory.path;

            if (File(cloudTripPath).existsSync()) {
              File(cloudTripPath).deleteSync();
            }

            try {
              await dio.download(tripUrl, cloudTripPath,
                  onReceiveProgress: (progress, total) {}).then((value) {
                commonProvider.downloadTripProgressBar(false);
                Utils.showSnackBar(
                  context,
                  scaffoldKey: scaffoldKey,
                  message: 'File Downloaded Successfully',
                );
              });
            } on d.DioError catch (e) {
              commonProvider.downloadTripProgressBar(false);
              Utils.customPrint('DOWNLOAD EXE: ${e.error}');
              CustomLogger().logWithFile(
                  Level.error, "DOWNLOAD EXE: ${e.error} -> $page");

              Navigator.pop(context);
            }
          }
        }
      } else {
        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory("storage/emulated/0/Download/${fileName}");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        cloudTripPath = directory.path;

        if (File(cloudTripPath).existsSync()) {
          File(cloudTripPath).deleteSync();
        }

        try {
          await dio.download(tripUrl, cloudTripPath,
              onReceiveProgress: (progress, total) {}).then((value)
          {
            commonProvider.downloadTripProgressBar(false);
            Utils.showSnackBar(
              context,
              scaffoldKey: scaffoldKey,
              message: 'File Downloaded Successfully',
            );
          });
        } on d.DioError catch (e) {
          commonProvider.downloadTripProgressBar(false);
          Utils.customPrint('DOWNLOAD EXE: ${e.error}');
          CustomLogger()
              .logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");
        }
      }
    }
    else {
      iosInfo = await DeviceInfoPlugin().iosInfo;

      String fileName = tripUrl.split('/').last;

      Directory directory;

      directory = await getApplicationDocumentsDirectory();

      Directory tripsDirectory = Directory('${directory.path}/trips');

      if (!tripsDirectory.existsSync()) {
        await tripsDirectory.create();
      }

      cloudTripPath = '${directory.path}/trips/${fileName}';

      Utils.customPrint("IOS IMAGE PATH ${cloudTripPath}");
      CustomLogger()
          .logWithFile(Level.info, "IOS IMAGE PATH ${cloudTripPath}-> $page");

      if (File(cloudTripPath).existsSync()) {
        File(cloudTripPath).deleteSync();
      }

      try {
        await dio.download(tripUrl, cloudTripPath,
            onReceiveProgress: (progress, total) {}).then((value)
        {
          commonProvider.downloadTripProgressBar(false);
          Utils.showSnackBar(
            context,
            scaffoldKey: scaffoldKey,
            message: 'File Downloaded Successfully',
          );
        });
      } on d.DioError catch (e) {
        commonProvider.downloadTripProgressBar(false);
        Utils.customPrint('DOWNLOAD EXE: ${e.error}');
        CustomLogger()
            .logWithFile(Level.error, "DOWNLOAD EXE: ${e.error} -> $page");
      } on SocketException catch (s) {
        commonProvider.downloadTripProgressBar(false);
        Utils.customPrint('DOWNLOAD EXE SOCKET EXCEPTION: $s');
        CustomLogger().logWithFile(
            Level.error, "DOWNLOAD EXE SOCKET EXCEPTION: $s -> $page");
      } catch (er) {
        commonProvider.downloadTripProgressBar(false);
        Utils.customPrint('DOWNLOAD EXE SOCKET EXCEPTION: $er');
        CustomLogger().logWithFile(
            Level.error, "DOWNLOAD EXE SOCKET EXCEPTION: $er -> $page");
      }
    }
    return cloudTripPath;
  }

//     Future<void> saveLPRData(String data,File lprFile,IOSink lprFileSink)async{
// String? lprFileName;
//         int lprFileSize = await GetFile().checkLPRFileSize(lprFile);

//         /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
//         /// Now File Size is 200000
//         if (lprFileSize >= 200000) {
//           Utils.customPrint('STOPPED WRITING');
//           Utils.customPrint('CREATING NEW FILE');

//           CustomLogger().logWithFile(Level.info, "STOPPED WRITING -> $page");
//           CustomLogger().logWithFile(Level.info, "CREATING NEW FILE -> $page");
//       fileIndex = fileIndex + 1;
//       lprFileName = 'lpr_$fileIndex.csv';

//       // Close the existing file and open a new one
//       lprFileSink.close();
//       lprFile=File(lprFileName);
//       lprFileSink=lprFile.openWrite(mode: FileMode.append);
      
//      // lprFileSink = null;

//           /// STOP WRITING & CREATE NEW FILE
//         } else {
//           Utils.customPrint('LPR WRITING');

//           // String finalString = '';

//           // /// Creating csv file Strings by combining all the values
//           //  var todayDate = DateTime.now().toUtc();
//           // finalString = '${data} ${todayDate}';

//           /// Writing into a csv file
//       lprFileSink.write('$data');
//       Utils.customPrint('LPR Data $data');
//       Utils.customPrint('LPR Path Was ' + lprFile.path);


//         }
//       }


  Future<void> saveLPRData(String data,)async{
        String tripId = '';

        int fileIndex = 0;
            List<String>? tripData =
    sharedPreferences!
        .getStringList('trip_data');
    if (tripData != null) {
      tripId = tripData[0];
    }



    String lprFileName = 'lpr_$fileIndex.csv';
        String lprFilePath = await GetFile().getlprFile(tripId, lprFileName);
      //  File file = File(filePath);
        File lprFile = File(lprFilePath);
       // int fileSize = await GetFile().checkFileSize(file);
        int lprFileSize = await GetFile().checkLPRFileSize(lprFile);

        /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
        /// Now File Size is 200000
        if (lprFileSize >= 200000) {
          Utils.customPrint('STOPPED WRITING');
          Utils.customPrint('CREATING NEW FILE');

          CustomLogger().logWithFile(Level.info, "STOPPED WRITING -> $page");
          CustomLogger().logWithFile(Level.info, "CREATING NEW FILE -> $page");
          fileIndex = fileIndex + 1;
          lprFileName = 'lpr_$fileIndex.csv';

          /// STOP WRITING & CREATE NEW FILE
        } else {
          Utils.customPrint('WRITING');

          String finalString = '';

          /// Creating csv file Strings by combining all the values
          finalString = data;

          /// Writing into a csv file
          lprFile.writeAsString('$finalString', mode: FileMode.append);

          Utils.customPrint('LPR Data $data');
                    Utils.customPrint('LPR Path Wsa '+lprFile.path);


        }
      }
      // Future<void> closeLprFile()async{
      //   if(lprFileSink!=null){
      //     //lprFileSink?.flush();
      //     lprFileSink?.close();
      //   }
      // }

// Future<void> downloadLPRData()async{


// }
  
}
