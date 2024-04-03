import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/models/my_delegate_invite_model.dart';

class MyDelegateInviteProvider with ChangeNotifier{
  Client client = Client();

    Future<MyDelegateInviteModel> getDelegateInvites( BuildContext context,
      String? accessToken, GlobalKey<ScaffoldState> scaffoldKey) async {
MyDelegateInviteModel? myDelegateInviteModel; 
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };
//Uri uri = Uri.parse("https://c150cdf6-9597-4e78-bc98-21578721804d.mock.pstmn.io/getDelegateData");

    Uri uri = Uri.https(Urls.baseUrl, Urls.myDelegateInvites);

    try {
      final response =
          await client.get(uri, headers: headers, );

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('My Delegate Invites : ' + response.body);
      kReleaseMode
          ? null

          : Utils.customPrint('My Delegate Invites Status code : ' + response.statusCode.toString());


      if (response.statusCode == HttpStatus.ok) {
        myDelegateInviteModel = MyDelegateInviteModel.fromJson(json.decode(response.body));
        CustomLogger().logWithFile(Level.info, "My Delegate Invite Response : ' + ${response.body}");

        if(myDelegateInviteModel == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on MyDelegateInviteModel");
        }

        return myDelegateInviteModel;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "EXE RESP STATUS CODE: ${response.statusCode} -> ");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        myDelegateInviteModel = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        

        myDelegateInviteModel = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);

      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> ");

      myDelegateInviteModel = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught myDelegateInviteModel:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught myDelegateInviteModel:- $exception \n $s -> ");


      myDelegateInviteModel = null;
    }
    return myDelegateInviteModel ?? MyDelegateInviteModel();
  }



    Future<dynamic> delegateAcceptReject( BuildContext context,
      String? accessToken, GlobalKey<ScaffoldState> scaffoldKey,bool flag ,String verifyToken) async {
var data; 
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "x_access_token": '$accessToken',
    };
    Uri uri = Uri.https(Urls.baseUrl, Urls.delegateAccessAcceptReject);
var body={
  'verify':verifyToken,
  'flag':flag.toString(),
};

    try {
      final response =
          await client.post(uri, headers: headers, body: jsonEncode(body));

      var decodedData = json.decode(response.body);

      kReleaseMode ? null : Utils.customPrint('My Delegate Invites Accept Reject : ' + response.body);
      kReleaseMode
          ? null

          : Utils.customPrint('My Delegate Invites Accept Reject Status code : ' + response.statusCode.toString());


      if (response.statusCode == HttpStatus.ok) {
                  Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);

        CustomLogger().logWithFile(Level.info, "My Delegate Invites Accept Reject Response : ' + ${response.body}");

        if(data == null){
          CustomLogger().logWithFile(Level.error, "Error while parsing json data on MyDelegateInviteModel");
        }

        return data;
      } else if (response.statusCode == HttpStatus.gatewayTimeout) {
        kReleaseMode
            ? null
            : Utils.customPrint('My Delegate Invites Accept Reject EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        CustomLogger().logWithFile(Level.error, "My Delegate Invites Accept Reject EXE RESP STATUS CODE: ${response.statusCode} -> ");

        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        data = null;
      } else {
        if (scaffoldKey != null) {
          Utils.showSnackBar(context,
              scaffoldKey: scaffoldKey, message: decodedData['message']);
        }

        kReleaseMode
            ? null
            : Utils.customPrint('EXE RESP STATUS CODE: ${response.statusCode}');
        kReleaseMode ? null : Utils.customPrint('EXE RESP: $response');

        

        data = null;
      }
    } on SocketException catch (_) {
      Utils().check(scaffoldKey);

      kReleaseMode ? null : Utils.customPrint('Socket Exception');
      CustomLogger().logWithFile(Level.error, "Socket Exception -> ");

      data = null;
    } catch (exception, s) {
      kReleaseMode ? null : Utils.customPrint('error caught myDelegateInviteModel:- $exception \n $s');

      CustomLogger().logWithFile(Level.error, "error caught myDelegateInviteModel:- $exception \n $s -> ");


      data = null;
    }
    return data;
  }


}