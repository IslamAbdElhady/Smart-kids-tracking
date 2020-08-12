import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kinder_garten/Widgets/CustomButton.dart';
import 'package:kinder_garten/Screens/Home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:kinder_garten/Widgets/CustomDialog.dart';

class LogInScreen2 extends StatelessWidget {

  static const routeName = '/login';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signAsGuest({BuildContext context})async{
    FirebaseUser user = await _auth.signInAnonymously().then((result){
      return result.user;
    });
    if(user!=null && user.isAnonymous == true){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context)=> HomePageScreen()));
      print("woooooooork :) ");
    }else{
      CustomDialog.showFailedDialog(
        context,
        "حدث خطأ ما يرجي المحاولة مره اخري",
        dismissible: true
      );
      print("noooooooork :( ");
    }
  }

  Future<void> signByGoogleAccount({BuildContext context})async{

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      if(user!=null && user.isAnonymous == false){
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context)=> HomePageScreen()));
        print(">>>>>>>>>>>>>>>>>>>>>>>>> woooooooork :) ");
    }else{
      CustomDialog.showFailedDialog(
          context,
          "حدث خطأ ما يرجي المحاولة مره اخري",
          dismissible: true
      );
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>> noooooooork :( ");
    }
  }




  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: _buildScreen(size: _size,context: context),
    );
  }

  Widget _buildScreen({Size size,BuildContext context}){
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: size.width,
        height: size.height-MediaQuery.of(context).padding.top,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/images/logo.png"),
                    width: size.width*0.4,
                    height: size.width*0.3,
                  ),
                  SizedBox(height: 35,),
                  Text(
                    "Welcome to the kindergarten app",
                    style: TextStyle(color: Colors.grey,fontSize: 20),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomButtonWidget(
                      title: "sign in with google Account",
                      onPressed: ()async{
                        await signByGoogleAccount(context: context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomButtonWidget(
                      title: "sign in as Guest",
                      onPressed: ()async{
                        await signAsGuest(context: context);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}