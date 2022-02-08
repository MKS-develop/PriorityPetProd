import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Beneficios/planeshome.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/beneficios.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

double width;

class BeneficiosHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  BeneficiosHome({this.petModel, this.defaultChoiceIndex});

  @override
  _BeneficiosHomeState createState() => _BeneficiosHomeState();
}

class _BeneficiosHomeState extends State<BeneficiosHome> {
  PetModel model;

  BeneficiosModel bene;
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  File _imageFile;
  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    DocumentReference documentReference = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("planes")
        .doc("Basico");
    documentReference.get().then((dataSnapshot) {});
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
                        "Beneficios",
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                      child: RaisedButton(
                        onPressed: () {
                          _planModalBottomSheet(context);
                          changePet(model);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Color(0xFF277eb6),
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Ver plan",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 160.0,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: db
                              .collection("Dueños")
                              .doc(PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userUID))
                              .collection("planes")
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      dataSnapshot.data.docs[0]['id'],
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 160.0,
                                      child: FlatButton(
                                        onPressed: () {},
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        color: Color(0xFF57419D),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dataSnapshot.data
                                                  .docs[0]['Cantidad_mascotas']
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              ' mascotas',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }),
                    ),
                    Container(
                      width: 160.0,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Tienes disponibles',
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 160.0,
                                child: FlatButton(
                                    onPressed: () {},
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    color: Color(0xFF57419D),
                                    child: Text(
                                      "xxx pet points",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("Dueños")
                        .doc(PetshopApp.sharedPreferences
                            .getString(PetshopApp.userUID))
                        .collection("planes")
                        .doc("Basico")
                        .collection("beneficios")
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
                            BeneficiosModel bene = BeneficiosModel.fromJson(
                                dataSnapshot.data.docs[index].data());
                            return sourceInfo(bene, context);
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

  Widget sourceInfo(BeneficiosModel bene, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: Image.asset(
                        'diseñador/drawable/Beneficios/Grupo317.png',
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              bene.titulo,
                              style: TextStyle(
                                color: Color(0xFF57419D),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              bene.cantidad,
                              style: TextStyle(
                                  fontSize: 14.0, color: Color(0xFF7F9D9D)),
                            ),
                            Text(
                              bene.descripcion,
                              style: TextStyle(
                                  fontSize: 14.0, color: Color(0xFF7F9D9D)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      bene.disponible,
                      style: TextStyle(
                        color: Color(0xFF57419D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' disponible',
                      style: TextStyle(
                        color: Color(0xFF57419D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * .60,

            color: Color(0xFF737373), //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor

            child: StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection("Dueños")
                    .doc(PetshopApp.sharedPreferences
                        .getString(PetshopApp.userUID))
                    .collection("planes")
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return new Container(
                      width: 60.0,
                      decoration: new BoxDecoration(
                          color: Color(0xFF57419D),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  dataSnapshot.data.docs[0]['id'],
                                  style: TextStyle(
                                    color: Color(0xFFEB9448),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: db
                                  .collection("Dueños")
                                  .doc(PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userUID))
                                  .collection("planes")
                                  .doc("Basico")
                                  .collection("beneficios")
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
                                      BeneficiosModel bene =
                                          BeneficiosModel.fromJson(dataSnapshot
                                              .data.docs[index]
                                              .data());
                                      return sourceListInfo(bene, context);
                                    });
                              }),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              onPressed: () {
                                _goPlanes();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              color: Color(0xFFEB9448),
                              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Actualizar plan",
                                      style: TextStyle(
                                          fontFamily: 'Product Sans',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ));
                }),
          );
        });
  }

  Widget sourceListInfo(BeneficiosModel bene, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.fromLTRB(25, 0, 18, 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    bene.cantidad,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    bene.descripcion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goPlanes() {
    Route route = MaterialPageRoute(
        builder: (c) => PlanesHome(
            petModel: model, defaultChoiceIndex: widget.defaultChoiceIndex));
    Navigator.pushReplacement(context, route);
  }

  idplan() {
    DocumentReference documentReference = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("planes")
        .doc("Basico");
    documentReference.get().then((dataSnapshot) {
      print(dataSnapshot["id"]);
      String Pid = dataSnapshot["id"];
      print(pid);
      return Pid;
    });
  }
}
