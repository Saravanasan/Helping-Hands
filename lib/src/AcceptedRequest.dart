import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helping_hand/src/MyPost.dart';
import 'package:helping_hand/src/foodDonor.dart';
import 'package:helping_hand/src/profile.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptedRequestPage extends StatefulWidget {
  AcceptedRequestPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AcceptedRequestPageState createState() => _AcceptedRequestPageState();
}

class _AcceptedRequestPageState extends State<AcceptedRequestPage> {

    final storage = new FlutterSecureStorage();
    String uid;
      bool _homeBool = true, _accReqBool = true, _myPostBool = true;

  void initState() {
      super.initState();
      try{
        storage.read(key: 'uid').then((value){
        setState(() {
        uid = value;  
        });
        
      });
      }catch(e){
        print(e);
      }
    }

  void logout() async {
    String errorMessage; 
    try{
      await FirebaseAuth.instance.signOut();  
    }
    catch(e){ errorMessage = e.message; }
    if(errorMessage != null){
      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
    }
    else{
      await storage.deleteAll();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }   
  }

  void info(String id, int index)async{
    DocumentSnapshot data = await Firestore.instance.collection('userdata').document(uid).get();
    int persons = data.data['acceptedrequests'][index]['persons'];
    return showDialog(  
      context: context,  
      builder: (BuildContext context) {
        return AlertDialog(  
        title: Text('Details'),  
        content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection("userdata").document(id).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  }   
                  return Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Name : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: snapshot.data['name'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ), 
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Email-Id : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                           TextSpan(text: snapshot.data['email'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ),
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Service Name : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                           TextSpan(text: snapshot.data['servname'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ),
                    SizedBox(height: 7),
                     Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Requested Number : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: persons.toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ),
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Address : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: snapshot.data['address'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ),
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left:10),
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Contact Number: ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: snapshot.data['contact'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                          ]
                        ),
                      ) 
                    ), 
                  ],
                );
              }
            ), 
            ),
          ],
        )
        ),  
        actions: <Widget>[  
          new FlatButton(  
            child: new Text('Back'),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          )  
        ],  
      );

      }
    );  
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.power_settings_new),
          tooltip: 'Logout',
          onPressed: () {
            logout();
          },
        ),
        ],
        title: Text('Accepted Reuests'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: (uid == null)?CircularProgressIndicator():
      Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height *0.3,
        child: new StreamBuilder(
          stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
          builder: (context,snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator() );
            }
            return ListView.separated(
              separatorBuilder:  (BuildContext context, int index) => Divider(), 
              itemCount: snapshot.data['acceptedrequests'].length,
              itemBuilder: (BuildContext context, int index){
                return Row(
                  children: <Widget>[
                      Expanded(
                        flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child :  Text(snapshot.data['acceptedrequests'][index]['servname'], style: TextStyle(fontSize: 17),textAlign: TextAlign.left, textDirection: TextDirection.ltr),
                                )
                              ],
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  alignment: Alignment.bottomRight,
                                  child :   IconButton(
                                    alignment: Alignment.center,
                                    icon: Icon(Icons.info),
                                    onPressed: (){
                                      info(snapshot.data['acceptedrequests'][index]['userid'], index);
                                    },
                                  ),
                                )
                              ],
                            )
                          ),
                  ]
                );
              } 
            );
          }
        ),
            )
          ]
         )
      ),
       drawer: Drawer(
        child: StreamBuilder(
          stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
          builder: (context,snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator() );
            }
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(snapshot.data['name']), 
                  accountEmail: Text(snapshot.data['email']),
                  currentAccountPicture:  GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProfilePage()));
                    },
                    child: CircleAvatar(
                      backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                      ? Colors.blue
                      : Colors.white,
                      child: Text(
                        '${snapshot.data['name'].toString()[0]}',
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Home',
                   style: TextStyle(
                      color:  _homeBool ? Colors.black : Colors.blue
                    )
                  ),
                  onTap: () {
                    _homeBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => FoodDonorPage()));
                  },
                ),
                ListTile(
                  title: Text('Accepted Requests',
                   style: TextStyle(
                      color:  _accReqBool ? Colors.blue : Colors.black
                    ),
                    ),
                  onTap: () {
                    _accReqBool = true;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('My Posts',
                  style: TextStyle(
                      color:  _myPostBool ? Colors.black : Colors.blue
                    ),
                    ),
                  onTap: () {
                    _myPostBool = false;
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyPostPage()));
                  },
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}