import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/upload_trip_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';
import '../models/user_feedback_model.dart';
import 'common_provider.dart';
import 'package:http/http.dart' as http;

class UserFeedbackProvider with ChangeNotifier {
  UserFeedbackModel? userFeedbackModel;
  CommonProvider? commonProvider;

  Future<UserFeedbackModel?> sendUserFeedbackDio(
      BuildContext context,
      String token,
      String subject,
      String description,
      Map<String, dynamic> deviceInfo,
      List<File?> fileList,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    Uri uri = Uri.https(Urls.baseUrl, Urls.userFeedback);

    var request = http.MultipartRequest(
        'POST',
        uri
    );

    fileList.forEach((element) async {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('files', element!.path);
      request.files.add(multipartFile);
    });
    request.fields['subject'] = subject;
    request.fields['description'] = description;
    request.fields['deviceInfo'] = jsonEncode(deviceInfo);



    var headers = {
      HttpHeaders.contentTypeHeader : 'multipart/form-data',
      "x-access-token" : token,
    };

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    http.Response responseValue = await http.Response.fromStream(response);


    try{

      Utils.customPrint('STREAM RESPONSE: ${responseValue.body}');

      dynamic decodedData = json.decode(responseValue.body);

      if(response.statusCode == HttpStatus.ok)
      {
        userFeedbackModel = UserFeedbackModel.fromJson(json.decode(responseValue.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return UserFeedbackModel.fromJson(decodedData);

      }
      else if(response.statusCode == HttpStatus.gatewayTimeout)
      {

        kReleaseMode ? null : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        userFeedbackModel = null;

      }
      else if(response.statusCode == HttpStatus.unauthorized)
      {

        kReleaseMode ? null : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');
      }
      else if(response.statusCode == 400)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      }
      else{

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        kReleaseMode ? null : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        userFeedbackModel = null;

      }
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      userFeedbackModel = null;
    }catch (exception, s) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('error caught exception:- $exception \n $s');
      userFeedbackModel = null;
    }

    return userFeedbackModel;
  }
}