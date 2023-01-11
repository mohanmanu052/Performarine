import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/common_model.dart';

class SendSensorInfoApiProvider with ChangeNotifier {
  //CreateTripModel? createTripModel;
  CommonModel? commonModel;
  // DeviceInfo? deviceInfo;
  Future<CommonModel> sendSensorInfo(
      BuildContext context,
      String? accessToken,
      File sensorZipFiles,
      Map<String, dynamic> queryParameters,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };
    Uri uri = Uri.https(
      Urls.baseUrl,
      Urls.SendSensorData,
    );
    kReleaseMode ? null : log('CREATE TRIP REQ ${jsonEncode(queryParameters)}');

    try {
      var request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll(headers);
      request.fields['tripData'] = queryParameters.toString();
      // request.fields['sensorZipFiles'] = '${zipFile}';

      http.MultipartFile file = await http.MultipartFile.fromPath(
          'sensorZipFiles', '${sensorZipFiles.path}');
      request.files.add(file);

      http.StreamedResponse response = await request.send();
      http.Response responseValue = await http.Response.fromStream(response);

      kReleaseMode
          ? null
          : debugPrint('Create Trip REQ : ' + responseValue.body);
      debugPrint('Create Trip CODE : ' + responseValue.statusCode.toString());

      var decodedData = json.decode(responseValue.body);

      if (response.statusCode == HttpStatus.ok) {
        kReleaseMode
            ? null
            : debugPrint('Create Trip Response : ' + responseValue.body);

        commonModel = CommonModel.fromJson(json.decode(responseValue.body));
        //final pref = await Utils.initSharedPreferences();
        //pref.setString('createTrip', response.body);
        // pref.setString('tripId', commonModel?.data?.id ?? '');
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
        return commonModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        commonModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $response');
      }
      commonModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      commonModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : debugPrint('error caught login:- $exception \n $s');
      commonModel = null;
    }

    return commonModel!;
  }
}
