import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

import '../common_widgets/utils/urls.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/log_level.dart';
import '../models/trip_list_model.dart';

class TripListApiProvider extends ChangeNotifier {
  Client client = Client();
  TripList? tripListModel;
  String page = "List_vessels_provider";

  Future<TripList> tripListData(String vesselID, BuildContext context,
      String? accessToken, GlobalKey<ScaffoldState> scaffoldKey) async {

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
      "x_access_token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.GetTripList);

    var body = {"vesselID": vesselID};

    try {
      final response =
          await client.post(uri, headers: headers, body: json.encode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : debugPrint('Trip : ' + response.body);
      kReleaseMode
          ? null
          : debugPrint('Trip Status code : ' + response.statusCode.toString());
      debugPrint('Trip Status code 1: $decodedData');
      loggD.d('Trip Status code 1: $decodedData -> $page ${DateTime.now()}');
      loggV.v('Trip Status code 1: $decodedData -> $page ${DateTime.now()}');

      if (response.statusCode == HttpStatus.ok) {
        tripListModel = TripList.fromJson(json.decode(response.body));
        loggI.i("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");
        loggV.v("API response status is ${response.statusCode} on -> $page ${DateTime.now()}");

        if(tripListModel == null){
          loggE.e("Error while parsing json Data on -> $page ${DateTime.now()}");
          loggV.v("Error while parsing json Data on -> $page ${DateTime.now()}");
        }

        return tripListModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
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

        tripListModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

        tripListModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');
      loggD.d("Socket Exception -> $page ${DateTime.now()}");
      loggE.e("Socket Exception -> $page ${DateTime.now()}");
      loggV.v("Socket Exception -> $page ${DateTime.now()}");

      tripListModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : debugPrint('error caught login:- $exception \n $s');
      loggD.d("error caught login:- $exception \n $s -> $page ${DateTime.now()}");
      loggE.e("error caught login:- $exception \n $s -> $page ${DateTime.now()}");
      loggV.v("error caught login:- $exception \n $s -> $page ${DateTime.now()}");

      tripListModel = null;
    }
    return tripListModel ?? TripList();
  }
}
