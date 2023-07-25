import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/upload_trip_model.dart';

import '../common_widgets/widgets/log_level.dart';
import '../models/user_feedback_model.dart';
import 'common_provider.dart';
import 'package:http/http.dart' as http;

class UserFeedbackProvider with ChangeNotifier {
  UserFeedbackModel? userFeedbackModel;
  CommonProvider? commonProvider;
  String page = "user_feedback_provider";

  Future<UserFeedbackModel?> sendUserFeedbackDio(
      BuildContext context,
      String token,
      String subject,
      String description,
      Map<String, dynamic> deviceInfo,
      List<File?> fileList,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    Uri uri = Uri.https(Urls.baseUrl, Urls.userFeedback);

    var request = http.MultipartRequest(
        'POST',
        uri
    );

    fileList.forEach((element) async {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('files', element!.path);
      print("request: ${request.files.length}");
      request.files.add(multipartFile);
    });

    request.fields['subject'] = subject;
    request.fields['description'] = description;
    request.fields['deviceInfo'] = jsonEncode(deviceInfo);



    var headers = {
      HttpHeaders.contentTypeHeader : 'multipart/form-data',
      "x-access-token" : token,
    };

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    http.Response responseValue = await http.Response.fromStream(response);


    try{

      print('STREAM RESPONSE: ${responseValue.body}');
      CustomLogger().logWithFile(Level.info, "STREAM RESPONSE: ${responseValue.body}-> $page");

      dynamic decodedData = json.decode(responseValue.body);

      if(response.statusCode == HttpStatus.ok)
      {
        userFeedbackModel = UserFeedbackModel.fromJson(json.decode(responseValue.body));

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${responseValue.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.userFeedback}  is: ${response.statusCode}-> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
        if(userFeedbackModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on userFeedbackModel -> $page");
        }

        return UserFeedbackModel.fromJson(decodedData);

      }
      else if(response.statusCode == HttpStatus.gatewayTimeout)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        userFeedbackModel = null;

      }
      else if(response.statusCode == HttpStatus.unauthorized)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");
      }
      else{

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");

        userFeedbackModel = null;

      }
    } on SocketException catch (_) {
      //_networkConnectivity.disposeStream();
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      userFeedbackModel = null;
    }catch (exception, s) {
      //_networkConnectivity.disposeStream();

      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught user feedback:- $exception \n $s -> $page");
      userFeedbackModel = null;
    }

    return userFeedbackModel;
  }
}