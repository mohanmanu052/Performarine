import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class DeleteAccountApiProvider with ChangeNotifier
{
  CommonModel? commonModel;

  String page = "delete_account_provider";

  Future<CommonModel> deleteAccount(
      BuildContext context,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.deleteAccount);

    try {
      final response = await http.get(uri, headers: headers);

      Utils.customPrint('DELETE ACCOUNT REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "DELETE ACCOUNT REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('DELETE ACCOUNT Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "DELETE ACCOUNT Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.deleteAccount}  is: ${response.statusCode}-> $page");


        commonModel = CommonModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(scaffoldKey.currentContext!,
            scaffoldKey: scaffoldKey, message: commonModel!.message, status: commonModel!.status!);

        return commonModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
      
        commonModel = null;
      }else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message'], status: false);
      
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      commonModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      commonModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught DELETE ACCOUNT:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught DELETE ACCOUNT:- $exception \n $s -> $page");
      commonModel = null;
    }
    return commonModel ?? CommonModel();
  }
}