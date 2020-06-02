import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:helping_hand/src/foodDonor.dart';
import 'package:helping_hand/src/foodRecipient.dart';

import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../loginPage.dart';

class UserManagement {
  BehaviorSubject currentUser = BehaviorSubject<String>.seeded('nouser');

  Widget handleAuth() {
    return new StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.uid);
          currentUser.add(snapshot.data.uid);        }
        return LoginPage();
      },
    );
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }

  authorizeAdmin(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('userdata')
          .where('_id', isEqualTo: user.uid)
          .getDocuments()
          .then((docs) {
        if (docs.documents[0].exists) {
          print(docs.documents[0].data['role']);
          if (docs.documents[0].data['role'] == 'Food Donor') {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new FoodDonorPage()));
          } else if(docs.documents[0].data['role'] == 'Food Recepient'){
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new FoodRecepientPage()));
          }
          else{
            print('Not Authorized');
          }
        }
      });
    });
  }
}