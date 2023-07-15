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

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForInfoLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileI!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggI = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForWarningLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileW!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggW = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

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

      dynamic decodedData = json.decode(responseValue.body);

      if(response.statusCode == HttpStatus.ok)
      {
        userFeedbackModel = UserFeedbackModel.fromJson(json.decode(responseValue.body));
        loggD.d('Register Response : ' + responseValue.body + '-> $page ${DateTime.now()}');
        loggV.v('Register Response : ' + responseValue.body + '-> $page ${DateTime.now()}');
        loggI.i("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");
        loggV.v("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
        if(userFeedbackModel == null){
          loggE.e("Error while parsing json data on -> $page ${DateTime.now()}");
          loggV.v("Error while parsing json data on -> $page ${DateTime.now()}");
        }

        return UserFeedbackModel.fromJson(decodedData);

      }
      else if(response.statusCode == HttpStatus.gatewayTimeout)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');
        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        userFeedbackModel = null;

      }
      else if(response.statusCode == HttpStatus.unauthorized)
      {

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');
      }
      else{

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        kReleaseMode ? null : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

        userFeedbackModel = null;

      }
    } on SocketException catch (_) {
      //_networkConnectivity.disposeStream();
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      loggD.d('Socket Exception -> $page ${DateTime.now()}');
      loggE.e('Socket Exception -> $page ${DateTime.now()}');
      loggV.v('Socket Exception -> $page ${DateTime.now()}');

      userFeedbackModel = null;
    }catch (exception, s) {
      //_networkConnectivity.disposeStream();

      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
      loggD.d('error caught exception:- $exception \n $s -> $page ${DateTime.now()}');
      loggE.e('error caught exception:- $exception \n $s -> $page ${DateTime.now()}');
      loggV.v('error caught exception:- $exception \n $s -> $page ${DateTime.now()}');
      userFeedbackModel = null;
    }

    return userFeedbackModel;
  }
}