import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _passwordConfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthRepository>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        body: ListView(children: [
          Container(
              padding: EdgeInsets.all(15),
              child: Text(
                'Welcome to Startup Names Generator , please log in below',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              )),
          Container(
              padding: EdgeInsets.all(15),
              child: TextField(
                obscureText: true,
                controller: _email,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), labelText: 'Email'),
              )),
          Container(
              padding: EdgeInsets.all(15),
              child: TextField(
                obscureText: true,
                controller: _password,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), labelText: 'Password'),
              )),
          user.status == Status.Authenticating
              ? Center(child: CircularProgressIndicator()):
          ElevatedButton(
              onPressed: () async {
                if (!await user.signIn(_email.text, _password.text)) {
                  final snackBar = SnackBar(
                      content: Text('There was an error logging into the app'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }else{
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => MyApp()));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Log in'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.red))))),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  showModalBottomSheet(context: context,
                      builder: (BuildContext context) {
                    return Container(

                      height: 200,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Please confirm your password bellow: '),
                          TextFormField(
                            controller: _passwordConfirm,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              // errorText: confirmPasswords(_passwordConfirm.text,_password.text),
                            ),
                            obscureText: true,
                          ),

                          ElevatedButton(
                            onPressed: () async {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.teal),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  side: BorderSide(color: Colors.teal))),),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                      });
                });
              },
              child: Text('New user? Click to sign up'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.teal),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.teal)))))
        ]));
  }

String confirmPasswords(pass1,pass2){
    if(pass1==pass2){
      return 'Password';
    }else{
      return 'Passwords must match';
    }
}
}
