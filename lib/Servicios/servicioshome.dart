import 'package:geolocator/geolocator.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Servicios/serviciopage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'detalleservicio.dart';
import 'dart:math' show cos, sqrt, asin;

double width;

class ServiciosHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  ServiciosHome({this.petModel, this.defaultChoiceIndex});

  @override
  _ServiciosHomeState createState() => _ServiciosHomeState();
}

class _ServiciosHomeState extends State<ServiciosHome> {
  PetModel model;
  ServiceModel servicio;
  TextEditingController _searchTextEditingController =
      new TextEditingController();
  List _allResults = [];
  List _resultsList = [];
  static List<ServiceModel> finalServicesList = [];
  Future resultsLoaded;
  GeoPoint userLatLong;

  @override
  void initState() {
    super.initState();
    MastersList();
    _searchTextEditingController.addListener(_onSearchChanged);
    _allResults = [];
    finalServicesList = [];
    changePet(widget.petModel);
    getLatLong();
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

  @override
  void dispose() {
    _searchTextEditingController.removeListener(_onSearchChanged);
    _searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  MastersList() async {
    List list_of_locations = await FirebaseFirestore.instance
        .collection("Localidades")
        .where("serviciosContiene", isEqualTo: true)
        .where("pais",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais))

        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list_of_locations.length; i++) {
      FirebaseFirestore.instance
          .collection("Localidades")
          .doc(list_of_locations[i].documentID.toString())
          .collection("Servicios")
          .where("categoria", isNotEqualTo: "Salud")

          .snapshots()
          .listen(CreateListofServices);
    }
    return list_of_locations;
  }

  CreateListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        finalServicesList.add(ServiceModel.fromFireStore(Doc));
        _allResults.add(ServiceModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchTextEditingController.text != "") {
      for (ServiceModel tituloSnapshot in _allResults) {
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
      //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
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
            "Servicios",
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
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: SizedBox(
        height: 220.0,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(
            image: AssetImage('diseñador/drawable/Servicios/pruebafondo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60.0, 0, 10.0),
      child: Column(
        children: [
          Text(
            'Servicios de primera calidad',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            'Consiente a tu mascota',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
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
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            margin: EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _searchTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: '¿Qué buscas?',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 15.0, color: Color(0xFF7f9d9D)),
                              ),
                              onChanged: (text) {
                                text = text.toLowerCase();
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(220, 15, 0, 0),
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
        ],
      ),
    );
  }

  Widget _iconos() {
    return Column(
      children: [
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Exámenes y Estudios";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicioPage(
                            petModel: model,
                            tituloDetalle: tituloDetalle,
                            defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'assets/images/examen.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Exámenes y Estudios",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Cuidado de Mascotas";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicioPage(
                            petModel: model,
                            tituloDetalle: tituloDetalle,
                            defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'assets/images/cuidado.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Cuidado de Mascotas",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Entrenamiento";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicioPage(
                            petModel: model,
                            tituloDetalle: tituloDetalle,
                            defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'assets/images/entrenamiento.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Entrenamiento",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Recreación";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicioPage(
                            petModel: model,
                            tituloDetalle: tituloDetalle,
                            defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.0,
                      child: Image.asset(
                        'assets/images/recreacion.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Recreación",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Otros servicios";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicioPage(
                            petModel: model,
                            tituloDetalle: tituloDetalle,
                            defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.0,
                      child: Image.asset(
                        'assets/images/otro.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Otros servicios",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cuerpo() {
    return Column(
      children: <Widget>[
        _titulo(),
        _menu(),
        _searchTextEditingController.text.isEmpty
            ? _iconos()
            : Container(
                height: 102 * double.parse(_resultsList.length > 10 ? '10' : _resultsList.length.toString()),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Expanded(
                      child: Container(
                        height:
                            102 * double.parse(_resultsList.length > 10 ? '10' : _resultsList.length.toString()),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _resultsList.length > 10 ? 10 : _resultsList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return sourceInfo2(_resultsList[index], context);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _search() {
    Container(
      height: 102 * double.parse(_resultsList.length.toString()),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: Container(
              height: 102 * double.parse(_resultsList.length.toString()),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _resultsList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return sourceInfo2(_resultsList[index], context);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget sourceInfo2(ServiceModel servicio, BuildContext context) {
    double totalD = 0;
    double rating = 0;

    return InkWell(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Localidades")
              .where("localidadId", isEqualTo: servicio.localidadId)
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
                  LocationModel location = LocationModel.fromJson(
                      dataSnapshot.data.docs[index].data());
                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Aliados")
                          .where("aliadoId", isEqualTo: location.aliadoId)
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
                              AliadoModel aliado = AliadoModel.fromJson(
                                  dataSnapshot.data.docs[index].data());
                              if (location.location != null) {
                                totalD = Geolocator.distanceBetween(
                                    userLatLong.latitude,
                                    userLatLong.longitude,
                                    location.location.latitude,
                                    location.location.longitude) /
                                    1000;
                              }
                              if (aliado.totalRatings != null) {
                                rating =
                                    aliado.totalRatings / aliado.countRatings;
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetallesServicio(
                                            petModel: model,
                                            serviceModel: servicio,
                                            aliadoModel: aliado,
                                            defaultChoiceIndex:
                                                widget.defaultChoiceIndex,
                                            locationModel: location,
                                            userLatLong: userLatLong)),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 8, 2, 8),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)

                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 1.0,
                                                    spreadRadius: 0.0,
                                                    offset: Offset(2.0,
                                                        2.0), // shadow direction: bottom right
                                                  )
                                                ],
                                              ),
                                              child: Image.network(
                                                aliado.avatar,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, object, stacktrace) {
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                              height: 73,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(aliado.nombreComercial,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Color(0xFF57419D),
                                                              fontWeight:
                                                                  FontWeight.bold),
                                                          textAlign:
                                                              TextAlign.left),
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
                                                    ],
                                                  ),
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
                                            ),
                                            totalD != 0
                                                ? SizedBox(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 9,
                                                        ),
                                                        Icon(
                                                          Icons.location_on_rounded,
                                                          color: secondaryColor,
                                                        ),
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                            totalD < 500
                                                                ? '${totalD.toStringAsFixed(1)} Km'
                                                                : '+500 Km',
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                            textAlign:
                                                                TextAlign.center),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      });
                });
          }),
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
