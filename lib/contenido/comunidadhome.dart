import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Models/contenido.dart';
import 'package:pet_shop/Models/favoritos.dart';
import 'package:pet_shop/Models/location.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Models/prod.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'package:pet_shop/Models/expediente.dart';


import 'dart:math' show cos, sqrt, asin;

import 'contenidohome.dart';

double width;

class ComunidadHome extends StatefulWidget {
  final PetModel petModel;
  final ProductModel productModel;
  final Producto productoModel;
  final String tituloDetalle;
  final int defaultChoiceIndex;

  ComunidadHome({
    this.petModel,
    this.productModel,
    this.productoModel,
    this.defaultChoiceIndex,
    Key key,
    @required this.tituloDetalle,
  }) : super(key: key);

  @override
  _ComunidadHomeState createState() => _ComunidadHomeState();
}

class _ComunidadHomeState extends State<ComunidadHome> {
  List _allResults = [];
  List _resultsList = [];
  List _otroResults = [];


  String uid;
  Future resultsLoaded;

  DateTime selectedDate = DateTime.now();
  String _categoria;
  TextEditingController _searchTextEditingController =
      new TextEditingController();

  ProductModel product;
  Producto producto;
  PetModel model;
  ExpedienteModel exp;

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  GeoPoint userLatLong;

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    // getAllSnapshots();
    MastersList(_categoria);
    MastersList2();
    getLatLong();
  }

  getLatLong() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        userLatLong = (dataSnapshot["location"]);
      });
    });
  }

  @override
  void dispose() {
    _searchTextEditingController.removeListener(_onSearchChanged);
    _searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // resultsLoaded = getCategoriesSnapshots();
  }

  MastersList(String categoria) {
    FirebaseFirestore.instance
        .collection("Contenido")
        .where("pais",
        isEqualTo: PetshopApp.sharedPreferences
            .getString(PetshopApp.userPais))
        .where("isApproved", isEqualTo: true)
        .orderBy('createdOn', descending: true)
        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(ContenidoModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  MastersList2() {
    FirebaseFirestore.instance
        .collection("Productos")
        .where('categoria', isEqualTo: widget.tituloDetalle)
        .where("pais",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .where('tipoMascota', isEqualTo: _categoria)
        .snapshots()
        .listen(createListofServices2);
  }

  createListofServices2(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _otroResults.add(ProductoModel.fromFireStore(Doc));
      });
    }
  }

  searchResultsList() {
    var showResults = [];
    if (_searchTextEditingController.text != "") {
      for (var tituloSnapshot in _allResults) {
        var titulo = tituloSnapshot.titulo.toLowerCase();
        if (titulo.contains(_searchTextEditingController.text.toLowerCase())) {
          showResults.add(tituloSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  _onSearchChanged() {
    searchResultsList();
    print(_searchTextEditingController.text);
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
        bottomNavigationBar: CustomBottomNavigationBar(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          height: _screenHeight,
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
                       'Comunidad',
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
                                    autocorrect: true,
                                    controller: _searchTextEditingController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      icon: new Icon(Icons.search),

                                      hintText: 'Buscar',
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                // Container(
                //   height: 180.0,
                //   width: double.infinity,
                // child: Row(
                //   children: [
                _resultsList.length == 0
                    ? Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: _screenHeight * 0.3,
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                image:
                                    new AssetImage("images/perritotriste.png"),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                          ),
                          Text(
                            'No disponible',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        child: ListView.builder(
                            itemCount: _resultsList.length,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (
                              BuildContext context,
                              int index,
                            ) =>
                                sourceInfo(context, _resultsList[index])),
                      ),
                //   ],
                // ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Text(
                //         "Otros productos",
                //         style: TextStyle(
                //           color: Color(0xFF57419D),
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 5.0,
                // ),
                // Container(
                //   height: 90.0,
                //   width: double.infinity,
                //   child: Row(
                //     children: [
                //       StreamBuilder<QuerySnapshot>(
                //           stream: FirebaseFirestore.instance
                //               .collection("Productos")
                //               .where('categoria',
                //                   isEqualTo: widget.tituloDetalle)
                //               .snapshots(),
                //           builder: (context, dataSnapshot) {
                //             if (!dataSnapshot.hasData) {
                //               return Center(
                //                 child: CircularProgressIndicator(),
                //               );
                //             }
                //             return Container(
                //               child: Expanded(
                //                 child: ListView.builder(
                //                     itemCount: _otroResults.length,
                //                     scrollDirection: Axis.horizontal,
                //                     shrinkWrap: true,
                //                     itemBuilder: (
                //                       BuildContext context,
                //                       int index,
                //                     ) =>
                //                         sourceInfo2(
                //                             context, _otroResults[index])),
                //               ),
                //             );
                //           }),
                //     ],
                //   ),
                // ),
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


  sourceInfo(BuildContext context, ContenidoModel contenido) {
    double totalD = 0;
    int comments = 0;

    // bool check;
    // // final product = Producto.fromSnapshot(snapshot);
    // DocumentReference documentReference = FirebaseFirestore.instance
    //     .collection("Contenido")
    //     .doc(contenido.postId)
    //     .collection('Likes')
    //     .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    // documentReference.get().then((dataSnapshot) {
    //   setState(() {
    //      check = (dataSnapshot.data()["like"]);
    //   });
    // });
    // var comments = db.collection("Contenido").doc(contenido.postId)
    //     .collection('Comentarios').snapshots().length.toString();




  // Future<QuerySnapshot> productCollection  = Firestore.instance.collection("Contenido").doc(contenido.postId)
  //       .collection('Comentarios').get();
    FirebaseFirestore.instance
        .collection("Contenido").doc(contenido.postId)
        .collection('Comentarios')
        .get()
        .then((QuerySnapshot querySnapshot) {

       comments = querySnapshot.docs.length;

      print(querySnapshot.docs.length);
    });




    return InkWell(
      child: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Aliados')
                  .doc(contenido.aliadoId)
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
                      AliadoModel ali =
                          AliadoModel.fromJson(dataSnapshot.data.data());

                                  // var totalD = 0;
                      return ali.isApproved? GestureDetector(
                                    onTap: () {
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => ContenidoHome(
                                        petModel: model,
                                        contenidoModel: contenido,
                                        aliadoModel: ali,
                                        defaultChoiceIndex: widget.defaultChoiceIndex,
                                        )),
                                        );
                                    },
                                    child: Container(
                                      height: 125.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)

                                      ),
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 75,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(8.0),

                                                    child: Image.network(
                                                      contenido.urlImagen,
                                                      height: 70,
                                                      width: 70,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          object, stacktrace) {
                                                        return Container();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 3.0,
                                                ),
                                                Container(
                                                  height: 75.0,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(4, 8, 0, 0),
                                                    child: Column(
                                                      // mainAxisAlignment:
                                                      //     MainAxisAlignment.spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                            child: Text(
                                                                contenido.titulo,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left)),
                                                        // SizedBox(height: 1,),
                                                        Flexible(
                                                            child: Text(
                                                                contenido.descripcion,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: textColor,
                                                                    fontSize: 12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left)),
                                                        // SizedBox(height: 8.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                                            child: Divider(color: textColor,),
                                          ),

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: 15,),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(5, 0, 1, 8),
                                                    child: Icon(Icons.favorite, color: primaryColor,),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
                                                    child: Text(contenido.likes.toString(),
                                                        style: TextStyle(
                                                            color: primaryColor)),
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(5, 0, 1, 8),
                                                    child: Icon(Icons.comment_outlined, color: primaryColor,),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
                                                    child: Text(comments.toString(), style: TextStyle(color: primaryColor)),
                                                  ),
                                                  SizedBox(width: 15,),
                                                ],
                                              ),


                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ) : Container();
                                });


              }),
           SizedBox(height: 10.0),
        ],
      ),
    );
  }


}
