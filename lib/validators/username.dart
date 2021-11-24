


import './base.dart';


String? emailValidator(String? email){
  String? validation = nullValidator(email);
  if(validation != null){
    RegExp exp = RegExp("^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$");
    if(!exp.hasMatch(email!)){
        return '无效的邮箱';
    }
  }
  return validation;
}


String? phoneValidator(String? phone){
  String? validation = nullValidator(phone);
  if(validation != null){
    RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    if(!exp.hasMatch(phone!)){
        return '无效的手机号';
    }
  }
  return validation;
}



