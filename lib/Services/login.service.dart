import 'dart:convert';

import 'package:mhasla_wheels_mobile_application/Model/Userlogin.model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class LoginService{
  String loginstring ="";

  LoginService(){
      loginstring =  dotenv.env['API-BASE-URL']! + "/app/api/login";
  }

  void checklogin(var username, var password) async{
try {
  //loginapicall.

final request = await http.post(Uri.parse(loginstring), body: jsonEncode({
  "username" : username,
  "password" : password
}));

  if(request.statusCode!=200)
    {
      print("status code recieved ${request.statusCode}");
      throw Exception("Status code recieved : ${request.statusCode}");

    }
  else{
    print("response received");

    final response = jsonDecode(request.body);
    print(response);
  }

}catch(e)
    {
      throw Exception(e);
    }
  }

}