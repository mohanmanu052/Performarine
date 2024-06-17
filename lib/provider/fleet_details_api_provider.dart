import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

import '../common_widgets/utils/urls.dart';

class FleetDetailsApiProvider with ChangeNotifier
{
  FleetDetailsModel? fleetDetailsModel;

  String page = "fleet_details_provider";

  Future<FleetDetailsModel> getFleetDetails(
      BuildContext context,
      String accessToken,
      String fleetId,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.fleetDetails);

    var queryParameters = {
      "fleetId": fleetId,
    };

    Utils.customPrint('FLEET DETAILS REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "ResetPassword REQ $queryParameters -> $page");

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);
      Utils.customPrint('FLEET  REq : ' + jsonEncode(queryParameters).toString());

      Utils.customPrint('FLEET DETAILS REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Reset Password REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('FLEET DETAILS Response : ' + response.body);
log("FLEET DETAILS Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "FLEET DETAILS Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.fleetDetails}  is: ${response.statusCode}-> $page");


        fleetDetailsModel = FleetDetailsModel.fromJson(json.decode(response.body));

        //Utils.showSnackBar(scaffoldKey.currentContext!, scaffoldKey: scaffoldKey, message: fleetDetailsModel!.message, status: fleetDetailsModel!.status!);

        return fleetDetailsModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        fleetDetailsModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      fleetDetailsModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      fleetDetailsModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught FLEET DETAILS:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught FLEET DETAILS:- $exception \n $s -> $page");
      fleetDetailsModel = null;
    }
    return fleetDetailsModel ?? FleetDetailsModel();
  }
}