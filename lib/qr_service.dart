
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tireiq_versionii/home.dart';
import 'package:tireiq_versionii/vehicle_tire_room.dart';

class QRService extends StatefulWidget {
  late String wheel;
  late String email;
  late String vehicle;
  QRService(String wheel,String email,String vehicle){
    this.wheel=wheel;
    this.email=email;
    this.vehicle=vehicle;
  }

  @override
  State<QRService> createState() => _QRServiceState(wheel,email,vehicle);
}

class _QRServiceState extends State<QRService> {
  late String wheel;
  late String email;
  late String vehicle;
  _QRServiceState(String wheel,String email,String vehicle){
    this.wheel=wheel;
    this.email=email;
    this.vehicle=vehicle;
  }
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }
  void _onQRViewCreated(QRViewController control) async{
    this.controller = control;
    final prefs=await SharedPreferences.getInstance();
    controller.scannedDataStream.listen((scanData) {
      setState(() async{
        result = scanData;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text(result!.code.toString())),
        // );
        if(result!=null){
          await prefs.setString(wheel+"Key", result!.code.toString());
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicle).doc("TirePairStatus")
              .update({
                wheel:result!.code.toString()
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home(email, vehicle)),
                (Route<dynamic> route) => false,
          );
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
