class LoginresponseModel{
  String token = "";
  String id = "";
  static String? error = null;
  LoginresponseModel(var token, var id){
      this.token = token;
      this.id = id;
  }
}