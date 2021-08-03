import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:getflutter/components/rating/gf_rating.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Servicio.dart';
import 'package:pet_shop/Servicios/serviciocontratar.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

int cantidad = 1;

double width;

class ServicioDetalle extends StatefulWidget {
  final PetModel petModel;
  final ServicioModel servicioModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  ServicioDetalle(
      {this.petModel,
      this.servicioModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _ServicioDetalleState createState() => _ServicioDetalleState();
}

class _ServicioDetalleState extends State<ServicioDetalle> {
  DateTime selectedDate = DateTime.now();

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

    int total = widget.servicioModel.precio;
    total = total * cantidad;
    String precio = total.toString();
    String cant = cantidad.toString();
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
                        "Detalles",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: _screenWidth,
                      child: Column(
                        children: [
                          Container(
                              height: 250.0,
                              width: _screenWidth,
                              child: Image.network(
                                widget.servicioModel.urlImagen,
                                fit: BoxFit.fill,
                              )),
                          SizedBox(
                            height: 15.0,
                          ),
                          GFRating(
                            size: 34.0,
                            color: Colors.orange,
                            value: widget.servicioModel.totalRatings /
                                widget.servicioModel.countRatings,
                            borderColor: Colors.orange,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.servicioModel.titulo,
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.servicioModel.direccion,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.servicioModel.ciudad,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          print(widget.servicioModel.urlImagen);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServicioContratar(
                                    petModel: model,
                                    servicioModel: widget.servicioModel,
                                    defaultChoiceIndex:
                                        widget.defaultChoiceIndex)),
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Color(0xFF57419D),
                        padding: EdgeInsets.all(10.0),
                        child: Text("Contratar servicio",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 18.0)),
                      ),
                    ),
                  ],
                )
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
      print(nuevo);
    });
    return nuevo;
  }

  void checkItemInCart(
      String itemID, String cant, String precio, BuildContext context) {
    // PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList).contains(itemID)
    //     ? Fluttertoast.showToast(msg: "El producto ya se encuentra en el carrito.")
    //
    //     : addItemtoCart(itemID, context);
    addItemtoCart(itemID, cant, precio, context);
  }

  addItemtoCart(
      String itemID, String cant, String precio, BuildContext context) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(productId)
        .set({
      "aliadoId": widget.servicioModel.aliadoId,
      "iId": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse(precio),
      "cantidad": int.parse(cant),
      "productoId": itemID,
    });

    setState(() {
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });

    // List tempCartList = PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList);
    // tempCartList.add(itemID);
    //
    // PetshopApp.firestore.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).updateData({
    //   PetshopApp.userCartList: tempCartList,
    // }).then((v){
    //  Fluttertoast.showToast(msg: "Se ha agregado su producto al carrito.");
    //  PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, tempCartList);
    // });
  }

  Widget sourceInfo(ProductModel product, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell();
  }
}
