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

class CreateDelegateApiProvider with ChangeNotifier
{

  Client client = Client();
  CommonModel? commonModel;

  String page = "create_delegate_api_provider";

  Future<CommonModel?> createDelegate(BuildContext context,
      String? accessToken, String vesselId, userEmail, delegateAccessType, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };

    var body = {
      "vesselID": vesselId,
      "userEmail": userEmail,
      "delegateAccessType" : delegateAccessType
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.createDelegate);

    Utils.customPrint('CREATE DELEGATE REQ $body');

    try {
      final response =
      await client.post(uri, headers: headers, body: json.encode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('CREATE DELEGATE : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('CREATE DELEGATE code : ' + response.statusCode.toString());
      Utils.customPrint('CREATE DELEGATE code 1: $decodedData');

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

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        commonModel = null;
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

        commonModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      commonModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught CREATE DELEGATE :- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught CREATE DELEGATE :- $exception \n $s -> $page");

      commonModel = null;
    }
    return commonModel;
  }

}