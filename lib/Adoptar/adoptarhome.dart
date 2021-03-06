import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Adoptar/adoptardetalles.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/favoritos.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/mascotas/registromascota.dart';

class AdoptarHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  AdoptarHome({this.petModel, this.defaultChoiceIndex});

  @override
  _AdoptarHomeState createState() => _AdoptarHomeState();
}

class _AdoptarHomeState extends State<AdoptarHome> {
  PetModel model;
  final db = FirebaseFirestore.instance;
  List _allResults = [];
  List _resultsList = [];
  List _pagResults = [];
  int cargado = 0;
  bool loading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {

    MastersList();
    _scrollController.addListener(_onScrollEvent);
    super.initState();
  }
  void _onScrollEvent() {
    final extentAfter = _scrollController.position.extentAfter;
    // print("Extent after: $extentAfter");
    if(extentAfter<=0 && !loading){
      print('Nueva infoooo: ${_pagResults.length}');
      func(cargado,cargado+10);
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_onScrollEvent);
    // _searchTextEditingController.removeListener(func(0, 10));
    super.dispose();

  }

  MastersList() {
    FirebaseFirestore.instance
        .collection("Mascotas")
        .where("pais",
        isEqualTo: PetshopApp.sharedPreferences
            .getString(PetshopApp.userPais))
        .where("apadrinadoStatus", isEqualTo: false)
        .where("adoptadoStatus", isEqualTo: false)
        .orderBy('createdOn', descending: true)
        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(PetModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    for (var tituloSnapshot in _allResults) {
      // var tipoAliado = tituloSnapshot.tipoAliado;
      // if (tipoAliado == 'Pet Friendly' || tipoAliado == 'Otros lugares Pet Friendly'|| tipoAliado == 'Restaurante o Caf?? Pet Friendly') {
        showResults.add(tituloSnapshot);
      // }
    }


    setState(() {
      _resultsList = showResults;
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
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar:
            CustomBottomNavigationBar(petModel: widget.petModel),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          height: _screenHeight,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.3), BlendMode.dstATop),
              image: new AssetImage("dise??ador/drawable/fondohuesitos.png"),
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
                        "Adopta o apadrina",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      // color: Colors.blue,
                        height: _screenHeight * 0.7,
                      // color: Colors.blue,
                      // width: _screenWidth,
                      child: GridView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _pagResults.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.7),
                        // physics: BouncingScrollPhysics(),
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          return sourceInfo(_pagResults[index], context);
                        },
                      )

                    ),
                  ],
                )],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    PetModel model,
    BuildContext context,
  ) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Container(
          // color: Colors.grey,
          height: 98.0,
          width: 75.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
    Container(
      height: 140.0,
      width: 75.0,
      child: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Aliados')
          .doc(model.aliadoId)
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
              AliadoModel ali = AliadoModel.fromJson(
                  dataSnapshot.data.data());
              return ali.isApproved? GestureDetector(
                onTap: () {
                  var likeRef = db.collection("Mascotas").doc(model.mid);
                  likeRef.update({
                    'views': FieldValue.increment(1),
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdoptarDetalles(
                                petModel: model,
                                defaultChoiceIndex: widget.defaultChoiceIndex, aliadoModel: ali,)),
                  );
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        model.petthumbnailUrl,
                        height: 90,
                        width: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, object, stacktrace) {
                          return Container();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(model.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF57419D), fontSize: 11)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 17,
                              color: Color(0xFF7F9D9D),
                            ),
                            Text(
                                model.views != null
                                    ? model.views.toString()
                                    : '0',
                                style: TextStyle(color: Color(0xFF7F9D9D))),
                          ],
                        ),
                        Container(
// color: Colors.purple,
                          height: 30.0,
                          width: 40.0,

                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Mascotas')
                                  .doc(model.mid)
                                  .collection('Favoritos')
                                  .where('uid',
                                  isEqualTo: PetshopApp
                                      .sharedPreferences
                                      .getString(PetshopApp.userUID))
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (!dataSnapshot.hasData) {
                                  return Row(
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  );
                                }
                                if (dataSnapshot.data.docs.length < 1) {
                                  return Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.favorite_border_outlined,
                                        size: 17,
                                        color: Color(0xFF7F9D9D),
                                      ),
                                    ],
                                  );
                                }

                                return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: 1,
                                    shrinkWrap: true,
                                    itemBuilder: (context,
                                        index,) {
                                      FavoritosModel favorito =
                                      FavoritosModel.fromJson(
                                          dataSnapshot.data.docs[index]
                                              .data());
                                      return Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            icon: favorito.like
                                                ? Icon(Icons.favorite)
                                                : Icon(Icons
                                                .favorite_border_outlined),
                                            color: Color(0xFF57419D),
                                            iconSize: 17,
                                            onPressed: () {
                                              setState(() {
                                                if (favorito.like) {
                                                  favorito.like = false;

                                                  FirebaseFirestore.instance
                                                      .collection(
                                                      'Mascotas')
                                                      .doc(model.mid)
                                                      .collection(
                                                      'Favoritos')
                                                      .doc(PetshopApp
                                                      .sharedPreferences
                                                      .getString(
                                                      PetshopApp
                                                          .userUID))
                                                      .set({
                                                    'like': false,
                                                    'uid': PetshopApp
                                                        .sharedPreferences
                                                        .getString(
                                                        PetshopApp
                                                            .userUID),
                                                  }).then((result) {
                                                    print("new USer true");
                                                  }).catchError((onError) {
                                                    print("onError");
                                                  });
                                                } else {
                                                  favorito.like = true;

                                                  FirebaseFirestore.instance
                                                      .collection(
                                                      'Mascotas')
                                                      .doc(model.mid)
                                                      .collection(
                                                      'Favoritos')
                                                      .doc(PetshopApp
                                                      .sharedPreferences
                                                      .getString(
                                                      PetshopApp
                                                          .userUID))
                                                      .set({
                                                    'like': true,
                                                    'uid': PetshopApp
                                                        .sharedPreferences
                                                        .getString(
                                                        PetshopApp
                                                            .userUID),
                                                  }).then((result) {
                                                    print("new USer true");
                                                  }).catchError((onError) {
                                                    print("onError");
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            height: 100,
                                          ),
                                        ],
                                      );
                                    });
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ) : Container();
            }
        );
      }),
    )],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
