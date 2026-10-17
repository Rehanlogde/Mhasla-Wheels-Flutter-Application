import 'package:mhasla_wheels_mobile_application/Model/Userlogin.model.dart';
import 'package:mhasla_wheels_mobile_application/Services/login.service.dart';

class LoginRequestHandle{

  LoginService ls = new LoginService();
  var loginpass;
  void servicecall(Userlogin usermodel)async{
    try {
 ls.checklogin(usermodel.username, usermodel.password);

    }
    catch(e){
      throw Exception(e);
    }

    }

}