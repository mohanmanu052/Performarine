import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/delete_trip_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class DeleteTripApiProvider with ChangeNotifier
{
  Client client = Client();
  DeleteTripModel? deleteTripModel;
  String page = "List_vessels_provider";

  Future<DeleteTripModel?> deleteTrip(BuildContext context,
      String? accessToken, String tripId, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.deleteTrip);

    var body = {"tripID": tripId};

    try {
      final response =
      await client.delete(uri, headers: headers, body: json.encode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('Trip : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('Trip Status code : ' + response.statusCode.toString());
      Utils.customPrint('Trip Status code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        deleteTripModel = DeleteTripModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: deleteTripModel!.message);
        return deleteTripModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        deleteTripModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");

        deleteTripModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      deleteTripModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught tripListModel:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught tripListModel:- $exception \n $s -> $page");

      deleteTripModel = null;
    }
    return deleteTripModel;
  }
}