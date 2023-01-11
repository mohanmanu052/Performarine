import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';

class EditVesselApiProvider with ChangeNotifier {
  AddVesselModel? addVesselModel;

  Future<AddVesselModel> editVesselData(
      BuildContext context,
      AddVesselRequestModel? addVesselRequestModel,
      String userId,
      String vesselId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
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

      kReleaseMode ? null : debugPrint('NAME ${addVesselRequestModel.name!}');
      kReleaseMode ? null : debugPrint('Model ${addVesselRequestModel.model!}');
      kReleaseMode
          ? null
          : debugPrint('Builder Name ${addVesselRequestModel.builderName!}');
      kReleaseMode
          ? null
          : debugPrint('regNumber ${addVesselRequestModel.regNumber!}');
      kReleaseMode ? null : debugPrint('mmsi ${addVesselRequestModel.MMSI!}');
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
              'length Overall ${addVesselRequestModel.lenghtOverAll!}');
      kReleaseMode ? null : debugPrint('beam ${addVesselRequestModel.beam!}');
      kReleaseMode ? null : debugPrint('depth ${addVesselRequestModel.depth!}');
      kReleaseMode
          ? null
          : debugPrint('vesselSize ${addVesselRequestModel.size!}');
      kReleaseMode
          ? null
          : debugPrint('capacity ${addVesselRequestModel.capacity!}');
      kReleaseMode
          ? null
          : debugPrint('built Year ${addVesselRequestModel.builtYear!}');
      kReleaseMode ? null : debugPrint('user Id ${userId}');
      kReleaseMode
          ? null
          : debugPrint(
              'Image Urls ${addVesselRequestModel.imageUrls!.isEmpty}');
      kReleaseMode
          ? null
          : debugPrint('user Id ${addVesselRequestModel.batteryCapacity}');

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
      request.fields['imageURL'] = addVesselRequestModel.imageUrls ?? ' ';
      request.fields['vesselID'] = vesselId;
      request.fields['batteryCapacity'] =
          addVesselRequestModel.batteryCapacity!;

      http.StreamedResponse response = await request.send();

      http.Response responseValue = await http.Response.fromStream(response);

      kReleaseMode
          ? null
          : debugPrint('Add VESSEL RESP : ' + jsonEncode(responseValue.body));

      var decodedData = json.decode(responseValue.body);
// here
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
      kReleaseMode ? null : debugPrint('error caught login:- $exception \n $s');
      addVesselModel = null;
    }

    return addVesselModel!;
  }
}
