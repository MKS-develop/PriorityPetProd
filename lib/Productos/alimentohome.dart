import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

import 'alimentodetalle.dart';
import 'dart:math' show cos, sqrt, asin;

double width;

class AlimentoHome extends StatefulWidget {
  final PetModel petModel;
  final ProductModel productModel;
  final Producto productoModel;
  final String tituloDetalle;
  final int defaultChoiceIndex;

  AlimentoHome({
    this.petModel,
    this.productModel,
    this.productoModel,
    this.defaultChoiceIndex,
    Key key,
    @required this.tituloDetalle,
  }) : super(key: key);

  @override
  _AlimentoHomeState createState() => _AlimentoHomeState();
}

class _AlimentoHomeState extends State<AlimentoHome> {
  ScrollController _scrollController = ScrollController();
  List _allResults = [];
  List _resultsList = [];
  List _otroResults = [];
  List _pagResults = [];
  bool loading = false, allLoaded = false;
  bool check = false;
  String uid;
  Future resultsLoaded;
  int cargado = 0;

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



  void _onScrollEvent() {
    final extentAfter = _scrollController.position.extentAfter;
    // print("Extent after: $extentAfter");
    if(extentAfter<=0 && !loading){
      print('Nueva infoooo: ${_pagResults.length}');
      func(cargado,cargado+10);
    }
  }
  _scrollListener(){

    if(_scrollController.offset >= _scrollController.position.maxScrollExtent &&_scrollController.position.outOfRange)
      //  if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent)
        {
      print('Nueva infoooo');
      func(11,20);
    }


  }
  @override
  void initState() {

    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    // getAllSnapshots();
    MastersList(_categoria);
    // MastersList2();
    getLatLong();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    // _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_onScrollEvent);
    super.initState();



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
    _scrollController.dispose();
    _scrollController.removeListener(_onScrollEvent);
    // _searchTextEditingController.removeListener(func(0, 10));
    super.dispose();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // resultsLoaded = getCategoriesSnapshots();
  }

