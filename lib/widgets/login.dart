




import 'dart:convert';

import 'package:cone_flutter_login/types/account.dart';
import 'package:cone_flutter_login/types/types.dart';
import 'package:cone_flutter_login/validators/validators.dart' as validators;
import 'recover_password/recover_password.dart';
import 'package:cone_flutter_login/widgets/recover_password/username_verify.dart';
import 'package:cone_flutter_login/widgets/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



enum LoginType{ 
  email, 
  phone
}

// typedef AuthCallback = Future<String?> Function(Account account);
// typedef ProviderAuthCallback = Future<String> Function();
// typedef RecoverCallback = Future<String> Function(String);


class LoginProvider {
  final IconData icon;
  final String label;
  final ProviderAuthCallback callback;

  LoginProvider({required this.icon, required this.callback, this.label = ''});
}



abstract class BaseAccountManager{
  BaseAccountManager();
  
}

// class Account{
//   late String username;
//   late String password;
//   int loginTimes = 1;

//   Account(this.username, this.password);

//   toJson(){
//     return {'username': username, 'password': password};
//   }

//   Account.fromJson(json){
//     username = json['username'];
//     password = json['password'];
//   }

// }


class AccountManager{
  // ignore: non_constant_identifier_names
  final String ACCOUNTS = 'loginAccounts';

  // ignore: prefer_final_fields
  List<Account> items = [];


  void addAccount(Account account){
    items.removeWhere((element) => element.username == account.username);
    items.insert(0, account); saveAccounts();
  }


  Account? get recentAccount{
    if(items.isNotEmpty){
      return items.first;
    }
  }

  setRecentAccountIndex(index){
    var a = items.removeAt(index);
    items.insert(0, a); saveAccounts();
  }

  Account deleteAccountByIndex(index){
    Account a = items.removeAt(index);
    saveAccounts();
    return a;
  }

  List<Account> relevantAccounts({String? username}){
    List<Account> accounts = [];
    if(username != null && username.isNotEmpty){
      for (var element in accounts) {
        if(element.username.contains(username)){
          accounts.add(element);
        }
      }
    }
    return accounts;
  }

  saveAccounts() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(ACCOUNTS, jsonEncode(items));
  }

  Future loadAccounts() async{
    final prefs = await SharedPreferences.getInstance();
    var accountsString = prefs.getString(ACCOUNTS);
    if(accountsString != null){
      List accounts = jsonDecode(accountsString);
      for (var element in accounts) {
        items.add(Account.fromJson(element));
      }
    }
  }

  
}


class AccountListWidget extends StatefulWidget {
  const AccountListWidget({
    Key? key, 
    required this.accountManager,
    this.onCurrentIndexChanged,
    this.margin,

  }) : super(key: key);

  final EdgeInsetsGeometry? margin;
  final AccountManager accountManager;
  final void Function(Account account)? onCurrentIndexChanged;

  @override
  _AccountListWidgetState createState() => _AccountListWidgetState();
}

