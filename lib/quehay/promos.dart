import 'dart:io';

import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/petfriendly.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/quehay/detallespromos.dart';
import '../Widgets/myDrawer.dart';
import 'package:pet_shop/Models/Promo.dart';

double width;

class PromoHome extends StatefulWidget {
  final PromotionModel promotionModel;
  final PetModel petModel;
  final int defaultChoiceIndex;

  PromoHome({this.petModel, this.promotionModel, this.defaultChoiceIndex});

  @override
  _PromoHomeState createState() => _PromoHomeState();
}

class _PromoHomeState extends State<PromoHome> {
  AliadoModel ali;
  PetModel model;
  PromotionModel pro;
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  File _imageFile;
  bool select = true;
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
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
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
                        "Qué hay hoy",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              select = true;
                            });
                          },
                          minWidth: _screenWidth * 0.4,
                          padding: EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.zero,
                            ),
                          ),
                          child: Text(
                            'Promociones',
                            style: TextStyle(
                                color:
                                    select ? Colors.white : Color(0xFF57419D),
                                fontSize: 16),
                          ),
                          color:
                              select ? Color(0xFF57419D) : Color(0xFFBDD7D6)),
                      SizedBox(
                        width: 10.0,
                      ),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              select = false;
                            });
                          },
                          minWidth: _screenWidth * 0.4,
                          padding: EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Pet Friendly',
                            style: TextStyle(
                                color:
                                    select ? Color(0xFF57419D) : Colors.white,
                                fontSize: 16),
                          ),
                          color:
                              select ? Color(0xFFBDD7D6) : Color(0xFF57419D)),
                    ],
                  ),
                ),
                select == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Promociones")
                                .where("pais",
                                    isEqualTo: PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userPais))
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
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    PromotionModel pro =
                                        PromotionModel.fromJson(dataSnapshot
                                            .data.docs[index]
                                            .data());
                                    return sourceInfo(pro, context);
                                  });
                            }),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Aliados")
                                .where("pais",
                                    isEqualTo: PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userPais))
                                .where('tipoAliado', isEqualTo: 'Pet Friendly')
                                .snapshots(),
                            builder: (context, dataSnapshot) {
                              if (!dataSnapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: dataSnapshot.data.docs.length,
                                  shrinkWrap: true,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    AliadoModel ali = AliadoModel.fromJson(
                                        dataSnapshot.data.docs[index].data());
                                    return sourceInfo2(ali, context);
                                  });
                            }),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    PromotionModel pro,
    BuildContext context,
  ) {
    return InkWell(
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Aliados')
                  .doc(pro.aliadoid)
                  .snapshots(),
              builder: (context, dataSnapshot) {
                if (!dataSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context,
                        index,) {
                      AliadoModel ali =
                      AliadoModel.fromJson(dataSnapshot.data.data());

                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Localidades")
                              .where("aliadoId", isEqualTo: ali.aliadoId)
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 1,
                                shrinkWrap: true,
                                itemBuilder: (context,
                                    index,) {
                                  LocationModel location = LocationModel
                                      .fromJson(
                                      dataSnapshot.data.docs[index].data());
                                  return Container(
                                    height: 150,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 140,
                                          child: Image.network(
                                            pro.urlImagen,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, object,
                                                stacktrace) {
                                              return Container();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 14.0,
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.4,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start,
                                                children: [
                                                  Flexible(
                                                      child: Text(pro.titulo,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                          textAlign: TextAlign
                                                              .left)),
                                                ],
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    if (model == null) {
                                                      {
                                                        showDialog(
                                                            builder: (
                                                                context) =>
                                                            new ChoosePetAlertDialog(
                                                              message:
                                                              "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                                            ),
                                                            context: context);
                                                      }
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                DetallesPromo(
                                                                  petModel: model,
                                                                  promotionModel: pro,
                                                                  aliadoModel: ali,
                                                                  locationModel: location,
                                                                  defaultChoiceIndex: widget
                                                                      .defaultChoiceIndex,
                                                                )),
                                                      );
                                                    }
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(5)),
                                                  color: Color(0xFFEB9448),
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text("Más información",
                                                          style: TextStyle(
                                                              fontFamily: 'Product Sans',
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 18.0)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            );
                          });
                    });
              }),],
      ),
    );
  }

  Widget sourceInfo2(
    AliadoModel ali,
    BuildContext context,
  ) {
    return InkWell(
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    ali.avatar ?? 'Cargando',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.fill,
                    errorBuilder: (context, object, stacktrace) {
                      return Container();
                    },
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          ali.nombre ?? 'Cargando',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF57419D),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ali.direccion ?? 'Cargando',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Teléfono: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Flexible(
                            child: Text(
                              ali.telefono ?? 'Cargando',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  changeAli(Al) {
    setState(() {
      ali = Al;
    });

    return Al;
  }

  changeDet(Det) {
    setState(() {
      pro = Det;
    });

    return Det;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
