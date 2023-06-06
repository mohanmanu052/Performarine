import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common_widgets/utils/urls.dart';
import '../common_widgets/utils/utils.dart';
import '../models/reports_model.dart';
import 'package:http/http.dart' as http;

class ReportModuleProvider with ChangeNotifier {
  ReportModel? reportModel;

  Future<ReportModel> reportData(
      String startDate,
      String endDate,
      int? caseType,
      String? vesselID,
      String? token,
      List<String> selectedTripId,
      BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token!,
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.reportModule);

    var queryParameters;
    Utils.customPrint("filter by date:$startDate, $endDate ");
    var tempStartDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(startDate+" 00:00:00.000").toUtc());
    var tempEndDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(endDate+" 23:11:59.000").toUtc());
    Utils.customPrint("filter by date:$tempStartDate, $tempEndDate");

    if(caseType == 1){
      queryParameters= {
        "case": caseType,
        "vesselID": vesselID,
        "startDate": tempStartDate,
        "endDate": tempEndDate
      };
    } else{
      queryParameters= {
        "case": caseType,
        "tripIds" : selectedTripId
      };
    }





    Utils.customPrint('Report module REQ $queryParameters\ntoken:$token');

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        final pref = await Utils.initSharedPreferences();

        reportModel = ReportModel.fromJson(json.decode(response.body));



        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return reportModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

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
      }
      reportModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');

      reportModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught report module:- $exception \n $s');
      reportModel = null;
    }
    return reportModel ?? ReportModel();
  }
}
