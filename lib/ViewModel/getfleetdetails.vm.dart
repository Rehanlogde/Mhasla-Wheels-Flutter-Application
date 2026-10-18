import 'package:mhasla_wheels_mobile_application/Model/Fleetcollection.model.dart';
import 'package:mhasla_wheels_mobile_application/Model/fleet.model.dart';
import 'package:mhasla_wheels_mobile_application/Services/fleetinformation.service.dart';
Future<void> getfleetinformation() async{

  try{
    print('Executing this fleet info function');
    FleetinformationService fs = FleetinformationService();
     await fs.getfleetdetails();
    Fleetcollection.size = await fs.returnsizeoflist();
    var listofdata = await fs.returnlistofvehiclesdata();
    print("Recieved : $listofdata");

  Fleetcollection.fleetsdata.clear();
for(int i = 0; i < listofdata.length; i++)
     {
       Fleetinformation fs = Fleetinformation();
       fs.capacity = listofdata[i]['capacity'];
       fs.fare = listofdata[i]["priceperkm"];
       fs.vehiclename = listofdata[i]['vehiclename                      '];
       fs.vehiclesafety = listofdata[i]['vehiclesafety'];
       fs.vehicleid = listofdata[i]['vehicleid'];
       fs.yearpurchased = listofdata[i]['year'];
       Fleetcollection.fleetsdata.add(fs);
     }

print("this is the fleet data:  ${Fleetcollection.fleetsdata}");
  }
  catch(e)
  {
    print("Got an exception $e");
  }

}

Future<void> storeinformationoffleets() async{

}