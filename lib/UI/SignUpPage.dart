import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // text field state
  String fullName = '';
  String email = '';
  String password = '';

  String _name, _email, _password;

  checkAuthentication() async {

    _auth.authStateChanges().listen((user) async
    {
      if(user != null)
      {
        Navigator.pushReplacementNamed(context, "/");
      }
    }
    );
  }

  @override
  void initState(){
    super.initState();
    this.checkAuthentication();
  }

  signUp()async{

    if(_formKey.currentState.validate())
    {
      _formKey.currentState.save();

      try{
        UserCredential user = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        if(user!= null)
        {
          fullName = _name;
          email = _email;
          // UserUpdateInfo updateuser = UserUpdateInfo();
          // updateuser.displayName = _name;
          // user.updateProfile(updateuser);
          await _auth.currentUser.updateProfile(displayName: _name);
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
        }
      }
      catch(e){

        showError(e.message);
        print(e);
      }
    }

  }
  showError(String errormessage){

    showDialog(

        context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(

            title: Text('ERROR'),
            content: Text(errormessage),

            actions: <Widget>[
              FlatButton(

                  onPressed: (){
                    Navigator.of(context).pop();
                  },


                  child: Text('OK'))
            ],
          );
        }


    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: SingleChildScrollView(
          child: Container(

            child: Column(

              children: <Widget>[
                SizedBox(
                  height: 25,
                ),

                Container(
                  child: Image(image: AssetImage("assets/App.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),

                Container(

                  child: Form(

                    key: _formKey,
                    child: Column(

                      children: <Widget>[

                        Container(

                          child: TextFormField(

                              validator: (input)
                              {
                                if(input.isEmpty)

                                  return 'Enter Name';
                              },

                              decoration: InputDecoration(

                                labelText: 'Name',
                                prefixIcon:Icon(Icons.person),
                              ),


                              onSaved: (input) => _name = input


                          ),
                        ),

                        Container(

                          child: TextFormField(

                              validator: (input)
                              {
                                if(input.isEmpty)

                                  return 'Enter Email';
                              },

                              decoration: InputDecoration(

                                  labelText: 'Email',
                                  prefixIcon:Icon(Icons.email)
                              ),

                              onSaved: (input) => _email = input


                          ),
                        ),
                        Container(

                          child: TextFormField(

                              validator: (input)
                              {
                                if(input.length < 6)

                                  return 'Provide Minimum 6 Character';
                              },

                              decoration: InputDecoration(

                                labelText: 'Password',
                                prefixIcon:Icon(Icons.lock),
                              ),
                              obscureText: true,


                              onSaved: (input) => _password = input


                          ),
                        ),
                        SizedBox(height:20),

                        RaisedButton(
                          padding: EdgeInsets.fromLTRB(70,10,70,10),
                          onPressed: signUp,
                          child: Text('SignUp',style: TextStyle(

                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold

                          )),

                          color: Colors.orange,
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(20.0),
                          ),

                        )
                      ],
                    ),

                  ),
                ),
              ],
            ),
          ),
        )

    );
  }
}
