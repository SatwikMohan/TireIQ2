
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tireiq_versionii/add_vehicle.dart';
import 'package:tireiq_versionii/vehicle_tire_room.dart';

class Home extends StatefulWidget {
  late String email;
  late String vehicleNo;
  Home(String email,String vehicleNo){
    this.email=email;
    this.vehicleNo=vehicleNo;
  }

  @override
  State<Home> createState() => _HomeState(email,vehicleNo);
}

class _HomeState extends State<Home> {
  late String email;
  late String vehicleNo;
  _HomeState(String email,String vehicleNo){
    this.email=email;
    this.vehicleNo=vehicleNo;
  }
  int pageIndex = 0;
  final tabs=[VehicleTireRoom(),AddVehicle()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          vehicleNo,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout,color: Colors.amber,),
              onPressed: (){

              },
              label: Text(
                'Log OUT',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold
                ),
              )
          )
        ],
      ),
      body:tabs[pageIndex],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.brown[400],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  pageIndex = 0;
                });
              },
              icon: pageIndex == 0
                  ? const Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 35,
              )
                  : const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 35,
              ),
            ),
            IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  pageIndex = 1;
                });
              },
              icon: pageIndex == 1 ? const Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 35,
              )
                  : const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 35,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
