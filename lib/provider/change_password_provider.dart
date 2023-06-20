import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import '../models/change_password_model.dart';

class ChangePasswordProvider with ChangeNotifier {
  ChangePasswordModel? changePasswordModel;

  Future<ChangePasswordModel> changePassword(
      BuildContext context,
      String token,
      String password,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.changePassword);

    var queryParameters = {
      "reset_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY4NzI2NzIyNiwianRpIjoiZGE5MDBkYjEtZDhiOS00NGNlLWE0ZWEtNDczNTQ1ZDA0OWZmIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjY0OTE2MGQwZmY4MzU5Y2E5MDRhMDVlNSIsIm5iZiI6MTY4NzI2NzIyNiwiZXhwIjoxNjg3MzUzNjI2fQ.PVeMqBQaWK-EMBYS6POjGx_-9W9NrjCCCC4huMf5sBM",
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

        changePasswordModel = ChangePasswordModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return changePasswordModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        changePasswordModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
      }
      changePasswordModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');

      changePasswordModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught change password:- $exception \n $s');
      changePasswordModel = null;
    }
    return changePasswordModel ?? ChangePasswordModel();
  }
}
