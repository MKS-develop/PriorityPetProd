import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Servicio.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

int cantidad = 1;

double width;

class ServicioContratar extends StatefulWidget {
  final PetModel petModel;
  final ServicioModel servicioModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  ServicioContratar(
      {this.petModel,
      this.servicioModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _ServicioContratarState createState() => _ServicioContratarState();
}

class _ServicioContratarState extends State<ServicioContratar> {
  DateTime selectedDate = DateTime.now();
  var sliderValue = 1.0;
  ServicioModel servicio;
  PetModel model;
  CartModel cart;
  bool select = false;
  bool uploading = false;

  String petImageUrl = "";
  String downloadUrl = "";

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          height: _screenHeight,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.3), BlendMode.dstATop),
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
                        "Contratar servicio",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Image.network(
                              widget.servicioModel.urlImagen,
                              fit: BoxFit.fill,
                              errorBuilder: (context, object, stacktrace) {
                                return Container();
                              },
                            )),
                      ],
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.servicioModel.titulo,
                            style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(widget.servicioModel.direccion,
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.left),
                        Text(widget.servicioModel.ciudad,
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.left),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Text(
                                (widget.servicioModel.totalRatings /
                                        widget.servicioModel.countRatings)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 17, color: Colors.orange),
                                textAlign: TextAlign.left),
                            Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Días a contratar",
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(sliderValue.toStringAsFixed(0),
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(" días",
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Slider(
                        min: 1,
                        max: 30,
                        divisions: 30,
                        value: sliderValue,
                        activeColor: Color(0xFFEB9448),
                        onChanged: (newValue) {
                          setState(() {
                            sliderValue = newValue;
                          });
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  nuevoPet(nuevo) {
    setState(() {
      servicio = nuevo;
    });
    return nuevo;
  }
}

Widget sourceInfo(ProductModel product, BuildContext context,
    {Color background, removeCartFunction}) {
  return InkWell();
}
