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
import 'package:performarine/models/common_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class RemoveDelegateApiProvider with ChangeNotifier
{
  Client client = Client();
  CommonModel? removeDelegateModel;
  String page = "remove_delegate_api_provider";

  Future<CommonModel?> removeDelegate(BuildContext context,
      String? accessToken, String vesselID, delegateID, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.removeDelegate);

    var body = {
      "delegateID": delegateID,
      "vesselID": vesselID
    };

    try {
      final response =
      await client.post(uri, headers: headers, body: json.encode(body));

      Utils.customPrint('REMOVE DELEGATES REQ : ' + json.encode(body));

      var decodedData = json.decode(response.body);

      log('REMOVE DELEGATES : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('REMOVE DELEGATES Status code : ' + response.statusCode.toString());
      Utils.customPrint('REMOVE DELEGATES Status code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        removeDelegateModel = CommonModel.fromJson(json.decode(response.body));

         Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: removeDelegateModel!.message);
        return removeDelegateModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        removeDelegateModel = null;
      }else if(decodedData['statusCode'] == 401)
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

        removeDelegateModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      removeDelegateModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught REMOVE DELEGATES:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught REMOVE DELEGATES:- $exception \n $s -> $page");

      removeDelegateModel = null;
    }
    return removeDelegateModel;
  }
}