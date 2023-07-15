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

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForInfoLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileI!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggI = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForWarningLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileW!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggW = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

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
        loggI.i("API response is ${responseValue.statusCode} on -> $page ${DateTime.now()}");
        loggV.v("API response is ${responseValue.statusCode} on -> $page ${DateTime.now()}");

        addVesselModel =
            AddVesselModel.fromJson(json.decode(responseValue.body));

        if(addVesselModel == null){
          loggE.e("Error while parsing json data on -> $page ${DateTime.now()}");
          loggV.v("Error while parsing json data on -> $page ${DateTime.now()}");
        }
        loggD.d('Register Response: ' + json.decode(responseValue.body) + '-> $page ${DateTime.now()}');
        loggV.v('Register Response: ' + json.decode(responseValue.body) + '-> $page ${DateTime.now()}');

        Utils.showSnackBar(context,
            scaffoldKey: scaffoldKey, message: decodedData['message']);

        return addVesselModel!;
      } else if (responseValue.statusCode == HttpStatus.gatewayTimeout) {
        Utils.customPrint('EXE RESP STATUS CODE: ${responseValue.statusCode}');
        Utils.customPrint('EXE RESP: $responseValue');
        loggD.d('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $responseValue -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $responseValue -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $responseValue -> $page ${DateTime.now()}');

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
        loggD.d('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggD.d('EXE RESP: $responseValue -> $page ${DateTime.now()}');
        loggE.e('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggE.e('EXE RESP: $responseValue -> $page ${DateTime.now()}');

        loggV.v('EXE RESP STATUS CODE: ${responseValue.statusCode} -> $page ${DateTime.now()}');
        loggV.v('EXE RESP: $responseValue -> $page ${DateTime.now()}');
      }
      addVesselModel = null;
    } on SocketException catch (_) {
      await Utils().check(scaffoldKey);
      Utils.customPrint('Socket Exception');
      loggD.d('Socket Exception -> $page ${DateTime.now()}');
      loggE.e('Socket Exception -> $page ${DateTime.now()}');
      loggV.v('Socket Exception -> $page ${DateTime.now()}');

      addVesselModel = null;
    } catch (exception, s) {
      Utils.customPrint('error caught login:- $exception \n $s');
      loggD.d('error caught login:- $exception \n $s -> $page ${DateTime.now()}');
      loggE.e('error caught login:- $exception \n $s -> $page ${DateTime.now()}');
      loggV.v('error caught login:- $exception \n $s -> $page ${DateTime.now()}');
      addVesselModel = null;
    }

    return addVesselModel!;
  }
}
