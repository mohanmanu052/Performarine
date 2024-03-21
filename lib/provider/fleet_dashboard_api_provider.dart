import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/provider/common_provider.dart';

import '../common_widgets/widgets/log_level.dart';


class FleetDashboardApiProvider with ChangeNotifier
{
  Client client = Client();
  FleetDashboardModel? fleetDashboardModel;

  CommonProvider? commonProvider;
  String page = "Get_user_config_api_provider";

  Future<FleetDashboardModel?> fleetDashboardData(BuildContext context,
      String? accessToken, GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.fleetDashboardApi);

    try {
      final response =
      await client.get(uri, headers: headers,);

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('fleetDashboardData : ' + response.body);
      kReleaseMode
          ? null
          : Utils.customPrint('Fleet Dashboard Status code : ' + response.statusCode.toString());
      log('Fleet Dashboard Status code 1: $decodedData');

      if (response.statusCode == HttpStatus.ok) {
        fleetDashboardModel = FleetDashboardModel.fromJson(json.decode(response.body));

        //Utils.showSnackBar(context, scaffoldKey: scaffoldKey, message: fleetDashboardModel!.message);
        return fleetDashboardModel!;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $response -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        fleetDashboardModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${response.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $response -> $page");

        fleetDashboardModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      fleetDashboardModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught fleetDashboardModel:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught fleetDashboardModel:- $exception \n $s -> $page");

      fleetDashboardModel = null;
    }
    return fleetDashboardModel;
  }


  Future<Response> acceptfleetInvite(Uri url)async{
    Response? response;
    try {
      // Uri uri1 = Uri.https('goeapidev.azurewebsites.net/fleetmember');
      // var headers = {
      //   HttpHeaders.contentTypeHeader: 'application/json',
      //   "x_access_token": '',
      // };
       response =
      await client.get(url,
          //headers: headers
      );
      print('the response was-----'+response.toString());
return response;
    }catch(err){

    }
   return response??Response('', 400);
  }

}