import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:kinder_garten/model/childModel.dart';
import 'package:location/location.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong/latlong.dart' as latLanPackage;


class ShowMap extends StatefulWidget {

  final ChildModel baby;

  ShowMap({this.baby});
  @override
  _ShowMapState createState() => _ShowMapState(baby: this.baby);
}
class _ShowMapState extends State<ShowMap> {

  ChildModel baby;
  _ShowMapState({this.baby});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GoogleMapController _controller;
  static String _mapApiKey = "AIzaSyC_2Bl7U94OAHmQWVuYRhLjaWJdKJqH_-0";
  BitmapDescriptor customHomeIcon;
  BitmapDescriptor customChildIcon;
  BitmapDescriptor customBusIcon;
  Set<Marker> markers;
  String _apiRootDomain = "http://router.project-osrm.org/route/v1/driving";
  Set<Polyline> _routesPolylines = Set();
  LatLng busLocation;
  bool cameraMoved = false;
  List<ChildModel> myBabyList = [];
  Set<Circle> circles = Set();
  double circleDistance = 500;



  createHomeMarker(context) {
    if (customHomeIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/home.png')
          .then((icon) {
        setState(() {
          customHomeIcon = icon;
        });
      });
    }
  }
  createChildMarker(context) {
    if (customChildIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/child.png')
          .then((icon) {
        setState(() {
          customChildIcon = icon;
        });
      });
    }
  }
  createBusMarker(context) {
    if (customBusIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/bus_location.png')
          .then((icon) {
        setState(() {
          customBusIcon = icon;
        });
      });
    }
  }

  getAllChildren()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.get("my_childern") != null){
      List temp = prefs.get("my_childern");
      temp.forEach((item){
        setState(() {
          if(ChildModel.fromJson(item).id!=baby.id){
            myBabyList.add(
                ChildModel.fromJson(item)
            );
          }
        });
      });
    }
  }

  addOldMark()async{

    if(baby.homeLan != null && baby.homeLng !=null){
      Marker m = Marker(
          markerId: MarkerId('markHomeId'),
          icon: customHomeIcon,
          position: LatLng(baby.homeLan,baby.homeLng)
      );
      setState(() {
        markers.add(m);
      });
    }
    if(baby.kinderLan != null && baby.kinderLng !=null){
      Marker m = Marker(
          markerId: MarkerId('markKinderId'),
          icon: customChildIcon,
          position: LatLng(baby.kinderLan,baby.kinderLng)
      );
      setState(() {
        markers.add(m);
      });
    }

    Marker m = Marker(
        markerId: MarkerId('markbusId'),
        icon: customBusIcon,
        position: busLocation
    );
    setState(() {
      markers.add(m);
    });
  }

  calculateDistance(){
    final latLanPackage.Distance distance = latLanPackage.Distance();
    final double dis = distance.as(
        latLanPackage.LengthUnit.Meter,
        latLanPackage.LatLng(baby.kinderLan,baby.kinderLng),
        latLanPackage.LatLng(busLocation.latitude,busLocation.longitude)
    );


    if(dis>circleDistance && isTrueTimeToShow()){
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        textColor: Colors.white,
        msg: "worning your baby out of save areaby ${dis-circleDistance} meter",
        backgroundColor: Colors.red,
        fontSize: 18,
        gravity: ToastGravity.CENTER
      );
    }
  }


  bool isTrueTimeToShow(){
   DateTime timeNow = DateTime.now();
   int dayOff1 = DateTime.saturday;
   int dayOff2 = DateTime.friday;
   int timeOffStart = 8;
   int timeOffEnd = 16;
   List<int> monthOff = [6,7,8,9];


   if(monthOff.toString().contains("${timeNow.month}")){
     return false;
   }
   if((timeNow.hour>= timeOffStart && timeNow.hour<= timeOffEnd)
       && (timeNow.day!= dayOff1 && timeNow.day!= dayOff2)){
     return true;
   }
   return false;
  }

  @override
  void initState() {
    if(baby.kinderLan!=null){
      circles = [Circle(
        fillColor: Colors.blueGrey.withOpacity(0.2),
        strokeColor: Colors.redAccent,
        circleId: CircleId("kinder_circle"),
        strokeWidth: 3,
        center: LatLng(baby.kinderLan,baby.kinderLng),
        radius: circleDistance,
      )].toSet();
    }
    super.initState();
    markers = Set.from([]);
    getAllChildren();
  }

  @override
  Widget build(BuildContext context) {
    createChildMarker(context);
    createHomeMarker(context);
    createBusMarker(context);



    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: Stack(
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance.collection('children').document(baby.babyKey).snapshots(),
            builder: (context,snapshot){
              if(snapshot.data==null) return Container();

              DocumentSnapshot data = snapshot.data;
              if(data["lat"].toString().length>5){
                if(busLocation!=null && baby.kinderLan!=null){
                  calculateDistance();
                }
                try{
                  busLocation = LatLng(double.parse(data["lat"]),
                      double.parse(data["lng"]));
                }catch(e){
                  busLocation = LatLng(data["lat"], data["lng"]);
                }
              }
              Marker m = Marker(
                  markerId: MarkerId('markbusId'),
                  icon: customBusIcon,
                  position: busLocation
              );
              markers.add(m);
              if(!cameraMoved){
                if(_controller!=null)
                _controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: busLocation, zoom: 15
                  ),
                ));
              }

              return Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: GoogleMap(

                  polylines: _routesPolylines,
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    addOldMark();
                  },
                  circles: circles,
                  initialCameraPosition: CameraPosition(
                      target: busLocation, zoom: 5),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  trafficEnabled: false,
                  indoorViewEnabled: true,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.easeInCirc,
        overlayColor: Colors.black,
        overlayOpacity: 0.2,
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
          child: Icon(Icons.pin_drop,color: Colors.cyan,),
          backgroundColor: Colors.white,
          label: 'Mark Kinder',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: ()=> showPlacePicker(isHome: false),

          ),
          SpeedDialChild(
              child: Icon(Icons.home,color: Colors.cyan,),
              backgroundColor: Colors.white,
              label: 'Mark Home',
              labelStyle: TextStyle(fontSize: 18.0),
            onTap: ()=> showPlacePicker(isHome: true),
          ),
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("assets/images/route.png"),
            ),
            backgroundColor: Colors.white,
            label: 'to home',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: ()=>getMapRoute(toHome: true),
          ),
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("assets/images/route.png"),
            ),
            backgroundColor: Colors.white,
            label: 'to kinderGarten',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: ()=>getMapRoute(toHome: false),
          ),
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.navigation,color: Colors.green,),
            ),
            backgroundColor: Colors.white,
            label: 'Track',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: (){
              setState(() {
                cameraMoved = false;
              });
            },
          ),
        ],
      ),
    );
  }

  void showPlacePicker({@required bool isHome}) async {
    LocationResult result = await showLocationPicker(
      context,
        _mapApiKey,
      initialCenter: busLocation,
      requiredGPS: true
    );
    Marker m = Marker(
        markerId: MarkerId(isHome?"markHomeId":'markKinderId'),
        icon: isHome?customHomeIcon:customChildIcon,
        position: result.latLng);

    setState(() {
      markers.add(m);
    });
    baby = isHome? ChildModel(
      babyKey: baby.babyKey,
      name: baby.name,
      kinderName: baby.kinderName,
      id: baby.id,
      otherPlaces: baby.otherPlaces,
      kinderLng: baby.kinderLng,
      kinderLan: baby.kinderLan,
      homeLan: result.latLng.latitude,
      homeLng: result.latLng.longitude,
    ): ChildModel(
      babyKey: baby.babyKey,
      name: baby.name,
      kinderName: baby.kinderName,
      id: baby.id,
      otherPlaces: baby.otherPlaces,
      kinderLng: result.latLng.longitude,
      kinderLan: result.latLng.latitude,
      homeLan: baby.homeLan,
      homeLng: baby.homeLng,
    );
    if(baby.homeLng!=null && baby.kinderLng!=null)
      updateMyBaby();
  }

  updateMyBaby()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    ChildModel currentBaby = !isHome?
