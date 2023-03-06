import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tireiq_versionii/LogIn.dart';
import 'package:tireiq_versionii/SignUp.dart';
import 'package:tireiq_versionii/home.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs=await _prefs;
  String email=prefs.get('UserEmail').toString();
  String vehicleNo=prefs.get('UserVehicleRegNo').toString();
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  runApp(MyApp(email,vehicleNo));
}

class MyApp extends StatelessWidget {
  late String email;
  late String vehicleNo;
  MyApp(String email,String vehicleNo){
    this.email=email;
    this.vehicleNo=vehicleNo;
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        backgroundColor: Colors.white,
        splash: Image(image:AssetImage('assets/images/img_1.png'),width: 300,height: 300,),
        nextScreen: email=="null"?LogIn():Home(email,vehicleNo),
        splashTransition: SplashTransition.rotationTransition,
      ),
    );
  }
}
