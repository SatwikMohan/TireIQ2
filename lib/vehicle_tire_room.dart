
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_blue_elves/flutter_blue_elves.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tireiq_versionii/qr_service.dart';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:flutter_blue/gen/flutterblue.pb.dart' as ProtoBluetoothDevice;

class VehicleTireRoom extends StatefulWidget {

  @override
  State<VehicleTireRoom> createState() => _VehicleTireRoomState();
}

class _VehicleTireRoomState extends State<VehicleTireRoom> {
  String frontLeftStatus="Front Left Status\nClick on wheel to pair";
  String frontRightStatus="Front Right Status\nClick on wheel to pair";
  String rearLeftStatus="Rear Left Status\nClick on wheel to pair";
  String rearRightStatus="Rear Right Status\nClick on wheel to pair";

  String frontLeftConnection="Not Connected";
  String frontRightConnection="Not Connected";
  String rearLeftConnection="Not Connected";
  String rearRightConnection="Not Connected";

  String frontLeftTemp="";
  String frontRightTemp="";
  String rearRightTemp="";
  String rearLeftTemp="";

  String frontLeftPressure="";
  String frontRightPressure="";
  String rearLeftPressure="";
  String rearRightPressure="";

  String ValueUpdateTime="-:-:-";
  String ConnectionUpdateTime="-:-:-";

  String frontLeftUpdateTime="-";
  String frontRightUpdateTime="-";
  String rearLeftUpdateTime="-";
  String rearRightUpdateTime="-";

  int flt=1;//flag
  int frt=1;//flag
  int rlt=1;//flag
  int rrt=1;//flag

  int frontLeftLastTime=0;
  int frontRightLastTime=0;
  int rearLeftLastTime=0;
  int rearRightLastTime=0;

  List<BluetoothDevice> deviceList=<BluetoothDevice>[];

  late String email;
  late String vehicleRegNo;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  void scanDevices(){
    // deviceList.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Scanning devices please wait')),
    );