//    ChildModel(
//      kinderName: baby.kinderName,
//      name: baby.name,
//      id: baby.id,
//      kinderLan: latLng.latitude,
//      kinderLng: latLng.longitude,
//      homeLan: baby.homeLan,
//      homeLng: baby.homeLng,
//      otherPlaces: baby.otherPlaces
//    ):
//    ChildModel(
//      kinderName: baby.kinderName,
//      name: baby.name,
//      id: baby.id,
//      homeLan: latLng.latitude,
//      homeLng: latLng.longitude,
//      kinderLan: baby.kinderLan,
//      kinderLng: baby.kinderLng,
//      otherPlaces: baby.otherPlaces
//    );
    myBabyList.add(baby);

    //  save in Shared Preferences
    List<String> savedList = [];
    myBabyList.forEach((child){
      savedList.add(child.toJson());
    });
    prefs.setStringList("my_childern", savedList);
  }


  getMapRoute({bool toHome})async{

    setState(() {
      cameraMoved = true;
    });

    _drawRoutesBetween2Points(
      from: busLocation,
      to: toHome?LatLng(baby.homeLan , baby.homeLng):LatLng(baby.kinderLan,baby.kinderLng)
    );

//
//    DirectionsResponse x = await GoogleMapsDirections(apiKey: _mapApiKey).directions(
//      Location(prefs.getDouble("kinder_lat"),prefs.getDouble("kinder_lng")),
//      Location(prefs.getDouble("home_lat"),prefs.getDouble("home_lng")),
//    );
//    print(x.errorMessage);
//    print(">>>>>>>>>>>>>>>>>>>>>>");

    setState(() {});

  }

  //=-===========================


  void _drawRoutesBetween2Points({LatLng from , LatLng to}) async {

    String url = '$_apiRootDomain/${from.longitude},${from.latitude};${to.longitude},${to.latitude}.json';

    print('request URL is: $url\n');

    final http.Response response = await http.get(url);

    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> parsedJson = json.decode(response.body);
      String routesPolyline = parsedJson['routes'][0]['geometry'];

      final coorValues = _decodePoly(routesPolyline);
      List<LatLng> routesPoints = [];
      for (int i = 0; i < coorValues.length; i += 2) {
        routesPoints.add(LatLng(coorValues[i], coorValues[i + 1]));
      }

      final poly = Polyline(
        polylineId: PolylineId(routesPoints.toString()),
        points: routesPoints,
        width: 10,
        color: Colors.indigo,
      );

      setState(() {
        _routesPolylines = [poly].toSet();
        print(routesPoints.toString());
      });
    } else {
      print('Error fetching routes');
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('API request failed!'),
        ),
      );
    }
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }




}