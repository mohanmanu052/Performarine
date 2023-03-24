import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class GetUserConfigApiProvider with ChangeNotifier {
  GetUserConfigModel? getUserConfigModel;
  final DatabaseService _databaseService = DatabaseService();

  CommonProvider? commonProvider;

  Future<GetUserConfigModel?> getUserConfigData(
      BuildContext context,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    commonProvider = context.read<CommonProvider>();

    commonProvider!.updateExceptionOccurredValue(false);

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
      "Connection": "Keep-Alive",
    };

    Uri uri = Uri.http(Urls.baseUrl, Urls.getUserConfig);

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

        if (decodedData['status']) {
          getUserConfigModel =
              GetUserConfigModel.fromJson(json.decode(response.body));
        } else {
          commonProvider!.updateExceptionOccurredValue(true);

          showDialog(
              context: scaffoldKey.currentContext!,
              builder: (BuildContext context) {
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
            Navigator.of(context).pop();
          });
        }

        /* Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);*/

        return getUserConfigModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        commonProvider!.updateExceptionOccurredValue(true);

        showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
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
          Navigator.of(context).pop();
        });

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        getUserConfigModel = null;
      } else {
        commonProvider!.updateExceptionOccurredValue(true);

        showDialog(
            context: scaffoldKey.currentContext!,
            builder: (BuildContext context) {
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
          Navigator.of(context).pop();
        });

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
      }
      getUserConfigModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey, userConfig: true);

      Utils.customPrint('Socket Exception');

      commonProvider!.updateExceptionOccurredValue(true);

      getUserConfigModel = null;
    } catch (exception, s) {
      commonProvider!.updateExceptionOccurredValue(true);

      showDialog(
          context: scaffoldKey.currentContext!,
          builder: (BuildContext context) {
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
        Navigator.of(context).pop();
      });

      Utils.customPrint('error caught login:- $exception \n $s');

      getUserConfigModel = null;
    }

    return getUserConfigModel;
  }
}
