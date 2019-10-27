import 'package:bar_ilan/blocs/bloc.dart';
import 'package:bar_ilan/utils/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  var _username = TextEditingController();
  var _password = TextEditingController();
  bool enabled = true;
  final focus = FocusNode();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    focus.dispose();
    super.dispose();
  }

  void submitForm() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      return;
    }

    setState(() {
      enabled = false;
    });

    print("1");

    await ping(context);

    print("2");

    if (Provider.of<Bloc>(context).isSignedIn) {
      Navigator.of(context).pop(true);
      print("3");
    }
    setState(() {
      enabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _username.text = Provider.of<Bloc>(context).username;
    _password.text = Provider.of<Bloc>(context).password;
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Username and password for inbar.biu.ac.il"),
          Divider(),
          TextField(
            controller: _username,
            textAlign: TextAlign.center,
            autocorrect: true,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: "Username",
              prefixIcon: Icon(Icons.account_circle),
              suffixIcon: Icon(
                Icons.ac_unit,
                color: Colors.transparent,
              ),
              errorText: ((_username?.text?.isEmpty) ?? false)
                  ? "Can't Be empty"
                  : null,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (val) => FocusScope.of(context).requestFocus(focus),
          ),
          Divider(),
          TextField(
            controller: _password,
            obscureText: true,
            focusNode: focus,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: "Password",
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(
                Icons.ac_unit,
                color: Colors.transparent,
              ),
              errorText: (_password.text.isEmpty) ? "Can't Be empty" : null,
            ),
            textInputAction: TextInputAction.done,
            onEditingComplete: submitForm,
            onSubmitted: (val) => focus.unfocus(),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
          ),
          RaisedButton(
            child: Text("Submit"),
            color: Colors.green,
            onPressed: enabled ? submitForm : null,
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
          ),
          Text(
            Provider.of<Bloc>(context).error ?? "",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
