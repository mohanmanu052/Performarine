import 'dart:convert';
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
    commonProvider = context.read<CommonProvider>();

    commonProvider!.updateExceptionOccurredValue(false);


    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        //ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
            ),
            output: multiOutput
        );
      },
    );

    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        //ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
            ),
            output: multiOutput
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        //ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
            ),
            output: multiOutput
        );
      },
    );

    getDirectoryForInfoLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileI!);
        //ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggI = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
            ),
            output: multiOutput
        );
      },
    );

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

      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REQ : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);
        loggD.d('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggV.v('Register Response : ' + response.body + '-> $page ${DateTime.now()}');
        loggI.i("Api response ${response.statusCode} in ${Urls.baseUrl}${Urls.getUserConfig} -> $page ${DateTime.now()}");
        loggV.v("Api response ${response.statusCode} in ${Urls.baseUrl}${Urls.getUserConfig} -> $page ${DateTime.now()}");

        if (decodedData['status']) {
          getUserConfigModel =
              GetUserConfigModel.fromJson(json.decode(response.body));
          if(getUserConfigModel == null){
            loggE.e("Error while parsing json data on -> $page ${DateTime.now()}");
            loggV.v("Error while parsing json data on -> $page ${DateTime.now()}");
          }
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

        return getUserConfigModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');

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
        loggD.d('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $response -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $response -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${response.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $response -> $page ${DateTime.now()}');
      }
      getUserConfigModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey, userConfig: true);

      Utils.customPrint('Socket Exception');
      loggD.d('Socket Exception -> $page ${DateTime.now()}');
      loggE.e('Socket Exception -> $page ${DateTime.now()}');
      loggV.v('Socket Exception -> $page ${DateTime.now()}');

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

      commonProvider!.updateConnectionCloseStatus(false);

      Utils.customPrint('error caught login:- $exception \n $s');
      loggD.d('error caught login:- $exception \n $s -> $page ${DateTime.now()}');
      loggE.e('error caught login:- $exception \n $s -> $page ${DateTime.now()}');
      loggV.v('error caught login:- $exception \n $s -> $page ${DateTime.now()}');

      getUserConfigModel = null;
    }

    return getUserConfigModel;
  }
}
