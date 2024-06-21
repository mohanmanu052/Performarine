import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/speed_reports_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class SpeedReportsApiProvider with ChangeNotifier
{
  SpeedReportsModel? speedReportsModel;
  String page = "speed_reports_provider";

  Future<SpeedReportsModel> speedReports(
      BuildContext context,
      String token,
      String vesselId,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.speedReports);

    var queryParameters = {
      "vesselId": vesselId,
    };

    Utils.customPrint('SPEED REPORTS REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "SPEED REPORTS REQ $queryParameters -> $page");

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('SPEED REPORTS REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "SPEED REPORTS REs : ' + ' ${response.body}-> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        speedReportsModel = SpeedReportsModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: 'speedReportsModel!.message');
        return speedReportsModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        speedReportsModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      speedReportsModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      speedReportsModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught SPEED REPORTS:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught SPEED REPORTS:- $exception \n $s -> $page");
      speedReportsModel = null;
    }
    return speedReportsModel ?? SpeedReportsModel();
  }
}