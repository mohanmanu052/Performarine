import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class RemoveFleetMember extends ChangeNotifier
{
  Client client = Client();
  CommonModel? commonModel;

  String page = "remove_fleet_member_api_provider";

  Future<CommonModel?> removeFleetMember(BuildContext context,
      String? accessToken, Map<String,dynamic> body, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };

    debugPrint("REMOVE FLEET MEMBER REQ BODY ${body}");

    Uri uri = Uri.https(Urls.baseUrl, Urls.removeFleetMember);

    Utils.customPrint('REMOVE FLEET MEMBER REQ $body');

    try {
      final response =
      await client.post(uri, headers: headers, body: json.encode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('REMOVE FLEET MEMBER : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('REMOVE FLEET MEMBER code : ' + response.statusCode.toString());
      Utils.customPrint('REMOVE FLEET MEMBER code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        commonModel = CommonModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: commonModel!.message);
        return commonModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        commonModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
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

        commonModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      commonModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught REMOVE FLEET MEMBER :- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught REMOVE FLEET MEMBER :- $exception \n $s -> $page");

      commonModel = null;
    }
    return commonModel;
  }
}