import 'package:mhasla_wheels_mobile_application/Model/Userdashboard.model.dart';
import 'package:mhasla_wheels_mobile_application/Services/userdashboard.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> getuserdetails() async{

  try{
      print("Calling the service function");
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userid = await prefs.getString('userid');
      print(userid);

await getuserdashboarddetails(userid!);

  }
  catch(e)
  {

  }
}
