import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:http/http.dart' as http;
import 'package:performarine/models/common_model.dart';


class FleetAssignVesselsProvider with ChangeNotifier{
  Future<CommonModel> addVesselAndGrantAccess({String? token,BuildContext? context,GlobalKey<ScaffoldState> ?scaffoldKey,Map<String,dynamic>? data})async{
   
   CommonModel? responseModel;
         Utils.customPrint('Fleet List RES : ' + jsonEncode(data));

    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": token!
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.addFleetVessels);


    try {
      var response = await http.post(uri,
          body: jsonEncode(data), headers: headers);

      Utils.customPrint('Fleet List RES : ' + response.body);
      CustomLogger().logWithFile(Level.info, "Fleet List RES : ' + ' ${response?.body}");

var decodedData=json.decode(response.body);
      if (response.statusCode == HttpStatus.ok) {

        Utils.customPrint('Add Fleet Vessel  Response : ' + response.body);
        CustomLogger().logWithFile(Level.info, "Add Fleet Vessel  Response : ' + ${response.body}");
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.addFleetVessels}  is: ${response.statusCode}->");

        responseModel = CommonModel.fromJson(json.decode(response.body));

        Utils.showSnackBar(context!,
            scaffoldKey: scaffoldKey, message: decodedData['message']);


         return responseModel;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${response?.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response?.statusCode} ");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context!,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        responseModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context!,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${response?.statusCode}');
        Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response?.statusCode} ->");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response");
      }
     responseModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey!);

      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception ->");

      responseModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Get Fleet List:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught Get Fleet List:- $exception \n $s -> ");
      responseModel = null;
    }
    return 
    responseModel??CommonModel() ;
  }


  
}