import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final bool obscure;
  final String hint;
  final Function errorCondition;
  final errorMessage;
  final Icon myIcon;
  TextInputType textInputType = TextInputType.text;
  Function iconOnPressed;
  bool enable;

  CustomTextField({this.controller,this.obscure = false,this.hint,this.myIcon,
    this.iconOnPressed,this.textInputType,this.enable=true,this.errorCondition,this.errorMessage});

  StreamController _streamController = StreamController<String>.broadcast();

  void dispose() {
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<String>(
      stream: _streamController.stream,
      initialData: "",
      builder: (context, snapshot) {
        return Container(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoDirection(
                text: controller.text,
                child: TextFormField(
                  onChanged: (value){
                    _streamController.sink.add(value);
                  },
                  enabled: enable,
                  obscureText: obscure,
                  controller: controller,
                  decoration: InputDecoration(
                    errorText: checkError(snapshot.data),
                    errorStyle: TextStyle(color: Colors.teal),
                    prefixIcon: IconButton(
                        icon: myIcon!=null?myIcon:Icon(null),
                        onPressed: iconOnPressed
                    ),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 13),
                    alignLabelWithHint: true
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  keyboardType: textInputType,
                  style: TextStyle(fontSize: 15,),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  checkError(data){
    if(errorCondition(data)) return errorMessage;
    else return null;
  }

}
