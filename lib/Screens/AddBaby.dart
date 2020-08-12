import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/Home_screen.dart';
import 'package:kinder_garten/Widgets/CustomButton.dart';
import 'package:kinder_garten/Widgets/CustomDialog.dart';
import 'package:kinder_garten/Widgets/CustomTextFeild.dart';
import 'package:kinder_garten/model/childModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class AddBaby extends StatefulWidget {

  final String userId;
  AddBaby({this.userId});

  @override
  _AddBabyState createState() => _AddBabyState();
}

class _AddBabyState extends State<AddBaby> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  StreamController _buttonOnPress = StreamController<bool>.broadcast();

  TextEditingController babyName = TextEditingController();
  TextEditingController kinderName = TextEditingController();
  TextEditingController babyKey = TextEditingController();

  List<ChildModel> myChildren = [];

  @override
  void dispose() {
    _buttonOnPress.close();
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _addBaby()async{
    if(babyName.text.length<4 && kinderName.text.length<4){
      _buttonOnPress.sink.add(true);
      return;
    }
    if(babyKey.text.length<4) return;
    bool isExist = await firebaseOperations(key: babyKey.text,userId: widget.userId);
    if(isExist){
      Future.delayed(Duration(milliseconds: 500));
      addMyBaby();
    }else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("المفتاح غير موجود يرجي المحاوله مره اخري"),));
    }
  }

  _init()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.get("my_childern") != null){
      List temp = prefs.get("my_childern");
      temp.forEach((item){
        myChildren.add(
            ChildModel.fromJson(item)
        );
      });
    }
  }

  addMyBaby()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ChildModel newBaby = ChildModel(
      kinderName: kinderName.text,
      name: babyName.text,
      id: Random().nextInt(1223),
      babyKey: babyKey.text
    );
    myChildren.add(newBaby);

    //  save in Shared Preferences
    List<String> savedList = [];
    myChildren.forEach((child){
      savedList.add(child.toJson());
    });
    prefs.setStringList("my_childern", savedList);

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context)=> HomePageScreen())
    );

  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        babyKey.text = scanData;
      });
      if(scanData!=null) Navigator.pop(context);
    });
  }

  _showQrScanner(){
    showDialog(barrierDismissible: true, context: context,
        builder: (BuildContext context){
          return Container(
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.000005),
              content: Container(
                width: MediaQuery.of(context).size.width*0.4,
                child: AspectRatio(
                  aspectRatio: 5/6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Future<bool> firebaseOperations({String key,String userId})async{

    var result = await Firestore.instance.collection('children').document(key).get();

    if(result.data==null){
      return false;
    }else{
      Firestore.instance.collection('children').document(key).updateData({
        'guardian':"$userId"
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final workSpaceHeight = _size.height-100 -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("KinderGarten",style: TextStyle(color: Colors.white,fontSize: 18),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: workSpaceHeight,
          width: _size.width,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[

                  Image(
                    image: AssetImage("assets/images/logo.png"),
                    width: _size.width*0.4,
                    height: _size.width*0.3,
                  ),

                  _buildScreen(size: _size),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen({Size size}){
    return StreamBuilder(
      stream: _buttonOnPress.stream,
      initialData: false,
      builder: (context, snapShot){
        return Column(
          children: <Widget>[
            SizedBox(height: 20,),
            CustomTextField(
              hint:  "baby Name",
              controller: babyName,
              textInputType: TextInputType.text,
              myIcon: Icon(Icons.phone,color: Colors.teal,),
              errorMessage: "يرجي ادخال اسم الطفل ",
              errorCondition: (String data){
                if(!snapShot.data) return false;
                return babyName.text.length<4?(data.length<4):false;              },
            ),
            SizedBox(height: 20,),
            CustomTextField(
              hint: "kinderGarten name",
              controller: kinderName,
              textInputType: TextInputType.text,
              myIcon: Icon(Icons.child_care,color: Colors.teal,),
              errorMessage: "يرجي ادخال اسم الحضانة",
              errorCondition: (String data){
                if(!snapShot.data) return false;
                return kinderName.text.length<4?(data.length<4):false;
              },
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomTextField(
                    hint: "baby key",
                    controller: babyKey,
                    textInputType: TextInputType.text,
                    myIcon: Icon(Icons.child_care,color: Colors.teal,),
                    errorMessage: "يرجي ادخال مفتاح الطفل",
                    errorCondition: (String data){
                      if(!snapShot.data) return false;
                      return babyKey.text.length<4?(data.length<4):false;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check_box_outline_blank,color: Colors.teal,),
                  onPressed: _showQrScanner,
                ),
              ],
            ),
            SizedBox(height: 50,),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CustomButtonWidget(
                title: "Add",
                onPressed: _addBaby,
              ),
            ),
          ],
        );
      },
    );
  }
}