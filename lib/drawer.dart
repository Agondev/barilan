import 'package:bar_ilan/views/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blocs/bloc.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String urlLogout = "/Logout.aspx";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Provider.of<Bloc>(context).isDarkTheme
                    ? Colors.purple
                    : Colors.amber),
            child: (Provider.of<Bloc>(context).signedIn)
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      Provider.of<Bloc>(context)
                        .dio
                        .get(Provider.of<Bloc>(context).url + urlLogout);
                        Provider.of<Bloc>(context).signedIn = false;
                        setState(() => null);
                    },
                  )
                : FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(Provider.of<Bloc>(context).fullName),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                        ),
                        Icon(Icons.account_box),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await showDialog(
                          context: context,
                          builder: (_c) {
                            return Dialog(
                              child: LoginView(),
                            );
                          });
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("Hebrew"),
              Container(
                width: 100,
                child: Switch(
                  value: Provider.of<Bloc>(context).isEng,
                  onChanged: (val) => Provider.of<Bloc>(context).lang = !Provider.of<Bloc>(context).isEng,
                ),
              ),
              Text("English"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.brightness_high),
              Container(
                width: 100,
                child: Switch(
                  value: Provider.of<Bloc>(context).prefs.getBool("isDark"),
                  onChanged: (val) => Provider.of<Bloc>(context).theme = val,
                ),
              ),
              Icon(Icons.brightness_3),
            ],
          )
        ],
      ),
    );
  }
}
