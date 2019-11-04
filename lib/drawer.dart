import 'package:bar_ilan/utils/dio.dart';
import 'package:bar_ilan/views/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blocs/bloc.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
            child: (Provider.of<Bloc>(context).isSignedIn)
                ? FloatingActionButton.extended(
                    label: Text(Provider.of<Bloc>(context).fullName),
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Logout?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text("Cancel"),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                FlatButton(
                                  child: const Text("Logout"),
                                  onPressed: () {
                                    ping(context, page: dioPageLogout);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          }).then((val) => val ? Navigator.pop(context) : null);
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafeArea(
                          child: Scaffold(
                            appBar: AppBar(
                              automaticallyImplyLeading: true,
                            ),
                            body: LoginView(),
                          ),
                        ),
                      ),
                    ),
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
                  onChanged: (val) async {
                    ping(context,
                        event: (val) ? r"ctl00$ctl16" : r"ctl00$ctl17");
                    Provider.of<Bloc>(context).isEng = !val;
                  },
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
          ),
          // (kReleaseMode)
          //     ? Container() :
          ExpansionTile(
            title: Text(Provider.of<Bloc>(context).error ?? "NoError"),
            initiallyExpanded: true,
            children: <Widget>[
              Text(Provider.of<Bloc>(context).username ?? "NoUser"),
              Text(Provider.of<Bloc>(context).password ?? "NoPass"),
              Text(Provider.of<Bloc>(context).isSignedIn
                  ? "Signed in"
                  : "Signed Out"),
              RaisedButton.icon(
                icon: Icon(Icons.cached),
                label: Text("Delete Cache"),
                onPressed: () => Provider.of<Bloc>(context).cache.clearAll(),
              )
            ],
          ),
        ],
      ),
    );
  }
}
