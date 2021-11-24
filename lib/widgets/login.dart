




import 'dart:convert';

import 'package:cone_flutter_login/validators/validators.dart' as validators;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



enum LoginType{ 
  email, 
  phone
}

typedef AuthCallback = Future<String> Function(Account account);
typedef ProviderAuthCallback = Future<String> Function();
typedef RecoverCallback = Future<String> Function(String);


class LoginProvider {
  final IconData icon;
  final String label;
  final ProviderAuthCallback callback;

  LoginProvider({required this.icon, required this.callback, this.label = ''});
}



abstract class BaseAccountManager{
  BaseAccountManager();
  
}

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


class AccountManager{
  // ignore: non_constant_identifier_names
  final String ACCOUNTS = 'loginAccounts';

  final List<Account> _accounts = const [];

  const AccountManager();

  onCreate(){
    loadAccounts();
  }

  onDestory(){
    saveAccounts();
  }

  Account? get recentAccount{
    if(_accounts.isNotEmpty){
      return _accounts.last;
    }
  }

  List<Account> relevantAccounts({String? username}){
    List<Account> accounts = [];
    if(username != null && username.isNotEmpty){
      for (var element in _accounts) {
        if(element.username.contains(username)){
          accounts.add(element);
        }
      }
    }
    return accounts;
  }

  saveAccounts() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(ACCOUNTS, jsonEncode(_accounts));
  }

  loadAccounts() async{
    final prefs = await SharedPreferences.getInstance();
    var accountsString = prefs.getString(ACCOUNTS);
    if(accountsString != null){
      List accounts = jsonDecode(accountsString);
      for (var element in accounts) {
        _accounts.add(Account.fromJson(element));
      }
    }
  }

  
}


class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key, 
    required this.onRegister,
    required this.onLogin,
    required this.onRecoverPassword,
    this.title,
    this.logo,
    // this.messages,
    // this.theme,
    this.userValidator,
    this.passwordValidator = validators.passwordValidator,
    this.onSubmitAnimationCompleted,
    this.accountManager = const AccountManager(),
    this.logoTag,
    this.loginType = LoginType.email,
    this.titleTag,
    this.loginProviders = const <LoginProvider>[],
    this.hideForgotPasswordButton = false,
    this.hideSignUpButton = false,
    this.loginAfterSignUp = true,
    this.navigateBackAfterRecovery = false
  }): super(key: key);


  final AccountManager? accountManager;

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback onRegister;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback onLogin;

  /// [LoginUserType] can be email, name or phone, by default is email. It will change how
  /// the edit text autofill and behave accordingly to your choice
  final LoginType loginType;

  /// list of LoginProvider each have an icon and a callback that will be Called when
  /// the user hit the provider icon button
  /// if not specified nothing will be shown
  final List<LoginProvider> loginProviders;

  /// Called when the user hit the submit button when in recover password mode
  final RecoverCallback onRecoverPassword;

  /// The large text above the login [Card], usually the app or company name
  final String? title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String? logo;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  // final LoginMessages? messages;

  /// FlutterLogin's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  // final LoginTheme? theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise
  final FormFieldValidator<String>? userValidator;

  /// Same as [userValidator] but for password
  final FormFieldValidator<String> passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function? onSubmitAnimationCompleted;

  /// Hero tag for logo image. If not specified, it will simply fade out when
  /// changing route
  final String? logoTag;

  /// Hero tag for title text. Need to specify `LoginTheme.beforeHeroFontSize`
  /// and `LoginTheme.afterHeroFontSize` if you want different font size before
  /// and after hero animation
  final String? titleTag;

  /// Set to true to hide the Forgot Password button
  final bool hideForgotPasswordButton;

  /// Set to true to hide the SignUp button
  final bool hideSignUpButton;

  /// Set to false to return back to sign in page after successful sign up
  final bool loginAfterSignUp;

  /// Navigate back to the login screen after recovery of password.
  final bool navigateBackAfterRecovery;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool obscureText = true;
  Color eyeColor = Colors.grey;
  final formKey = GlobalKey<FormState>();

  String? _username;
  String? _password;

  FormFieldValidator<String> get userValidator{
    if(widget.userValidator == null){
      if(widget.loginType == LoginType.email){
        return validators.emailValidator;
      }
      else if(widget.loginType == LoginType.phone){
        return validators.phoneValidator;
      }
      throw UnsupportedError("unsupport login type ${widget.loginType}");
    }
    return widget.userValidator!;
  }

  TextFormField usernameInput(){
    return TextFormField(
      // onSaved: (String value) => _pwd = value,
      onTap: (){
        
      },
      onChanged: (String? username){

      },
      onSaved: (String? username) => _username = username,
      maxLength: 11,
      decoration: const InputDecoration(
        labelText: '用户名',
      ),
      validator: userValidator,
    );
  }

  TextFormField passworddInput(){
    return TextFormField(
      obscureText: obscureText,
      onSaved: (String? value) => _password = value,
      validator: widget.passwordValidator,
      decoration: InputDecoration(
        labelText: '密码',
        suffixIcon: IconButton(
            icon: Icon(Icons.remove_red_eye, color: eyeColor),
            onPressed:(){
              setState(() {
                obscureText = !obscureText;
                eyeColor = obscureText ? Colors.grey: Colors.blue;
              });
            }
        ),
      ),
    );
  }

  Widget loginButton(){
    return Align(
      child: SizedBox(
        width: 300.0,
        height: 50.0,
        child: TextButton(
          child: const Text('登录', style: TextStyle(color: Colors.white),),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blueAccent,),
            shape: MaterialStateProperty.all(const StadiumBorder(side: BorderSide(color: Colors.blueAccent))),
          ),
          onPressed: (){
            if(formKey.currentState!.validate()){
              formKey.currentState!.save();
              widget.onLogin(Account(_username!, _password!));
            }
          }
          
        ),
      ),
    );
  }

  Widget forgetPasswordButton(){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          child: const Text('忘记密码？'),
          onTap: (){
            // ignore: avoid_print
            print('forget password');
          },
        )
      ),
    );
  }

  Padding registerButton(){
    
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        child: const Align(
          alignment: Alignment.center,
          child: Text('没有账号？点击注册'),
        ),
        onTap: (){
        },
      ),
    );
  }

  Align thirdPartyLoginWidgets(){

    return Align(
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(Icons.android,size: 50,color: Colors.blue),
                onPressed: (){
    

                }
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(Icons.desktop_windows,size: 50,color: Colors.blue,),
                onPressed: (){
                  
                }
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(Icons.directions_bike,size: 50,color: Colors.blue),
                onPressed: (){
    

                }
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                usernameInput(),
                passworddInput(),
                loginButton(),
                forgetPasswordButton(),
                registerButton(),
                thirdPartyLoginWidgets()
              ],
            ),
          ),
        ),
      ),
    );
  }
}