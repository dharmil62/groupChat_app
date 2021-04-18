import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'UI/HomePage.dart';
import 'UI/HomePage.dart';
import 'UI/LoginPage.dart';
import 'UI/SignUpPage.dart';
import 'UI/Start.dart';
import 'helper/helper_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _getUserLoggedInStatus();
  }

  _getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      if(value != null) {
        setState(() {
          _isLoggedIn = value;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        primaryColor: Colors.orange,
        fontFamily: 'jost',
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? HomePage() : Start(),

      routes: <String, WidgetBuilder>{
        "Login" : (BuildContext context)=>LoginPage(),
        "SignUp": (BuildContext context)=>SignUpPage(),
        "Start": (BuildContext context)=>Start(),
      },

    );
  }
}