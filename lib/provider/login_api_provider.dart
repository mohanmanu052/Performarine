import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/login_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

import '../common_widgets/widgets/log_level.dart';

class LoginApiProvider with ChangeNotifier {
  LoginModel? loginModel;
  String page = "Login_api_provider";

  Future<LoginModel> login(
      BuildContext context,
      String email,
      String password,
      bool isLoginWithGoogle,
      bool isLoginWithApple,
      String socialLoginId,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.loginUrl);

    var queryParameters;

    if (isLoginWithGoogle) {
      queryParameters = {
        "userEmail": email.toLowerCase(),
        "password": password,
        "loginType": isLoginWithApple ? "apple" :"gmail",
        "socialLoginId": socialLoginId,
      };
    } else {
      queryParameters = {
        "userEmail": email.toLowerCase(),
        "password": password,
        "loginType": "regular",
        "socialLoginId": ""
      };
    }

    Utils.customPrint('Login REQ $queryParameters');
    CustomLogger().logWithFile(Level.info, "Login REQ $queryParameters -> $page");

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "REGISTER REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.loginUrl}  is: ${response.statusCode}-> $page");

        final pref = await Utils.initSharedPreferences();
        final storage = new FlutterSecureStorage();

        loginModel = LoginModel.fromJson(json.decode(response.body));
        if(loginModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on loginModel -> $page");
        }

        if (loginModel!.status!) {
          pref.setBool('isUserLoggedIn', true);
          await storage.write(key: 'loginModel', value: loginModel.toString());
          await storage.write(key: 'loginData', value: response.body);
          //pref.setString('loginData', response.body);
          //pref.setString('loginModel', loginModel.toString());
        }

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return loginModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        loginModel = null;
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
      loginModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      loginModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught login:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught login:- $exception \n $s -> $page");
      loginModel = null;
    }
    return loginModel ?? LoginModel();
  }
}
