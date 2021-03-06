import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:pet_shop/Authentication/map.dart';
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
import 'package:pet_shop/Widgets/ktitle.dart';
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
  List _allResults = [];
  List _resultsList = [];
  GeoPoint userLatLong;
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
    MastersList();
    changePet(widget.petModel);

    _isSelected = false;
    _defaultChoiceIndex = 0;
    getLatLong();
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  MastersList() {
    FirebaseFirestore.instance
        .collection("Aliados")
        .where("pais",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .where("isApproved", isEqualTo: true)
        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(AliadoModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
      for (var tituloSnapshot in _allResults) {
        var tipoAliado = tituloSnapshot.tipoAliado;
        if (tipoAliado == 'Pet Friendly' || tipoAliado == 'Otros lugares Pet Friendly'|| tipoAliado == 'Restaurante o Caf?? Pet Friendly') {
          showResults.add(tituloSnapshot);
        }
      }


    setState(() {
      _resultsList = showResults;
    });
  }

  getLatLong() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Due??os")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        userLatLong = (dataSnapshot["location"]);
      });
    });
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
                    Text(
                      "Promociones",
                      style: TextStyle(
                        color: Color(0xFF57419D),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Container(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       FlatButton(
                //           onPressed: () {
                //             setState(() {
                //               select = true;
                //             });
                //           },
                //           minWidth: _screenWidth * 0.4,
                //           padding: EdgeInsets.all(15.0),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.only(
                //               topLeft: Radius.circular(10.0),
                //               topRight: Radius.zero,
                //               bottomLeft: Radius.circular(10.0),
                //               bottomRight: Radius.zero,
                //             ),
                //           ),
                //           child: Text(
                //             'Promociones',
                //             style: TextStyle(
                //                 color:
                //                     select ? Colors.white : Color(0xFF57419D),
                //                 fontSize: 16),
                //           ),
                //           color:
                //               select ? Color(0xFF57419D) : Color(0xFFBDD7D6)),
                //       SizedBox(
                //         width: 10.0,
                //       ),
                //       FlatButton(
                //           onPressed: () {
                //             setState(() {
                //               select = false;
                //             });
                //           },
                //           minWidth: _screenWidth * 0.4,
                //           padding: EdgeInsets.all(15.0),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.only(
                //               topLeft: Radius.zero,
                //               topRight: Radius.circular(10.0),
                //               bottomLeft: Radius.zero,
                //               bottomRight: Radius.circular(10.0),
                //             ),
                //           ),
                //           child: Text(
                //             'Pet Friendly',
                //             style: TextStyle(
                //                 color:
                //                     select ? Color(0xFF57419D) : Colors.white,
                //                 fontSize: 16),
                //           ),
                //           color:
                //               select ? Color(0xFFBDD7D6) : Color(0xFF57419D)),
                //     ],
                //   ),
                // ),
                select == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Promociones")
                                .where("pais",
                                isEqualTo: PetshopApp.sharedPreferences
                                    .getString(PetshopApp.userPais))

                                .where('isApproved', isEqualTo: true)
                                .orderBy('createdOn', descending: true)
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
                        child: Container(
                                height: 120 * double.parse(_resultsList.length.toString()),
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _resultsList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      return sourceInfo2(_resultsList[index], context);
                                    }),


                            ),

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
                    itemBuilder: (
                      context,
                      index,
                    ) {
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
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  LocationModel location =
                                      LocationModel.fromJson(
                                          dataSnapshot.data.docs[index].data());
                                  return Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)

                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            child: Image.network(
                                              pro.urlImagen,
                                              height: 140,
                                              width: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, object, stacktrace) {
                                                return Container();
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 14.0,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                        child: Text(pro.titulo,
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                            textAlign:
                                                                TextAlign.left)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      if (model == null) {
                                                        {
                                                          showDialog(
                                                              builder: (context) =>
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
                                                              builder: (context) =>
                                                                  DetallesPromo(
                                                                    petModel:
                                                                        model,
                                                                    promotionModel:
                                                                        pro,
                                                                    aliadoModel:
                                                                        ali,
                                                                    locationModel:
                                                                        location,
                                                                    defaultChoiceIndex:
                                                                        widget
                                                                            .defaultChoiceIndex,
                                                                  )),
                                                        );
                                                      }
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5)),
                                                    color: Color(0xFFEB9448),
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text("M??s informaci??n",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Product Sans',
                                                                color:
                                                                    Colors.white,
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
                                    ),
                                  );
                                });
                          });
                    });
              }),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget sourceInfo2(
    AliadoModel ali,
    BuildContext context,
  ) {
    double totalD = 0;
    double rating = 0;
    return InkWell(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Localidades")
              .where("aliadoId",
              isEqualTo: ali.aliadoId)
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
                  LocationModel location =
                  LocationModel.fromJson(dataSnapshot
                      .data.docs[index]
                      .data());
                  if (userLatLong != null &&
                      location.location != null) {
                    totalD = Geolocator.distanceBetween(
                        userLatLong.latitude,
                        userLatLong.longitude,
                        location.location.latitude,
                        location.location.longitude) /
                        1000;
                  }
          return Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)

                ),
                height: 110.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ali.nombreComercial ?? ali.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF57419D),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  location.mapAddress != null
                                      ? Text(
                                      location.mapAddress,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      textAlign:
                                      TextAlign.left)
                                      : Text(
                                      location.mapAddress !=
                                          null
                                          ? location
                                          .mapAddress
                                          : location
                                          .direccionLocalidad,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      textAlign:
                                      TextAlign.left),
                                  Row(
                                    children: [
                                      Text(
                                        'Tel??fono: ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      Flexible(
                                        child: Text(
                                          location.telefonos ?? ali.telefono,
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                totalD != 0
                                    ? Row(

                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapHome(
                                                  petModel: widget.petModel,
                                                  defaultChoiceIndex: widget
                                                      .defaultChoiceIndex,
                                                  locationModel:
                                                  location,
                                                  aliadoModel:
                                                  ali,
                                                  userLatLong:
                                                  userLatLong)),
                                        );
                                      },  child: Icon(
                                      Icons.location_on_rounded,
                                      color: secondaryColor,
                                      size: 28,

                                    ),
                                    ),




                                    Text(
                                        totalD < 500
                                            ? '${totalD.toStringAsFixed(1)} Km'
                                            : '+500 Km',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                        ),
                                        textAlign:
                                        TextAlign.center),
                                  ],
                                )
                                    : Container(),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        rating.toString() != 'NaN'
                                            ? rating
                                            .toStringAsPrecision(
                                            1)
                                            : '0',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.orange),
                                        textAlign:
                                        TextAlign.left),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          );
        }
      );
            }
    ));
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
