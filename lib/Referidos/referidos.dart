import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

class ReferidosPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;

  ReferidosPage({this.petModel, this.productoModel, this.cartModel});

  @override
  _ReferidosPageState createState() => _ReferidosPageState();
}

class _ReferidosPageState extends State<ReferidosPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  String userEmail;
  String userName;
  String response;
  String userUsername;
  String aliadoId;
  String buttonText = "Enviar invitación";
  var referidos = [];

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(context, widget.petModel),
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: MyDrawer(),
        body: Container(
          height: _screenHeight,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Color(0xFF57419D)),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text(
                        "Invita a un amigo",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                          "Invita a tus amigos para que descarguen la APP Priority Pet Club y puedan formar parte de nuestra gran comunidad. Por cada amigo que se afilie te regalaremos 100 Pet Points",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.w300,
                          )),
                      SizedBox(height: 30.0),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre del invitado',
                              style: TextStyle(
                                  color: Color(0xFF7F9D9D),
                                  fontSize: 17.0,
                                  fontFamily: 'Product Sans'),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              width: width,
                              height: 55.0,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                validator: (val) => val.isEmpty
                                    ? "Nombre de la persona a la que deseas invitar"
                                    : null,
                                onChanged: (val) => userName = val,
                                decoration: InputDecoration(
                                    // filled: true,
                                    // fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(1.0),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    hintText:
                                        "Nombre de la persona a la que deseas invitar",
                                    errorStyle: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    )),
                              ),
                            ),
                          ]),
                      SizedBox(height: 30.0),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                  color: Color(0xFF7F9D9D),
                                  fontSize: 17.0,
                                  fontFamily: 'Product Sans'),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              width: width,
                              height: 55.0,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                validator: (val) => val.isEmpty
                                    ? "Email de la persona a la que deseas invitar"
                                    : null,
                                onChanged: (val) => userEmail = val,
                                decoration: InputDecoration(
                                    // filled: true,
                                    // fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(1.0),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    hintText:
                                        "Email de la persona a la que deseas invitar",
                                    errorStyle: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    )),
                              ),
                            ),
                          ]),
                      SizedBox(height: 30.0),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {
                          sendEmail();
                        },
                        minWidth: MediaQuery.of(context).size.width,
                        height: 55.0,
                        color: Color(0xFF57419D),
                        child: Text(buttonText,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Product Sans',
                                fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future sendEmail() async {
    if (referidos.contains(userEmail)) {
      response = "Ya se invito a esta persona";
      dialogError(context, response);
    } else if (userEmail == null ||
        userName == null ||
        !userEmail.contains("@")) {
      response = "Ingrese los datos correctamente";
      dialogError(context, response);
    } else {
      try {
        setState(() {
          buttonText = "Invitando...";
        });
        userUsername =
            PetshopApp.sharedPreferences.getString(PetshopApp.userName);
        var res = await http.get(
            'https://us-central1-priority-pet.cloudfunctions.net/sendInvitationEmail?dest=$userEmail&aliado=$userUsername&username=$userName');
        await db.collection('Referidos').doc(userEmail).setData({
          "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
          "referidoEmail": userEmail,
          "registrado": false
        });
        setState(() {
          response = res.body;
          dialog(context, response);
          print(response);
          buttonText = "Enviar invitación";
        });
      } catch (e) {
        print(e.message);
        return null;
      }
    }
  }

  Future<void> dialog(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFF57419D), size: 60.0),
                    SizedBox(height: 20.0),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> dialogError(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60.0),
                    SizedBox(height: 20.0),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<List<dynamic>> _getData() async {
    referidos = [];
    try {
      await db
          .collection('Referidos')
          .getDocuments()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.documents.forEach((referido) {
                  setState(() {
                    referidos.add(referido.documentID.toString());
                  });
                })
              });
      print(referidos.length);
    } catch (e) {
      print(e);
    }
    return referidos;
  }
}
