import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FleetinformationService {
    String apicall = "";
    int sizeoflist = 0;
  List<dynamic>? listofvehiclesdata = null;
    FleetinformationService(){
    apicall =   dotenv.env['API-BASE-URL']! + "/app/api/fetch-vehicles";
    print("host : ${apicall}");
    }

    Future<void> getfleetdetails() async {
    print("Calling API THE FLEET API");
    try {
      var response = await http.get(Uri.parse(apicall), headers: {
        'authorization': 'passing authorization'
      });

      if (response.statusCode != 200) {
        throw Exception("Status code : ${response.statusCode}");
      }
      else {
        var finaldata = jsonDecode(response.body);
        print(finaldata);
        this.sizeoflist = finaldata['vehiclesdata'].length;
        print("Stored sizeoflist : $sizeoflist");
        this.listofvehiclesdata =  finaldata['vehiclesdata']!;
        print("lisstofvehicles ${listofvehiclesdata}");
      }
    }
    catch (e) {
      throw Exception(e);
    }
  }

  List<dynamic> returnlistofvehiclesdata (){
      print("Returning list of vehicles : ${listofvehiclesdata}");
      return this.listofvehiclesdata!;
  }
  int returnsizeoflist(){
      return this.listofvehiclesdata!.length;
  }
}