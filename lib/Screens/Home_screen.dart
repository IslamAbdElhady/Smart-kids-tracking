import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/AddBaby.dart';
import 'package:kinder_garten/Screens/Chat/Chat_Screen.dart';
import 'package:kinder_garten/Screens/Map/Map_screen.dart';
import 'package:kinder_garten/Screens/LogIn_Screen.dart';
import 'package:kinder_garten/Widgets/CustomButton.dart';
import 'package:kinder_garten/model/childModel.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageScreen extends StatefulWidget {
  String currentUserId;

  HomePageScreen({this.currentUserId});
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  double latitude=0.0;
  double longitude=0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LocationData  currentLocation;
  var location = new Location();
  List<ChildModel> myBabyList = [];

  @override
  initState(){
    super.initState();
    _init();
  }

  Future<Map<String,double>> getCurrentLocation()async{
    Map<String,double> result={
      "latitude":0.0,
      "longitude":0.0
    };
    try {
      currentLocation = await location.getLocation();
      result = {
        "latitude":currentLocation.latitude,
        "longitude":currentLocation.longitude
      };
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
      });
    }catch (e) {
      currentLocation = null;
    }
    return result;
  }

  void _signOut()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context)=> LogInScreen(title: "KinderGarten",)));
    print("log out");
  }

  _init()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.get("my_childern") != null){
      List temp = prefs.get("my_childern");
      temp.forEach((item){
        setState(() {
          myBabyList.add(
              ChildModel.fromJson(item)
          );
        });
      });
    }
  }

  void _addBaby(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context)=> AddBaby(userId: widget.currentUserId,))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("KinderGarten",style: TextStyle(color: Colors.white,fontSize: 18),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.exit_to_app,color: Colors.white,),
          ),
        ],
      ),

      body: Container(
        height: MediaQuery.of(context).size.height-100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: myBabyList.map((baby){
                    return _childView(baby: baby);
                  }).toList(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 60.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xff55ffff),Color(0xff89cff0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[500],
                        offset: Offset(0.0, 1.5),
                        blurRadius: 5.5,
                      ),
                    ]
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: _addBaby,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add,color: Colors.white,size: 30,),
                            Text("Add Baby",
                              style: TextStyle(fontSize: 20,color: Colors.white),),
                          ],
                        ),
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomButtonWidget(
                title: "chat with admin",
                onPressed: ()async{
                  print(">>>>>>>>>>>>>>>>>: ${widget.currentUserId}");
                  await Future.delayed(Duration(seconds: 3));
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=>
                        //MainScreen(currentUserId: widget.currentUserId,)
                    Chat(
                      //todo peerId is the static admin id
                      peerId: "mk5yYDHihrfxfdbRv8E06qMhZO93",

                      // todo peerAvatar is the static admin avatar
                      peerAvatar: "https://img.icons8.com/bubbles/2x/admin-settings-male.png",
                    )
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _childView({ChildModel baby}){
    return Padding(
      padding:const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.blue)
        ),
        child: ListTile(
          onTap: (){
            Navigator.push(context,MaterialPageRoute(builder:
            (context) => ShowMap(baby: baby,)));
          },
          title: Text(baby.name,style: TextStyle(fontSize: 18),),
          subtitle: Text(baby.kinderName,style: TextStyle(fontSize: 18),),
          leading: Image.asset("assets/images/chidImage.png"),
          trailing: Icon(Icons.track_changes),
        ),
      ),
    );
  }
}
