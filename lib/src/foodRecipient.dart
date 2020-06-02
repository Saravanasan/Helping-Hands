import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helping_hand/src/MyRequest.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helping_hand/src/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class FoodRecepientPage extends StatefulWidget {
  FoodRecepientPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FoodRecepientPageState createState() => _FoodRecepientPageState();
}

class _FoodRecepientPageState extends State<FoodRecepientPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();
  final databaseReference = Firestore.instance;
  String uid;
  var uuid = Uuid();

  bool _homeBool = true, _myReqBool = true;

  TextEditingController valPersons = new TextEditingController();

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
      await _auth.signOut();  
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

  requestFood(int person, String id, dynamic post, int generator)async{
    String time = DateTime.now().toString();
    DocumentSnapshot donorUser = await Firestore.instance.collection('userdata').document(id).get();
    DocumentSnapshot recepientUser = await Firestore.instance.collection('userdata').document(uid).get();
    print(recepientUser['servname']!=null);
    if(recepientUser.data['contact'] == "" || recepientUser.data['contact'] == null ||
      recepientUser.data['name'] == "" || recepientUser.data['contact'] == null ||
      recepientUser.data['servname'] == "" || recepientUser.data['contact'] == null
     ){
       Fluttertoast.showToast(msg: 'Fill Profile Section first');
     }
    else if(donorUser.data['posts'][generator]['foodavail'] <= person){
      Fluttertoast.showToast(msg: 'Cannot exceed limit');
    }else{
      try{
        await databaseReference.collection('userdata').document(uid).updateData({'requests':FieldValue.arrayUnion([{'time': time,'userid': id, 'persons':person, 'status': 'Pending', 'post': post, 'servname': recepientUser.data['servname'], 'donorservcname': donorUser.data['servname']}])});
        await databaseReference.collection('userdata').document(id).updateData({'requests':FieldValue.arrayUnion([{'time': time,'userid': uid, 'persons':person, 'status': 'Pending', 'post': post, 'servname': recepientUser.data['servname'], 'donorservcname': donorUser.data['servname']}])});
      Fluttertoast.showToast(msg: 'Request Sent');
      }catch(e){
        Fluttertoast.showToast(msg: e.message);
      }
    }
  }

  void sendRequest(context, String _id, dynamic post, int generator)async{
    Alert(
      context: context,
      title: "Request",
      content: Column(
        children: <Widget>[
          TextField(
            controller: valPersons,
            decoration: InputDecoration(
              labelText: 'No. of Persons',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            if(valPersons.text.isEmpty){
              Fluttertoast.showToast(msg: 'Invalid Subject');
            }
            else{
              requestFood(int.parse(valPersons.text), _id, post, generator);
              valPersons.clear();
              Navigator.pop(context);
            }
          },
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.power_settings_new),
          tooltip: 'Logout',
          onPressed: () {
            logout();
          },
        ),
        ]
      ),
      body: SingleChildScrollView(
        child: (uid == null)?CircularProgressIndicator():
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ 
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('userdata').snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  }
                  return Column(
                    children : snapshot.data.documents.map<Widget>((index) {
                     return Column(
                      children:  List.generate(index['posts'].length,(generator){ 
                      return Card(
                        borderOnForeground: true,
                        margin: EdgeInsets.only(left: 20, right:20, top: 20, bottom: 20),
                        child : InkWell(
                          splashColor: Colors.blue,
                            onTap: () {
                            },
                          child: Column(
                            children: <Widget>[
                               new ListTile(
                                title:  Text(index['servname'].toString(), style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Name : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                        TextSpan(text: index['name'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                              ),
                              SizedBox(height: 7),
                              Container(
                                   width: MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Food Available : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                        TextSpan(text: index['posts'][generator]['foodavail'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                              ),
                              SizedBox(height: 7),
                              Container(
                                   width: MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Contact Number : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                        TextSpan(text: index['contact'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                              ),
                              SizedBox(height: 7),
                               Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Address : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                        TextSpan(text: index['address'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                              ),
                               ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: const Text('Request'),
                                    color: Colors.blue,
                                    onPressed: () {
                                      sendRequest(context,index.documentID, index['posts'][generator], generator);
                                    },
                                  ),
                                ],
                              ),
                            ]
                          ) 
                        )
                      );
                    })  
                        );
                    }
                  ).toList(),
                  );
                }
              )
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
                      color:  _homeBool ? Colors.blue : Colors.black
                    ),
                    ),
                  onTap: () {
                    _homeBool = true;
                    Navigator.pop(context);
                  },
                ),
                  ListTile(
                  title: Text('My Requests',
                   style: TextStyle(
                      color:  _myReqBool ? Colors.black : Colors.blue
                    ),
                  ),
                  onTap: () {
                    _myReqBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyRequestPage()));
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