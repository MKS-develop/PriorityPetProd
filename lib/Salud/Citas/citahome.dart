import 'dart:io';

import 'package:pet_shop/Authentication/map.dart';
import 'package:pet_shop/Chat/ChatPage.dart';
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
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

double width;

class CitaHome extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final int defaultChoiceIndex;
  final GeoPoint userLatLong;

  CitaHome(
      {this.petModel,
      this.aliadoModel,
      this.locationModel,
      this.serviceModel,
      this.defaultChoiceIndex,
      this.userLatLong});

  @override
  _CitaHomeState createState() => _CitaHomeState();
}

class _CitaHomeState extends State<CitaHome> {
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
        bottomNavigationBar: CustomBottomNavigationBar(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: _fondo(),
      ),
    );
  }

  Widget _fondo() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xFFf4f6f8),
      // decoration: new BoxDecoration(
      //   image: new DecorationImage(
      //     colorFilter: new ColorFilter.mode(
      //         Colors.white.withOpacity(0.3), BlendMode.dstATop),
      //     image: new AssetImage("dise??ador/drawable/fondohuesitos.png"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
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
            "Citas",
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
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(widget.aliadoModel.avatar),
                fit: BoxFit.cover,
                errorBuilder: (context, object, stacktrace) {
                  return Container();
                },
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
    return Column(
      children: [
        Container(
          width: 350,
          height: 40,

          decoration: BoxDecoration(
            color: primaryColor,
              borderRadius: BorderRadius.circular(10)

          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Valor de la consulta',
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
        ),
        SizedBox(height: 15),

        Text(widget.serviceModel.descripcion, style: TextStyle(color: textColor),),

        SizedBox(height: 15),

        Container(
          width: 340,
          height: 61,

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)

          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
              width: 85,
                child: Center(
                  child: IconButton(icon: Icon(Icons.calendar_today, color: secondaryColor, size: 29,), onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CitaAgenda(
                              petModel: model,
                              serviceModel: widget.serviceModel,
                              aliadoModel: widget.aliadoModel,
                              locationModel: widget.locationModel,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                              userLatLong: widget.userLatLong)),
                    );
                  }),
                ),
              ),
              widget.locationModel.location != null ?
              Container(
                width: 85,
                child: Center(
                  child: IconButton(icon: Icon(Icons.location_on_rounded, color: secondaryColor, size: 29,), onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapHome(
                              petModel: widget.petModel,
                              defaultChoiceIndex:
                              widget.defaultChoiceIndex,
                              locationModel: widget.locationModel,
                              aliadoModel: widget.aliadoModel,
                              userLatLong: widget.userLatLong)),
                    );
                  }),
                ),
              ): Container(),

              Container(
                width: 85,
                child: Center(
                  child: Transform.rotate(
                    angle: 24.5,
                    child: IconButton(icon: Icon(Icons.send, color: secondaryColor, size: 29,), onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                              petModel: widget.petModel,
                              aliado: widget.aliadoModel.aliadoId,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                      );
                    }),
                  ),
                ),
              ),

            ],
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 340,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Container(
                  width: 85,
                  child: Center(child: Text('Cita', style: TextStyle(color: textColor),))),

              widget.locationModel.location != null ?
              Container(
                  width: 85,
                  child: Center(child: Text('Ubicaci??n', style: TextStyle(color: textColor)))): Container(),

              Container(
                  width: 85,
                  child: Center(child: Text('Mensaje', style: TextStyle(color: textColor)))),
            ],
          ),
        )

      ],
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
                Text(
                  'Agendar cita',
                  style: TextStyle(fontSize: 13),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CitaAgenda(
                                petModel: model,
                                serviceModel: widget.serviceModel,
                                aliadoModel: widget.aliadoModel,
                                locationModel: widget.locationModel,
                                defaultChoiceIndex: widget.defaultChoiceIndex,
                                userLatLong: widget.userLatLong)),
                      );
                    },
                    child: Image.asset(
                      'dise??ador/drawable/Grupo253.png',
                      fit: BoxFit.contain,
                      height: 50,
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
            //           'dise??ador/drawable/Grupo234.png',
            //           fit: BoxFit.contain,
            //           height: 45,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Column(
              children: [

                widget.locationModel.location != null
                    ? Column(
                      children: [
                        Text(
                          'Ubicaci??n',
                          style: TextStyle(fontSize: 13),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapHome(
                                          petModel: widget.petModel,
                                          defaultChoiceIndex:
                                              widget.defaultChoiceIndex,
                                          locationModel: widget.locationModel,
                                          aliadoModel: widget.aliadoModel,
                                          userLatLong: widget.userLatLong)),
                                );
                              },
                              child: Image.asset(
                                'dise??ador/drawable/Grupo197.png',
                                fit: BoxFit.contain,
                                height: 50,
                              ),
                            ),
                          ),
                      ],
                    )
                    : Container(),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              petModel: widget.petModel,
                              aliado: widget.aliadoModel.aliadoId,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                color: Color(0xFFBDD7D6),
                child: Text(
                  'Enviar mensaje',
                  style: TextStyle(color: Color(0xFF57419D)),
                ),
              ),
            ),
          ],
        ),
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
              height: 120.0,
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
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.aliadoModel.nombreComercial,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    SizedBox(
                      height: 2.0,
                    ),
                    Text(
                        widget.locationModel.mapAddress != null
                            ? widget.locationModel.mapAddress
                            : widget.locationModel.direccionLocalidad,
                        style: TextStyle(fontSize: 12.0)),
                    SizedBox(
                      height: 2.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.aliadoModel.tipoAliado != 'M??dico'
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
        // _filaAgenda(),
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
                            'dise??ador/drawable/Rectangulo308.png',
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
                                            'Certificaci??n: ',
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
                      widget.aliadoModel.tipoAliado != 'M??dico'
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
