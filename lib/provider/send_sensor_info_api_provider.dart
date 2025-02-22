import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/upload_trip_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

import '../common_widgets/widgets/log_level.dart';

class SendSensorInfoApiProvider with ChangeNotifier {
  CommonModel? commonModel;
  UploadTripModel? uploadTripModel;

  Map _source = {ConnectivityResult.none: false};
  String string = '';
  String page = "Send_sensor_info_api_provider";

  Future<UploadTripModel?> sendSensorDataInfoDio(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      Map<String, dynamic> tripData,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey,
      {bool calledFromSignOut = false}) async {
    d.Dio dio = d.Dio();
    log('ZIPPPP: ${jsonEncode(tripData)}');
    //Utils.customPrint('ZIPPPP: ${zipFile.existsSync()}');
    var formData = d.FormData.fromMap({
      "tripData": jsonEncode(tripData),
      'sensorZipFiles': await d.MultipartFile.fromFile(
        zipFile!.path,
        filename: zipFile.path.split('/').last,
        contentType: new MediaType("application", "zip"),
      ),
    });
    Uri uri = Uri.https(Urls.baseUrl, Urls.SendSensorData);

    try {
      await dio.post(
        uri.toString(),
        data: formData,
        options: d.Options(
          headers: {
            "Content-Type": 'multipart/form-data',
            "x-access-token": '$accessToken', // set content-length
          },
        ),
        onSendProgress: (int sent, int total) async {
          int finalProgress =
              int.parse((sent / total * 100).toStringAsFixed(0));

          if (!calledFromSignOut) {
            final AndroidNotificationDetails androidPlatformChannelSpecifics =
                AndroidNotificationDetails(
                    'progress channel', 'progress channel',
                    channelDescription: 'progress channel description',
                    channelShowBadge: false,
                    importance: Importance.max,
                    priority: Priority.high,
                    onlyAlertOnce: true,
                    ongoing: true,
                    showProgress: true,
                    maxProgress: 100,
                    progress: finalProgress);
            final NotificationDetails platformChannelSpecifics =
                NotificationDetails(
                    android: androidPlatformChannelSpecifics,
                    iOS: DarwinNotificationDetails());
            flutterLocalNotificationsPlugin.show(
                9989,
                '$tripId - $finalProgress/100 %',
                '$tripId - $finalProgress/100 %',
                platformChannelSpecifics,
                payload: 'item x');
          }
        },
      ).then((response) {
       // _networkConnectivity.disposeStream();
        Utils.customPrint(' SEND SENSOR RESPONSE: ${response.statusCode}');
        Utils.customPrint('RESPONSE: ${jsonEncode(response.data)}');
        CustomLogger().logWithFile(Level.info, "RESPONSE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "RESPONSE: ${jsonEncode(response.data)} -> $page");
        var decodedData = json.decode(jsonEncode(response.data));
        if (response.statusCode == HttpStatus.ok) {
          Utils.customPrint('Send sensor info api Response : ' + response.data.toString());

          CustomLogger().logWithFile(Level.info, "Send sensor info api Response : ' + ${response.data.toString()} -> $page");
          CustomLogger().logWithFile(Level.info, "API response status is: ${response.statusCode} on -> $page");

          if (decodedData['status']) {
            if(uploadTripModel == null){
              CustomLogger().logWithFile(Level.error, "Error while parsing json data on uploadTripModel -> $page");
            }
            uploadTripModel = UploadTripModel.fromJson(decodedData);
          } else {
            if(uploadTripModel == null){
              CustomLogger().logWithFile(Level.error, "Error while parsing json data on uploadTripModellll -> $page");
            }
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
                      uploadTripModel = UploadTripModel.fromJson(decodedData);
          }
          return uploadTripModel;
        } else if (response.statusCode == HttpStatus.gatewayTimeout) {
          Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          Utils.customPrint('EXE RESP: $response');

          CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
          CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

          if (!calledFromSignOut) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }
        
          uploadTripModel = null;
        } else if(decodedData['statusCode'] == 401)
          {
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));

          }else {
          if (!calledFromSignOut) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }
        
          Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          Utils.customPrint('EXE RESP: $response');
          CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
          CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
        }
        uploadTripModel = null;
      }).onError((error, stackTrace) async{
       // _networkConnectivity.disposeStream();
        Utils.customPrint('ERROR DIO: $error\n$stackTrace');

        CustomLogger().logWithFile(Level.error, "ERROR DIO: $error\n$stackTrace -> $page");
        CustomLogger().logWithFile(Level.warning, "Failed to upload trip. Please check internet connection and try again.-> $page");
        if (!calledFromSignOut) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey,
              message:
                  'Failed to upload trip. Please check internet connection and try again.');}
              flutterLocalNotificationsPlugin.cancel(9989);
        uploadTripModel = null;
        return null;
      });
    } on SocketException catch (_) {
      //_networkConnectivity.disposeStream();
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      uploadTripModel = null;
    }catch (exception, s) {

      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught uploadTripModel:- $exception \n $s -> $page");
      uploadTripModel = null;
    }

    return uploadTripModel;
  }
}

class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(this.method, this.url, this.onProgress) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;
  final String method;
  final Uri url;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// That will emit the request body.
  http.ByteStream finalize() {
    final byteStream = super.finalize();

    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        if (total >= bytes) {
          sink.add(data);
        }
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

