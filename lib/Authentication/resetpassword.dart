
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/DialogBox/errorDialog.dart';
import 'package:pet_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";



  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery
        .of(context)
        .size
        .width,
        _screenHeight = MediaQuery
            .of(context)
            .size
            .height;

    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("diseñador/drawable/Patitas.png"),
              alignment: Alignment(1.2, 1.13),
            ),
          ),
          child:Column(

            children: [
              SizedBox(height: 100.0,),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'diseñador/logo.png',
                      fit: BoxFit.contain,
                      height: 50,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back_ios, color: Color(0xFF57419D)), onPressed: (){
                      Navigator.pop(context);
                    }
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text("Reinicio de contraseña", style: TextStyle(color: Color(0xFF57419D), fontSize: 18, fontWeight: FontWeight.bold,),),),
                  ],
                ),
              ),


              SizedBox(height: 50.0,),
              Form(
                key: _formKey,
                child: Column(
                  children: [

                    Container(
                      width: _screenWidth*0.84,
                      child: CustomTextField(
                        controller: _emailTextEditingController,
                        keyboard: TextInputType.emailAddress,
                        hintText: "Coloca tu correo electrónico",
                        isObsecure: false,
                      ),
                    ),



                  ],
                ),

              ),
              SizedBox(height: 20.0,),
              Container(
                width: _screenWidth*0.84,

                child: RaisedButton(
                  onPressed: () {
                    _emailTextEditingController.text.isNotEmpty && EmailValidator.validate(_emailTextEditingController.text)
                        ? sendEmail(_emailTextEditingController.text)

                        : showDialog(context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message: "Por favor ingrese un correo electrónico válido...",);
                        });

                  },

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Color(0xFF57419D),
                  padding: EdgeInsets.all(15.0),
                  child: Text("Enviar correo para reinicio",
                      style: TextStyle(color: Colors.white, fontSize: 20.0)),

                ),
              ),




            ],

          ),
        ),
      ),
    );
  }

sendEmail(String email){
  PetshopApp.auth.sendPasswordResetEmail(email: email);
  Fluttertoast.showToast(msg: "Se ha enviado un correo a la dirección $email para el reinicio de su contraseña.");
  Navigator.pop(context);


  }







  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(message: msg,);
        }
    );
  }




}



