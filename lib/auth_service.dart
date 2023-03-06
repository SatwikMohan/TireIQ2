
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LogIn.dart';
import 'home.dart';
class AuthService{

  FirebaseAuth auth=FirebaseAuth.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void RegisterWithEmailAndPassword(String email,String password,String vehicleRegNo, BuildContext context) async{
      SharedPreferences prefs=await _prefs;
      try{
        await auth.createUserWithEmailAndPassword(email: email, password: password);
        prefs.setString('UserEmail', email);
        prefs.setString('UserVehicleRegNo', vehicleRegNo);
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo).doc("TirePairStatus")
            .set({
              "frontLeft":"Not Paired",
              "frontRight":"Not Paired",
              "rearLeft":"Not Paired",
              "rearRight":"Not Paired"
          });
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo).doc("TireConnectionStatus")
            .set({
          "frontLeft":"Not Connected",
          "frontRight":"Not Connected",
          "rearLeft":"Not Connected",
          "rearRight":"Not Connected"
        });
        await FirebaseFirestore.instance.collection("users").doc(email+"Vehicle").set({
              "1":vehicleRegNo
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home(email,vehicleRegNo)),
        );
      }catch(e){
        print("Error=> Register => "+e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong!!')),
        );
      }
  }

  void LogInwithEmailAndPassword(String email,String password, BuildContext context) async{
      SharedPreferences prefs=await _prefs;
      late String vehicleNo;
      await FirebaseFirestore.instance.collection("users").doc(email+"Vehicle").get().then((value){
          dynamic data=value.data();
          print("Vehicle No. => "+data['1']);
          vehicleNo=data['1'];
          prefs.setString('UserVehicleRegNo', vehicleNo);
      });
      try{
        await auth.signInWithEmailAndPassword(email: email, password: password);
        prefs.setString('UserEmail', email);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home(email,vehicleNo)),
        );
      }catch(e){
        print("Error=> LogIn => "+e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong!!')),
        );
      }
  }

}