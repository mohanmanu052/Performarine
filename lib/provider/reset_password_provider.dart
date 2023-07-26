import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/reset_password_model.dart';

import '../common_widgets/widgets/log_level.dart';


class ResetPasswordProvider with ChangeNotifier {
  ResetPasswordModel? resetPasswordModel;
  String page = "reset_password_provider";

  Future<ResetPasswordModel> resetPassword(
      BuildContext context,
      String token,
      String password,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.resetPassword);

    var queryParameters = {
    "reset_token": token,
      "password": password
    };

    Utils.customPrint('ResetPassword REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "ResetPassword REQ $queryParameters -> $page");

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('Reset Password REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Reset Password REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.resetPassword}  is: ${response.statusCode}-> $page");

        if(resetPasswordModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on resetPasswordModel -> $page");
        }

        resetPasswordModel = ResetPasswordModel.fromJson(json.decode(response.body));

          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey, message: resetPasswordModel!.message, status: resetPasswordModel!.status!);

        return resetPasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
        }

        resetPasswordModel = null;
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
      resetPasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      resetPasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught reset password:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught reset password:- $exception \n $s -> $page");
      resetPasswordModel = null;
    }
    return resetPasswordModel ?? ResetPasswordModel();
  }
}
