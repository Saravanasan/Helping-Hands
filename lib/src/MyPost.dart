import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helping_hand/src/AcceptedRequest.dart';
import 'package:helping_hand/src/foodDonor.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'package:helping_hand/src/profile.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class MyPostPage extends StatefulWidget {
  MyPostPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {

  TextEditingController valFoodAvail = new TextEditingController();
  TextEditingController valAddress = new TextEditingController();
  final storage = new FlutterSecureStorage();
  final databaseReference = Firestore.instance;
  bool _homeBool = true, _accReqBool = true, _myPostBool = true;
  String uid;

    var uuid = Uuid();

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

  void createPost(String foodAvail)async{
    DocumentSnapshot user = await Firestore.instance.collection('userdata').document(uid).get();
    if(user.data['posts'].length >= 1){
      Fluttertoast.showToast(msg: 'You cannot create more than 1 post');
    }
    else if(user.data['contact'] != "" && user.data['contact'] != null &&
      user.data['name'] != "" && user.data['contact'] != null &&
      user.data['servname'] != "" && user.data['contact'] != null
     ){
      await databaseReference.collection('userdata').document(uid).updateData({'posts':FieldValue.arrayUnion([{'_id': uuid.v1(),'foodavail':int.parse(foodAvail), 'time':DateTime.now().toString()}])});
    }
    else{
      Fluttertoast.showToast(msg: 'Fill Profile Section');
    }
  }

  void _showDialog(String name,dynamic data) {
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
                deletePost(name,data);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updatePost(String _id, String foodAvail, dynamic data)async{
    try{
      await databaseReference.collection("userdata").document(uid).updateData({"posts":FieldValue.arrayRemove([data])});
      await databaseReference.collection('userdata').document(uid).updateData({'posts':FieldValue.arrayUnion([{'_id': _id,'foodavail': int.parse(foodAvail), 'time':DateTime.now().toString()}])});
    }catch(e){
      Fluttertoast.showToast(msg: e.message);
    }
    Fluttertoast.showToast(msg: 'Updated Successfully');
  }

  void deletePost(String name,dynamic data)async{
    String delError;
  try{
      await databaseReference.collection("userdata").document(uid).updateData({"posts":FieldValue.arrayRemove([data])});
    }
    catch(e){
      delError = e.message;
      Fluttertoast.showToast(msg: e.message);
    }
    if(delError == null){
      Fluttertoast.showToast(msg: 'Successfully deleted');
    }
  }

  void editPost(String _id, dynamic data){
    Alert(
      context: context,
      title: "Edit Post",
      content: Container(

       child:  new StreamBuilder(
          stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
          builder: (context,snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator() );
            } 
            return Column(
              children: <Widget>[
                TextField(
                  controller: valFoodAvail..text = data['foodavail'].toString(),
                  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  decoration: InputDecoration(
                    hintText: 'No. of Persons',
                    labelText: 'Food Available rate'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            );                     
          }
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            if(valFoodAvail.text.isEmpty){
              Fluttertoast.showToast(msg: 'Invalid Details');
            }
            else{
              updatePost(_id,valFoodAvail.text, data);
              valFoodAvail.clear();
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

  void addPost(context) async{
    Alert(
      context: context,
      title: "Add Post",
      content: new StreamBuilder(
        stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
        builder: ( context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator() );
          } 
          return Column(
            children: <Widget>[
              TextField(
                controller: valFoodAvail,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  hintText: 'No. of Persons',
                  labelText: 'Food Available rate'
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          );                     
        }
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            if( valFoodAvail.text.isEmpty){
              Fluttertoast.showToast(msg: 'Invalid Details');
            }
            else{
              createPost(valFoodAvail.text);
              valFoodAvail.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
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
              child: StreamBuilder(
                stream: Firestore.instance.collection('userdata').document(uid).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  }
                  return Column(
                    children:  List.generate(snapshot.data['posts'].length,(generator){ 
                      return Card(
                        borderOnForeground: true,
                        margin: EdgeInsets.only(left: 20, right:20, top: 20, bottom: 20),
                        child : InkWell(
                          splashColor: Colors.blue,
                            onTap: () {},
                          child: Column(
                            children: <Widget>[
                               new ListTile(
                                title:  Text(snapshot.data['servname'].toString(), style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
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
                                        TextSpan(text: snapshot.data['name'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
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
                                        TextSpan(text: snapshot.data['posts'][generator]['foodavail'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
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
                                        TextSpan(text: snapshot.data['contact'].toString(), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: const Text('EDIT'),
                                    onPressed: () {
                                      editPost(snapshot.data['posts'][generator]['_id'].toString(), snapshot.data['posts'][generator]);
                                    },
                                  ),
                                  FlatButton(
                                    child: const Text('DELETE'),
                                    onPressed: () {
                                      _showDialog(snapshot.data['name'].toString(),snapshot.data['posts'][generator]);
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
              )
            )
          ]
        )
      ),
      floatingActionButton :FloatingActionButton(
        onPressed: () {
          addPost(context);
        },
        child: Icon(Icons.add),
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
                    ),
                    ),
                  onTap: () {
                    _homeBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => FoodDonorPage()));
                  },
                ),
                ListTile(
                  title: Text('Accepted Requests',
                   style: TextStyle(
                      color:  _accReqBool ? Colors.black : Colors.blue
                    ),
                    ),
                  onTap: () {
                    _accReqBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AcceptedRequestPage()));
                  },
                ),
                ListTile(
                  title: Text('My Posts',
                   style: TextStyle(
                      color:  _myPostBool ? Colors.blue : Colors.black
                    ),
                    ),
                  onTap: () {
                    _myPostBool= true;
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