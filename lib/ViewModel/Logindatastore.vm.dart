import 'package:shared_preferences/shared_preferences.dart';

Future<void> logindatastore(token, id)async{
try {
  print(token);
  print(id);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("usertoken", token);
  prefs.setString("userid", id);
}
catch(e){
    throw Exception(e);
}
}
