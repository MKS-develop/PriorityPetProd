import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../../Widgets/myDrawer.dart';
import 'package:pet_shop/Models/expediente.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

double width;

class ConsultaDetalle extends StatefulWidget {
  final PetModel petModel;
  final String tituloDetalle;
  final int defaultChoiceIndex;

  ConsultaDetalle({
    this.petModel,
    this.defaultChoiceIndex,
    Key key,
    @required this.tituloDetalle,
  }) : super(key: key);

  @override
  _ConsultaDetalleState createState() => _ConsultaDetalleState();
}

class _ConsultaDetalleState extends State<ConsultaDetalle> {
  DateTime selectedDate = DateTime.now();
  ExpedienteModel expedienteModel;
  PetModel model;
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
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Text(
                    widget.tituloDetalle,
                    style: TextStyle(
                      color: Color(0xFF57419D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("Expedientes")
                        .where('mid', isEqualTo: widget.petModel.mid)
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          itemCount: dataSnapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            ExpedienteModel exp = ExpedienteModel.fromJson(
                                dataSnapshot.data.docs[index].data());
                            String tituloDetalle = widget.tituloDetalle;
                            return sourceInfo(exp, tituloDetalle, context);
                          });
                    }),
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

  Widget sourceInfo(
    ExpedienteModel exp,
    String tituloDetalle,
    BuildContext context,
  ) {
    if (tituloDetalle == 'Peso (Kg)') {}

    return InkWell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tituloDetalle == 'Peso (Kg)' ? exp.peso : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Peso (Kg)'
                    ? DateFormat('yyyy-MM-dd').format(exp.fechaPeso.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Temperatura (°C)'
                    ? exp.temperatura.toString()
                    : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Temperatura (°C)'
                    ? DateFormat('yyyy-MM-dd')
                        .format(exp.fechaTemperatura.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Desparasitación'
                    ? DateFormat('yyyy-MM-dd')
                        .format(exp.fechaDesparasitacion.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Vacunas' ? exp.vacuna : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Vacunas'
                    ? DateFormat('yyyy-MM-dd').format(exp.fechaVacuna.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Alergias' ? exp.alergia : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Alergias'
                    ? DateFormat('yyyy-MM-dd').format(exp.fechaAlergia.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Patologías' ? exp.patologia : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Patologías'
                    ? DateFormat('yyyy-MM-dd')
                        .format(exp.fechaPatologia.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
              Text(
                tituloDetalle == 'Esterilizado/Castrado' ? exp.esteril : '',
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF7F9D9D),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                tituloDetalle == 'Esterilizado/Castrado'
                    ? DateFormat('yyyy-MM-dd').format(exp.fechaEsteril.toDate())
                    : '',
                style: TextStyle(fontSize: 14.0, color: Color(0xFF7F9D9D)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
