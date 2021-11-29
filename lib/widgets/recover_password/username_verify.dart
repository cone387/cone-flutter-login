


import 'package:cone_flutter_login/widgets/recover_password/verify_code.dart';
import 'package:flutter/material.dart';

class UsernameVerifyWidget extends StatefulWidget {
  final Future<String?> Function(String username) validator;
  const UsernameVerifyWidget({ Key? key, required this.validator}) : super(key: key);

  @override
  _UsernameVerifyWidgetState createState() => _UsernameVerifyWidgetState();
}

class _UsernameVerifyWidgetState extends State<UsernameVerifyWidget> {

  String errText = '';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffix: InkWell(onTap: (){
                widget.validator.call(_controller.text).then((value){
                  if(value != null){
                    
                  }else{
                    Navigator.of(context).push(MaterialPageRoute(builder: (contenxt){
                      return const VerifyCodeWidget();
                    }));
                  }

                });
              }, child: const Text('验证'))
            ),
          ),
        ),
      ),
    );
  }
}