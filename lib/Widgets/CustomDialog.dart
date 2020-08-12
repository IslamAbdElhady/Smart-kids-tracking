import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog{

  static void showSuccessDialog(BuildContext context,String action,
      {Function function,bool dismissible = false}){
    showDialog(barrierDismissible: dismissible,
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async {
              return Future.value(dismissible);
            },
            child: Container(
              child: AlertDialog(
                backgroundColor: Colors.white,
                title: Text("attention please",
                  style: TextStyle(color: Colors.black87),),
                content: new Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.check,size: 60,color: Colors.blue,),
                      Flexible(child: Text(action
                        ,style: TextStyle(fontSize: 18,color: Colors.black87),
                        textAlign: TextAlign.center,))
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton.icon(
                      onPressed:(){
                        Navigator.pop(context);
                        if(function != null) function();
                      },
                      icon: new Icon(Icons.check),
                      label: Text("continue",
                          style: TextStyle(color: Colors.black87),)
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  static void showUnKnowDialog(BuildContext context,String action,
      {Function function,bool dismissible = false}){
    showDialog(barrierDismissible: dismissible,
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async {
              return Future.value(dismissible);
            },
            child: Container(
              child: AlertDialog(
                backgroundColor: Colors.white,
                title: Text("attention please",
                  style: TextStyle(color: Colors.black87),),
                content: new Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.warning,size: 60,color: Colors.yellow.shade500,),
                      Flexible(child: Text(action
                        ,style: TextStyle(fontSize: 18,color: Colors.black87),
                        textAlign: TextAlign.center,))
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton.icon(
                      onPressed:(){
                        Navigator.pop(context);
                        if(function != null) function();
                      },
                      icon: new Icon(Icons.check),
                      label: Text("continue",
                        style: TextStyle(color: Colors.black87),)
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  static void showFailedDialog(BuildContext context,String action,
      {Function function,bool dismissible = false}){
    showDialog(barrierDismissible: dismissible,
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async {
              return Future.value(dismissible);
            },
            child: AlertDialog(
              backgroundColor: Colors.white,
              title: Text("attention please",
                  style: TextStyle(color: Colors.black87),),
              content: new Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.close,size: 55,color: Colors.red,),
                    Flexible(child: Text(action
                      ,style: TextStyle(fontSize: 18,color: Colors.black87),
                      textAlign: TextAlign.center,))
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton.icon(
                    onPressed:(){
                      Navigator.pop(context);
                      if(function != null) function();
                    },
                    icon: new Icon(Icons.check),
                    label: Text("continue",
                      style: TextStyle(color: Colors.black87),)
                ),
              ],
            ),
          );
        }
    );
  }

  static void showSnackBar(BuildContext context,String value,
      {GlobalKey<ScaffoldState> scaffoldKey,int duration = 3}) {
    FocusScope.of(context).requestFocus(new FocusNode());
    scaffoldKey.currentState?.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      behavior: SnackBarBehavior.fixed,

      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 18.0,fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.black87.withBlue(10),
      duration: Duration(seconds: duration),
    ));
  }

}

