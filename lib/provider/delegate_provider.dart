import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class DelegateProvider with ChangeNotifier{
  Client client = Client();


  Future<Response> acceptDelegateInvitation(Uri url)async{
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
      print('accept delegate invite response status code was ${response.statusCode.toString()}');
      log('accept delegate invite response ${response.body.toString()}');
return response;
    }catch(err){

    }
   return response??Response('', 400);
  }

}