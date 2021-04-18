import 'dart:convert';

import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'HomePage.dart';
import 'package:http/http.dart' as http;

import 'LoginPage.dart';
import 'SignUpPage.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final fbLogin = FacebookLogin();
  final AuthService _authService = AuthService();

  // text field state
  String fullName = '';
  String email = '';
  String password = '';


  Future<String> signInWithGoogle() async {


    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      fullName = user.displayName;
      email = user.email;

      await _authService.registerWithEmailAndPassword(fullName, email, password).then((result) async{
        await HelperFunctions.saveUserLoggedInSharedPreference(true);
        await HelperFunctions.saveUserEmailSharedPreference(email);
        await HelperFunctions.saveUserNameSharedPreference(fullName);

        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          print("Logged in: $value");
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });

      return '$user';
    }

    return null;
  }

  Future signInFB() async {
    final FacebookLoginResult result = await fbLogin.logIn(["email"]);
    final String token = result.accessToken.token;
    final response = await       http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
    final profile = jsonDecode(response.body);

    final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if(user!= null){
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
    }

    fullName = profile['name'];
    email = profile['email'];

    await _authService.registerWithEmailAndPassword(fullName, email, password).then((result) async{
      await HelperFunctions.saveUserLoggedInSharedPreference(true);
      await HelperFunctions.saveUserEmailSharedPreference(email);
      await HelperFunctions.saveUserNameSharedPreference(fullName);

      await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
        print("Logged in: $value");
      });
      await HelperFunctions.getUserEmailSharedPreference().then((value) {
        print("Email: $value");
      });
      await HelperFunctions.getUserNameSharedPreference().then((value) {
        print("Full Name: $value");
      });
    });

    print(profile);

    return profile;
  }

  navigateToLogin()async{

    Navigator.pushReplacementNamed(context, "Login");
  }

  navigateToRegister()async{

    Navigator.pushReplacementNamed(context, "SignUp");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Container(
        child: Column(
          children: <Widget>[

            SizedBox(height: 20.0),

            Container(


              child: Image(image: AssetImage("assets/GroupChat.jpg"),
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height : 10),
            Padding(
              padding: EdgeInsets.only(left: 30,right: 30),
              child: RichText(

                  text: TextSpan(
                      text: 'Welcome to ', style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),

                      children: <TextSpan>[
                        TextSpan(
                            text: 'Group', style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color:Colors.orange)
                        )
                      ]
                  )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "Messenger", style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color:Colors.orange),
              ),
            ),


            SizedBox(height: 10.0),

            Text('Communication made Easy',style: TextStyle(color:Colors.black),),

            SizedBox(height: 15.0),


            Row( mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
                Padding(padding: EdgeInsets.all(10)),
                Expanded(
                  child: RaisedButton(
                      padding: EdgeInsets.only(left:30,right:30),
                      onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginPage();
                            },
                          ),
                        );
                      },
                      child: Text('LOGIN',style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.orange
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                // SizedBox(width:20.0),

                Expanded(child: RaisedButton(
                    padding: EdgeInsets.only(left:30,right:30),

                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUpPage();
                          },
                        ),
                      );
                    },
                    child: Text('REGISTER',style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.orange
                ),),
                Padding(padding: EdgeInsets.all(10)),

              ],
            ),


            SizedBox(height : 20.0),

            SignInButton(
              Buttons.Google,
              text: "Sign in with Google",
              onPressed: () {
                signInWithGoogle().then((result) {
                  if (result != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ),
                    );
                  }
                });
              },
            ),
            Padding(
                padding: EdgeInsets.all(5),
            ),
            Center(
              child: Text('OR',style: TextStyle(color:Colors.black, fontSize: 14,
                fontWeight: FontWeight.bold,),),
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            SignInButton(
              Buttons.FacebookNew,
              text: "Sign in with Facebook",
              onPressed: () {
                // signInFB().whenComplete(() =>{
                // Navigator.of(context).pushReplacement(
                // MaterialPageRoute(
                // builder: (context) {
                // return HomePage();
                // },
                // ),
                // ),
                // });
                signInFB().then((result) {
                  if (result != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ),
                    );
                  }
                  // else{
                  //   Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(
                  //       builder: (context) {
                  //         return Start();
                  //       },
                  //     ),
                  //   );
                  // }
                });
              },
            ),
          ],
        ),
      ),

    );
  }
}
