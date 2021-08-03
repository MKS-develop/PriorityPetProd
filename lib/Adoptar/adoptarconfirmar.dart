import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/expedientechart.dart';
import 'package:pet_shop/Models/temperaturachart.dart';
import 'package:pet_shop/Store/storehome.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'package:pet_shop/Models/expediente.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

double width;

class AdoptarConfirmar extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  AdoptarConfirmar({this.petModel, this.defaultChoiceIndex});

  @override
  _AdoptarConfirmarState createState() => _AdoptarConfirmarState();
}

class _AdoptarConfirmarState extends State<AdoptarConfirmar> {
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
                            "Adopción",
                            style: TextStyle(
                              color: Color(0xFF57419D),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("¡Ya casi estamos listos!",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    SizedBox(
                      height: 15,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.petModel.petthumbnailUrl,
                        height: 150,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: _screenWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text("Gracias por querer adoptarme."),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  "El albergue se comunicará contigo para las evaluaciones y luego podrás tenerme en casa, para darme mucho cariño."),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(3.0),
                            //   child: Text(
                            //       "Tendrás una entrevista y luego podrás tenerme en casa."),
                            // ),
                          ],
                        )),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 200,
                      child: RaisedButton(
                        onPressed: () {
                          Message(context,
                              'Su adopción ha sido procesada correctamente, espere un correo con todos los detalles.');
                          _interesados();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StoreHome(
                                    petModel: widget.petModel,
                                    defaultChoiceIndex:
                                        widget.defaultChoiceIndex)),
                          );
                        },
                        // uploading ? null : ()=> uploadImageAndSavePetInfo(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Color(0xFF57419D),
                        padding: EdgeInsets.all(6.0),
                        child: Text("Confirmar adopción",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 15.0)),
                      ),
                    ),
                  ]),
                ))));
  }

  _interesados() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Mascotas')
        .doc(widget.petModel.mid)
        .collection('Interesados')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "mid": widget.petModel.mid,
      "interesado": true,
    });
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  Future<void> Message(BuildContext context, String error) async {
    // Navigator.of(context, rootNavigator: true).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 55.0),
                    SizedBox(height: 20.0),
                    Text(
                      error,
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
