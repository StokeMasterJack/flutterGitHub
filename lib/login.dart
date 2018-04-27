import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github/ssutil_flutter.dart';

typedef Future<User> LoginService(Credentials login);

class LoginPage extends StatelessWidget {
  final LoginService loginService;
  final Credentials cachedLogin;

  LoginPage({this.loginService, this.cachedLogin});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: new SingleChildScrollView(
            child: new LoginForm(
                cachedLogin: this.cachedLogin,
                loginService: this.loginService,
                onLoginSuccess: (User user) {
                  Navigator.pop(context, user);
                })));
  }
}

class LoginForm extends StatefulWidget {
  final Credentials cachedLogin;
  final LoginService loginService;
  final ValueChanged<User> onLoginSuccess;

  LoginForm({this.cachedLogin, this.loginService, this.onLoginSuccess});

  @override
  State createState() => new _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController username = new TextEditingController();
  final TextEditingController password = new TextEditingController();
  Future<User> fUser;

  @override
  void initState() {
    super.initState();
    if (widget.cachedLogin != null) {
      username.text = widget.cachedLogin.username;
      password.text = widget.cachedLogin.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: fUser,
        builder: (context, AsyncSnapshot<User> snap) {
          return buildFromSnap(context, snap);
        });
  }

  Widget buildFromSnap(BuildContext context, AsyncSnapshot<User> snap) {
    return new Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: new Text("Enter your existing login and password"),
              ),
              new TextFormField(
                autofocus: false,
                decoration: new InputDecoration(labelText: "Username"),
                controller: username,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a username';
                  }
                },
              ),
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Password'),
                controller: password,
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a password';
                  }
                },
              ),
              new Padding(padding: const EdgeInsets.all(16.0)),
              buildButton(context, snap),
              buildMsg(context, snap)
            ],
          ),
        ));
  }

  bool isWaiting(AsyncSnapshot<User> snap) => snap.connectionState == ConnectionState.waiting;

  bool isDone(AsyncSnapshot<User> snap) => snap.connectionState == ConnectionState.done;

  Widget buildButton(BuildContext context, AsyncSnapshot<User> snap) {
    if (isWaiting(snap)) {
      return Defaults.waitBuilder(context);
    } else {
      return new Center(
        child: new RaisedButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _callLoginService();
            }
          },
          child: new Text('Submit'),
        ),
      );
    }
  }

  void _callLoginService() {
    var login = new Credentials(username.text, password.text);
    setState(() {
      this.fUser = widget.loginService(login);
      this.fUser.then((User u){
          if(u != null) {
            u.password = login.password;
            widget.onLoginSuccess(u);
          }
      });
    });


  }

  String computeMsg(AsyncSnapshot<User> snap) {
    if (isDone(snap)) {
      if (snap.data == null) {
        return "Login Failed";
      } else {
        return "Login Success";
      }
    } else {
      return "  ";
    }
  }

  Widget buildMsg(BuildContext context, AsyncSnapshot<User> snap) {
    return new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Center(
            child: new Text(
          computeMsg(snap),
          style: Theme.of(context).textTheme.headline,
        )));
  }
}
