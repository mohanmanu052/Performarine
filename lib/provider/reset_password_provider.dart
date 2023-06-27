import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/reset_password_model.dart';


class ResetPasswordProvider with ChangeNotifier {
  ResetPasswordModel? resetPasswordModel;

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

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        final pref = await Utils.initSharedPreferences();

        resetPasswordModel = ResetPasswordModel.fromJson(json.decode(response.body));

          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey, message: resetPasswordModel!.message, status: resetPasswordModel!.status!);

        return resetPasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

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
      }
      resetPasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');

      resetPasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught reset password:- $exception \n $s');
      resetPasswordModel = null;
    }
    return resetPasswordModel ?? ResetPasswordModel();
  }
}
