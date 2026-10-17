import 'package:mhasla_wheels_mobile_application/Model/Loginresponse.model.dart';
import 'package:mhasla_wheels_mobile_application/Model/Userlogin.model.dart';
import 'package:mhasla_wheels_mobile_application/Services/login.service.dart';
import 'package:mhasla_wheels_mobile_application/ViewModel/Logindatastore.vm.dart';
import 'package:mhasla_wheels_mobile_application/ViewModel/geruserdetails.vm.dart';

class LoginRequestHandle{

  LoginService ls = new LoginService();
  var loginpass;
  Future<(bool, String?)> servicecall(Userlogin usermodel)async{
    try {
      print("Checking login");
      var lm = await ls.checklogin(usermodel.username, usermodel.password);
      await logindatastore(lm!.token, lm!.id);

   await  getuserdetails();

   return (true, null);
      }
    catch(e){
print("returning something");
      if(LoginresponseModel.error != null)
        {
          print("returning this ${LoginresponseModel.error}");
          return (false, LoginresponseModel.error);
        }
      else {
        print("returning exception catched errro");
        return (false, e.toString());
      }
    }

    }

}