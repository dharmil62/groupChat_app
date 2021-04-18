import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email, _password;

  checkAuthentification() async
  {

    _auth.authStateChanges().listen((user) {

      if(user!= null)
      {
        print(user);

        Navigator.pushReplacementNamed(context, "/");
      }

    });



  }
  @override
  void initState()
  {
    super.initState();
    this.checkAuthentification();
  }
  login()async
  {
    if(_formKey.currentState.validate())
    {

      _formKey.currentState.save();

      try{
        UserCredential user = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      }

      catch(e)
      {
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
              TextButton(

                  onPressed: (){
                    Navigator.of(context).pop();
                  },


                  child: Text('OK'))
            ],
          );
        }


    );

  }

  navigateToSignUp()async
  {

    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpPage()));

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
                          onPressed: login,
                          child: Text('LOGIN',style: TextStyle(

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

                GestureDetector(
                  child: Text('Create an Account?'),
                  onTap: navigateToSignUp,
                )
              ],
            ),
          ),
        )

    );
  }
}
