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

class PetfriendlyHome extends StatefulWidget {
  final PromotionModel promotionModel;
  final PetModel petModel;
  final int defaultChoiceIndex;

  PetfriendlyHome({this.petModel, this.promotionModel, this.defaultChoiceIndex});

  @override
  _PetfriendlyHomeState createState() => _PetfriendlyHomeState();
}

class _PetfriendlyHomeState extends State<PetfriendlyHome> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchTextEditingController = new TextEditingController();
  List<dynamic> ciudades = [];
  String ciudad;
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
  List _pagResults = [];
  bool loading = false, allLoaded = false;
  int cargado = 0;
  String _categoria;

  @override
  void initState() {
    super.initState();
    MastersList(ciudad);
    changePet(widget.petModel);
    getCiudades(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));
    _searchTextEditingController.addListener(_onSearchChanged);
    _allResults = [];

    _isSelected = false;
    _defaultChoiceIndex = 0;
    getLatLong();
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  MastersList(String categoria) {
    FirebaseFirestore.instance
        .collection("Aliados")
        .where("pais",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
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

        var nombreComercial = tituloSnapshot.nombre.toLowerCase();

        if (tipoAliado.contains('Pet Friendly' ) || tipoAliado.contains('Otros lugares Pet Friendly' ) || tipoAliado.contains('Restaurante o Café Pet Friendly' )) {
          if (_searchTextEditingController.text != "") {

            if (nombreComercial.contains(_searchTextEditingController.text.toLowerCase())) {
              showResults.add(tituloSnapshot);
            }
          }
          else{
            showResults.add(tituloSnapshot);
          }

        }
        // else{
        //   showResults = List.from(_allResults);
        // }
      }


    setState(() {
      _resultsList = showResults;
      _pagResults = [];
      cargado = 0;
    });
    if(_resultsList.length<10)
    {
      func(0, _resultsList.length);
    }
    else{
      func(0, 10);
    }
  }
  _onSearchChanged() {
    searchResultsList();
    print(_searchTextEditingController.text);
  }

  getLatLong() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        userLatLong = (dataSnapshot.data()["location"]);
      });
    });
  }
  Future<List<dynamic>> getCiudades(pais) async {
    ciudades = [];
    try {
      await FirebaseFirestore.instance
          .collection('Ciudades')
          .where("paisId",
          isEqualTo:
          PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((paisA) {
          setState(() {
            ciudades = paisA["ciudades"].toList();
          });
        })
      });
      ciudades.sort();
      print(ciudades.length);
    } catch (e) {
      print(e);
    }
    return ciudades;
  }

  @override
  void dispose() {
    _searchTextEditingController.removeListener(_onSearchChanged);
    _searchTextEditingController.dispose();
    _scrollController.removeListener(_onScrollEvent);
    super.dispose();
  }
  void _onScrollEvent() {
    final extentAfter = _scrollController.position.extentAfter;
    // print("Extent after: $extentAfter");
    if(extentAfter<=0 && !loading){
      print('Nueva infoooo: ${_pagResults.length}');
      func(cargado,cargado+10);
    }
  }

  func(int start, int end) {

    setState(() {
      loading = true;
      // _pagResults = [];

    });
    _pagResults = _pagResults + List.from(_resultsList.getRange(start, end).toList());
    loading = false;
    setState(() {
      loading = false;
      print('el loading esta en $loading');
      cargado = cargado + 10;
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text(
                        "Pet Friendly",
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
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: _screenWidth * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.transparent,
                                      // color: Color(0xFF7f9d9D),
                                      width: 1.0,
                                    ),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  margin: EdgeInsets.all(5.0),
                                  child: TextField(
                                    controller: _searchTextEditingController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar aliado Pet Friendly',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Color(0xFF7f9d9D)),
                                    ),
                                    onChanged: (text) {
                                      text = text.toLowerCase();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(295, 15, 0, 0),
                                  margin: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xFF7f9d9D),
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
                // Padding(
                //   padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: _screenWidth * 0.9,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 border: Border.all(
                //                   color: Colors.transparent,
                //                   // color: Color(0xFF7f9d9D),
                //                   width: 1.0,
                //                 ),
                //                 borderRadius:
                //                 BorderRadius.all(Radius.circular(10.0)),
                //               ),
                //               padding: EdgeInsets.all(0.0),
                //               margin: EdgeInsets.all(5.0),
                //               child: DropdownButtonHideUnderline(
                //                 child: Stack(
                //                   children: <Widget>[
                //                     DropdownButton(
                //                         hint: Padding(
                //                           padding: const EdgeInsets.fromLTRB(
                //                               50, 0, 0, 0),
                //                           child: Text(
                //                             'Ciudad',
                //                             style: TextStyle(
                //                                 color: Colors.black,
                //                                 fontWeight: FontWeight.bold),
                //                           ),
                //                         ),
                //                         items: ciudades.map((dynamic value) {
                //                           return DropdownMenuItem<dynamic>(
                //                             value: value,
                //                             child: Padding(
                //                               padding:
                //                               const EdgeInsets.fromLTRB(
                //                                   40, 0, 0, 0),
                //                               child: Text(value),
                //                             ),
                //                           );
                //                         }).toList(),
                //                         isExpanded: true,
                //                         onChanged: (value) {
                //                           setState(() {
                //                             _categoria = value;
                //                             ciudad = value;
                //                             _resultsList = [];
                //                             _allResults = [];
                //                             _pagResults = [];
                //                             MastersList(value);
                //                           });
                //                         },
                //                         value: ciudad),
                //                     Container(
                //                       width: 20,
                //                       margin: EdgeInsets.symmetric(
                //                           vertical: 15, horizontal: 10),
                //                       child: Image.asset(
                //                         'diseñador/drawable/Grupo197.png',
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),


               Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          // color: Colors.blue,
                          height: _screenHeight * 0.59,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    // physics: NeverScrollableScrollPhysics(),
                                    itemCount: _pagResults.length,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      return sourceInfo2(_pagResults[index], context);
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
                              // .where("ciudad", isEqualTo: ciudad)
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
                                                        Text("Más información",
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
                                        'Teléfono: ',
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
