import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:performarine/models/login_model.dart';

class JwtUtils{
  static Future<bool> getDecodedData(String unilinkToken)async{
    final storage = new FlutterSecureStorage();
    String? loginData = await storage.read(key: 'loginData');
    LoginModel loginModel;
    //String? loginData = sharedPreferences!.getString('loginData');
    //Utils.customPrint('LOGIN DATA: $loginData');

    if (loginData != null) {
          loginModel = LoginModel.fromJson(json.decode(loginData));
          Map<String, dynamic> loginDecodedData = JwtDecoder.decode(loginModel.token??"");
          Map<String, dynamic> unilinkDecodedData = JwtDecoder.decode(unilinkToken);
if(loginDecodedData['sub']==unilinkDecodedData['sub']){
  return Future.value(true);
}else{
  return Future.value(false);
}

          print('the login decoded data was'+loginDecodedData.toString());
          print('the unilink decoded data was'+unilinkDecodedData.toString());

      // notifyListeners();
    }
return Future.value(false);

  }


  static String getFleetId(String unilink){
    String? fleetId;
          Map<String, dynamic> unilinkDecodedData = JwtDecoder.decode(unilink);
fleetId=unilinkDecodedData['fleetId'];

return fleetId??'';
}

  static String getVesselId(String unilink){
    String? vesselId;
          Map<String, dynamic> unilinkDecodedData = JwtDecoder.decode(unilink);
vesselId=unilinkDecodedData['vessel_id'];

return vesselId??'';
}


  static String getOwnerId(String unilink){
    String? ownerId;
          Map<String, dynamic> unilinkDecodedData = JwtDecoder.decode(unilink);
ownerId=unilinkDecodedData['owner_id'];

return ownerId??'';
}


}