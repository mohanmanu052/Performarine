import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

import '../common_widgets/widgets/log_level.dart';
import '../models/forgot_password_model.dart';


class ForgotPasswordProvider with ChangeNotifier {
  ForgotPasswordModel? forgotPasswordModel;
  String page = "forgot_password_provider";

  Future<ForgotPasswordModel> forgotPassword(
      BuildContext context,
      String email,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.forgotPassword);

    var queryParameters = {
      "email": email
    };

    Utils.customPrint('ResetPassword REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "ResetPassword REQ $queryParameters -> $page");

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "REGISTER REs : ' + ' ${response.body}-> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${json.decode(response.body)}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.forgotPassword}  is: ${response.statusCode}-> $page");

        final pref = await Utils.initSharedPreferences();

        forgotPasswordModel = ForgotPasswordModel.fromJson(json.decode(response.body));
        if(forgotPasswordModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on forgotPasswordModel -> $page");
        }

        Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: forgotPasswordModel!.message);

        return forgotPasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        forgotPasswordModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      forgotPasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      forgotPasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught forgot password:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught forgot password:- $exception \n $s -> $page");
      forgotPasswordModel = null;
    }
    return forgotPasswordModel ?? ForgotPasswordModel();
  }
}
