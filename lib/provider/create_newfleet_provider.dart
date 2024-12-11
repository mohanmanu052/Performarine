import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/create_fleet_response.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class CreateNewFleetProvider with ChangeNotifier{
  Future<CreateFleetResponse> createFleet(String token,
      GlobalKey<ScaffoldState> scaffoldKey,BuildContext context,Map<String,dynamic> data)async{
CreateFleetResponse? fleetResponse;
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.creteNewFleet);

    Utils.customPrint('Create Fleet  REQ $data');
    CustomLogger().logWithFile(Level.info, "Create New Fleet REQ $data ");

    try {
      final response = await http.post(uri,
          body: jsonEncode(data), headers: headers);

      Utils.customPrint('Create Fleet REs : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Create Fleet REs : ' + ' ${response.body}");

      var decodedData = json.decode(response.body);

      if (response.statusCode == HttpStatus.ok) {
        Utils.customPrint('Create Fleet  Response : ' + response.body);
        CustomLogger().logWithFile(Level.info, "Create Fleet Response : ' + ${response.body}");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.creteNewFleet}  is: ${response.statusCode}->");

        fleetResponse = CreateFleetResponse.fromJson(json.decode(response.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);


         return fleetResponse;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} ");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        fleetResponse = null;
      }else if(decodedData['statusCode'] == 401)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);
      
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} ->");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response");
      }
      fleetResponse = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception ->");

      fleetResponse = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Crate New Fleet:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught create Fleet:- $exception \n $s -> ");
      fleetResponse = null;
    }
    return fleetResponse ?? CreateFleetResponse();
  }

  }
//}