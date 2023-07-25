import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/upload_trip_model.dart';

class SendSensorInfoApiProvider with ChangeNotifier {
  CommonModel? commonModel;
  UploadTripModel? uploadTripModel;

  Map _source = {ConnectivityResult.none: false};
  String string = '';

  Future<UploadTripModel?> sendSensorDataInfoDio(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      Map<String, dynamic> tripData,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey,
      {bool calledFromSignOut = false}) async {
    d.Dio dio = d.Dio();
    Utils.customPrint('ZIPPPP: ${zipFile!.path}');
    Utils.customPrint('ZIPPPP: ${zipFile.existsSync()}');
    var formData = d.FormData.fromMap({
      "tripData": jsonEncode(tripData),
      'sensorZipFiles': await d.MultipartFile.fromFile(
        zipFile.path,
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
        Utils.customPrint('RESPONSE: ${response.statusCode}');
        Utils.customPrint('RESPONSE: ${jsonEncode(response.data)}');
        var decodedData = json.decode(jsonEncode(response.data));
        if (response.statusCode == HttpStatus.ok) {
          Utils.customPrint('Register Response : ' + response.data.toString());

          if (decodedData['status']) {
            uploadTripModel = UploadTripModel.fromJson(decodedData);
          } else {
            if (scaffoldKey != null) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey, message: decodedData['message']);
            }
            uploadTripModel = UploadTripModel.fromJson(decodedData);
          }
          return uploadTripModel;
        } else if (response.statusCode == HttpStatus.gatewayTimeout) {
          Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          Utils.customPrint('EXE RESP: $response');

          if (scaffoldKey != null) {
            if (!calledFromSignOut) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey, message: decodedData['message']);
            }
          }

          uploadTripModel = null;
        } else {
          if (scaffoldKey != null) {
            if (!calledFromSignOut) {
              Utils.showSnackBar(context,
                  scaffoldKey: scaffoldKey, message: decodedData['message']);
            }
          }

          Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          Utils.customPrint('EXE RESP: $response');
        }
        uploadTripModel = null;
      }).onError((error, stackTrace) async{
       // _networkConnectivity.disposeStream();
        Utils.customPrint('ERROR DIO: $error\n$stackTrace');
        if (scaffoldKey != null) {
          if (!calledFromSignOut) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey,
                message:
                    'Failed to upload trip. Please check internet connection and try again.');}
        }
        flutterLocalNotificationsPlugin.cancel(9989);
        uploadTripModel = null;
      });
    } on SocketException catch (_) {
      //_networkConnectivity.disposeStream();
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      uploadTripModel = null;
    }catch (exception, s) {

      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
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
    if (onProgress == null) return byteStream;

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

