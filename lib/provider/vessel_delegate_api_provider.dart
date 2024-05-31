import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/vessel_delegate_model.dart';

class VesselDelegateApiProvider with ChangeNotifier
{
  Client client = Client();
  VesselDelegateModel? vesselDelegateModel;
  String page = "vessel_delegate_api_provider";

  Future<VesselDelegateModel?> vesselDelegateData(BuildContext context,
      String? accessToken, String vesselID, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.vesselDelegates);

    var body = {

      "vesselID": vesselID

    };

    try {
      final response =
      await client.post(uri, headers: headers, body: json.encode(body));

      Utils.customPrint('VESSEL DELEGATES REQ : ' + json.encode(body));

      var decodedData = json.decode(response.body);

    log('VESSEL DELEGATES : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('VESSEL DELEGATES Status code : ' + response.statusCode.toString());
      Utils.customPrint('VESSEL DELEGATES Status code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        vesselDelegateModel = VesselDelegateModel.fromJson(json.decode(response.body));

       /* Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: vesselDelegateModel!.message);*/
        return vesselDelegateModel!;
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

        vesselDelegateModel = null;
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

        vesselDelegateModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      vesselDelegateModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught VESSEL DELEGATES:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caughtVESSEL DELEGATES:- $exception \n $s -> $page");

      vesselDelegateModel = null;
    }
    return vesselDelegateModel;
  }
}