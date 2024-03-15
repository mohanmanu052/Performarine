import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/common_model.dart';

class EditFleetApiProvider with ChangeNotifier
{
  CommonModel? editFleetModel;

  String page = "edit_fleet_api_provider";

  Future<CommonModel> editFleetDetails(
      BuildContext context,
      String accessToken,
      String fleetId,
      String fleetName,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.creteNewFleet);

    var queryParameters = {
      "fleetId": fleetId,
      "fleetName": fleetName
    };

    Utils.customPrint('EDIT FLEET DETAILS REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "EDIT FLEET DETAILS REQ $queryParameters -> $page");

    try {
      final response = await http.put(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('EDIT FLEET DETAILS REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "EDIT FLEET DETAILS REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('EDIT FLEET DETAILS Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "EDIT FLEET DETAILS Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.fleetDetails}  is: ${response.statusCode}-> $page");


        editFleetModel = CommonModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(scaffoldKey.currentContext!, scaffoldKey: scaffoldKey, message: editFleetModel!.message, status: editFleetModel!.status!);

        return editFleetModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        editFleetModel = null;
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
      editFleetModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      editFleetModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught EDIT FLEET DETAILS:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught Edit FLEET DETAILS:- $exception \n $s -> $page");
      editFleetModel = null;
    }
    return editFleetModel ?? CommonModel();
  }
}