import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

import '../common_widgets/widgets/log_level.dart';

class GetUserConfigApiProvider with ChangeNotifier {
  GetUserConfigModel? getUserConfigModel;

  CommonProvider? commonProvider;
  String page = "Get_user_config_api_provider";

  Future<GetUserConfigModel?> getUserConfigData(
      BuildContext context,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    BuildContext? ctx;

    bool showErrorDialog = false;

    commonProvider = context.read<CommonProvider>();

    commonProvider!.updateExceptionOccurredValue(false);

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
      "Connection": "Keep-Alive",
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.getUserConfig);

    var queryParameters = {
      "userID": userId,
    };

    try {
      Utils.customPrint('REGISTER REQ ${jsonEncode(queryParameters)}');
      CustomLogger().logWithFile(Level.info, "ResetPassword REQ $queryParameters -> $page");

      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REQ : ' + response.body);
      CustomLogger().logWithFile(Level.info, "REGISTER REs : ' + ' ${response.body}-> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);
       log('Register Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.getUserConfig}  is: ${response.statusCode}-> $page");

        if (decodedData['status']) {
          getUserConfigModel =
              GetUserConfigModel.fromJson(json.decode(response.body));
          if(getUserConfigModel == null){
            CustomLogger().logWithFile(Level.error, "Error while parsing json data on getUserConfigModel -> $page");
          }
        } else {
          commonProvider!.updateExceptionOccurredValue(true);

          showErrorDialog = true;

          showDialog(
              context: scaffoldKey.currentContext!,
              builder: (BuildContext context) {
                ctx = context;
                return CustomDialog(
                  text: 'Failed to sync',
                  subText: 'We are unable to sync data.',
                  positiveBtn: '',
                  cancelBtn: '',
                  positiveBtnOnTap: () {},
                  userConfig: false,
                  isError: true,
                );
              });

          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(ctx!).pop();
          });
        }

        return getUserConfigModel!;
      }
      else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        commonProvider!.updateExceptionOccurredValue(true);

        showErrorDialog = true;

        showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              ctx = context;
              return CustomDialog(
                text: 'Failed to sync',
                subText: 'We are unable to sync data.',
                positiveBtn: '',
                cancelBtn: '',
                positiveBtnOnTap: () {},
                userConfig: false,
                isError: true,
              );
            });

        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(ctx!).pop();
        });

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        getUserConfigModel = null;
      } else {
        commonProvider!.updateExceptionOccurredValue(true);

        showErrorDialog = true;

        showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              ctx = context;
              return CustomDialog(
                text: 'Failed to sync',
                subText: 'We are unable to sync data.',
                positiveBtn: '',
                cancelBtn: '',
                positiveBtnOnTap: () {},
                userConfig: false,
                isError: true,
              );
            });

        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(ctx!).pop();
        });

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      getUserConfigModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey, userConfig: true);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      commonProvider!.updateExceptionOccurredValue(true);

      getUserConfigModel = null;
    } catch (exception, s) {
      commonProvider!.updateExceptionOccurredValue(true);

      CustomLogger().logWithFile(Level.warning, "Failed to sync -> $page");

      showErrorDialog = true;

      showDialog(
          context: scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            ctx = context;
            return CustomDialog(
              text: 'Failed to sync',
              subText: 'We are unable to sync data.',
              positiveBtn: '',
              cancelBtn: '',
              positiveBtnOnTap: () {},
              userConfig: false,
              isError: true,
            );
          });

      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(ctx!).pop();
      });

      commonProvider!.updateConnectionCloseStatus(false);

      Utils.customPrint('error caught getUserConfig:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught getUserConfig:- $exception \n $s -> $page");

      getUserConfigModel = null;
    }

    return getUserConfigModel;
  }

}
