import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Reclamos/reclamos.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class AddReclamosPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  AddReclamosPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _AddReclamosPageState createState() => _AddReclamosPageState();
}

class _AddReclamosPageState extends State<AddReclamosPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  String tituloReclamo;
  int reclamos;
  String razonReclamo;
  String response;
  String numeroOrden;
  String tipoReclamo;
  List<dynamic> tiposReclamo = [];
  String codigoAliado;
  String buttonText = "Enviar reclamo";
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getData();
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
                        "Hacer un reclamos",
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
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Si tienes algún reclamo con respecto a algo relacionado a la aplicación envialo mediante este formulario",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF57419D),
                              fontWeight: FontWeight.w300,
                            )),
                        SizedBox(height: 20.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo de reclamo',
                                style: TextStyle(
                                    color: Color(0xFF7F9D9D),
                                    fontSize: 17.0,
                                    fontFamily: 'Product Sans'),
                              ),
                              SizedBox(height: 10.0),
                              FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 16.0),
                                        hintText: 'Tipo de reclamo',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                    isEmpty: tipoReclamo == '',
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        hint: Text(
                                          'Elige el tipo de reclamo',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        value: tipoReclamo,
                                        isDense: true,
                                        onChanged: (String newValue) {
                                          setState(() {
                                            tipoReclamo = newValue;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items:
                                            tiposReclamo.map((dynamic value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ]),
                        SizedBox(height: 30.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nro. de orden',
                                style: TextStyle(
                                    color: Color(0xFF7F9D9D),
                                    fontSize: 17.0,
                                    fontFamily: 'Product Sans'),
                              ),
                              SizedBox(height: 15.0),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: _screenWidth * 0.8,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Ordenes")
                                                  .where('uid',
                                                      isEqualTo: PetshopApp
                                                          .sharedPreferences
                                                          .get(PetshopApp
                                                              .userUID))
                                                  // .orderBy('createdOn', descending: false)
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  List<String> list = [];
                                                  for (int i = 0;
                                                      i <
                                                          dataSnapshot
                                                              .data.docs.length;
                                                      i++) {
                                                    DocumentSnapshot razas =
                                                        dataSnapshot
                                                            .data.docs[i];
                                                    list.add(
                                                      razas.id,
                                                    );
                                                  }
                                                  return Container(
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF7f9d9D),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            15, 0, 0, 0),
                                                    margin: EdgeInsets.all(5.0),
                                                    child:
                                                        DropdownSearch<String>(
                                                      dropdownSearchDecoration:
                                                          InputDecoration(
                                                        hintStyle: TextStyle(
                                                            fontSize: 16.0,
                                                            color: Color(
                                                                0xFF7f9d9D)),
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        enabled: false,
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      mode: Mode.BOTTOM_SHEET,
                                                      maxHeight: 300,
                                                      // searchBoxController:
                                                      //     _razaTextEditingController,
                                                      // popupBackgroundColor: Colors.amber,
                                                      // searchBoxDecoration: InputDecoration(
                                                      //   fillColor: Colors.blue,
                                                      // ),
                                                      showSearchBox: true,
                                                      showSelectedItem: true,
                                                      items: list,
                                                      // label: "Menu mode",
                                                      hint:
                                                          "Ingrese un número de orden si es necesario",

                                                      popupItemDisabled:
                                                          (String s) =>
                                                              s.startsWith('I'),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          numeroOrden = value;
                                                        });
                                                      },
                                                      selectedItem: numeroOrden,
                                                    ),
                                                  );
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Container(
                              //   width: width,
                              //   height: 55.0,
                              //   alignment: Alignment.center,
                              //   padding: EdgeInsets.symmetric(horizontal: 14.0),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     border: Border.all(
                              //       color: Colors.black.withOpacity(0.5),
                              //       width: 1.2,
                              //     ),
                              //     borderRadius: BorderRadius.circular(10),
                              //   ),
                              //   child: TextFormField(
                              //     onChanged: (val) => numeroOrden = val,
                              //     decoration: InputDecoration(
                              //         contentPadding: EdgeInsets.all(1.0),
                              //         labelStyle: TextStyle(
                              //           color: Colors.black,
                              //         ),
                              //         hintText:
                              //             "Ingrese un número de orden si es necesario",
                              //         errorStyle: TextStyle(
                              //             color: Colors.redAccent,
                              //             fontSize: 16.0),
                              //         enabledBorder: OutlineInputBorder(
                              //           borderSide: BorderSide.none,
                              //         ),
                              //         disabledBorder: OutlineInputBorder(
                              //           borderSide: BorderSide.none,
                              //         ),
                              //         border: OutlineInputBorder(
                              //           borderSide: BorderSide.none,
                              //         )),
                              //   ),
                              // ),
                            ]),
                        SizedBox(height: 30.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Razón del reclamo',
                                style: TextStyle(
                                    color: Color(0xFF7F9D9D),
                                    fontSize: 17.0,
                                    fontFamily: 'Product Sans'),
                              ),
                              SizedBox(height: 15.0),
                              Container(
                                width: width,
                                height: 155.0,
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
                                  maxLines: 7,
                                  onChanged: (val) => razonReclamo = val,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(1.0),
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      hintText: "Ingrese la razón del reclamo",
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
                            if (tipoReclamo == null || razonReclamo == null) {
                              String error = "Debes completar todos los campos";
                              // dialogError(context, error);
                            } else {
                              buttonText == "Enviando..."
                                  ? print("Enviando...")
                                  : Container();
                              sendReclamo();
                            }
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

  Future<List<dynamic>> _getData() async {
    try {
      await db
          .collection('TiposReclamo')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((tipoReclamo) {
                  setState(() {
                    tiposReclamo.add(tipoReclamo.id.toString());
                  });
                })
              });
      await db
          .collection('Reclamos')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                setState(() {
                  reclamos = querySnapshot.docs.length + 1;
                })
              });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadingDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 170,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20.0),
                    Text(
                      "Enviando reclamo...",
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

  Future sendReclamo() async {
    _loadingDialog(context);
    try {
      // ignore: unused_local_variable

      setState(() {
        buttonText = "Enviando...";
      });

      await db.collection('Reclamos').doc(productId).set({
        "id": productId,
        "reclamoId": "51" + reclamos.toString(),
        "aliadoId": codigoAliado,
        "reclamo": razonReclamo,
        "numeroOrden": numeroOrden ?? null,
        "tipoReclamo": tipoReclamo,
        "razonReclamo": razonReclamo,
        "descripcion": razonReclamo,
        "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
        "accion": null,
        "status": "Abierto",
        "usuarioAtendio": null,
        "fechaReclamo": FieldValue.serverTimestamp(),
        "fechaCierre": null,
        "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      });
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      String response = "Reclamo enviado";
      dialog(context, response);
      print(response);
      setState(() {
        buttonText = "Enviar reclamo";
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReclamosPage(
                petModel: widget.petModel,
                defaultChoiceIndex: widget.defaultChoiceIndex)),
      );
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> dialog(BuildContext context, String msg) async {
    Navigator.of(context).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              // height: 200,
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
}
