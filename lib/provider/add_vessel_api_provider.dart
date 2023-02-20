import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';

class AddVesselApiProvider with ChangeNotifier {
  AddVesselModel? addVesselModel;

  Future<AddVesselModel?> addVesselData(
      BuildContext context,
      CreateVessel? addVesselRequestModel,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {
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

      //Utils.customPrint('VESSEl IMAGE ${addVesselRequestModel!.imageURLs!}');
      Utils.customPrint(
          'VESSEl IMAGE ${addVesselRequestModel!.selectedImages!}');

      if (addVesselRequestModel.selectedImages == null ||
          addVesselRequestModel.selectedImages!.isEmpty) {
        // request.fields['files'] = '';
      } else {
        addVesselRequestModel.selectedImages!.forEach((element) async {
          int index = addVesselRequestModel.selectedImages!.indexOf(element);
          http.MultipartFile multipartFile =
              await http.MultipartFile.fromPath('files', element!.path);
          request.files.add(multipartFile);
        });
      }

      Utils.customPrint('NAME ${addVesselRequestModel.name!}');
      Utils.customPrint('Model ${addVesselRequestModel.model!}');
      Utils.customPrint('Builder Name ${addVesselRequestModel.builderName!}');
      Utils.customPrint('regNumber ${addVesselRequestModel.regNumber!}');
      Utils.customPrint('mmsi ${addVesselRequestModel.mMSI!}');
      Utils.customPrint('Engine Type ${addVesselRequestModel.engineType!}');
      Utils.customPrint('Fuel Capacity ${addVesselRequestModel.fuelCapacity!}');
      Utils.customPrint('weight ${addVesselRequestModel.weight!}');
      Utils.customPrint('freeBoard ${addVesselRequestModel.freeBoard!}');
      Utils.customPrint(
          'length Overall ${addVesselRequestModel.lengthOverall!}');
      Utils.customPrint('beam ${addVesselRequestModel.beam!}');
      Utils.customPrint('depth ${addVesselRequestModel.draft!}');
      Utils.customPrint('vesselSize ${addVesselRequestModel.vesselSize!}');
      Utils.customPrint('capacity ${addVesselRequestModel.capacity!}');
      Utils.customPrint('built Year ${addVesselRequestModel.builtYear!}');
      Utils.customPrint('user Id ${userId}');
      Utils.customPrint('user Id ${userId}');

      request.headers.addAll(headers);
      request.fields['id'] = addVesselRequestModel.id!;
      request.fields['name'] = addVesselRequestModel.name!;
      request.fields['model'] = addVesselRequestModel.model!;
      request.fields['builderName'] = addVesselRequestModel.builderName!;
      request.fields['regNumber'] = addVesselRequestModel.regNumber!;
      request.fields['MMSI'] = addVesselRequestModel.mMSI!;
      request.fields['engineType'] = addVesselRequestModel.engineType!;
      request.fields['fuelCapacity'] = addVesselRequestModel.fuelCapacity!;
      request.fields['weight'] = addVesselRequestModel.weight!;
      request.fields['freeBoard'] = addVesselRequestModel.freeBoard!.toString();
      request.fields['lengthOverall'] =
          addVesselRequestModel.lengthOverall!.toString();
      request.fields['beam'] = addVesselRequestModel.beam!.toString();
      request.fields['depth'] = addVesselRequestModel.draft!.toString();
      request.fields['vesselSize'] =
          addVesselRequestModel.vesselSize!.toString();
      request.fields['capacity'] = addVesselRequestModel.capacity!.toString();
      request.fields['builtYear'] = addVesselRequestModel.builtYear!.toString();
      request.fields['userID'] = userId;
      request.fields['batteryCapacity'] =
          addVesselRequestModel.batteryCapacity!;
      Utils.customPrint('Add VESSEL RESP : ' + jsonEncode(request.fields));

      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);

      Utils.customPrint('Add VESSEL RESP : ' + responseValue.body);

      Utils.customPrint(
          'Add VESSEL RESP : ' + responseValue.statusCode.toString());

      Utils.customPrint('Add VESSEL RESP : ' + jsonEncode(responseValue.body));

      var decodedData = json.decode(responseValue.body);

      if (responseValue.statusCode == HttpStatus.ok) {
        Utils.customPrint('Register Response : ' + responseValue.body);

        addVesselModel =
            AddVesselModel.fromJson(json.decode(responseValue.body));

        /* Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);*/

        return addVesselModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        Utils.customPrint('EXE RESP: $responseValue');

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
        addVesselModel = null;
      }
      addVesselModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');

      addVesselModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught Add Vessel:- $exception \n $s');
      addVesselModel = null;
    }

    return addVesselModel;
  }
}
