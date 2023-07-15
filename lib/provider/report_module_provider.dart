import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../common_widgets/utils/urls.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/log_level.dart';
import '../models/reports_model.dart';
import 'package:http/http.dart' as http;

class ReportModuleProvider with ChangeNotifier {
  ReportModel? reportModel;
  String page = "Report_module_Provider";

  Future<ReportModel> reportData(
      String startDate,
      String endDate,
      int? caseType,
      String? vesselID,
      String? token,
      List<String> selectedTripId,
      BuildContext context,
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
      "x-access-token": token!,
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.reportModule);

    var queryParameters;
    var tempStartDate;
    var tempEndDate;
    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      Utils.customPrint("filter by date:$startDate, $endDate ");
      tempStartDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(startDate + " 00:00:00.000").toUtc());
      tempEndDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(endDate + " 23:11:59.000").toUtc());
      Utils.customPrint("filter by date:$tempStartDate, $tempEndDate");
    }
    if (caseType == 1) {
      queryParameters = {
        "case": caseType,
        "vesselID": vesselID,
        "startDate": tempStartDate,
        "endDate": tempEndDate
      };
    } else {
      queryParameters = {"case": caseType, "tripIds": selectedTripId};
    }

    Utils.customPrint('Report module REQ $queryParameters\ntoken:$token');

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
        if(reportModel == null){
          loggE.e("Error while parsing json data on -> $page ${DateTime.now()}");
          loggV.v("Error while parsing json data on -> $page ${DateTime.now()}");
        }

        reportModel = ReportModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return reportModel!;
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
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        reportModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
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
      reportModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      loggD.d('Socket Exception -> $page ${DateTime.now()}');
      loggE.e('Socket Exception -> $page ${DateTime.now()}');
      loggV.v('Socket Exception -> $page ${DateTime.now()}');

      reportModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught report module:- $exception \n $s');
      loggD.d('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      loggE.e('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      loggV.v('error caught report module:- $exception \n $s -> $page ${DateTime.now()}');
      reportModel = null;
    }
    return reportModel ?? ReportModel();
  }
}
