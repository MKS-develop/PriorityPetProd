import 'dart:io';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/Servicio.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Servicios/contratoservicio.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/quehay/contratopromos.dart';
import '../Widgets/myDrawer.dart';
import 'package:pet_shop/Models/Promo.dart';

double width;

class DetallesServicio extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final ServicioModel servicioModel;
  DetallesServicio(
      {this.petModel,
      this.serviceModel,
      this.aliadoModel,
      this.locationModel,
      this.servicioModel});

  @override
  _DetallesServicioState createState() => _DetallesServicioState();
}

class _DetallesServicioState extends State<DetallesServicio> {
  ServiceModel service;
  AliadoModel ali;
  LocationModel location;

  PetModel model;
  DateTime selectedDate = DateTime.now();

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  void initState() {
    super.initState();

    changePet(widget.petModel);
    changeDet(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    double rating =
        widget.aliadoModel.totalRatings / widget.aliadoModel.countRatings;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(context, widget.petModel),
        drawer: MyDrawer(),
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                        widget.serviceModel.categoria,
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
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        widget.aliadoModel.avatar,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      height: 100.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(widget.aliadoModel.nombreComercial,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          Text(widget.locationModel.direccionLocalidad,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.left),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  rating.toString() != 'NaN'
                                      ? rating.toStringAsPrecision(2)
                                      : '0',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.orange),
                                  textAlign: TextAlign.left),
                              Icon(
                                Icons.star,
                                color: Colors.orange,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.91,
                  decoration: BoxDecoration(
                      color: Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(widget.serviceModel.titulo,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF57419D),
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left)),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(widget.serviceModel.descripcion,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left)),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text('Condiciones',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF57419D),
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left)),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(widget.serviceModel.condiciones,
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.left)),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF57419D),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            Text(
                                (widget.serviceModel.precio).toString() !=
                                        'null'
                                    ? (widget.serviceModel.precio).toString()
                                    : '0',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF57419D),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              // AddOrder(widget.promotionModel.promoId, context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContratoServicio(
                                        petModel: model,
                                        aliadoModel: ali,
                                        serviceModel: service,
                                        locationModel: location)),
                              );
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            color: Color(0xFF57419D),
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Contratar servicio",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        color: Colors.white,
                                        fontSize: 18.0)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  changeLoc(Det) {
    setState(() {
      location = Det;
    });

    return Det;
  }

  changeAli(Al) {
    setState(() {
      ali = Al;
    });

    return Al;
  }

  changeDet(Det) {
    setState(() {
      service = Det;
    });

    return Det;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
