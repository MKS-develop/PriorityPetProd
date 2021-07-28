import 'dart:io';

import 'package:age/age.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/expedientechart.dart';
import 'package:pet_shop/Models/temperaturachart.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Widgets/customTextIconField.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'package:pet_shop/Models/expediente.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

double width;

class HistoriaAdopcion extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  HistoriaAdopcion({this.petModel, this.defaultChoiceIndex});

  @override
  _HistoriaAdopcionState createState() => _HistoriaAdopcionState();
}

class _HistoriaAdopcionState extends State<HistoriaAdopcion> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _datePeso = new TextEditingController();
  final TextEditingController _dateTemp = new TextEditingController();
  final TextEditingController _dateEste = new TextEditingController();
  final TextEditingController _dateVacu = new TextEditingController();
  final TextEditingController _dateAler = new TextEditingController();
  final TextEditingController _datePat = new TextEditingController();
  final TextEditingController _textPeso = new TextEditingController();
  final TextEditingController _textTemp = new TextEditingController();
  final TextEditingController _textEste = new TextEditingController();
  final TextEditingController _dateDesparasitacion =
      new TextEditingController();

  String _pat = "";
  String _aler = "";
  String _vacu = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<charts.Series<ExpedienteChart, String>> _seriesBarData;
  List<ExpedienteChart> mydata;

  _generateData(mydata) {
    _seriesBarData = List<charts.Series<ExpedienteChart, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (ExpedienteChart expe, _) =>
            DateFormat('dd-MM-yyyy').format(expe.fechaPeso.toDate()),
        measureFn: (ExpedienteChart expe, _) => expe.peso,
        fillColorFn: (ExpedienteChart expe, _) =>
            charts.ColorUtil.fromDartColor(Color(0xFF57419D)),
        id: 'ExpedienteChart',
        data: mydata,
      ),
    );
  }

  List<charts.Series<TemperaturaChart, String>> _seriesBarData2;
  List<TemperaturaChart> mydata2;

  _generateData2(mydata2) {
    _seriesBarData2 = List<charts.Series<TemperaturaChart, String>>();
    _seriesBarData2.add(
      charts.Series(
        domainFn: (TemperaturaChart temperaturaChart, _) =>
            DateFormat('dd-MM-yyyy')
                .format(temperaturaChart.fechaTemperatura.toDate()),
        measureFn: (TemperaturaChart temperaturaChart, _) =>
            temperaturaChart.temperatura,
        fillColorFn: (TemperaturaChart temperaturaChart, _) =>
            charts.ColorUtil.fromDartColor(Color(0xFF57419D)),
        id: 'TemperaturaChart',
        data: mydata2,
      ),
    );
  }

  PetModel model;
  ExpedienteModel exp;
  bool select = true;
  bool uploading = false;
  bool peso = false;
  bool temperatura = false;
  bool desparasitacion = false;
  bool vacunas = false;
  bool alergias = false;
  bool patologias = false;
  bool castrado = false;

  String petImageUrl = "";
  String downloadUrl = "";

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _pat = " ";
    _aler = " ";
    _vacu = " ";
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    // DateTime birthday = widget.petModel.fechanac.toDate();
    // DateTime today = DateTime.now(); //2020/1/24
    // AgeDuration age;
    // age = Age.dateDifference(
    //     fromDate: birthday, toDate: today, includeToDate: false);
    //
    // print(age.years);
    // print(DateFormat('yyyy-MM-dd').format(widget.petModel.fechanac.toDate()));
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
                height: MediaQuery.of(context).size.height,
                // decoration: new BoxDecoration(
                //   image: new DecorationImage(
                //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
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
                            "Expediente médico",
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: Column(children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle = "Peso (Kg)";
                                      setState(() {
                                        peso = true;
                                      });

                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => PesoDetalle(petModel: model, tituloDetalle: tituloDetalle,)),
                                      // );
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/peso.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Peso",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        peso == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    peso = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    peso = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              peso == true
                                  ? Container(
                                      height: 200,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('Expedientes')
                                            .doc(widget.petModel.mid)
                                            .collection('Peso')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return LinearProgressIndicator();
                                          } else {
                                            List<ExpedienteChart> expediente =
                                                snapshot.data.docs
                                                    .map((documentSnapshot) =>
                                                        ExpedienteChart.fromMap(
                                                            documentSnapshot
                                                                .data()))
                                                    .toList();

                                            return _buildChart(
                                                context, expediente);
                                          }
                                        },
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle = "Temperatura (°C)";
                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => TempDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                      setState(() {
                                        temperatura = true;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/temperatura.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Temperatura",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        temperatura == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    temperatura = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    temperatura = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              temperatura == true
                                  ? Container(
                                      height: 200,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('Expedientes')
                                            .doc(widget.petModel.mid)
                                            .collection('Temperatura')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return LinearProgressIndicator();
                                          } else {
                                            List<TemperaturaChart>
                                                temperaturachart = snapshot
                                                    .data.docs
                                                    .map((documentSnapshot) =>
                                                        TemperaturaChart
                                                            .fromMap(
                                                                documentSnapshot
                                                                    .data()))
                                                    .toList();

                                            return _buildChart2(
                                                context, temperaturachart);
                                          }
                                        },
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle = "Desparasitación";
                                      setState(() {
                                        desparasitacion = true;
                                      });

                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/despa.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Desparasitación",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        desparasitacion == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    desparasitacion = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    desparasitacion = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              desparasitacion == true
                                  ? Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Fecha',
                                            style: TextStyle(
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                              stream: db
                                                  .collection("Expedientes")
                                                  .doc(widget.petModel.mid)
                                                  .collection("Desparasitacion")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: dataSnapshot
                                                        .data.documents.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      ExpedienteModel exp =
                                                          ExpedienteModel
                                                              .fromJson(
                                                                  dataSnapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .data());
                                                      return Column(
                                                        children: [
                                                          Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(exp
                                                                      .fechaDesparasitacion
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Color(
                                                                      0xFF7F9D9D))),
                                                        ],
                                                      );
                                                    });
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle = "Vacunas";
                                      setState(() {
                                        vacunas = true;
                                      });

                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/vacunas.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Vacunas",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        vacunas == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    vacunas = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    vacunas = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              vacunas == true
                                  ? Container(
                                      child: Column(
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: db
                                                  .collection("Expedientes")
                                                  .doc(widget.petModel.mid)
                                                  .collection("Vacunas")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: dataSnapshot
                                                        .data.documents.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      ExpedienteModel exp =
                                                          ExpedienteModel
                                                              .fromJson(
                                                                  dataSnapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .data());
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            exp.vacuna,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Color(
                                                                    0xFF7F9D9D),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(exp
                                                                      .fechaVacuna
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Color(
                                                                      0xFF7F9D9D))),
                                                        ],
                                                      );
                                                    });
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        alergias = true;
                                      });
                                      String tituloDetalle = "Alergias";
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/alergia.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Alergias",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        alergias == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    alergias = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    alergias = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              alergias == true
                                  ? Container(
                                      child: Column(
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: db
                                                  .collection("Expedientes")
                                                  .doc(widget.petModel.mid)
                                                  .collection("Alergias")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: dataSnapshot
                                                        .data.docs.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      ExpedienteModel exp =
                                                          ExpedienteModel
                                                              .fromJson(
                                                                  dataSnapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .data());
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            exp.alergia,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Color(
                                                                    0xFF7F9D9D),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(exp
                                                                      .fechaAlergia
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Color(
                                                                      0xFF7F9D9D))),
                                                        ],
                                                      );
                                                    });
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle = "Patologías";
                                      setState(() {
                                        patologias = true;
                                      });

                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/pato.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Patologías",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        patologias == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    patologias = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    patologias = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              patologias == true
                                  ? Container(
                                      child: Column(
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: db
                                                  .collection("Expedientes")
                                                  .doc(widget.petModel.mid)
                                                  .collection("Patologias")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: dataSnapshot
                                                        .data.documents.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      ExpedienteModel exp =
                                                          ExpedienteModel
                                                              .fromJson(
                                                                  dataSnapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .data());
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            exp.patologia,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Color(
                                                                    0xFF7F9D9D),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(exp
                                                                      .fechaPatologia
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Color(
                                                                      0xFF7F9D9D))),
                                                        ],
                                                      );
                                                    });
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: _screenWidth,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String tituloDetalle =
                                          "Esterilizado/Castrado";
                                      // Navigator.push(
                                      //   context,
                                      //
                                      //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                      // );
                                      setState(() {
                                        castrado = true;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Color(0xFF57419D),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'diseñador/drawable/Salud/castrado.png'),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Esterilizado/Castrado",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Product Sans',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        castrado == false
                                            ? IconButton(
                                                icon: Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    castrado = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.remove_rounded,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    castrado = false;
                                                  });
                                                }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              castrado == true
                                  ? Container(
                                      child: Column(
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: db
                                                  .collection("Expedientes")
                                                  .doc(widget.petModel.mid)
                                                  .collection("Esterilizacion")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: dataSnapshot
                                                        .data.documents.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      ExpedienteModel exp =
                                                          ExpedienteModel
                                                              .fromJson(
                                                                  dataSnapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .data());
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            exp.esteril,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Color(
                                                                    0xFF7F9D9D),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(exp
                                                                      .fechaEsteril
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Color(
                                                                      0xFF7F9D9D))),
                                                        ],
                                                      );
                                                    });
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ]),
                          ),
                        ]),
                  ]),
                ))));
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  Widget _buildChart(BuildContext context, List<ExpedienteChart> expe) {
    mydata = expe;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 400.0,
        width: double.infinity,
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData,
                  animate: true,
                  animationDuration: Duration(seconds: 2),
                  barGroupingType: charts.BarGroupingType.groupedStacked,
                  defaultRenderer: new charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart2(
      BuildContext context, List<TemperaturaChart> temperaturachart) {
    mydata2 = temperaturachart;
    _generateData2(mydata2);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 400.0,
        width: double.infinity,
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData2,
                  animate: true,
                  animationDuration: Duration(seconds: 2),
                  barGroupingType: charts.BarGroupingType.groupedStacked,
                  defaultRenderer: new charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _selectDatePeso(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _datePeso.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateDesparasitacion(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateDesparasitacion.value =
            TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateTemp(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateTemp.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateEste(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateEste.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateVacu(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateVacu.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateAler(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateAler.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDatePat(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = DateFormat('dd-MM-yyyy').format(picked).toString();
        _datePat.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }
}
