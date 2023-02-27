/*
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/services/database_service.dart';

class GetUserConfigApiProvider with ChangeNotifier {
  GetUserConfigModel? getUserConfigModel;
  final DatabaseService _databaseService = DatabaseService();

  Future<GetUserConfigModel> getUserConfigData(
      BuildContext context,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.getUserConfig);

    var queryParameters = {
      "userID": userId,
    };

    try {
      Utils.customPrint('REGISTER REQ ${jsonEncode(queryParameters)}');

      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REQ : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        getUserConfigModel =
            GetUserConfigModel.fromJson(json.decode(response.body));

        await _databaseService
            .insertVessel(
            getUserConfigModel.vessels!)

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return getUserConfigModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        getUserConfigModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
      }
      getUserConfigModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');

      getUserConfigModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught login:- $exception \n $s');
      getUserConfigModel = null;
    }

    return getUserConfigModel!;
  }
}
*/
