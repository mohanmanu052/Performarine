import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../common_widgets/utils/urls.dart';
import '../common_widgets/utils/utils.dart';
import '../models/trip_list_model.dart';

class TripListApiProvider extends ChangeNotifier {
  Client client = Client();
  TripList? tripListModel;

  Future<TripList> tripListData(String vesselID, BuildContext context,
      String? accessToken, GlobalKey<ScaffoldState> scaffoldKey) async {
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

      kReleaseMode ? null : Utils.customPrint('Trip : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('Trip Status code : ' + response.statusCode.toString());
      Utils.customPrint('Trip Status code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        tripListModel = TripList.fromJson(json.decode(response.body));

        return tripListModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

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
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        tripListModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');

      tripListModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught login:- $exception \n $s');

      tripListModel = null;
    }
    return tripListModel ?? TripList();
  }
}
