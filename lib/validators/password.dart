



import './base.dart';

String passwordValidator(password){
  String validation = nullValidator(password);
  if(validation.isEmpty){
    if(password.trim().length<6 || password.trim().length>18){
        return '密码长度为6到18位';
      }
    }
  return validation;
}