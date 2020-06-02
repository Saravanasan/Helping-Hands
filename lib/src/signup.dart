import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helping_hand/src/loginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uuid/uuid.dart';

ProgressDialog pr;

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController valName = new TextEditingController();
  TextEditingController valRoll = new TextEditingController();
  TextEditingController valEmail = new TextEditingController();
  TextEditingController valPassword = new TextEditingController();
  TextEditingController valCPassword = new TextEditingController();

  bool _bName = true, _bRole = true, _bEmail = true, _bPassword = true, _bCPassword = true;
  bool _showPassword = false, _showCPassword = false;
  String dropdownValue = 'Select a Role';

    var uuid = Uuid();

  RegExp regName = new RegExp(r"([a-zA-Z]{3,30}\s*)+");
  RegExp regRoll = new RegExp(r"^[0-9]{10}$");
  RegExp regEmail = new RegExp(r"[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+");
  RegExp regPassword = new RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _entryFieldName(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valName,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onChanged: (val){
              if(regName.hasMatch(val)){
                _bName = true;
              } 
              else {
               _bName = false;
             }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              errorText: _bName ? null : "Enter valid Name", 
            )
          )
        ],
      ),
    );
  }

  Widget _entryFieldRole(String title) {
  return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
           // height: 50,
            child:   InputDecorator(
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                errorText: _bRole ? null : "Choose a role", 
                filled: true,
              ),
              child: Container(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>( 
                    value: dropdownValue,
                    iconSize: 26,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      if(dropdownValue == 'Select a Role'){
                        _bRole = false;
                      }
                    },
                    items: <String>['Select a Role', 'Food Donor', 'Food Recepient']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ) 
                ),
              ),
            ),
          ),    
        ],
      ),
    );
  }

  Widget _entryFieldEmail(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valEmail,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onChanged: (val){
              if(regEmail.hasMatch(val)){
                _bEmail = true;
            } else {
                _bEmail = false;
            }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              errorText: _bEmail ? null : "Enter valid Email-id", 
            )
          )
        ],
      ),
    );
  }

  Widget _entryFieldPassword(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valPassword,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            obscureText: !_showPassword,
            onChanged: (val){
              if(regPassword.hasMatch(val)){
                _bPassword = true;
              }
                else {
                _bPassword = false;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: this._showPassword ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() => this._showPassword = !this._showPassword);
                },
              ),
              errorText: _bPassword ? null : "Invalid Password. Example - Password@24", 
            )
          )
        ],
      ),
    );
  }

  Widget _entryFieldCPassword(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valCPassword,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            obscureText: !_showCPassword,
            onChanged: (val){
              if(valPassword.text == valCPassword.text){
                _bCPassword = true;
              }
              else{
                _bCPassword = false;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: this._showCPassword ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() => this._showCPassword = !this._showCPassword);
                },
              ),
              errorText: _bCPassword ? null : "Password does not match", 
            )
          )
        ],
      ),
    );
  }

  void register(String name, String roll, String email, String password, String role, String cPassword) async{
    String errorMessage; 
    FirebaseUser user;
    if(regName.hasMatch(name) && regEmail.hasMatch(email) && regPassword.hasMatch(password) && regPassword.hasMatch(cPassword) &&  dropdownValue != 'Select a Role' && password == cPassword ){
      pr.show();
      try{
        user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      }
      catch(e){ errorMessage = e.message; }
      if(errorMessage != null){
        Future.delayed(Duration(seconds: 1)).then((value){
        pr.hide().whenComplete((){});});
        Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
      }
      else{
        try{
          Firestore.instance.collection("userdata").document(user.uid)
          .setData({
            'name': name,
            'email': email,
            'role': role,
            'posts':[],
            'requests':[],
            'acceptedrequests':[],
            'declinedrequests':[]
          });
        user.sendEmailVerification();
        Future.delayed(Duration(seconds: 2)).then((value){
          pr.hide().whenComplete(() {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
          });
        });
        Fluttertoast.showToast(msg: 'Verification link sent to email successfully', backgroundColor: Colors.black);
      }
      catch(e){
        Future.delayed(Duration(seconds: 1)).then((value){
        pr.hide().whenComplete((){});});
        Fluttertoast.showToast(msg: e, backgroundColor: Colors.black);
      }
    }
  }
    else{
      Fluttertoast.showToast(msg: 'Fill details correctly');
    }
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: (){
        register(valName.text, valRoll.text, valEmail.text, valPassword.text, dropdownValue, valCPassword.text);
        valName.clear();
        dropdownValue = 'Select a Role';
        valEmail.clear();
        valPassword.clear();
        valCPassword.clear();
      },
      child : Container(      
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2
            )
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blue, Colors.black]
          )
        ),
        child: Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Help',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: 'ing',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: ' Ha',
            style: TextStyle(color: Colors.black, fontSize: 30),),
          TextSpan(
            text: 'n',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: 'd',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ]
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldName("Username"),
        _entryFieldEmail("Email id"),
        _entryFieldRole("Role"),
        _entryFieldPassword("Password"),
        _entryFieldCPassword("Confirm Password"),
      ],
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
        title: Text('Helping Hands'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), 
            onPressed: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
            }
          )
      ),
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child:  _title(),
            ),
            Container(
              margin:  new EdgeInsets.only(
                left: 20.0,
                bottom: 0.0,
                right: 20.0,
                top: 40
              ),
              child: _emailPasswordWidget()
            ),
            Container(
              margin: new EdgeInsets.only(left: 20.0,right:20.0, top: 20),
              child: _submitButton()
            ),
            Container(
              margin: new EdgeInsets.only(left: 20.0,right:20.0, top: 20),
              child: _loginAccountLabel(),
            ),
          ],
        ),
      ),  
    );
  }
}