  MastersList(String categoria) {
    FirebaseFirestore.instance
        .collection("Productos")
        .where('categoria', isEqualTo: widget.tituloDetalle)
        .where("pais",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .where('tipoMascota', isEqualTo: categoria)

        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(ProductoModel.fromFireStore(Doc));
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
    _pagResults = [];
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


  // mockFetch() async {
  //   if(allLoaded){
  //     return;
  //   }
  //   setState(() {
  //     loading = true;
  //   });
  //   await Future.delayed(Duration(milliseconds: 500));
  //   List newData =_resultsList.length == _pagResults.length ? [] : List.generate(20, (index) => );
  //   if(newData.isNotEmpty){
  //
  //   }
  // }

  _onSearchChanged() {
    searchResultsList();
    print(_searchTextEditingController.text);
  }


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
                        widget.tituloDetalle,
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
                                      hintText: 'Buscar producto por nombre',
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
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: _screenWidth * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("Especies")
                                    .orderBy('createdOn', descending: false)
                                    .snapshots(),
                                builder: (context, dataSnapshot) {
                                  if (!dataSnapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    List<DropdownMenuItem> list = [];
                                    for (int i = 0;
                                        i < dataSnapshot.data.docs.length;
                                        i++) {
                                      DocumentSnapshot document =
                                          dataSnapshot.data.docs[i];
                                      list.add(
                                        DropdownMenuItem(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                50, 0, 0, 0),
                                            child: Text(
                                              document.id,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          value: "${document.id}",
                                        ),
                                      );
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.transparent,
                                          // color: Color(0xFF7f9d9D),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      margin: EdgeInsets.all(5.0),
                                      child: DropdownButtonHideUnderline(
                                        child: Stack(
                                          children: <Widget>[
                                            DropdownButton(
                                                hint: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          50, 0, 0, 0),
                                                  child: Text(
                                                    'Tipo de mascota',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                items: list,
                                                isExpanded: true,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _categoria = value;
                                                    _resultsList = [];
                                                    _allResults = [];
                                                    _pagResults = [];
                                                    print(value);
                                                    MastersList(value);
                                                  });
                                                },
                                                value: _categoria),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                                child: Image.asset(
                                                  'diseñador/drawable/Alimento1/459.png',
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Text(
                //         _categoria != null ? _categoria : 'Nuestra selección',
                //         style: TextStyle(
                //           color: Color(0xFF57419D),
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 3.0,
                ),

                // Container(
                //   height: 180.0,
                //   width: double.infinity,
                // child: Row(
                //   children: [
                _pagResults.length == 0
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
                    : Column(
                      children: [
                        Container(
                          height: _screenHeight * 0.51,
                             // height: 130 * double.parse(_pagResults.length.toString()),
                            child: GridView.builder(
                                controller: _scrollController,
                                itemCount: _pagResults.length,
                                scrollDirection: Axis.vertical,
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1,
                                        childAspectRatio: 0.58),
                                itemBuilder: (
                                  BuildContext context,
                                  int index,
                                ) =>
                                    sourceInfo(context, _pagResults[index])
                            ),
                          ),
                        // loading ?
                        // Center(
                        //   child: Container(
                        //     height: 80,
                        //     child: CupertinoActivityIndicator(),
                        //   ),
                        // ): Container(),

                      ],
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
                // PagedGridView(pagingController: _pagingController, builderDelegate: PagedChildBuilderDelegate<ProductoModel>(
                //     itemBuilder: (
                //   BuildContext context,
                //   int index,
                // ) =>
                //     sourceInfo(context,_resultsList[index])),




                  // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //   crossAxisCount: 2,
                  //   crossAxisSpacing: 1,
                  //   childAspectRatio: 0.58),)
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

  Widget sourceInfo(BuildContext context, ProductoModel product) {
    double totalD = 0;
    // final product = Producto.fromSnapshot(snapshot);
    // DocumentReference documentReference = FirebaseFirestore.instance
    //     .collection("Productos")
    //     .doc(product.productoId)
    //     .collection('Favoritos')
    //     .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    // documentReference.get().then((dataSnapshot) {
    //   setState(() {
    //      check = (dataSnapshot.data()["like"]);
    //   });
    //
    //   print(check);
    // });
    return InkWell(
      child: Column(
        children: [
          Container(
               height: 285.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)

              ),
              width: MediaQuery.of(context).size.width * 0.43,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Aliados')
                      .doc(product.aliadoId)
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
                          return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Localidades")
                                  .where("localidadId",
                                      isEqualTo: product.localidadId)
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

                                      // var totalD = 0;

                                      return ali.isApproved? GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AlimentoDetalle(
                                                        petModel: model,
                                                        productoModel: product,
                                                        aliadoModel: ali,
                                                        defaultChoiceIndex: widget
                                                            .defaultChoiceIndex,
                                                        locationModel:
                                                            location),
                                              ));
                                        },
                                        child: Container(

                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(8, 12, 8, 5),
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(8.0),

                                                  child:
                                                  product.urlImagen != '' ?
                                                  Image.network(
                                                    product.urlImagen,
                                                    height: 150,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        object, stacktrace) {
                                                      return Container();
                                                    },
                                                  ) : Container(
                                                    height: 150,
                                                    decoration: new BoxDecoration(
                                                      image: new DecorationImage(
                                                        image:
                                                        new AssetImage("images/sinproducto.jpg"),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 3.0,
                                              ),
                                              Container(
                                                height: 190.0,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    // mainAxisAlignment:
                                                    //     MainAxisAlignment.spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                          child: Text(
                                                              product.titulo,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left)),
                                                      Flexible(
                                                          child: Text(
                                                              product.dirigido,
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left)),
                                                      // SizedBox(height: 8.0),
                                                      totalD != 0
                                                          ? Container(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 9,
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .location_on_rounded,
                                                                    color:
                                                                        secondaryColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                      totalD <
                                                                              500
                                                                          ? '${totalD.toStringAsFixed(1)} Km'
                                                                          : '+500 Km',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center),
                                                                ],
                                                              ),
                                                            )
                                                          : Container(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                              PetshopApp
                                                                      .sharedPreferences
                                                                      .getString(
                                                                          PetshopApp
                                                                              .simboloMoneda) +
                                                                  product.precio
                                                                      .toStringAsFixed(
                                                                          2),
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0xFF57419D),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(0,0,13,0),
                                                            child: Container(
                                                              height: 32.0,
                                                              width: 30.0,
                                                              child: StreamBuilder<
                                                                      QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Productos')
                                                                      .doc(product
                                                                          .productoId)
                                                                      .collection(
                                                                          'Favoritos')
                                                                      .where(
                                                                          'uid',
                                                                          isEqualTo: PetshopApp
                                                                              .sharedPreferences
                                                                              .getString(PetshopApp
                                                                                  .userUID))
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      dataSnapshot) {
                                                                    if (!dataSnapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      );
                                                                    }
                                                                    if (dataSnapshot
                                                                            .data
                                                                            .docs
                                                                            .length ==
                                                                        0) {
                                                                      return Center(
                                                                          child:
                                                                              Text(
                                                                        '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                5),
                                                                      ));
                                                                    }

                                                                    return ListView
                                                                        .builder(
                                                                            physics:
                                                                                NeverScrollableScrollPhysics(),
                                                                            itemCount:
                                                                                1,
                                                                            shrinkWrap:
                                                                                true,
                                                                            itemBuilder:
                                                                                (
                                                                              context,
                                                                              index,
                                                                            ) {
                                                                              FavoritosModel
                                                                                  favorito =
                                                                                  FavoritosModel.fromJson(dataSnapshot.data.docs[index].data());
                                                                              return Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  IconButton(
                                                                                    icon: favorito.like ? Icon(Icons.favorite) : Icon(Icons.favorite_border_outlined),
                                                                                    color: Color(0xFF57419D),
                                                                                    iconSize: 20,
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        if (favorito.like) {
                                                                                          favorito.like = false;

                                                                                          FirebaseFirestore.instance.collection("Productos").doc(product.productoId).collection('Favoritos').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).set({
                                                                                            'like': false,
                                                                                            'uid': PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
                                                                                          }).then((result) {
                                                                                            print("new USer true");
                                                                                          }).catchError((onError) {
                                                                                            print("onError");
                                                                                          });
                                                                                        } else {
                                                                                          favorito.like = true;

                                                                                          FirebaseFirestore.instance.collection("Productos").doc(product.productoId).collection('Favoritos').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).set({
                                                                                            'like': true,
                                                                                            'uid': PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
                                                                                          }).then((result) {
                                                                                            print("new USer true");
                                                                                          }).catchError((onError) {
                                                                                            print("onError");
                                                                                          });
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                  }),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ): Container();
                                    });
                              });
                        });
                  })),
          // SizedBox(width: 10.0),
        ],
      ),
    );
  }

  Widget sourceInfo2(BuildContext context, ProductoModel product) {
    // var product = Producto.fromSnapshot(document);
    return InkWell(
      child: Row(
        children: [
          Container(
            height: 80.0,
            width: 200.0,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Aliados')
                    .doc(product.aliadoId)
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
                        return ali.isApproved? GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlimentoDetalle(
                                      petModel: model,
                                      productoModel: product,
                                      aliadoModel: ali,
                                      defaultChoiceIndex:
                                          widget.defaultChoiceIndex),
                                ));
                          },
                          child: Container(
                            height: 80.0,
                            width: 185.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFF4F6F8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 40.0,
                                        child: Image.network(
                                          product.urlImagen,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, object, stacktrace) {
                                            return Container();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Container(
                                    height: 60.0,
                                    width: 120.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            child: Text(product.titulo,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.left)),
                                        Flexible(
                                            child: Text(product.tipoMascota,
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left)),
                                        Flexible(
                                            child: Text(product.dirigido,
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left)),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Text(
                                                PetshopApp.sharedPreferences
                                                    .get(PetshopApp
                                                        .simboloMoneda),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.left),
                                            Text(
                                                product.precio
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.left),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ): Container();
                      });
                }),
          ),
          SizedBox(width: 10.0),
        ],
      ),
    );
  }
}
