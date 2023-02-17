import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/common_model.dart';
import 'package:dio/dio.dart' as d;
import 'package:performarine/models/upload_trip_model.dart';

class SendSensorInfoApiProvider with ChangeNotifier {
  //CreateTripModel? createTripModel;
  CommonModel? commonModel;
  UploadTripModel? uploadTripModel;
  // DeviceInfo? deviceInfo;
  Future<CommonModel> sendSensorInfo(
      BuildContext context,
      String? accessToken,
      File sensorZipFiles,
      Map<String, dynamic> queryParameters,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };
    Uri uri = Uri.https(
      Urls.baseUrl,
      Urls.SendSensorData,
    );
    kReleaseMode ? null : log('CREATE TRIP REQ ${jsonEncode(queryParameters)}');

    try {
      var request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll(headers);
      request.fields['tripData'] = jsonEncode(queryParameters);
      // request.fields['sensorZipFiles'] = '${zipFile}';

      http.MultipartFile file = await http.MultipartFile.fromPath(
          'sensorZipFiles', '${sensorZipFiles.path}');
      request.files.add(file);

      http.StreamedResponse response = await request.send();
      http.Response responseValue = await http.Response.fromStream(response);

      kReleaseMode
          ? null
          : debugPrint('Create Trip REQ : ' + responseValue.body);
      debugPrint('Create Trip CODE : ' + responseValue.statusCode.toString());

      var decodedData = json.decode(responseValue.body);

      if (response.statusCode == HttpStatus.ok) {
        kReleaseMode
            ? null
            : debugPrint('Create Trip Response : ' + responseValue.body);

        commonModel = CommonModel.fromJson(json.decode(responseValue.body));
        //final pref = await Utils.initSharedPreferences();
        //pref.setString('createTrip', response.body);
        // pref.setString('tripId', commonModel?.data?.id ?? '');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
        return commonModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        commonModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
      }
      commonModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      commonModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : debugPrint('error caught login:- $exception \n $s');
      commonModel = null;
    }

    return commonModel!;
  }

  Future<UploadTripModel?> sendSensorDataInfoDio(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      Map<String, dynamic> tripData,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    d.Dio dio = d.Dio();
    var formData = d.FormData.fromMap({
      'tripData': tripData,
      'sensorZipFiles': await d.MultipartFile.fromFile(
        zipFile!.path,
        filename: zipFile.path.split('/').last,
        contentType: new MediaType("image", "jpeg"),
      ),
    });

    debugPrint('SENSOR DATA ${formData.fields}');
    //debugPrint('SENSOR DATA ');

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
          print(
              'UPLOAD PROGRESS: ${(sent / total * 100).toStringAsFixed(0)} $sent $total');

          int finalProgress =
              int.parse((sent / total * 100).toStringAsFixed(0));

          final AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails('progress channel', 'progress channel',
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
              NotificationDetails(android: androidPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(
              9989,
              '$tripId - $finalProgress/100 %',
              '$tripId - $finalProgress/100 %',
              platformChannelSpecifics,
              payload: 'item x');

          /*if (sent == total) {
            await flutterLocalNotificationsPlugin.cancel(9989);
          }*/
        },
      ).then((response) {
        print('RESPONSE: ${response.statusCode}');
        print('RESPONSE: ${jsonEncode(response.data)}');
        var decodedData = json.decode(jsonEncode(response.data));
        if (response.statusCode == HttpStatus.ok) {
          kReleaseMode
              ? null
              : debugPrint('Register Response : ' + response.data.toString());

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
          kReleaseMode
              ? null
              : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          kReleaseMode ? null : debugPrint('EXE RESP: $response');

          if (scaffoldKey != null) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }

          uploadTripModel = null;
        } else {
          if (scaffoldKey != null) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }

          kReleaseMode
              ? null
              : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          kReleaseMode ? null : debugPrint('EXE RESP: $response');
        }
        uploadTripModel = null;
      }).onError((error, stackTrace) {
        print('ERROR DIO: $error\n$stackTrace');
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey,
              message:
                  'Failed to upload trip. Please check internet connection and try again.');
        }
        flutterLocalNotificationsPlugin.cancel(9989);
        uploadTripModel = null;
      });
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      uploadTripModel = null;
    } catch (exception, s) {
      kReleaseMode
          ? null
          : debugPrint('error caught exception:- $exception \n $s');
      uploadTripModel = null;
    }

    return uploadTripModel;
  }

  Future<CommonModel> sendSensorDataInfoStreamed(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      Map<String, dynamic> tripData,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    Uri uri = Uri.https(Urls.baseUrl, Urls.SendSensorData);

    final request = MultipartRequest(
      'POST',
      uri,
      (int bytes, int total) {
        final progress = bytes / total;
        print('PROGRESS: $progress ($bytes/$total)');
      },
    );

    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['x-access-token'] = '$accessToken';

    request.headers['tripData'] = jsonEncode(tripData);

    request.files.add(
      await http.MultipartFile.fromBytes(
        'sensorZipFiles',
        zipFile!.readAsBytesSync(),
      ),
    );

    try {
      final streamedResponse = await request.send();
      http.Response responseValue =
          await http.Response.fromStream(streamedResponse);

      kReleaseMode
          ? null
          : debugPrint('Create Trip REQ : ' + responseValue.body);
      debugPrint('Create Trip CODE : ' + responseValue.statusCode.toString());

      var decodedData = json.decode(responseValue.body);

      if (responseValue.statusCode == HttpStatus.ok) {
        kReleaseMode
            ? null
            : debugPrint('Create Trip Response : ' + responseValue.body);

        commonModel = CommonModel.fromJson(json.decode(responseValue.body));
        //final pref = await Utils.initSharedPreferences();
        //pref.setString('createTrip', response.body);
        // pref.setString('tripId', commonModel?.data?.id ?? '');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
        return commonModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $responseValue');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        commonModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $responseValue');
      }
      commonModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      commonModel = null;
    } catch (exception, s) {
      kReleaseMode
          ? null
          : debugPrint('error caught exception:- $exception \n $s');
      commonModel = null;
    }

    return commonModel!;
  }
}

class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(this.method, this.url, this.onProgress) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;
  final String method;
  final Uri url;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
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
