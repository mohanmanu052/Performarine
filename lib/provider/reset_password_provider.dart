import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

import '../models/forgot_password_model.dart';


class ResetPasswordProvider with ChangeNotifier {
  ForgotPasswordModel? forgotPasswordModel;

  Future<ForgotPasswordModel> resetPassword(
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

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        final pref = await Utils.initSharedPreferences();

        forgotPasswordModel = ForgotPasswordModel.fromJson(json.decode(response.body));

          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey, message: forgotPasswordModel!.message);

        return forgotPasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

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
      }
      forgotPasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');

      forgotPasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught reset password:- $exception \n $s');
      forgotPasswordModel = null;
    }
    return forgotPasswordModel ?? ForgotPasswordModel();
  }
}
