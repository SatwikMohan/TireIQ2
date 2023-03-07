
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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

  List<ScanResult> deviceList=<ScanResult>[];

  late String email;
  late String vehicleRegNo;

  void scanDevices(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Scanning devices please wait')),
    );
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 20));
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results.toSet().toList().where((element) => element.device.name=="TIRE")) {
        print('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}')),
        );
        deviceList.add(r);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${r.device.id} to devices list now size is ${deviceList.length}'),
            ));
      }

    });

    flutterBlue.stopScan();

  }

  void getData() async{

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ran after 20s'),
        ));

    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();

    final prefs=await SharedPreferences.getInstance();
    email=await prefs.getString('UserEmail').toString();
    vehicleRegNo=await prefs.getString('UserVehicleRegNo').toString();
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

        // ScanResult frontleft=deviceList[deviceList.indexWhere((element) =>
        //       element.device.id.toString()==frontLeftStatus
        // )];

        // try{
        //   if(frontleft!=null){
        //     await frontleft!.device.connect(autoConnect: false).then((value){
        //       setState(() {
        //         frontLeftConnection="Connected";
        //       });
        //     });
        //   }
        // }catch(e){
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text(e.toString()),
        //       ));
        // }


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

        ScanResult rearleft=deviceList[deviceList.indexWhere((element) =>
        element.device.id.toString()==rearLeftStatus
        )];

        try{

          await rearleft.device.connect(autoConnect: false).then((value) async{
            setState(() {
              rearLeftConnection="Connected";
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(rearleft.device.state.first.toString()),
              ));

        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ));
        }

      }
      if(rrs!="Not Paired"){
        setState(() {
          rearRightStatus=rrs;
        });


        ScanResult rearright=deviceList[deviceList.indexWhere((element) =>
        element.device.id.toString()==rearRightStatus
        )];


        try{

          await rearright.device.connect(autoConnect: false).then((value) async{
            setState(() {
              rearRightConnection="Connected";
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(rearright.device.state.first.toString()),
              ));

        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ));
        }


      }
    });
    //Speaker - BC:A9:61:4F:47:BB

    // FlutterBlue flutterBlue = FlutterBlue.instance;
    // flutterBlue.startScan(timeout: Duration(seconds: 30));
    // flutterBlue.scanResults.listen((results) async {
    //   // do something with scan results
    //   for (ScanResult r in results) {
    //     print('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //           content: Text('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}')),
    //     );
    //     if(r.device.id=="BC:A9:61:4F:47:BB"){
    //       await r.device.connect();
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text('front left connection successful'),
    //           ));
    //     }else{
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text(frontLeftStatus+' not found'),
    //           ));
    //     }
    //   }
    //
    //   //flutterBlue.stopScan();
    //
    // });

    // FlutterBlueElves.instance.startScan(30000).listen((scanItem) async {
    //   // ///Use the information in the scanned object to filter the devices you want
    //   // ///if want to connect someone,call scanItem.connect,it will return Device object
    //   // Device device = scanItem.connect(connectTimeout: 5000);
    //   // ///you can use this device to listen bluetooth device's state
    //   // device.stateStream.listen((newState){
    //   //   ///newState is DeviceState type,include disconnected,disConnecting, connecting,connected, connectTimeout,initiativeDisConnected,destroyed
    //   // }).onDone(() {
    //   //   ///if scan timeout or you stop scan,will into this
    //   // });
    //
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //             content: Text('Name =>${scanItem.name} MAC ADD=> ${scanItem.id}')),
    //       );
    //
    //       if(scanItem.id==frontLeftStatus){
    //         await scanItem.connect(connectTimeout: 5000);
    //       }else{
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //               content: Text('${frontLeftStatus} not found')),
    //         );
    //       }
    //
    // });


    // try {
    //   BluetoothConnection connection = await BluetoothConnection.toAddress(frontLeftStatus);
    //   print('Connected to the device');
    //
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //                 content: Text('Connected to the device')),
    //           );
    //
    //   // connection.input?.listen((Uint8List data) {
    //   //   print('Data incoming: ${ascii.decode(data)}');
    //   //   connection.output.add(data); // Sending data
    //   //
    //   //   if (ascii.decode(data).contains('!')) {
    //   //     connection.finish(); // Closing connection
    //   //     print('Disconnecting by local host');
    //   //   }
    //   // }).onDone(() {
    //   //   print('Disconnected by remote request');
    //   // });
    // }
    // catch (exception) {
    //   print('Cannot connect, exception occured');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content: Text('Cannot connect, exception occured')),
    //   );
    // }

  }

  @override
  void initState() {

    BluetoothEnable.enableBluetooth.then((result) {
      if (result == "true") {
        // Bluetooth has been enabled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Bluetooth has been enabled')),
        );
        // FlutterBlue flutterBlue = FlutterBlue.instance;
        // flutterBlue.startScan(timeout: Duration(seconds: 30));
        // flutterBlue.scanResults.listen((results) async {
        //   // do something with scan results
        //   for (ScanResult r in results) {
        //     print('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}');
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //             content: Text('${r.device.name} Mac Address : ${r.device.id} found! rssi: ${r.rssi}')),
        //       );
        //       if(r.device.id==frontLeftStatus){
        //         await r.device.connect();
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(
        //               content: Text('front left connection successful'),
        //         ));
        //       }else{
        //         ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //         content: Text(frontLeftStatus+' not found'),
        //         ));
        //       }
        //   }
        //   flutterBlue.stopScan();
        //
        // });

        // final flutterReactiveBle = FlutterReactiveBle();
        // flutterReactiveBle.scanForDevices(withServices: [],).listen((device) {
        //   //code for handling results
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //         content: Text(device.name+" "+device.id)),
        //   );
        //
        // }, onError: () {
        //   //code for handling error
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //         content: Text('Bluetooth Scan Error')),
        //   );
        //
        // });

      }
      else if (result == "false") {
        // Bluetooth has not been enabled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Bluetooth cannot be enabled')),
        );
      }
    });

    // FlutterBlueElves.instance.androidOpenBluetoothService((isOk) {
    //   print(isOk ? "The user agrees to turn on the Bluetooth function" : "The user does not agrees to turn on the Bluetooth function");
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //             content: Text('Bluetooth has been enabled')),
    //       );
    // });

    Timer(Duration(seconds: 2), () {
      scanDevices();
    });

    Timer(Duration(seconds: 23), () {
      getData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.only(top: 100,left: 20,right: 20,bottom: 20),
          child: Container(
            color: Colors.white.withOpacity(0.3),
            child: Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text('Front Left Pressure',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text('Front Left Temperature',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(frontLeftStatus,style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(frontLeftConnection,style: TextStyle(fontSize: 8),),
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
                          Text('Front Right Pressure',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text('Front Right Temperature',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(frontRightStatus,style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(frontRightConnection,style: TextStyle(fontSize: 8),),
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
                          Text('Rear Left Pressure',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text('Rear Left Temperature',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(rearLeftStatus,style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(rearLeftConnection,style: TextStyle(fontSize: 8),),
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
                          Text('Rear Right Pressure',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text('Rear Right Temperature',style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(rearRightStatus,style: TextStyle(fontSize: 8),),
                          SizedBox(height: 10,),
                          Text(rearRightConnection,style: TextStyle(fontSize: 8),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
