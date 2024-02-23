import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:http/http.dart' as http;

class FleetListProvider with ChangeNotifier{
    Future<FleetListModel> getFleetDetails({String? token,BuildContext? context,GlobalKey<ScaffoldState> ?scaffoldKey})async{
   FleetListModel? fleetResponse;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token!
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.fleetList);


    try {
      final response = await http.get(uri,

           headers: headers);


      Utils.customPrint('Fleet List RES : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Fleet List RES : ' + ' ${response.body}");

var decodedData=json.decode(response.body);
      if (response.statusCode == HttpStatus.ok) {
              // decodedData = json.decode(response.body);

        Utils.customPrint('Fleet List  Response : ' + response.body);
        CustomLogger().logWithFile(Level.info, "Fleet List Response : ' + ${response.body}");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.fleetList}  is: ${response.statusCode}->");

        fleetResponse = FleetListModel.fromJson(json.decode(response.body));

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

      fleetResponse = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Get Fleet List:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught Get Fleet List:- $exception \n $s -> ");
      fleetResponse = null;
    }
    return 
    fleetResponse ?? FleetListModel();
  }

}