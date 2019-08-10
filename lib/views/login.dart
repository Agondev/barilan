import 'package:bar_ilan/blocs/bloc.dart';
import 'package:bar_ilan/utils/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String result;
  String username;
  String password;
  bool enabled = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Username and password for inbar.biu.ac.il"),
          Divider(),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: "Username",
              prefixIcon: Icon(Icons.account_circle),
              suffixIcon: Icon(
                Icons.ac_unit,
                color: Colors.transparent,
              ),
              errorText: (username != null && username.isEmpty)
                  ? "Can't Be empty"
                  : null,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (t) => setState(() => username = t),
          ),
          Divider(),
          TextField(
            obscureText: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: "Password",
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(
                Icons.ac_unit,
                color: Colors.transparent,
              ),
              errorText: (password != null && password.isEmpty)
                  ? "Can't Be empty"
                  : null,
            ),
            textInputAction: TextInputAction.done,
            onChanged: (t) => setState(() => password = t),
          ),
          Container(margin: EdgeInsets.only(top: 8),),
          RaisedButton(
            child: Text("Submit"),
            color: Colors.green,
            onPressed: enabled
                ? () async {
                    if (username == null ||
                        password == null ||
                        username.isEmpty ||
                        password.isEmpty) {
                      setState(() {
                        username = username ?? "";
                        password = password ?? "";
                      });
                      return;
                    }
                    setState(() {
                      enabled = false;
                    });

                    FocusScope.of(context).unfocus();

                    await ping(context,
                        password: password, username: username);

                    // Check if ping result is successful. If yes, pop.

                    setState(() {
                      enabled = true;
                    });
                  }
                : null,
          ),
          Container(margin: EdgeInsets.only(top: 4),),
          Text(Provider.of<Bloc>(context).error ?? "", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900),),
        ],
      ),
    );
  }
}
