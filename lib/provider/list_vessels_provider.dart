import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

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

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.GetTripList);

    var body = {"vesselID": vesselID};

    try {
      final response =
          await client.post(uri, headers: headers, body: json.encode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('Trip : ' + response.body);
      kReleaseMode
          ? null

          : Utils.customPrint('Trip Status code : ' + response.statusCode.toString());
    Utils.customPrint('Trip Status code 1: $decodedData');
      CustomLogger().logWithFile(Level.info, "Trip Status code 1: $decodedData -> $page");


      if (response.statusCode == HttpStatus.ok) {
        tripListModel = TripList.fromJson(json.decode(response.body));
        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.GetTripList}  is: ${response.statusCode}-> $page");

        if(tripListModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on tripListModel -> $page");
        }

        return tripListModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        tripListModel = null;
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

        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");

        tripListModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);

      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      tripListModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught tripListModel:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught tripListModel:- $exception \n $s -> $page");


      tripListModel = null;
    }
    return tripListModel ?? TripList();
  }
}
