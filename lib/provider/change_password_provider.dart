import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';
import '../common_widgets/widgets/log_level.dart';
import '../models/change_password_model.dart';

class ChangePasswordProvider with ChangeNotifier {
  ChangePasswordModel? changePasswordModel;
  String page = "change_password_provider";

  Future<ChangePasswordModel> changePassword(
      BuildContext context,
      String token,
      String currentPassword,
      String newPassword,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.changePassword);

    var queryParameters = {
      "currentPassword": currentPassword,
      "newPassword": newPassword
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
        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.changePassword}  is: ${response.statusCode}-> $page");

        changePasswordModel = ChangePasswordModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        if(changePasswordModel == null){
          CustomLogger().logWithFile(Level.error, "Getting null while json parsing -> $page");
        }

        return changePasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        changePasswordModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      changePasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      changePasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught change password:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught change password:- $exception \n $s -> $page");
      changePasswordModel = null;
    }
    return changePasswordModel ?? ChangePasswordModel();
  }
}
