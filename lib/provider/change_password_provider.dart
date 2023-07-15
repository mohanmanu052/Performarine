import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import '../common_widgets/widgets/log_level.dart';
import '../models/change_password_model.dart';

class ChangePasswordProvider with ChangeNotifier {
  ChangePasswordModel? changePasswordModel;
  String page = "change_password_provider";

  Future<ChangePasswordModel> changePassword(
      BuildContext context,
      String token,
      String currentPassword,
      String newPassword,
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
      "x-access-token": token
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.changePassword);

    var queryParameters = {
      "currentPassword": currentPassword,
      "newPassword": newPassword
    };

    Utils.customPrint('ResetPassword REQ $queryParameters');
    loggD.d('ResetPassword REQ $queryParameters-> $page ${DateTime.now()}');
    loggV.v('ResetPassword REQ $queryParameters-> $page ${DateTime.now()}');

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);
      loggD.d('REGISTER REs : ' + ' ${response.body} ->' '$page ${DateTime.now()}');
      loggV.v('REGISTER REs : ' + ' ${response.body} ->' '$page ${DateTime.now()}');

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);
        loggD.d('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggV.v('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggI.i("API success of ${Urls.baseUrl}${Urls.createVessel} -> $page ${DateTime.now()} ");
        loggV.v("API success of ${Urls.baseUrl}${Urls.createVessel} -> $page ${DateTime.now()} ");

        final pref = await Utils.initSharedPreferences();

        changePasswordModel = ChangePasswordModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        if(changePasswordModel == null){
          loggE.e("Getting null while json parsing -> $page ${DateTime.now()}");
          loggV.v("Getting null while json parsing -> $page ${DateTime.now()}");
        }

        return changePasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        loggD.d("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        changePasswordModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        loggD.d("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggD.d("EXE RESP: $response -> $page ${DateTime.now()}");
        loggE.e("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggE.e("EXE RESP: $response -> $page ${DateTime.now()}");

        loggV.v("EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}");
        loggV.v("EXE RESP: $response -> $page ${DateTime.now()}");
      }
      changePasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      loggD.d("Socket Exception -> $page ${DateTime.now()}");
      loggE.e("Socket Exception -> $page ${DateTime.now()}");
      loggV.v("Socket Exception -> $page ${DateTime.now()}");

      changePasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught change password:- $exception \n $s');
      loggD.d("error caught Add Vessel:- $exception \n $s -> $page ${DateTime.now()}");
      loggE.e("error caught Add Vessel:- $exception \n $s -> $page ${DateTime.now()}");
      loggV.v("error caught Add Vessel:- $exception \n $s -> $page ${DateTime.now()}");
      changePasswordModel = null;
    }
    return changePasswordModel ?? ChangePasswordModel();
  }
}
