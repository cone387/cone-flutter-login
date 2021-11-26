

class Account{
  late String username;
  late String password;
  int loginTimes = 1;

  Account(this.username, this.password);

  toJson(){
    return {'username': username, 'password': password};
  }

  Account.fromJson(json){
    username = json['username'];
    password = json['password'];
  }

}
