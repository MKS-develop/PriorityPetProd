import 'dart:io';

import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Salud/Citas/citaspage.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/videocita/videocita.dart';
import 'package:pet_shop/videocita/videopage.dart';
import '../Widgets/myDrawer.dart';
import 'package:pet_shop/Salud/Expediente/historiamedica.dart';

import '../main.dart';
import 'Clinicas/clinicaspage.dart';

double width;

class SaludHome extends StatefulWidget {
  final PetModel petModel;
  SaludHome({this.petModel});

  @override
  _SaludHomeState createState() => _SaludHomeState();
}

class _SaludHomeState extends State<SaludHome> {
  PetModel model;
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  File _imageFile;

  @override
  void initState() {
    super.initState();

    changePet(widget.petModel);

    _isSelected = false;
    _defaultChoiceIndex = 0;
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
                        "Salud",
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
                  height: 30.0,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Localidades")
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container(
                        child: ListView.builder(
                            itemCount: 1,
                            shrinkWrap: true,
                            itemBuilder: (
                                context,
                                index,
                                ) {
                              LocationModel location = LocationModel.fromJson(
                                  dataSnapshot.data.docs[index].data());
                              return SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CitasPage(
                                              petModel: model,
                                              locationModel: location)),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFFEB9448),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                          'diseñador/drawable/Salud/Grupo87.png'),
                                      SizedBox(
                                        width: 15.0,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text("Citas",
                                              style: TextStyle(
                                                  fontFamily: 'Product Sans',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0)),
                                          Text("Haz una cita facil y rápida",
                                              style: TextStyle(
                                                  fontFamily: 'Product Sans',
                                                  color: Colors.white,
                                                  fontSize: 15.0)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    }),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoPage(petModel: model)),
                      );
                      // showDialog(
                      //     context: context,
                      //     child: new ChoosePetAlertDialog(
                      //       message:
                      //           "Esta función estará disponible próximamente...",
                      //     ));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Color(0xFFEB9448),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image.asset('diseñador/drawable/Salud/Grupo90.png'),
                        SizedBox(
                          width: 15.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Videoconsultas",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)),
                            Text("Consulta online con los especialistas",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontSize: 15.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HistoriaMedica(petModel: model)),
                      );
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Color(0xFFEB9448),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image.asset(
                            'diseñador/drawable/Servicios/Grupo364.png'),
                        SizedBox(
                          width: 15.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Expediente médico",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)),
                            Text("Ten al día el expediente de tu mascota",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontSize: 15.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ClinicasPage(petModel: model)),
                      );
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Color(0xFFEB9448),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image.asset('diseñador/drawable/Salud/Grupo85.png'),
                        SizedBox(
                          width: 15.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Clínicas",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)),
                            Text("Listado de clínicas disponibles",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontSize: 15.0)),
                          ],
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

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
