import 'package:cone_flutter_login/router.dart';
import 'package:cone_flutter_login/widgets/login.dart';
import 'widgets/recover_password/recover_password.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // routes: {
      //   Routes.LOGIN: (context) => LoginPage(
      //     onRegister: (account) async{}, 
      //     onLogin: (account) async{print("登录成功");}, 
      //     onRecoverPassword: (account) async{return '';}
      //   ),
      //   Routes.REGISTER: (BuildContext context) => RegisterPage(
      //     userValidator: userValidator, 
      //     passwordValidator: passwordValidator)
      // },
      showSemanticsDebugger: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // initialRoute: Routes.LOGIN,
      home: LoginPage(
        onRegister: (account) async{}, 
        onLogin: (account) async{print("登录成功");}, 
        onRecoverPassword: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecoverPasswordPage(
              validator: (username) async => '',
            )));
        }),
    );
  }
}
