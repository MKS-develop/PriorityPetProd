import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextIconField extends StatelessWidget
{
  final TextEditingController controller;
  final IconData data;
  final TextInputType keyboard;

  final String hintText;
  bool isObsecure = false;



  CustomTextIconField(
      {Key key, this.controller, this.data, this.hintText,this.isObsecure, this.keyboard}
      ) : super(key: key);



  @override
  Widget build(BuildContext context)
  {
    return Container
    (

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF7f9d9D), width: 1.0,),

        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),

      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.all(5.0),

      width: 360,
      child: TextFormField(
style: TextStyle(fontSize: 15, color: Color(0xFF1A3E4D)),
        keyboardType: keyboard,
        controller: controller,
        textAlign: TextAlign.left,
        obscureText: isObsecure,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
            border: InputBorder.none,
        prefixIcon: Icon(data,
        ),

          focusColor: Color(0xFF7f9d9D),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 16.0, color: Color(0xFF7f9d9D)),


        ),


      ),
    );
  }
}
