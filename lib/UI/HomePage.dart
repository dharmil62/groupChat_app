import 'package:chat_app/UI/Start.dart';
import 'package:chat_app/UI/profile_page.dart';
import 'package:chat_app/UI/search_page.dart';
import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/group_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _groups;


  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }


  // widgets
  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _popupDialog(context);
                },
                child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0)
            ),
            SizedBox(height: 20.0),
            Text("You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button above."),
          ],
        )
    );
  }



  Widget groupsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _groups,
      builder: (context, snapshot) {
        if(!snapshot.hasData || !snapshot.data.exists) {
          return noGroupWidget();
        }
        // var doc;
        var doc = snapshot.data["groups"];
        // _groups.map((docs) => {
        //   doc = docs['groups'],
        // });
        if(doc != null) {
          // print(snapshot.data['groups'].length);
          if(doc.docs.length != 0) {
            return ListView.builder(
                itemCount: doc.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int reqIndex = doc.length - index - 1;
                  return GroupTile(userName: snapshot.data["fullName"], groupId: _destructureId(doc[reqIndex]), groupName: _destructureName(doc[reqIndex]));
                }
            );
          }
          else {
            return noGroupWidget();
          }
        }
        else {
          return noGroupWidget();
        }
      },
    );
  }


  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    DatabaseService(uid: _user.uid).getUserGroups().then((snapshots) {
      // print(snapshots);
      setState(() {
        _groups = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }


  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }


  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }


  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create"),
      onPressed:  () async {
        if(_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).createGroup(val, _groupName);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: TextField(
          onChanged: (val) {
            _groupName = val;
          },
          style: TextStyle(
              fontSize: 15.0,
              height: 2.0,
              color: Colors.black
          )
      ),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  // Building the HomePage widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups', style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              icon: Icon(Icons.search, color: Colors.white, size: 25.0),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
              }
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
            SizedBox(height: 15.0),
            Text('$_userName', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 7.0),
            ListTile(
              onTap: () {},
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Groups'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage(userName: _userName, email: _email)));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Start()), (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      ),
    );
  }
}
