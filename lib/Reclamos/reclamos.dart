import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Reclamo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Reclamos/addreclamos.dart';
import 'package:pet_shop/Reclamos/reclamo.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class ReclamosPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  ReclamosPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _ReclamosPageState createState() => _ReclamosPageState();
}

class _ReclamosPageState extends State<ReclamosPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  List allResults = [];
  List ordenes = [];
  int ratingC = 0;

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
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar: CustomBottomNavigationBar(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
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
                        "Reclamos",
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddReclamosPage()),
                      );
                    },
                    minWidth: MediaQuery.of(context).size.width,
                    height: 55.0,
                    color: Color(0xFF57419D),
                    child: Text("Hacer un reclamo",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Product Sans',
                            fontSize: 18.0)),
                  ),
                ),
                SizedBox(height: 25.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder(
                            stream: db
                                .collection('Reclamos')
                                .where('uid',
                                    isEqualTo: PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userUID))
                                .snapshots(),
                            // ignore: missing_return
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data.docs.length == 0) {
                                return Center(
                                    child: Column(children: [
                                  Text(
                                    'No tienes ningun reclamo aún',
                                    style: TextStyle(
                                        color: Color(0xFF57419D),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.0),
                                  ),
                                ]));
                              }
                              return ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, i) {
                                  ReclamoModel reclamo = ReclamoModel.fromJson(
                                      snapshot.data.docs[i].data());
                                  return getReclamos(reclamo);
                                },
                              );
                            }),
                        SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getReclamos(ReclamoModel reclamo) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReclamoPage(
                    reclamoModel: reclamo,
                    petModel: widget.petModel,
                    defaultChoiceIndex: widget.defaultChoiceIndex)),
          );
        },
        child: ReclamoCard(reclamo));
  }

  Widget ReclamoCard(ReclamoModel reclamo) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 75.0,
      margin: EdgeInsets.only(bottom: 15.0),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nro. del reclamo",
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF57419D))),
              Text(reclamo.reclamoId.toString(),
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF57419D))),
            ],
          ),
          Container(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status del reclamo",
                    style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF57419D))),
                Text(reclamo.status.toString(),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF57419D))),
              ],
            ),
            SizedBox(width: 25.0),
            Text("Ver",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
          ]))
        ],
      ),
    );
  }
}
