import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/reset_password_model.dart';

import '../common_widgets/widgets/log_level.dart';


class ResetPasswordProvider with ChangeNotifier {
  ResetPasswordModel? resetPasswordModel;
  String page = "reset_password_provider";

  Future<ResetPasswordModel> resetPassword(
      BuildContext context,
      String token,
      String password,
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

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.resetPassword);

    var queryParameters = {
    "reset_token": token,
      "password": password
    };

    Utils.customPrint('ResetPassword REQ $queryParameters');

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);
        loggD.d('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggV.v('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggI.i("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");
        loggV.v("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");

        final pref = await Utils.initSharedPreferences();

        if(resetPasswordModel == null){
          loggE.e("Error while parsing json data on -> $page ${DateTime.now()}");
          loggV.v("Error while parsing json data on -> $page ${DateTime.now()}");
        }

        resetPasswordModel = ResetPasswordModel.fromJson(json.decode(response.body));

          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey, message: resetPasswordModel!.message, status: resetPasswordModel!.status!);

        return resetPasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');
        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        resetPasswordModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');
      }
      resetPasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      loggD.d('Socket Exception -> $page ${DateTime.now()}');
      loggE.e('Socket Exception -> $page ${DateTime.now()}');
      loggV.v('Socket Exception -> $page ${DateTime.now()}');

      resetPasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught reset password:- $exception \n $s');
      loggD.d('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      loggE.e('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      loggV.v('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      resetPasswordModel = null;
    }
    return resetPasswordModel ?? ResetPasswordModel();
  }
}
