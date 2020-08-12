import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

// ignore: must_be_immutable
class CustomButtonWidget extends StatelessWidget {

  String title;
  Function onPressed;
  CustomButtonWidget({@required this.onPressed, @required this.title});

  @override
  Widget build(BuildContext context) {
    return ProgressButton(
      height: 60,
      borderRadius: 6,
      color: Color(0xff67acc0),
      onPressed: onPressed,
      defaultWidget: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600),
      ),
      progressWidget: CircularProgressIndicator(
        backgroundColor: Color(0xff67acc0),
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
      type: ProgressButtonType.Raised,
    );
  }
}