class _AccountListWidgetState extends State<AccountListWidget> {
  @override
  Widget build(BuildContext context) {
    List<Account> accounts = widget.accountManager.items;
    // RenderBox? renderObject = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    // final position = renderObject!.localToGlobal(Offset.zero);
    // double screenW = MediaQuery.of(context).size.width;
    // double currentW = renderObject.paintBounds.size.width;
    // double currentH = renderObject.paintBounds.size.height;
    // double margin = (screenW - currentW) / 2;
    // double offsetY = position.dy;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ListView.separated(
            itemBuilder: (context, index){
              return ListTile(
                onTap: (){
                  setState(() {
                    widget.accountManager.setRecentAccountIndex(index);
                  });
                  widget.onCurrentIndexChanged?.call(accounts[index]);
                },
                title: Text(accounts[index].username),
                trailing: IconButton(onPressed: (){
                  setState(() {
                    widget.accountManager.deleteAccountByIndex(index);
                  });
                }, icon: const Icon(
                  Icons.highlight_off,
                  color: Colors.black,
                )),
              );
            }, 
            separatorBuilder: (context, index){
              return const Divider(height: 1, color: Colors.grey,);
            }, 
          shrinkWrap: true,
          itemCount: accounts.length,
          padding: const EdgeInsets.all(0),
        ),
        // width: currentW,
        // height: (accountManager.items.length * 2 * itemHeight +
        //     (accountManager.items.length - 1) * dividerHeight),
        margin: widget.margin,
      );
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
    this.accountManager,
    this.logoTag,
    this.loginType = LoginType.email,
    this.titleTag,
    this.loginProviders = const <LoginProvider>[],
    this.hideForgotPasswordButton = false,
    this.hideSignUpButton = false,
    this.loginAfterRegister = true,
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
  final void Function() onRecoverPassword;

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
  final bool loginAfterRegister;

  /// Navigate back to the login screen after recovery of password.
  final bool navigateBackAfterRecovery;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  AccountManager? _accountManager;

  bool obscureText = true;
  bool _expand = false;
  final GlobalKey _globalKey = GlobalKey();
  Color eyeColor = Colors.grey;
  final formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  initState(){
    super.initState();
    accountManager.loadAccounts().then((value){
      Account? recentAccount = accountManager.recentAccount;
      if(recentAccount != null){
        _usernameController.text = recentAccount.username;
        _passwordController.text = recentAccount.password;
      }
      
    });
    
  }

  AccountManager get accountManager{
    if(_accountManager == null && widget.accountManager == null){
      _accountManager = AccountManager();
    }
    return _accountManager!;
  }

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
      key: _globalKey,
      controller: _usernameController,
      maxLength: 30,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: '用户名',
        suffixIcon: InkWell(
          onTap: (){
            setState(() {_expand = !_expand;});
          },
          child: Icon(_expand? Icons.arrow_drop_up: Icons.arrow_drop_down),),
        // suffix: IconButton(onPressed: (){
        //   setState(() {
        //     _expand = !_expand;
        //   });
        // }, icon: Icon(_expand? Icons.arrow_drop_up: Icons.arrow_drop_down))
      ),
      validator: userValidator,
    );
  }

  TextFormField passworddInput(){
    return TextFormField(
      obscureText: obscureText,
      controller: _passwordController,
      validator: widget.passwordValidator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
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
    return Row(
      children: [
        Expanded(
          child: TextButton(
            child: const Text('登录', style: TextStyle(color: Colors.white),),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent,),
              shape: MaterialStateProperty.all(const StadiumBorder(side: BorderSide(color: Colors.blueAccent))),
            ),
            onPressed: (){
              if(formKey.currentState!.validate()){
                Account account = Account(_usernameController.text, _passwordController.text);
                accountManager.addAccount(account);
                widget.onLogin(account);
              }
            }
            
          ),
        ),
      ],
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
            widget.onRecoverPassword();
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return RegisterPage(userValidator: userValidator, 
              passwordValidator: widget.passwordValidator,
              onRegister: (account) async{
                String? value = await widget.onRegister(account);
                if(value == null && widget.loginAfterRegister){
                  setState(() {
                    accountManager.addAccount(account);
                  });
                  Navigator.of(context).pop();
                }
                return value;
              },
              loginAfterRegister: widget.loginAfterRegister);
          }));
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
    Account? recentAccount = accountManager.recentAccount;
    if(recentAccount != null){
      _usernameController.text = recentAccount.username;
      _passwordController.text = recentAccount.password;
    }
    return Scaffold(
      body: Stack(
        children: 
          [Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20),
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
          ),
          Offstage(
            child: _buildListView(),
            offstage: !_expand,
          ),

        ],
      ),
    );
  }

  Widget _buildListView() {
    if(_expand){
      RenderBox? renderObject = _globalKey.currentContext?.findRenderObject() as RenderBox?;
      final position = renderObject!.localToGlobal(Offset.zero);
      double screenW = MediaQuery.of(context).size.width;
      double currentW = renderObject.paintBounds.size.width;
      double currentH = renderObject.paintBounds.size.height;
      double margin = (screenW - currentW) / 2;
      double offsetY = position.dy;
      // double itemHeight = 30.0;
      // double dividerHeight = 2;
      return AccountListWidget(accountManager: accountManager,
        margin: EdgeInsets.fromLTRB(margin, offsetY + currentH, margin, 0),
        onCurrentIndexChanged: (_){setState(() {
          _expand = !_expand;
        });},
      );
    }
    return Container();
  }

}