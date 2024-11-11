import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';
import 'package:http/http.dart' as http;

class TripNameUpdateProvider with ChangeNotifier {
  // SpeedReportsModel? speedReportsModel;
  String page = "trip";

  Future<CommonModel> updateTripName(
      BuildContext context,
      String token,
      String tripId,
      String tripName,
      GlobalKey<ScaffoldState> scaffoldKey) async {
        CommonModel resposeModel;
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.updateTripName);

    var bodyData = {"tripId": tripId, "tripName": tripName};

    Utils.customPrint('TRIP UPDATE REQ $bodyData');
    CustomLogger()
        .logWithFile(Level.info, "Trip Name Update REQ $bodyData -> $page");

    try {
      final response =
          await http.post(uri, body: jsonEncode(bodyData), headers: headers);

      Utils.customPrint('TRIP UPDATE REs : ' + response.body);
      CustomLogger().logWithFile(
          Level.info, "TRIP UPDATE REs : ' + ' ${response.body}-> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> data = jsonDecode(response.body);
         resposeModel = CommonModel.fromJson(json.decode(response.body));
        //  Future.delayed(Duration(seconds: 2),(){
        //   Utils.showSnackBar(context,
        //       scaffoldKey: scaffoldKey, message: data['message']);

        //  });

        //   // Utils.showSnackBar(context,
        //   //     scaffoldKey: scaffoldKey, message: data['message']);

        return Future.value(resposeModel);
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error,
            "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        // Utils.showSnackBar(context,
        //     scaffoldKey: scaffoldKey, message: decodedData['message']);
              return Future.value(CommonModel());

        // speedReportsModel = null;
      } else if (decodedData['statusCode'] == 401) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SessionExpiredScreen()));
      } else {
        // Utils.showSnackBar(context,
        //     scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info,
            "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      // speedReportsModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      // speedReportsModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught TRIP UPDATE:- $exception \n $s');
      CustomLogger().logWithFile(
          Level.error, "error caught TRIP UPDATE:- $exception \n $s -> $page");
      //  speedReportsModel = null;
    }
             return Future.value(CommonModel());
;
  }
}
