import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mhasla_wheels_mobile_application/Model/Userdashboard.model.dart';

Future<void>  getuserdashboarddetails(String userid)async {
  String apiurl = dotenv.env['API-BASE-URL']! +
      "/app/api/getuserdashboarddetails";
  try {
    print("Executing the service file");
    print(apiurl);
    var response = await http.get(Uri.parse(apiurl), headers: {
      "authorization" : userid
    });
    if(response.statusCode!=200)
      {
        throw Exception();
      }
    else {

      var finalresponse = jsonDecode(response.body);
      print(finalresponse);


      Userdashboard.name = finalresponse['username'];
      Userdashboard.useremail = finalresponse['useremail'];
      Userdashboard.completedtrips = int.parse(finalresponse['completedtrips']);
      Userdashboard.upcomingtrips = int.parse( finalresponse['upcomingtrips']);
      print("final upcoming and completed trips : ${Userdashboard.upcomingtrips}");
      
    }
  }
  catch (e) {
 print(e);
    throw Exception(e);
  }
}

