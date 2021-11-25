

String? nullValidator(String? string){
  if(string == null || string.isEmpty){
    return '字段不能为空';
  }
  return null;
}