import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/models/export_report_model.dart';

import '../common_widgets/utils/urls.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/log_level.dart';
import '../models/reports_model.dart';
import 'package:http/http.dart' as http;

class ReportModuleProvider with ChangeNotifier {
  ReportModel? reportModel;
  String page = "Report_module_Provider";



Future<ExportDataModel> exportReportData(Map<String,dynamic> body,String token,BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey)async{
        print('the export report body was----'+body.toString());

ExportDataModel?  exportData;


      var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token,
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.reportModule);



    try {

      final response = await http.post(uri,
          body: jsonEncode(body), headers: headers);
                Utils.customPrint('Headers REs : ' + headers.toString());

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        exportData = ExportDataModel.fromJson(json.decode(response.body));

  //       if(exportData.data?.exportUrl!=null&&exportData.data!.exportUrl!.isNotEmpty){
  //           final response = await http.get(Uri.parse(exportData.data!.exportUrl!));
  //             if (response.statusCode == 200) {
  //   final appDir = await getApplicationDocumentsDirectory();
  //   final filePath = '${appDir.path}/${extractFileNameFromUrl(exportData.data!.exportUrl!.toString())}';

  //   final File imageFile = File(filePath);
  //   await imageFile.writeAsBytes(response.bodyBytes);

  //   // You can display a success message or use the saved image as needed.
  //   print('Csv File downloaded Suceessfully: $filePath');
  // } 

  //       }

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return exportData!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

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

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      reportModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      reportModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught report module:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught report module:- $exception \n $s -> $page");
      reportModel = null;
    }
    return exportData ?? ExportDataModel();
  }


String extractFileNameFromUrl(String url) {
  Uri uri = Uri.parse(url);
  return uri.pathSegments.last;
}




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
        "startDate": startDate,
        "endDate": endDate
      };
    } else {
      queryParameters = {"case": caseType, "tripIds": selectedTripId};
    }

    Utils.customPrint('Report module REQ $queryParameters\ntoken:$token');
    CustomLogger().logWithFile(Level.info, "Report module REQ $queryParameters\ntoken:$token -> $page");

    try {

      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);
                Utils.customPrint('Headers REs : ' + headers.toString());


      Utils.customPrint('Report REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Report REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);
        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.reportModule}  is: ${response.statusCode}-> $page");

        final pref = await Utils.initSharedPreferences();
        if(reportModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on reportModel -> $page");
        }

        reportModel = ReportModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return reportModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

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

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      reportModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      reportModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught report module:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught report module:- $exception \n $s -> $page");
      reportModel = null;
    }
    return reportModel ?? ReportModel();
  }
}
