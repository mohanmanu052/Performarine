import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/models/vessel.dart';

import '../common_widgets/widgets/log_level.dart';

class AddVesselApiProvider with ChangeNotifier {
  AddVesselModel? addVesselModel;
  String page = "Add_Vessel_Api_Provider";

  Future<AddVesselModel?> addVesselData(
      BuildContext context,
      CreateVessel? addVesselRequestModel,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey,
      {bool calledFromSignOut = false}) async {

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };

    Uri uri = Uri.https(Urls.baseUrl, Urls.createVessel);

    try {
      var request = http.MultipartRequest(
        'POST',
        uri,
      );

      if (addVesselRequestModel!.selectedImages == null ||
          addVesselRequestModel.selectedImages!.isEmpty) {
      } else {
        addVesselRequestModel.selectedImages!.forEach((element) async {
          int index = addVesselRequestModel.selectedImages!.indexOf(element);
          http.MultipartFile multipartFile =
              await http.MultipartFile.fromPath('files', element!.path);
          request.files.add(multipartFile);
        });
      }

      // Utils.customPrint('NAME ${addVesselRequestModel.name!}');
      // Utils.customPrint('Model ${addVesselRequestModel.model!}');
      // Utils.customPrint('Builder Name ${addVesselRequestModel.builderName!}');
      // Utils.customPrint('regNumber ${addVesselRequestModel.regNumber!}');
      // Utils.customPrint('mmsi ${addVesselRequestModel.mMSI!}');
      // Utils.customPrint('Engine Type ${addVesselRequestModel.engineType!}');
      // Utils.customPrint('Fuel Capacity ${addVesselRequestModel.fuelCapacity!}');
      // Utils.customPrint('weight ${addVesselRequestModel.weight!}');
      // Utils.customPrint('freeBoard ${addVesselRequestModel.freeBoard!}');
      // Utils.customPrint(
      //     'length Overall ${addVesselRequestModel.lengthOverall!}');
      // Utils.customPrint('beam ${addVesselRequestModel.beam!}');
      // Utils.customPrint('depth ${addVesselRequestModel.draft!}');
      // Utils.customPrint('vesselSize ${addVesselRequestModel.vesselSize!}');
      // Utils.customPrint('capacity ${addVesselRequestModel.capacity!}');
      // Utils.customPrint('built Year ${addVesselRequestModel.builtYear!}');
      // Utils.customPrint('user Id ${userId}');
      // Utils.customPrint('user Id ${userId}');
      // Utils.customPrint('VESSEL STATUS ${addVesselRequestModel.vesselStatus}');

      request.headers.addAll(headers);
      request.fields['id'] = addVesselRequestModel.id!;
      request.fields['name'] = addVesselRequestModel.name!;
      request.fields['model'] = addVesselRequestModel.model!;
      request.fields['builderName'] = addVesselRequestModel.builderName!;
      request.fields['regNumber'] = addVesselRequestModel.regNumber!;
      request.fields['MMSI'] = addVesselRequestModel.mMSI!;
      request.fields['engineType'] = addVesselRequestModel.engineType!;
      request.fields['fuelCapacity'] = addVesselRequestModel.fuelCapacity!.toString();
      request.fields['weight'] = addVesselRequestModel.weight!;
      request.fields['freeBoard'] = addVesselRequestModel.freeBoard!.toString();
      request.fields['lengthOverall'] =
          addVesselRequestModel.lengthOverall!.toString();
      request.fields['beam'] = addVesselRequestModel.beam!.toString();
      request.fields['depth'] = addVesselRequestModel.draft!.toString();
      request.fields['vesselSize'] =
          addVesselRequestModel.vesselSize!.toString();
      request.fields['batteryCapacity'] = addVesselRequestModel.batteryCapacity!.toString();
      request.fields['capacity'] = addVesselRequestModel.capacity!.toString();
      request.fields['builtYear'] = addVesselRequestModel.builtYear!.toString();
      request.fields['userID'] = userId;
      request.fields['vesselStatus'] = addVesselRequestModel.vesselStatus == 0
          ? '2'
          : addVesselRequestModel.vesselStatus!.toString();

      request.fields['batteryCapacity'] =
          addVesselRequestModel.batteryCapacity!;
      request.fields['hullShape'] = addVesselRequestModel.hullType!.toString();
      Utils.customPrint('Add VESSEL RESP : ' + jsonEncode(request.fields));

      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);

      Utils.customPrint('Add VESSEL RESP : ' + responseValue.body);
      CustomLogger().logWithFile(Level.info, "Add VESSEL RESP : ' + ${jsonEncode(responseValue.body)}-> $page");

      var decodedData = json.decode(responseValue.body);
        Utils.customPrint('Upload Trip body  was: ' + decodedData.toString());

      if (responseValue.statusCode == HttpStatus.ok) {
        Utils.customPrint('Upload Trip Response was: ' + responseValue.body);
        CustomLogger().logWithFile(Level.info, "API success of ${Urls.baseUrl}${Urls.createVessel} is: ${responseValue.statusCode}-> $page");

        addVesselModel =
            AddVesselModel.fromJson(json.decode(responseValue.body));

        if(addVesselModel == null){
          CustomLogger().logWithFile(Level.error, "==========Error======= Getting null while json parsing in addVesselModel -> $page");
        }

        return addVesselModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        Utils.customPrint('EXE RESP: $responseValue');
        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page");
        CustomLogger().logWithFile(Level.error, "EXE RESP: $responseValue -> $page");

        if (scaffoldKey != null) {
          if (!calledFromSignOut) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }
        }

        addVesselModel = null;
      } else {
        if (scaffoldKey != null) {
          if (calledFromSignOut) {
            Utils.showSnackBar(context,
                scaffoldKey: scaffoldKey, message: decodedData['message']);
          }
        }
        //
        // Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        // Utils.customPrint('EXE RESP: $responseValue');

        CustomLogger().logWithFile(Level.info, "EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page");
        CustomLogger().logWithFile(Level.info, "EXE RESP: $responseValue -> $page");
        addVesselModel = null;
      }
      addVesselModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> $page");

      addVesselModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Add Vessel:- $exception \n $s');
      CustomLogger().logWithFile(Level.error, "error caught Add Vessel:- $exception \n $s-> $page");
      addVesselModel = null;
    }

    return addVesselModel;
  }
}
