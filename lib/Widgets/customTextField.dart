import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget
{
  final TextEditingController controller;
  final IconData data;
  final String hintText;
  final TextInputType keyboard;

  bool isObsecure = false;




  CustomTextField(
      {Key key, this.controller, this.data, this.hintText,this.isObsecure, this.keyboard, }
      ) : super(key: key);





  @override
  Widget build(BuildContext context)
  {
    double _screenWidth = MediaQuery
        .of(context)
        .size
        .width,
        _screenHeight = MediaQuery
            .of(context)
            .size
            .height;
    return Container
    (
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF7f9d9D), width: 1.0,),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),

      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
      margin: EdgeInsets.all(5.0),

      width: _screenWidth*0.9,
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        style: TextStyle(fontSize: 17, color: Color(0xFF1A3E4D)),
        controller: controller,
        keyboardType: keyboard,
        textAlign: TextAlign.left,
        obscureText: isObsecure,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
            border: InputBorder.none,
          focusColor: Color(0xFF7f9d9D),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15.0, color: Color(0xFF7f9d9D)),

        ),


      ),
    );
  }
}
