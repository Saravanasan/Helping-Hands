import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helping_hand/src/AcceptedRequest.dart';
import 'package:helping_hand/src/MyPost.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'package:helping_hand/src/profile.dart';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;

class FoodDonorPage extends StatefulWidget {
  FoodDonorPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FoodDonorPageState createState() => _FoodDonorPageState();
}

class _FoodDonorPageState extends State<FoodDonorPage> {

  TextEditingController valFoodAvail = new TextEditingController();
  TextEditingController valAddress = new TextEditingController();
  TextEditingController valName = new TextEditingController();
  TextEditingController valEmail = new TextEditingController();
  TextEditingController valServName = new TextEditingController();
  TextEditingController valRecepAddress = new TextEditingController();
  TextEditingController valContact = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();
  final databaseReference = Firestore.instance;
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

  void navigate(){
     Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProfilePage()));
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
    void acceptRequest(String id, dynamic data)async{
    pr.show();
    dynamic postData = data['post'];
    dynamic donordata = data;
    int initialPersons = data['post']['foodavail'];
    int persons = data['persons'];
    try{
      DocumentSnapshot donorUser =  await Firestore.instance.collection('userdata').document(uid).get();
      if(donorUser.data['posts'].length == 0){
        Future.delayed(Duration(seconds: 1)).then((value){
        pr.hide().whenComplete((){});});
        Fluttertoast.showToast(msg: 'Post has been deleted, click X to delete the request');
      }
      else{
       data['post']['foodavail'] = donorUser.data['posts'][0]['foodavail'];
      QuerySnapshot postCheck = await Firestore.instance.collection('userdata').where('posts',arrayContains: data['post']).getDocuments();
      print(postCheck.documents.isEmpty);
      if(postCheck.documents.isNotEmpty){
        DocumentSnapshot recepientUser = await Firestore.instance.collection('userdata').document(id).get();
        DocumentSnapshot donorUser =  await Firestore.instance.collection('userdata').document(uid).get();


        data['userid'] = uid;
        await databaseReference.collection("userdata").document(id).updateData({"requests":FieldValue.arrayRemove([data])});
        data['status'] = 'Accepted';

        data['post']['foodavail'] = data['post']['foodavail'] - persons;
        await databaseReference.collection('userdata').document(id).updateData({"acceptedrequests":FieldValue.arrayUnion([data])});
        postData['foodavail'] = donorUser.data['posts'][0]['foodavail'];


        await databaseReference.collection("userdata").document(uid).updateData({"posts":FieldValue.arrayRemove([postData])});
        postData['foodavail'] = donorUser.data['posts'][0]['foodavail'] - persons;


        await databaseReference.collection('userdata').document(uid).updateData({"posts":FieldValue.arrayUnion([postData])});
        donordata['post']['foodavail'] = initialPersons;
        donordata['status'] = 'Pending';
        donordata['userid'] = id;

        await databaseReference.collection("userdata").document(uid).updateData({"requests":FieldValue.arrayRemove([donordata])});
        donordata['status'] = 'Accepted';


        await databaseReference.collection('userdata').document(uid).updateData({"acceptedrequests":FieldValue.arrayUnion([donordata])});
        Future.delayed(Duration(seconds: 2)).then((value){
          pr.hide().whenComplete(() {
            Fluttertoast.showToast(msg: 'Contact '+ recepientUser.data['contact']+' for further details');
          });
        });
      }else{
        Future.delayed(Duration(seconds: 1)).then((value){
      pr.hide().whenComplete((){});});
        Fluttertoast.showToast(msg: 'Post has been deleted, click X to delete the request');
      } 
    }
    }catch(e){
      Future.delayed(Duration(seconds: 1)).then((value){
      pr.hide().whenComplete((){});});
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
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
                cancelRequest(id,data);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void cancelRequest(String id, dynamic data)async{
    dynamic postData = data['post'];
    dynamic donordata = data;
    int initialPersons = data['post']['foodavail'];
    try{
      data['userid'] = uid;
      await databaseReference.collection("userdata").document(id).updateData({"requests":FieldValue.arrayRemove([data])});
      data['status'] = 'Declined';
      data['userid'] = uid;
      await databaseReference.collection('userdata').document(id).updateData({"declinedrequests":FieldValue.arrayUnion([data])});
      postData['foodavail'] = initialPersons;
      donordata['post']['foodavail'] = initialPersons;
      donordata['status'] = 'Pending';
      donordata['userid'] = id;
      print(donordata);
      await databaseReference.collection("userdata").document(uid).updateData({"requests":FieldValue.arrayRemove([donordata])});
    }catch(e){
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void info(String id, int index)async{
    DocumentSnapshot data = await Firestore.instance.collection('userdata').document(uid).get();
    int persons = data.data['requests'][index]['persons'];
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
     pr = new ProgressDialog(context);
    pr.style(
      message: '   Please Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400
      ),
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w600
      )
    );
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
        title: Text('Home'),
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
              itemCount: snapshot.data['requests'].length,
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
                                  child :  Text(snapshot.data['requests'][index]['servname'], style: TextStyle(fontSize: 17),textAlign: TextAlign.left, textDirection: TextDirection.ltr),
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
                                      info(snapshot.data['requests'][index]['userid'], index);
                                    },
                                  ),
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
                                  child :  IconButton(
                                    alignment: Alignment.center,
                                    icon: Icon(Icons.check),
                                    onPressed: (){
                                      acceptRequest(snapshot.data['requests'][index]['userid'],snapshot.data['requests'][index] );
                                    },
                                  ),
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
                                  child :  IconButton(
                                    alignment: Alignment.center,
                                    icon: Icon(Icons.cancel,),
                                    onPressed: (){
                                      _showDialog(snapshot.data['requests'][index]['userid'],snapshot.data['requests'][index] );
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
                  title: Text(
                    'Home',
                    style: TextStyle(
                      color:  _homeBool ? Colors.blue : Colors.black
                    ),
                  ),
                  onTap: () {
                    _homeBool = true;
                    Navigator.pop(context);
                  },
                ),
                Container(
                  child: ListTile(
                  title: Text(
                    'Accepted Requests',
                    style: TextStyle(
                      color:  _accReqBool ? Colors.black : Colors.blue
                    ),
                  ),
                  onTap: () {
                    _accReqBool = false;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AcceptedRequestPage()));
                  },
                ),
                ),
                Container(
                  child:  ListTile(
                  title: Text('My Posts',
                    style: TextStyle(
                      color:  _myPostBool ? Colors.black : Colors.blue
                    ),),
                  onTap: () {
                    _myPostBool = false;
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyPostPage()));
                  },
                ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

}