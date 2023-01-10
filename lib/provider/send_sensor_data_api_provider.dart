import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/send_sensor_model.dart';
import 'package:dio/dio.dart' as d;

import '../main.dart';

class SendSensorDataApiProvider extends ChangeNotifier {
  SendSensorDataModel? sendSensorDataModel;

  Future<SendSensorDataModel> sendSensorDataDio(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    d.Dio dio = d.Dio();
    var formData = d.FormData.fromMap({
      'tripId': tripId,
      'sensorZipFiles': await d.MultipartFile.fromFile(zipFile!.path,
          filename: zipFile.path.split('/').last)
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
        onSendProgress: (int sent, int total) {
          print(
              'UPLOAD PROGRESS: ${(sent / total * 100).toStringAsFixed(0)} $sent $total');

          final AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails('progress channel', 'progress channel',
                  channelDescription: 'progress channel description',
                  channelShowBadge: false,
                  importance: Importance.max,
                  priority: Priority.high,
                  onlyAlertOnce: true,
                  showProgress: true,
                  maxProgress: 100,
                  progress: int.parse((sent / total * 100).toStringAsFixed(0)));
          final NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(
              9986,
              'progress notification title',
              'progress notification body',
              platformChannelSpecifics,
              payload: 'item x');

          /* if (sent == total) {
            await flutterLocalNotificationsPlugin.cancel(9981);
          }*/
        },
      ).then((response) {
        print('RESPONSE: ${response.statusCode}');
        print('RESPONSE: ${response.data}');
        var decodedData = json.decode(jsonEncode(response.data));
        if (response.statusCode == HttpStatus.ok) {
          kReleaseMode
              ? null
              : debugPrint('Register Response : ' + response.data.toString());

          if (decodedData['status']) {
            sendSensorDataModel = SendSensorDataModel.fromJson(decodedData);
          }
          return sendSensorDataModel!;
        } else if (response.statusCode == HttpStatus.gatewayTimeout) {
          kReleaseMode
              ? null
              : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
          kReleaseMode ? null : debugPrint('EXE RESP: $response');

          if (scaffoldKey != null) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }

          sendSensorDataModel = null;
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
        sendSensorDataModel = null;
      });
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      sendSensorDataModel = null;
    } catch (exception, s) {
      kReleaseMode
          ? null
          : debugPrint('error caught exception:- $exception \n $s');
      sendSensorDataModel = null;
    }

    return sendSensorDataModel!;
  }

  Future<SendSensorDataModel> sendSensorData(
      BuildContext context,
      String? accessToken,
      File? zipFile,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      "Content-Type": 'multipart/form-data',
      "x-access-token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.SendSensorData);
    try {
      var request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll(headers);
      request.fields['tripId'] = tripId;
      // request.fields['sensorZipFiles'] = '${zipFile}';

      http.MultipartFile file = await http.MultipartFile.fromPath(
          'sensorZipFiles', '${zipFile!.path}');
      request.files.add(file);

      kReleaseMode
          ? null
          : debugPrint('SEND SENSOR DATA RESP : ' + jsonEncode(request.fields));
      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);
      kReleaseMode
          ? null
          : debugPrint(
              'SEND SENSOR DATA RESP : ' + jsonEncode(responseValue.body));

      var decodedData = json.decode(responseValue.body);
      if (responseValue.statusCode == HttpStatus.ok) {
        kReleaseMode
            ? null
            : debugPrint('Register Response : ' + responseValue.body);

        if (decodedData['status']) {
          sendSensorDataModel = SendSensorDataModel.fromJson(decodedData);
        }
        return sendSensorDataModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $responseValue');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        sendSensorDataModel = null;
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
      sendSensorDataModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      sendSensorDataModel = null;
    } catch (exception, s) {
      kReleaseMode
          ? null
          : debugPrint('error caught exception:- $exception \n $s');
      sendSensorDataModel = null;
    }

    return sendSensorDataModel!;
  }
}
