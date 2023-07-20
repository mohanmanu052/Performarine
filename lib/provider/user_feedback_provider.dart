import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/upload_trip_model.dart';

/*<<<<<<< HEAD
class sendUserFeedbackProvider with ChangeNotifier {
  //CreateTripModel? createTripModel;
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
    print('ZIPPPP: ${zipFile!.path}');
    print('ZIPPPP: ${zipFile.existsSync()}');
    var formData = d.FormData.fromMap({
      "tripData": jsonEncode(tripData),
      'sensorZipFiles': await d.MultipartFile.fromFile(
        zipFile.path,
        filename: zipFile.path.split('/').last,
        contentType: MediaType("application", "zip"),
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
          // }else{
          //     Utils.showSnackBar(context,
          //         scaffoldKey: scaffoldKey,
          //         message:
          //         'Failed to upload trip. Please check internet connection and try again.');
          //   }
        }
        uploadTripModel = null;
      });
=======*/
import '../models/user_feedback_model.dart';
import 'common_provider.dart';
import 'package:http/http.dart' as http;

class UserFeedbackProvider with ChangeNotifier {
  UserFeedbackModel? userFeedbackModel;
  CommonProvider? commonProvider;

  Future<UserFeedbackModel?> sendUserFeedbackDio(
      BuildContext context,
      String token,
      String subject,
      String description,
      Map<String, dynamic> deviceInfo,
      List<File?> fileList,
      GlobalKey<ScaffoldState> scaffoldKey) async {


    debugPrint("REPORT PROVIDER TOKEN $token");

    Uri uri = Uri.https(Urls.baseUrl, Urls.userFeedback);

    var request = http.MultipartRequest(
        'POST',
        uri
    );

    var headers = {
      HttpHeaders.contentTypeHeader : 'multipart/form-data',
      "x-access-token" : token,
    };

    fileList.forEach((element) async {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('files', element!.path);
      print("request: ${request.files.length}");
      request.files.add(multipartFile);
    });

    request.fields['subject'] = subject;
    request.fields['description'] = description;
    request.fields['deviceInfo'] = jsonEncode(deviceInfo);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    http.Response responseValue = await http.Response.fromStream(response);


    try{

      print('STREAM RESPONSE: ${responseValue.body}');

      dynamic decodedData = json.decode(responseValue.body);

      if(response.statusCode == HttpStatus.ok)
      {
        userFeedbackModel = UserFeedbackModel.fromJson(json.decode(responseValue.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return UserFeedbackModel.fromJson(decodedData);

      }
      else if(response.statusCode == HttpStatus.gatewayTimeout)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        userFeedbackModel = null;

      }
      else if(response.statusCode == HttpStatus.unauthorized)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
      }
      else{

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        userFeedbackModel = null;

      }

    } on SocketException catch (_) {
      //_networkConnectivity.disposeStream();
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      userFeedbackModel = null;
    }catch (exception, s) {
      //_networkConnectivity.disposeStream();

      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
      userFeedbackModel = null;
    }

    return userFeedbackModel;
  }
}