import 'package:cone_flutter_login/types/account.dart';
import 'package:cone_flutter_login/types/types.dart';
import 'package:cone_flutter_login/widgets/login.dart';
import 'package:flutter/material.dart';



class RegisterPage extends StatefulWidget {

  const RegisterPage({
    Key? key,
    required this.userValidator,
    required this.passwordValidator,
    required this.onRegister,
    this.loginAfterRegister = true,
  
  }) : super(key: key);

  final bool loginAfterRegister;

  final AuthCallback onRegister;

  final FormFieldValidator<String> userValidator;

  /// Same as [userValidator] but for password
  final FormFieldValidator<String> passwordValidator;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showPassword = false;
  bool obscureText = true;

  final formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();


  TextFormField usernameInput(){
    return TextFormField(
      controller: _usernameController,
      maxLength: 30,
      decoration: const InputDecoration(
        labelText: '用户名',
      ),
      validator: widget.userValidator,
    );
  }

  TextFormField password1Input(){
    return TextFormField(
      obscureText: obscureText,
      controller: _password1Controller,
      validator: widget.passwordValidator,
      decoration: const InputDecoration(
        labelText: '密码',
      ),
    );
  }

  TextFormField password2Input(){
    return TextFormField(
      obscureText: obscureText,
      validator: (String? value){
        if(value != _password1Controller.text){
          return '两次密码不一致';
        }
      },
      decoration: const InputDecoration(
        labelText: '确认密码',
      )
    );
  }

  Widget registerButton(){
    return Row(
      children: [
        Expanded(
          child: TextButton(
            child: const Text('注册', style: TextStyle(color: Colors.white),),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent,),
              shape: MaterialStateProperty.all(const StadiumBorder(side: BorderSide(color: Colors.blueAccent))),
            ),
            onPressed: (){
              if(formKey.currentState!.validate()){
                Account account = Account(_usernameController.text, _password1Controller.text);
                widget.onRegister(account);
              }
            }
            
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('注册'),),
      body: SafeArea(
        minimum: const EdgeInsets.all(30),
        child: Center(
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                usernameInput(),
                password1Input(),
                Padding(padding: EdgeInsets.all(10)),
                password2Input(),
                Padding(padding: EdgeInsets.all(10)),
                // ignore: deprecated_member_use
                registerButton(),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}