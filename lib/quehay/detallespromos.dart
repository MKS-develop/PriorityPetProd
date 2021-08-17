import 'dart:io';
import 'package:pet_shop/Authentication/map.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
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

class DetallesPromo extends StatefulWidget {
  final PetModel petModel;
  final PromotionModel promotionModel;
  final AliadoModel aliadoModel;
  final int defaultChoiceIndex;
  final LocationModel locationModel;
  DetallesPromo(
      {this.petModel,
      this.promotionModel,
      this.aliadoModel,
      this.defaultChoiceIndex, this.locationModel
      });

  @override
  _DetallesPromoState createState() => _DetallesPromoState();
}

class _DetallesPromoState extends State<DetallesPromo> {
  AliadoModel ali;
  PromotionModel pro;
  PetModel model;
  DateTime selectedDate = DateTime.now();
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  double rating = 0;
  GeoPoint userLatLong;

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  void initState() {
    super.initState();

    changePet(widget.petModel);
    changeDet(widget.promotionModel);
    changeAli(widget.aliadoModel);
    _isSelected = false;
    _defaultChoiceIndex = 0;
    getLatLong();
  }

  getLatLong() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        userLatLong = (dataSnapshot.data()["location"]);
      });
    });
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    if (widget.aliadoModel.totalRatings != null) {
      rating =
          widget.aliadoModel.totalRatings / widget.aliadoModel.countRatings;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                        "Qué hay hoy",
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
                        widget.promotionModel.urlImagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, object, stacktrace) {
                          return Container();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.59,
                      height: 110.0,
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
                          widget.locationModel.mapAddress != null ?
                          Text(widget.locationModel.mapAddress,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ):

                          Text(widget.locationModel.direccionLocalidad,
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              widget.locationModel.location != null ?
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MapHome(petModel: widget.petModel, defaultChoiceIndex:
                                      widget.defaultChoiceIndex, locationModel: widget.locationModel, aliadoModel: widget.aliadoModel, userLatLong: userLatLong)),
                                    );
                                  },
                                  child: Image.asset(
                                    'diseñador/drawable/Grupo197.png',
                                    fit: BoxFit.contain,
                                    height: 33,
                                  ),
                                ),
                              ): Container(),
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
                                child: Text(widget.promotionModel.titulo,
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
                                child: Text(widget.promotionModel.descripcion,
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
                                child: Text(widget.promotionModel.condiciones,
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
                            Text(
                                PetshopApp.sharedPreferences
                                    .getString(PetshopApp.simboloMoneda),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF57419D),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            Text(
                                (widget.promotionModel.precio).toString() !=
                                        'null'
                                    ? (widget.promotionModel.precio)
                                        .toStringAsFixed(2)
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
                        widget.promotionModel.tipoPromocion != 'Información'
                            ? SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    // AddOrder(widget.promotionModel.promoId, context);
                                    print(widget.petModel.nombre);
                                    if (widget.promotionModel.tipoPromocion !=
                                        'Información') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContratoPromos(
                                                  petModel: widget.petModel,
                                                  promotionModel:
                                                      widget.promotionModel,
                                                  aliadoModel:
                                                      widget.aliadoModel,
                                                  defaultChoiceIndex:
                                                      widget.defaultChoiceIndex,
                                                  locationModel: widget.locationModel,
                                                )),
                                      );
                                    } else {
                                      showDialog(
                                          builder: (context) =>
                                              new ChoosePetAlertDialog(
                                                message:
                                                    "Esto es una campaña sólo informativa, sin costo alguno.",
                                              ),
                                          context: context);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          widget.promotionModel.tipoPromocion ==
                                                  'Producto'
                                              ? "Comprar promoción"
                                              : "Contratar servicio",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Colors.white,
                                              fontSize: 18.0)),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
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

  AddOrder(String itemID, BuildContext context) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection('Ordenes').doc(productId).set({
      "aliadoId": widget.promotionModel.aliadoid,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse(widget.promotionModel.precio.toString()),
      "promoid": itemID,
      "titulo": widget.promotionModel.titulo,
      'createdOn': DateTime.now()
    });

    setState(() {
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  changeAli(Al) {
    setState(() {
      ali = Al;
    });

    return Al;
  }

  changeDet(Det) {
    setState(() {
      pro = Det;
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
