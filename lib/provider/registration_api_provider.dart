import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/registration_model.dart';

class RegistrationApiProvider with ChangeNotifier {
  RegistrationModel? registrationModel;

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
      String socialLoginId,
      String profileImage,
      GlobalKey<ScaffoldState> scaffoldKey) async {
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
        "loginType": "gmail",
        "socialLoginId": socialLoginId,
        "profileImage": profileImage
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
        "socialLoginId": ""
      };
    }

    try {
      Utils.customPrint('REGISTER REQ ${jsonEncode(queryParameters)}');

      final response = await http.post(uri,
          body: jsonEncode(queryParameters), headers: headers);

      Utils.customPrint('REGISTER REQ : ' + response.body);

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + response.body);

        registrationModel =
            RegistrationModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return registrationModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        registrationModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');
      }
      registrationModel = null;
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

      registrationModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught login:- $exception \n $s');
      registrationModel = null;
    }

    return registrationModel!;
  }
}
