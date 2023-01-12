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

  Future<AddVesselModel> addVesselData(
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

      //debugPrint('VESSEl IMAGE ${addVesselRequestModel!.imageURLs!}');
      debugPrint('VESSEl IMAGE ${addVesselRequestModel!.selectedImages!}');

      if (addVesselRequestModel.selectedImages! == null) {
        request.fields['files'] = '';
      } else {
        addVesselRequestModel.selectedImages!.forEach((element) async {
          int index = addVesselRequestModel.selectedImages!.indexOf(element);
          http.MultipartFile multipartFile =
              await http.MultipartFile.fromPath('files', element!.path);
          request.files.add(multipartFile);
        });
      }

      kReleaseMode ? null : debugPrint('NAME ${addVesselRequestModel.name!}');
      kReleaseMode ? null : debugPrint('Model ${addVesselRequestModel.model!}');
      kReleaseMode
          ? null
          : debugPrint('Builder Name ${addVesselRequestModel.builderName!}');
      kReleaseMode
          ? null
          : debugPrint('regNumber ${addVesselRequestModel.regNumber!}');
      kReleaseMode ? null : debugPrint('mmsi ${addVesselRequestModel.mMSI!}');
      kReleaseMode
          ? null
          : debugPrint('Engine Type ${addVesselRequestModel.engineType!}');
      kReleaseMode
          ? null
          : debugPrint('Fuel Capacity ${addVesselRequestModel.fuelCapacity!}');
      kReleaseMode
          ? null
          : debugPrint('weight ${addVesselRequestModel.weight!}');
      kReleaseMode
          ? null
          : debugPrint('freeBoard ${addVesselRequestModel.freeBoard!}');
      kReleaseMode
          ? null
          : debugPrint(
              'length Overall ${addVesselRequestModel.lengthOverall!}');
      kReleaseMode ? null : debugPrint('beam ${addVesselRequestModel.beam!}');
      kReleaseMode ? null : debugPrint('depth ${addVesselRequestModel.draft!}');
      kReleaseMode
          ? null
          : debugPrint('vesselSize ${addVesselRequestModel.vesselSize!}');
      kReleaseMode
          ? null
          : debugPrint('capacity ${addVesselRequestModel.capacity!}');
      kReleaseMode
          ? null
          : debugPrint('built Year ${addVesselRequestModel.builtYear!}');
      kReleaseMode ? null : debugPrint('user Id ${userId}');
      kReleaseMode ? null : debugPrint('user Id ${userId}');

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
      kReleaseMode
          ? null
          : debugPrint('Add VESSEL RESP : ' + jsonEncode(request.fields));

      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);

      kReleaseMode
          ? null
          : debugPrint('Add VESSEL RESP : ' + jsonEncode(responseValue.body));

      var decodedData = json.decode(responseValue.body);

      if (responseValue.statusCode == HttpStatus.ok) {
        kReleaseMode
            ? null
            : debugPrint('Register Response : ' + responseValue.body);

        addVesselModel =
            AddVesselModel.fromJson(json.decode(responseValue.body));

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return addVesselModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $responseValue');

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

        kReleaseMode
            ? null
            : debugPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        kReleaseMode ? null : debugPrint('EXE RESP: $responseValue');
      }
      addVesselModel = null;
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);
      kReleaseMode ? null : debugPrint('Socket Exception');

      addVesselModel = null;
    } catch (exception, s) {
      kReleaseMode
          ? null
          : debugPrint('error caught Add Vessel:- $exception \n $s');
      addVesselModel = null;
    }

    return addVesselModel!;
  }
}
