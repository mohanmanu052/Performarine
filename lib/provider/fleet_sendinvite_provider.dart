import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/create_fleet_response.dart';
import 'package:performarine/pages/delete_account/session_expired_screen.dart';

class SendInviteProvider with ChangeNotifier{
  Future<CreateFleetResponse> sendFleetInvite({String? token,BuildContext? context,GlobalKey<ScaffoldState> ?scaffoldKey, Map<String,dynamic>? data})async{
   CreateFleetResponse? fleetResponse;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token!
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.inViteFleetMembers);

    Utils.customPrint('Invite Fleet Members REQ $data');
    CustomLogger().logWithFile(Level.info, "Invite Fleet Members REQ $data ");

    try {
      final response = await http.post(uri,
          body: jsonEncode(data), headers: headers);

      Utils.customPrint('Invite Fleet Members RES : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Invite Fleet Members RES : ' + ' ${response.body}");

var decodedData=json.decode(response.body);
      if (response.statusCode == HttpStatus.ok) {

        Utils.customPrint('Invite Fleet Members  Response : ' + response.body);
        CustomLogger().logWithFile(Level.info, "Invite Fleet Members Response : ' + ${response.body}");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.creteNewFleet}  is: ${response.statusCode}->");

        fleetResponse = CreateFleetResponse.fromJson(json.decode(response.body));

        Utils.showSnackBar(context!,
            scaffoldKey: scaffoldKey, message: decodedData['message']);


         return fleetResponse;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} ");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context!,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        fleetResponse = null;
      } else if(response.statusCode == 400)
      {
        Navigator.push(
            context!,
            MaterialPageRoute(
                builder: (context) => SessionExpiredScreen()));
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context!,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} ->");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response");
      }
     fleetResponse = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey!);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception ->");

      //fleetResponse = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Invite Fleet Members Fleet:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught create Fleet:- $exception \n $s -> ");
      fleetResponse = null;
    }
    return 
    fleetResponse ?? CreateFleetResponse();
  }

  
}