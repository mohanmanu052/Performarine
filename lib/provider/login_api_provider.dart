import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/login_model.dart';

class LoginApiProvider with ChangeNotifier {
  LoginModel? loginModel;

  Future<LoginModel> login(
      BuildContext context,
      String email,
      String password,
      bool isLoginWithGoogle,
      String socialLoginId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.loginUrl);

    var queryParameters;

    if (isLoginWithGoogle) {
      queryParameters = {
        "userEmail": email,
        "password": password,
        "loginType": "gmail",
        "socialLoginId": socialLoginId
      };
    } else {
      queryParameters = {
        "userEmail": email,
        "password": password,
        "loginType": "regular",
        "socialLoginId": ""
      };
    }

    Utils.customPrint('Login REQ $queryParameters');

    try {
      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REs : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        final pref = await Utils.initSharedPreferences();

        loginModel = LoginModel.fromJson(json.decode(response.body));

        pref.setBool('isUserLoggedIn', true);
        pref.setString('loginData', response.body);
        pref.setString('loginModel', loginModel.toString());

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return loginModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        loginModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
      }
      loginModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      /*showDialog(
          context: scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return CustomDialog(
              text: 'No Internet',
              subText: 'Please enable your data connection to continue.',
              negativeBtn: 'Re-Send',
              positiveBtn: 'Okay',
              negativeBtnOnTap: () {
                Navigator.of(scaffoldKey.currentContext!).pop();
              },
              positiveBtnOnTap: () {
                Navigator.of(scaffoldKey.currentContext!).pop();
              },
            );
          });*/
      Utils.customPrint('Socket Exception');

      loginModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught login:- $exception \n $s');
      loginModel = null;
    }
    return loginModel ?? LoginModel();
  }
}