    flutterBlue.startScan(timeout: Duration(seconds: 20));
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results.toSet().where((element) => element.device.name=="TIRE")) {
        print('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}')),
        // );
        deviceList.add(r.device);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text('Added ${r.device.id} to devices list now size is ${deviceList.length}'),
        // ));
      }

    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stop Scan Called'),
        ));

    print('Stop Scan Called');

    flutterBlue.stopScan();

    //ConnectDevices();

  }

  void loadData() async{

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('loading --'),
        ));

    final prefs=await SharedPreferences.getInstance();
    email=await prefs.getString('UserEmail').toString();
    vehicleRegNo=await prefs.getString('UserVehicleRegNo').toString();

    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();

    await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo).doc("TirePairStatus")
        .get().then((value) async {
      dynamic data=value.data();
      String fls=data['frontLeft'];
      String frs=data['frontRight'];
      String rls=data['rearLeft'];
      String rrs=data['rearRight'];

      if(fls!="Not Paired"){
        setState(() {
          frontLeftStatus=fls;
        });

      }
      if(frs!="Not Paired"){
        setState(() {
          frontRightStatus=frs;
        });


      }
      if(rls!="Not Paired"){
        setState(() {
          rearLeftStatus=rls;
        });


      }
      if(rrs!="Not Paired"){
        setState(() {
          rearRightStatus=rrs;
        });

      }


      BluetoothEnable.enableBluetooth.then((result) {
        if (result == "true") {
          // Bluetooth has been enabled
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Bluetooth has been enabled')),
          );

          Future.delayed(Duration(seconds:1),(){
            scanDevices();
          });

          Future.delayed(Duration(seconds:8),(){
            ConnectDevices();
          });

        }
        else if (result == "false") {
          // Bluetooth has not been enabled
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Bluetooth cannot be enabled')),
          );
        }
      });


    });

  }

  void startFrontLeftService(BluetoothDevice device){
    Timer.periodic(Duration(seconds: 60), (timer) async {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        // do something with service
        var characteristics = service.characteristics;
        print('List of Characteristcs of ${device.id} => '+characteristics.toString());

        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="20d3327e-ddb0-4e1e-ab13-7569a685b4bf")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              frontLeftTemp=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="1a8ce623-1cbc-4641-9f47-b75767a7275a")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              frontLeftPressure=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        DateTime dateTime=DateTime.now();
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
            .doc(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          "frontLeftPressure":frontLeftPressure,
          "frontLeftTemperature":frontLeftTemp,
          "frontRightPressure":frontRightPressure,
          "frontRightTemperature":frontRightTemp,
          "rearLeftPressure":rearLeftPressure,
          "rearLeftTemperature":rearLeftTemp,
          "rearRightPressure":rearRightPressure,
          "rearRightTemperature":rearRightTemp,
          "Time":dateTime.toString()
        });
        setState(() {
          ValueUpdateTime=dateTime.toString();
          frontLeftUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });

      });
    });
  }

  void startFrontRightService(BluetoothDevice device){
    Timer.periodic(Duration(seconds: 60), (timer) async {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        // do something with service
        var characteristics = service.characteristics;
        print('List of Characteristcs of ${device.id} => '+characteristics.toString());
        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="20d3327e-ddb0-4e1e-ab13-7569a685b4bf")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              frontRightTemp=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="1a8ce623-1cbc-4641-9f47-b75767a7275a")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              frontRightPressure=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        DateTime dateTime=DateTime.now();
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
            .doc(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          "frontLeftPressure":frontLeftPressure,
          "frontLeftTemperature":frontLeftTemp,
          "frontRightPressure":frontRightPressure,
          "frontRightTemperature":frontRightTemp,
          "rearLeftPressure":rearLeftPressure,
          "rearLeftTemperature":rearLeftTemp,
          "rearRightPressure":rearRightPressure,
          "rearRightTemperature":rearRightTemp,
          "Time":dateTime.toString()
        });
        setState(() {
          ValueUpdateTime=dateTime.toString();
          frontRightUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });

      });
    });
  }

  void startRearLeftService(BluetoothDevice device){
    Timer.periodic(Duration(seconds: 60), (timer) async {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        // do something with service
        var characteristics = service.characteristics;
        print('List of Characteristcs of ${device.id} => '+characteristics.toString());
        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="20d3327e-ddb0-4e1e-ab13-7569a685b4bf")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              rearLeftTemp=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="1a8ce623-1cbc-4641-9f47-b75767a7275a")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              rearLeftPressure=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        DateTime dateTime=DateTime.now();
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
            .doc(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          "frontLeftPressure":frontLeftPressure,
          "frontLeftTemperature":frontLeftTemp,
          "frontRightPressure":frontRightPressure,
          "frontRightTemperature":frontRightTemp,
          "rearLeftPressure":rearLeftPressure,
          "rearLeftTemperature":rearLeftTemp,
          "rearRightPressure":rearRightPressure,
          "rearRightTemperature":rearRightTemp,
          "Time":dateTime.toString()
        });
        setState(() {
          ValueUpdateTime=dateTime.toString();
          rearLeftUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });

      });
    });
  }

  void startRearRightService(BluetoothDevice device){
    Timer.periodic(Duration(seconds: 60), (timer) async {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        // do something with service
        var characteristics = service.characteristics;
        print('List of Characteristcs of ${device.id} => '+characteristics.toString());
        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="20d3327e-ddb0-4e1e-ab13-7569a685b4bf")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              rearRightTemp=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        for(BluetoothCharacteristic c in characteristics.where((element) => element.uuid.toString()=="1a8ce623-1cbc-4641-9f47-b75767a7275a")) {
          await c.setNotifyValue(true);
          c.value.listen((value) {
            // do something with new value
            setState(() {
              rearRightPressure=value[0].toString();
            });
            print('Notify Value =>=> '+value.toString());
            SnackBar(
              content: Text('Notify Value =>=> '+value.toString()),
            );
          });
        }

        DateTime dateTime=DateTime.now();
        await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
            .doc(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          "frontLeftPressure":frontLeftPressure,
          "frontLeftTemperature":frontLeftTemp,
          "frontRightPressure":frontRightPressure,
          "frontRightTemperature":frontRightTemp,
          "rearLeftPressure":rearLeftPressure,
          "rearLeftTemperature":rearLeftTemp,
          "rearRightPressure":rearRightPressure,
          "rearRightTemperature":rearRightTemp,
          "Time":dateTime.toString()
        });
        setState(() {
          ValueUpdateTime=dateTime.toString();
          rearRightUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });

      });
    });
  }

  void ConnectDevices() async{
    if(frontLeftStatus!='Front Left Status\nClick on wheel to pair'){
      setState(() {
        frontLeftConnection='Connecting..';
      });
      BluetoothDevice device=deviceList[deviceList.indexWhere((element)=>
      element.id.toString()==frontLeftStatus
      )];
      try {
        await device.connect().then((value){
          setState(() {
            frontLeftConnection='Connected';
            startFrontLeftService(device);
          });
        }).timeout(Duration(seconds: 10));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ));
      }
    }
    if(frontRightStatus!='Front Right Status\nClick on wheel to pair'){
      setState(() {
        frontRightConnection='Connecting..';
      });
      BluetoothDevice device=deviceList[deviceList.indexWhere((element)=>
      element.id.toString()==frontRightStatus
      )];
      try {
        await device.connect().then((value){
          setState(() {
            frontRightConnection='Connected';
            startFrontRightService(device);
          });
        }).timeout(Duration(seconds: 10));
      }  catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ));
      }
    }
    if(rearLeftStatus!='Rear Left Status\nClick on wheel to pair'){
      setState(() {
        rearLeftConnection='Connecting..';
      });
      BluetoothDevice device=deviceList[deviceList.indexWhere((element)=>
      element.id.toString()==rearLeftStatus
      )];
      try {
        await device.connect().then((value){
          setState(() {
            rearLeftConnection='Connected';
            startRearLeftService(device);
          });
        }).timeout(Duration(seconds: 10));
      }  catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ));
      }
    }
    if(rearRightStatus!='Rear Right Status\nClick on wheel to pair'){
      setState(() {
        rearRightConnection='Connecting..';
      });
      BluetoothDevice device=deviceList[deviceList.indexWhere((element)=>
      element.id.toString()==rearRightStatus
      )];
      try {
        await device.connect().then((value){
          setState(() {
            rearRightConnection='Connected';
            startRearRightService(device);
          });
        }).timeout(Duration(seconds: 10));
      }  catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ));
      }
    }

    Timer.periodic(Duration(seconds: 120), (timer) async{

      print('CONNECTION PERIODIC CHECK RAN AFTER 2 minutes');
      var connectedDeviceList=await flutterBlue.connectedDevices;
      for(BluetoothDevice device in connectedDeviceList){
        if(device.id.toString()==frontLeftStatus){
          setState(() {
            frontLeftConnection="Connected";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "frontLeft":"Connected",
            "Time":DateTime.now().toString()
          });
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
          });
          break;
        }else{
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
            frontLeftPressure="";
            frontLeftTemp="";
            frontLeftConnection="Re-Connecting..";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "frontLeft":"Not Connected",
            "Time":DateTime.now().toString()
          });
        }
      }
      for(BluetoothDevice device in connectedDeviceList){
        if(device.id.toString()==frontRightStatus){
          setState(() {
            frontRightConnection="Connected";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "frontRight":"Connected",
            "Time":DateTime.now().toString()
          });
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
          });
          break;
        }else{
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
            frontRightPressure="";
            frontRightTemp="";
            frontRightConnection="Re-Connecting..";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "frontRight":"Not Connected",
            "Time":DateTime.now().toString()
          });
        }
      }
      for(BluetoothDevice device in connectedDeviceList){
        if(device.id.toString()==rearLeftStatus){
          setState(() {
            rearLeftConnection="Connected";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "rearLeft":"Connected",
            "Time":DateTime.now().toString()
          });
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
          });
          break;
        }else{
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
            rearLeftPressure="";
            rearLeftTemp="";
            rearLeftConnection="Re-Connecting..";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "rearLeft":"Not Connected",
            "Time":DateTime.now().toString()
          });
        }
      }
      for(BluetoothDevice device in connectedDeviceList){
        if(device.id.toString()==frontLeftStatus){
          setState(() {
            rearRightConnection="Connected";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "rearRight":"Connected",
            "Time":DateTime.now().toString()
          });
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
          });
          break;
        }else{
          setState(() {
            ConnectionUpdateTime=DateTime.now().toString();
            rearRightPressure="";
            rearRightTemp="";
            rearRightConnection="Re-Connecting..";
          });
          await FirebaseFirestore.instance.collection("users").doc(email).collection(vehicleRegNo)
              .doc("TireConnectionStatus")
              .update({
            "rearRight":"Not Connected",
            "Time":DateTime.now().toString()
          });
        }
      }

    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if(frontLeftUpdateTime!="-"){
        setState(() {
          frontLeftUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });
      }
      if(frontRightUpdateTime!="-"){
        setState(() {
          frontRightUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });
      }
      if(rearLeftUpdateTime!="-"){
        setState(() {
          rearLeftUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });
      }
      if(rearRightUpdateTime!="-"){
        setState(() {
          rearRightUpdateTime=((DateTime.now().millisecondsSinceEpoch-DateTime.parse(ValueUpdateTime).millisecondsSinceEpoch)/1000).toString()+"s Ago";
        });
      }
    });

  }

  @override
  void initState() {

    super.initState();
    print('INIT STATE CALLED BEFORE LOAD DATA');
    Future.delayed(Duration(seconds:1),(){
      loadData();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.only(top: 50,left: 20,right: 20,bottom: 20),
          child: Container(
            color: Colors.white.withOpacity(0.3),
            child: Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(frontLeftPressure,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontLeftTemp,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontLeftStatus,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontLeftConnection,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontLeftUpdateTime,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(width: 10,),
                      //front left
                      GestureDetector(
                        onTap: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('front left '+email)),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRService("frontLeft",email,vehicleRegNo)),
                          );
                        },
                        child: Image.asset(
                          'assets/images/wheel.png',
                          fit: BoxFit.cover,
                          width: 60,height: 60,
                        ),
                      ),
                      //Image(image: AssetImage('assets/images/wheel.png'),width: 60,height: 60,),
                      SizedBox(width: 70,),
                      //front right
                      GestureDetector(
                        onTap: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('front right '+email)),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRService("frontRight",email,vehicleRegNo)),
                          );
                        },
                        child: Image.asset(
                          'assets/images/wheel.png',
                          fit: BoxFit.cover,
                          width: 60,height: 60,
                        ),
                      ),
                      //Image(image: AssetImage('assets/images/wheel.png'),width: 60,height: 60,),
                      SizedBox(width: 10,),
                      Column(
                        children: [
                          Text(frontRightPressure,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontRightTemp,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontRightStatus,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontRightConnection,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(frontRightUpdateTime,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Center(child: Image(image: NetworkImage('https://cdn.pixabay.com/photo/2013/07/12/11/58/car-145008_960_720.png'),width: 120,height: 190,)),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(rearLeftPressure,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearLeftTemp,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearLeftStatus,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearLeftConnection,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearLeftUpdateTime,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(width: 10,),
                      //rear left
                      GestureDetector(
                        onTap: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('rear left '+email)),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRService("rearLeft",email,vehicleRegNo)),
                          );
                        },
                        child: Image.asset(
                          'assets/images/wheel.png',
                          fit: BoxFit.cover,
                          width: 60,height: 60,
                        ),
                      ),
                      //Image(image: AssetImage('assets/images/wheel.png'),width: 60,height: 60,),
                      SizedBox(width: 70,),
                      //rear right
                      GestureDetector(
                        onTap: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('rear right '+email)),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRService("rearRight",email,vehicleRegNo)),
                          );
                        },
                        child: Image.asset(
                          'assets/images/wheel.png',
                          fit: BoxFit.cover,
                          width: 60,height: 60,
                        ),
                      ),
                      //Image(image: AssetImage('assets/images/wheel.png'),width: 60,height: 60,),
                      SizedBox(width: 10,),
                      Column(
                        children: [
                          Text(rearRightPressure,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearRightTemp,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearRightStatus,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearRightConnection,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Text(rearRightUpdateTime,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Text('Database Value Update Time : ${ValueUpdateTime}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  Text('Database Connection Update Time : ${ConnectionUpdateTime}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
