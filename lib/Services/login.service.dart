import 'dart:convert';

import 'package:mhasla_wheels_mobile_application/Model/Loginresponse.model.dart';
import 'package:mhasla_wheels_mobile_application/Model/Userlogin.model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class LoginService{
  String loginstring ="";
  LoginService(){
      loginstring =  dotenv.env['API-BASE-URL']! + "/app/api/login";
  }

  Future<LoginresponseModel?>checklogin(var username, var password) async{
try {
  //loginapicall.

  print("hitting APIT")
;

  final request = await http.post(Uri.parse(loginstring),headers: {
    'content-type' :  'application/json'
  }, body: jsonEncode({
  "email" : username,
  "password" : password
}));


  if(request.statusCode!=200)
    {
      print("status code recieved ${request.statusCode}");

      print("response received in failure");
      final response = jsonDecode(request.body);
      print(response);
      LoginresponseModel.error = response['error'];
      print("Status code recieved : ${request.statusCode}");
      throw Exception(response['error']);

    }
  else{
    print("response received");
    final response = jsonDecode(request.body);
    print(response);

    LoginresponseModel lm = new LoginresponseModel(response['token'], response["customer"]["id"]);
    return lm;
  }

}catch(e)
    {
      throw Exception(e);
    }
  }

}