import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/registration_model.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

import '../common_widgets/widgets/log_level.dart';

class RegistrationApiProvider with ChangeNotifier {
  RegistrationModel? registrationModel;
  String page = "Registration_API_Provider";

  Future<RegistrationModel> registerUser(
      BuildContext context,
      String email,
      String password,
      String countryCode,
      String phoneNumber,
      String country,
      String zipcode,
      dynamic lat,
      dynamic long,
      bool isRegisterWithGoogle,
      bool isRegisterWithApple,
      String socialLoginId,
      String profileImage,
      GlobalKey<ScaffoldState> scaffoldKey,
      String? firstName, lastName) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.registrationUrl);

    var queryParameters;
    if (isRegisterWithGoogle) {
      queryParameters = {
        "userEmail": email,
        "countryCode": countryCode,
        "phone": phoneNumber,
        "country": country,
        "zipCode": zipcode,
        "lat": lat,
        "long": long,
        "loginType": isRegisterWithApple ? "apple" : "gmail",
        "socialLoginId": socialLoginId,
        "profileImage": profileImage,
        "firstName": firstName ?? '',
        "lastName": lastName ?? '',
      };
    } else {
      queryParameters = {
        "userEmail": email,
        "password": password,
        "countryCode": countryCode,
        "phone": phoneNumber,
        "country": country,
        "zipCode": zipcode,
        "lat": lat,
        "long": long,
        "loginType": "regular",
        "socialLoginId": "",
        "firstName": firstName ?? '',
        "lastName": lastName ?? '',
      };
    }

    try {
      Utils.customPrint('REGISTER REQ 1 ${jsonEncode(queryParameters)}');
      CustomLogger().logWithFile(Level.info, "Register REQ $queryParameters -> $page");

      final response = await http.post(uri, body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REQ : ' + response.body);
      CustomLogger().logWithFile(Level.info, "REGISTER REs : ' + ${response.body} -> $page");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${response.body}-> $page");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.registrationUrl}  is: ${response.statusCode}-> $page");

        registrationModel =
            RegistrationModel.fromJson(json.decode(response.body));
        if(registrationModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on registrationModel -> $page");
        }

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return registrationModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");


        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        registrationModel = null;
      } else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      }else {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");
      }
      registrationModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      registrationModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught registration:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught registration:- $exception \n $s -> $page");
      registrationModel = null;
    }

    return registrationModel!;
  }
}
