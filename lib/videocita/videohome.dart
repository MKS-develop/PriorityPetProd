import 'dart:io';

import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/clinicas.dart';
import 'package:pet_shop/Models/especialidades.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Salud/Citas/citaagenda.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/videocita/videoagenda.dart';

double width;

class VideoHome extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final int defaultChoiceIndex;

  VideoHome(
      {this.petModel,
      this.aliadoModel,
      this.locationModel,
      this.serviceModel,
      this.defaultChoiceIndex});

  @override
  _VideoHomeState createState() => _VideoHomeState();
}

class _VideoHomeState extends State<VideoHome> {
  PetModel model;

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
  }

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
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: _fondo(),
      ),
    );
  }

  Widget _fondo() {
    return Container(
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
        child: Stack(
          children: <Widget>[
            _fondoImagen(),
            _cuerpo(),
          ],
        ),
      ),
    );
  }

  Widget _titulo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF57419D)),
            onPressed: () {
              Navigator.pop(context);
            }),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Text(
            "Videoconsulta",
            style: TextStyle(
              color: Color(0xFF57419D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fondoImagen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 170.0,
            width: 200.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image(
                image: NetworkImage(widget.aliadoModel.avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60.0, 0, 10.0),
      child: Column(
        children: [
          // Text('Los mejores productos', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),),
          // Text('Porque tu mascota se lo merece', style: TextStyle(color: Colors.white, fontSize: 16.0),)
        ],
      ),
    );
  }

  Widget _valor() {
    return Container(
      width: 350,
      height: 30,
      decoration: BoxDecoration(
        color: Color(0xFF57419D),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Agendar videoconsulta',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                PetshopApp.sharedPreferences
                    .getString(PetshopApp.simboloMoneda),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                (widget.serviceModel.precio).toStringAsFixed(2),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaAgenda() {
    return Column(
      children: [
        SizedBox(
          height: 20.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                // Text(
                //   'Agendar cita',
                //   style: TextStyle(fontSize: 13),
                // ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoAgenda(
                                petModel: model,
                                serviceModel: widget.serviceModel,
                                aliadoModel: widget.aliadoModel,
                                locationModel: widget.locationModel,
                              defaultChoiceIndex:
                              widget.defaultChoiceIndex,)),
                      );
                    },
                    child: Image.asset(
                      'diseñador/drawable/Grupo234.png',
                      fit: BoxFit.contain,
                      height: 60,
                    ),
                  ),
                ),
              ],
            ),
            // Column(
            //   children: [
            //     Text(
            //       'Agendar',
            //       style: TextStyle(fontSize: 13),
            //     ),
            //     Text(
            //       'Videoconsulta',
            //       style: TextStyle(fontSize: 13),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(5.0),
            //       child: GestureDetector(
            //         onTap: () {
            //           // Navigator.push(
            //           //   context,
            //           //   MaterialPageRoute(builder: (context) => CitaAgenda(petModel: model, serviceModel: widget.serviceModel,
            //           //       aliadoModel: widget.aliadoModel,
            //           //       locationModel:
            //           //       widget.locationModel, especialidadesModel: widget.especialidadesModel)),
            //           // );
            //         },
            //         child: Image.asset(
            //           'diseñador/drawable/Grupo234.png',
            //           fit: BoxFit.contain,
            //           height: 45,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // Column(
            //   children: [
            //     Text(
            //       'Ubicación',
            //       style: TextStyle(fontSize: 13),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(5.0),
            //       child: GestureDetector(
            //         onTap: () {
            //           // Navigator.push(
            //           //   context,
            //           //   MaterialPageRoute(builder: (context) => StoreHome(petModel: model)),
            //           // );
            //         },
            //         child: Image.asset(
            //           'diseñador/drawable/Grupo197.png',
            //           fit: BoxFit.contain,
            //           height: 45,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     SizedBox(
        //       child: RaisedButton(
        //         onPressed: () {},
        //         color: Color(0xFFBDD7D6),
        //         child: Text(
        //           'Enviar mensaje',
        //           style: TextStyle(color: Color(0xFF5B618F)),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _iconos() {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300.0,
              height: 100.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Alimento";
                  _planModalBottomSheet(context);
                  // Navigator.push(
                  //   context,
                  //
                  //   MaterialPageRoute(builder: (context) => AlimentoHome(petModel: model, tituloDetalle: tituloDetalle)),
                  // );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Color(0xFFF4F6F8),
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(widget.aliadoModel.nombreComercial,
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Text(widget.locationModel.direccionLocalidad,
                        style: TextStyle(fontSize: 12.0)),
                    SizedBox(
                      height: 2.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.aliadoModel.tipoAliado != 'Médico'
                            ? Text(
                                widget.serviceModel.titulo,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(
                                width: 180,
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: db
                                        .collection("Aliados")
                                        .doc(widget.serviceModel.aliadoId)
                                        .collection("Especialidades")
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (dataSnapshot.hasData) {
                                        if (dataSnapshot.data.docs.length ==
                                            0) {
                                          return Center(child: Container());
                                        }
                                      }
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              dataSnapshot.data.docs.length,
                                          shrinkWrap: true,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            EspecialidadesModel especialidades =
                                                EspecialidadesModel.fromJson(
                                                    dataSnapshot
                                                        .data.docs[index]
                                                        .data());
                                            return Row(
                                              children: [
                                                Text(
                                                  especialidades.especialidad,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    }),
                              ),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 30,
                          color: Color(0xFF277EB6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _cuerpo() {
    return Column(
      children: <Widget>[
        _titulo(),
        _menu(),
        _iconos(),
        _valor(),
        _filaAgenda(),
      ],
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });
    return otro;
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              color:
                  Color(0xFF737373), //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor

              child: Container(
                  width: 60.0,
                  height: MediaQuery.of(context).size.height,
                  decoration: new BoxDecoration(
                      color: Color(0xFFEB9448),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          width: 70.0,
                          height: 5.0,
                          child: Image.asset(
                            'diseñador/drawable/Rectangulo308.png',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        widget.aliadoModel.nombreComercial,
                        style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Aliados")
                              .doc(widget.serviceModel.aliadoId)
                              .collection("Especialidades")
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (dataSnapshot.hasData) {
                              if (dataSnapshot.data.docs.length == 0) {
                                return Center(child: Container());
                              }
                            }
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                itemCount: dataSnapshot.data.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  EspecialidadesModel especialidades =
                                      EspecialidadesModel.fromJson(
                                          dataSnapshot.data.docs[index].data());

                                  return Column(
                                    children: [
                                      Text(
                                        especialidades.especialidad,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Certificación: ',
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            especialidades.certificado,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          especialidades.hojaProfesional ==
                                                  'null'
                                              ? especialidades.hojaProfesional
                                              : '',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }),
                      widget.aliadoModel.tipoAliado != 'Médico'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.serviceModel.titulo,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  )));
        });
  }
}
