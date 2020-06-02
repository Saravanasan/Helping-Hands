import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helping_hand/src/foodRecipient.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'package:helping_hand/src/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

class MyRequestPage extends StatefulWidget {
  MyRequestPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyRequestPageState createState() => _MyRequestPageState();
}

class _MyRequestPageState extends State<MyRequestPage> {

  final storage = new FlutterSecureStorage();
  final databaseReference = Firestore.instance;
  TextEditingController valPersons = new TextEditingController();
  bool _homeBool = true, _myReqBool = true;

  String uid;

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

  editRequestFood(int person, String id, dynamic post, int generator)async{
    String time = DateTime.now().toString();
    DocumentSnapshot donorUser = await Firestore.instance.collection('userdata').document(id).get();
    if(donorUser.data['requests'][generator]['post']['foodavail'] <= person){
      Fluttertoast.showToast(msg: 'Cannot exceed limit');
    }
    else if(post['status'] != 'Accepted' && post['status'] != 'Declined'){
      try{
        await databaseReference.collection('userdata').document(uid).updateData({'requests':FieldValue.arrayRemove([post])});
        post['userid'] = uid;
        await databaseReference.collection('userdata').document(id).updateData({'requests':FieldValue.arrayRemove([post])});
        post['persons'] = person;
        post['time'] = time;
        post['userid'] = id;
        await databaseReference.collection('userdata').document(uid).updateData({'requests':FieldValue.arrayUnion([post])});
        post['userid'] = uid;
        await databaseReference.collection('userdata').document(id).updateData({'requests':FieldValue.arrayUnion([post])});
      }catch(e){
        Fluttertoast.showToast(msg: e.message);
        }
    }
    else{
      Fluttertoast.showToast(msg: 'Request already '+post['status']);
    }
    
  }

  void editRequest(context, String id, dynamic data, int generator)async{
    Alert(
      context: context,
      title: "Request",
      content: Column(
        children: <Widget>[
          TextField(
            controller: valPersons..text = data['persons'].toString(),
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
              editRequestFood(int.parse(valPersons.text), id, data, generator);
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

    void _showDialog(String id, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Are you sure want to delete"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                deleteRequest(id,data);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteRequest(String id, dynamic data)async{
    print(data);
    try{
      await databaseReference.collection('userdata').document(uid).updateData({'requests':FieldValue.arrayRemove([data])});
      data['userid'] = uid;
      print(data);
      await databaseReference.collection('userdata').document(id).updateData({'requests':FieldValue.arrayRemove([data])});
    }catch(e){
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
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

  bool checkForButton(String status){
    if( status == 'Accepted' || status == 'Declined'){
      return true;
    }
    else
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
        backgroundColor: Colors.blue,
            actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.power_settings_new),
          tooltip: 'Logout',
          onPressed: () {
            logout();
          },
        ),
        ],
      ),
      body: SingleChildScrollView(        
        child: (uid == null)?CircularProgressIndicator():
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: new StreamBuilder(
                stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  }
                  else{
                  var newList = snapshot.data['requests'] + snapshot.data['acceptedrequests'] + snapshot.data['declinedrequests'];
                  return Column(
                    children : List.generate(newList.length,(generator){
                      return Card(       
                        borderOnForeground: true,
                        margin: EdgeInsets.only(left: 20, top: 20, bottom: 20, right:20),
                        child : InkWell(
                          splashColor: Colors.blue,
                          onTap: () {},
                          child: Column(
                            children: <Widget>[
                              new ListTile(
                                title:  Text(newList[generator]['donorservcname'].toString(), style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                margin: EdgeInsets.only(left:10),
                                child: RichText(
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: "No. Of Persons : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                      TextSpan(text: newList[generator]['persons'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
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
                                      TextSpan(text: "Status : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                      TextSpan(text: newList[generator]['status'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                    ]
                                  ),
                                ) 
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: const Text('Edit'),
                                    onPressed: checkForButton(newList[generator]['status']) ?  null: ()=> editRequest(context, snapshot.data['requests'][generator]['userid'], snapshot.data['requests'][generator], generator) ,
                                  ),
                                  FlatButton(
                                    child: const Text('Delete'),
                                    onPressed: checkForButton(newList[generator]['status']) ?  null: ()=> _showDialog(snapshot.data['requests'][generator]['userid'], snapshot.data['requests'][generator]) ,    
                                  ),
                                ],
                              ),
                            ]
                          ) 
                        )
                      );
                    }
                  ).toList(),
                );
                }
              }),
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
                      color: _homeBool ? Colors.black : Colors.blue
                    ),
                  ),
                  onTap: () {
                    _homeBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => FoodRecepientPage()));
                  },
                ),
                ListTile(
                  title: Text('My Requests',
                   style: TextStyle(
                      color:  _myReqBool ? Colors.blue : Colors.black
                    ),
                  ),
                  onTap: () {
                    _myReqBool = true;
                    Navigator.pop(context);
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