import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Reclamo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Reclamos/reclamos.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:intl/date_symbol_data_local.dart';

class ReclamoPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final ReclamoModel reclamoModel;
  final int defaultChoiceIndex;

  ReclamoPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.reclamoModel,
      this.defaultChoiceIndex});

  @override
  _ReclamoPageState createState() => _ReclamoPageState();
}

class _ReclamoPageState extends State<ReclamoPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  ReclamoModel reclamo;

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    //initializeDateFormatting("es_VE", null).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    var formatter = DateFormat.yMd('es_VE');
    String newtime =
        formatter.format(widget.reclamoModel.fechaReclamo.toDate()).toString();
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
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(widget.reclamoModel.reclamoId,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w700))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Text("Reclamo",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 10.0),
                      Container(
                          child: Text(widget.reclamoModel.reclamo,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Text("Tipo de reclamo",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 10.0),
                      Container(
                          child: Text(
                              widget.reclamoModel.tipoReclamo.toString(),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Text("Razón del reclamo",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 10.0),
                      Container(
                          child: Text(
                              widget.reclamoModel.razonReclamo.toString(),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Text("Status del reclamo",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 10.0),
                      Container(
                          child: Text(widget.reclamoModel.status.toString(),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Text("Fecha del reclamo",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 10.0),
                      Container(
                          child: Text(newtime,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.w300))),
                      SizedBox(height: 20.0),
                      Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                            GestureDetector(
                              onTap: () {
                                deleteReclamo();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xFFF03434),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Eliminar reclamo',
                                        style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 10.0),
                                    Icon(Icons.delete, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ])),
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

  Future<dynamic> deleteReclamo() async {
    await db
        .collection('Reclamos')
        .doc(widget.reclamoModel.id)
        .delete()
        .then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReclamosPage(
                    petModel: widget.petModel,
                    defaultChoiceIndex: widget.defaultChoiceIndex,
                  )));
    });
  }
}
