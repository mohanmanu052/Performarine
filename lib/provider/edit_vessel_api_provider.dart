/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';

import '../common_widgets/widgets/log_level.dart';

class EditVesselApiProvider with ChangeNotifier {
  AddVesselModel? addVesselModel;
  String page = "Edit_vessel_api_provider";

  Future<AddVesselModel> editVesselData(
      BuildContext context,
      AddVesselRequestModel? addVesselRequestModel,
      String userId,
      String vesselId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x-access-token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.editVessel);

    try {
      var request = http.MultipartRequest(
        'POST',
        uri,
      );

      if (addVesselRequestModel!.files!.isNotEmpty) {
        addVesselRequestModel.files!.forEach((element) async {
          int index = addVesselRequestModel.files!.indexOf(element);
          http.MultipartFile multipartFile =
              await http.MultipartFile.fromPath('files', element!.path);
          request.files.add(multipartFile);
        });
      }

      Utils.customPrint('NAME ${addVesselRequestModel.name!}');
      Utils.customPrint('Model ${addVesselRequestModel.model!}');
      Utils.customPrint('Builder Name ${addVesselRequestModel.builderName!}');
      Utils.customPrint('regNumber ${addVesselRequestModel.regNumber!}');
      Utils.customPrint('mmsi ${addVesselRequestModel.MMSI!}');
      Utils.customPrint('Engine Type ${addVesselRequestModel.engineType!}');
      Utils.customPrint('Fuel Capacity ${addVesselRequestModel.fuelCapacity!}');
      Utils.customPrint('weight ${addVesselRequestModel.weight!}');
      Utils.customPrint('freeBoard ${addVesselRequestModel.freeBoard!}');
      Utils.customPrint(
          'length Overall ${addVesselRequestModel.lenghtOverAll!}');
      Utils.customPrint('beam ${addVesselRequestModel.beam!}');
      Utils.customPrint('depth ${addVesselRequestModel.depth!}');
      Utils.customPrint('vesselSize ${addVesselRequestModel.size!}');
      Utils.customPrint('capacity ${addVesselRequestModel.capacity!}');
      Utils.customPrint('built Year ${addVesselRequestModel.builtYear!}');
      Utils.customPrint('user Id ${userId}');
      Utils.customPrint(
          'Image Urls ${addVesselRequestModel.imageUrls!.isEmpty}');
      Utils.customPrint('user Id ${addVesselRequestModel.batteryCapacity}');

      request.headers.addAll(headers);
      request.fields['name'] = addVesselRequestModel.name!;
      request.fields['model'] = addVesselRequestModel.model!;
      request.fields['builderName'] = addVesselRequestModel.builderName!;
      request.fields['regNumber'] = addVesselRequestModel.regNumber!;
      request.fields['MMSI'] = addVesselRequestModel.MMSI!;
      request.fields['engineType'] = addVesselRequestModel.engineType!;
      request.fields['fuelCapacity'] = addVesselRequestModel.fuelCapacity!;
      request.fields['weight'] = addVesselRequestModel.weight!;
      request.fields['freeBoard'] = addVesselRequestModel.freeBoard!;
      request.fields['lengthOverall'] = addVesselRequestModel.lenghtOverAll!;
      request.fields['beam'] = addVesselRequestModel.beam!;
      request.fields['depth'] = addVesselRequestModel.depth!;
      request.fields['vesselSize'] = addVesselRequestModel.size!;
      request.fields['capacity'] = addVesselRequestModel.capacity!;
      request.fields['builtYear'] = addVesselRequestModel.builtYear!;
      request.fields['userID'] = userId;
      request.fields['vesselStatus'] = addVesselRequestModel.vesselStatus == 0
          ? '2'
          : addVesselRequestModel.vesselStatus!.toString();
      request.fields['imageURL'] = addVesselRequestModel.imageUrls ?? ' ';
      request.fields['vesselID'] = vesselId;
      request.fields['batteryCapacity'] =
          addVesselRequestModel.batteryCapacity!;

      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);

      Utils.customPrint('Add VESSEL RESP : ' + jsonEncode(responseValue.body));

      var decodedData = json.decode(responseValue.body);
// here
      if (responseValue.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + responseValue.body);
        CustomLogger().logWithFile(Level.info, "Register Response : ' + ${responseValue.body} -> $page");
        CustomLogger().logWithFile(Level.info, "API response is ${responseValue.statusCode} on -> $page");

        addVesselModel =
            AddVesselModel.fromJson(json.decode(responseValue.body));

        if(addVesselModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on -> $page");
        }
        CustomLogger().logWithFile(Level.info, "Register Response: ' + ${json.decode(responseValue.body)} + '-> $page");

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return addVesselModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        Utils.customPrint('EXE RESP: $responseValue');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $responseValue -> $page");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        addVesselModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        Utils.customPrint('EXE RESP: $responseValue');
        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $responseValue -> $page");
      }
      addVesselModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      addVesselModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught edit vessel api provider:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught edit vessel api provider:- $exception \n $s");

      addVesselModel = null;
    }

    return addVesselModel!;
  }
}
*/
