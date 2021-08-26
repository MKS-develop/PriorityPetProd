import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/clinicas.dart';
import 'package:pet_shop/Models/especialidades.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Salud/Citas/citaagenda.dart';
import 'package:pet_shop/Salud/Citas/citahome.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'package:pet_shop/Models/expediente.dart';

double width;

class CitasPage extends StatefulWidget {
  final PetModel petModel;
  final LocationModel locationModel;
  final ClinicasModel clinicasModel;
  final tituloCat;
  final int defaultChoiceIndex;

  CitasPage(
      {this.petModel,
      this.locationModel,
      this.tituloCat,
      this.clinicasModel,
      this.defaultChoiceIndex});

  @override
  _CitasPageState createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  List<dynamic> ciudades = [];
  String ciudad;
  DateTime selectedDate = DateTime.now();
  TextEditingController _searchTextEditingController =
      new TextEditingController();

  String _categoria;
  List _allResults = [];
  List _resultsList = [];
  Future resultsLoaded;
  static List<ServiceModel> finalServicesList = [];

  PetModel model;
  ExpedienteModel exp;

  bool select = false;
  bool uploading = false;

  String petImageUrl = "";
  String downloadUrl = "";
  GeoPoint userLatLong;
  double totalDist;

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    finalServicesList = [];
    getCiudades(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));
    MastersList();
    getLatLong();
    if (widget.tituloCat != null) {
      _searchTextEditingController.value =
          TextEditingValue(text: widget.tituloCat);
    }
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;

    totalDist = 12742 * asin(sqrt(a));

    // return 12742 * asin(sqrt(a));
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

  MastersList() async {
    // print('la vaina esss ${widget.clinicasModel.aliadoId}');
    if (widget.clinicasModel == null) {
      List list_of_locations = await FirebaseFirestore.instance
          .collection("Localidades")
          .where("serviciosContiene", isEqualTo: true)
          .where("pais", isEqualTo:
                  PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
          .where("ciudad", isEqualTo: _categoria)
          // .where("aliadoId", isEqualTo: widget.clinicasModel.aliadoId)
          .get()
          .then((val) => val.docs);

      for (int i = 0; i < list_of_locations.length; i++) {
        FirebaseFirestore.instance
            .collection("Localidades")
            .doc(list_of_locations[i].documentID.toString())
            .collection("Servicios")
            .where("categoria", isEqualTo: "Salud")
            .where("titulo", isNotEqualTo: "Videoconsulta",)


            .snapshots()
            .listen(CreateListofServices);
      }
      return list_of_locations;
    }
    if (widget.clinicasModel != null) {
      List list_of_locations = await FirebaseFirestore.instance
          .collection("Localidades")
          .where("serviciosContiene", isEqualTo: true)
          .where("ciudad", isEqualTo: _categoria)
          .where("aliadoId", isEqualTo: widget.clinicasModel.aliadoId)
          .get()
          .then((val) => val.docs);
      for (int i = 0; i < list_of_locations.length; i++) {
        FirebaseFirestore.instance
            .collection("Localidades")
            .doc(list_of_locations[i].documentID.toString())
            .collection("Servicios")
            .where("categoria", isEqualTo: "Salud")
            .snapshots()
            .listen(CreateListofServices);
      }
      return list_of_locations;
    }
  }

  CreateListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        finalServicesList.add(ServiceModel.fromFireStore(Doc));
        _allResults.add(ServiceModel.fromFireStore(Doc));
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

  final db = FirebaseFirestore.instance;

  // getCategoriesSnapshots() async {
  //   var data = await db
  //       .collection("Aliados")
  //       .where('tipoAliado', isEqualTo: "Médico")
  //       // .where('ciudad', isEqualTo: _categoria)
  //       .getDocuments();
  //   setState(() {
  //     _allResults = data.documents;
  //   });
  //   searchResultsList();
  //   return data.documents;
  // }

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
                        "Citas",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: _screenWidth * 0.9,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Stack(
                //               children: [
                //                 Container(
                //                   decoration: BoxDecoration(
                //                     color: Colors.white,
                //                     border: Border.all(
                //                       color: Color(0xFF7f9d9D),
                //                       width: 1.0,
                //                     ),
                //                     borderRadius:
                //                         BorderRadius.all(Radius.circular(10.0)),
                //                   ),
                //                   padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                //                   margin: EdgeInsets.all(5.0),
                //                   child: TextField(
                //                     controller: _searchTextEditingController,
                //                     keyboardType: TextInputType.text,
                //                     decoration: InputDecoration(
                //                       hintText: 'Buscar veterinario',
                //                       border: InputBorder.none,
                //                       hintStyle: TextStyle(
                //                           fontSize: 15.0,
                //                           color: Color(0xFF7f9d9D)),
                //                     ),
                //                     onChanged: (value) {
                //                       value = value.toLowerCase();
                //                       setState(() {});
                //                     },
                //                   ),
                //                 ),
                //                 Container(
                //                     padding: EdgeInsets.fromLTRB(320, 12, 0, 0),
                //                     margin: EdgeInsets.all(5.0),
                //                     child: Image.asset(
                //                       'diseñador/drawable/Alimento1/search1.png',
                //                     )),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Text(userLatLong.latitude.toString()),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: _screenWidth * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("CategoriasServicios")
                                    .doc('Salud')
                                    .collection('Servicios')
                                    .where('categoriaId', isEqualTo: 'Salud')
                                    // .orderBy('createdOn', descending: false)
                                    .snapshots(),
                                builder: (context, dataSnapshot) {
                                  if (!dataSnapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    List<String> list = [];
                                    for (int i = 0;
                                        i < dataSnapshot.data.docs.length;
                                        i++) {
                                      DocumentSnapshot razas =
                                          dataSnapshot.data.docs[i];
                                      list.add(
                                        razas.id,
                                      );
                                    }
                                    return Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(0xFF7f9d9D),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      margin: EdgeInsets.all(5.0),
                                      child: DropdownSearch<String>(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          hintStyle: TextStyle(
                                            fontSize: 16.0,
                                            // color: Color(0xFF7f9d9D)
                                          ),
                                          disabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabled: false,
                                          border: InputBorder.none,
                                        ),
                                        mode: Mode.BOTTOM_SHEET,
                                        maxHeight: 300,

                                        // searchBoxController:
                                        //     _searchTextEditingController,
                                        // popupBackgroundColor: Colors.amber,
                                        // searchBoxDecoration: InputDecoration(
                                        //   fillColor: Colors.blue,
                                        // ),
                                        hint: "Buscar servicio",
                                        showSearchBox: true,
                                        showSelectedItem: true,
                                        // showClearButton: true,
                                        items: list,
                                        // label: "Buscar servicio",

                                        popupItemDisabled: (String s) =>
                                            s.startsWith('I'),
                                        onChanged: (value) {
                                          setState(() {
                                            _searchTextEditingController.text =
                                                value;
                                          });
                                        },
                                        selectedItem:
                                            _searchTextEditingController.text,
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

                // StreamBuilder<QuerySnapshot>(
                //     stream: FirebaseFirestore.instance
                //         .collection("CategoriasServicios")
                //         .doc('Salud')
                //         .collection('Servicios')
                //         .where('categoriaId', isEqualTo: 'Salud')
                //         .snapshots(),
                //     builder: (context, dataSnapshot) {
                //       if (!dataSnapshot.hasData) {
                //         return Center(
                //           child: CircularProgressIndicator(),
                //         );
                //       } else {
                //         List<String> cat = [];
                //         for (int i = 0;
                //         i < dataSnapshot.data.docs.length;
                //         i++) {
                //           DocumentSnapshot categoria =
                //           dataSnapshot.data.documents[i];
                //
                //           cat.add(
                //             categoria.documentID,
                //           );
                //         }
                //         return Padding(
                //           padding: const EdgeInsets.all(10.0),
                //           child: Container(
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               border: Border.all(
                //                 color: Color(0xFF7f9d9D),
                //                 width: 1.0,
                //               ),
                //               borderRadius:
                //               BorderRadius.all(Radius.circular(10.0)),
                //             ),
                //             child: DropDownField(
                //               controller: _searchTextEditingController,
                //               hintText: 'Buscar servicio',
                //               hintStyle: TextStyle(
                //                   fontSize: 15.0,
                //                   color: Color(0xFF7f9d9D),
                //                   fontWeight: FontWeight.normal),
                //               icon: Padding(
                //                 padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //                 child: Image.asset(
                //                   'diseñador/drawable/Alimento1/search1.png',
                //                 ),
                //               ),
                //               enabled: true,
                //
                //               onValueChanged: (value) {
                //                 value = value.toLowerCase();
                //                 setState(() {
                //                   // _searchTextEditingController = value;
                //                 });
                //               },
                //               textStyle: TextStyle(
                //                   backgroundColor: Colors.transparent,
                //                   fontWeight: FontWeight.bold),
                //               items: cat,
                //             ),
                //           ),
                //         );
                //       }
                //     }),
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: _screenWidth * 0.9,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFF7f9d9D),
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
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          50, 0, 0, 0),
                                                      child: Text(
                                                        'Ciudad',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    items: ciudades
                                                        .map((dynamic value) {
                                                      return DropdownMenuItem<
                                                          dynamic>(
                                                        value: value,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  40, 0, 0, 0),
                                                          child: Text(value),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    isExpanded: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _categoria = value;
                                                        ciudad = value;
                                                        _allResults = [];
                                                        _resultsList = [];
                                                        MastersList();
                                                      });
                                                    },
                                                    value: _categoria),
                                                Container(
                                                  width: 20,
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 10),
                                                  child: Image.asset(
                                                    'diseñador/drawable/Grupo197.png',
                                                  ),
                                                ),
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
                            SizedBox(
                              height: 5.0,
                            ),
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
                                            image: new AssetImage(
                                                "images/perritotriste.png"),
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
                                    height: 99 *
                                        double.parse(
                                            _resultsList.length.toString()),
                                    // child: Expanded(
                                    child: Container(
                                      height: _screenHeight,
                                      width: _screenWidth,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: _resultsList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return sourceInfo2(
                                                _resultsList[index], context);
                                          }),
                                    ),
                                    // ),
                                  ),
                          ],
                        ),
                      ),
                    ],
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

  // Widget sourceInfo(BuildContext context, DocumentSnapshot document) {
  //   final clinica = ClinicasModel.fromSnapshot(document);
  //
  //   return InkWell(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Container(
  //         height: 90.0,
  //         width: MediaQuery.of(context).size.width,
  //         child: GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => CitaHome(petModel: model)),
  //             );
  //           },
  //           child: Container(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [],
  //                 ),
  //                 SizedBox(
  //                   height: 5,
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(8.0),
  //                       child: Image.network(
  //                         clinica.avatar,
  //                         width: 75.0,
  //                         height: 75.0,
  //                         fit: BoxFit.fill,
  //                         errorBuilder: (context, object, stacktrace) {
  //                           return Container();
  //                         },
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 8.0,
  //                     ),
  //                     Container(
  //                       width: MediaQuery.of(context).size.width * 0.6,
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(clinica.nombreComercial,
  //                               maxLines: 2,
  //                               style: TextStyle(
  //                                   fontSize: 17, fontWeight: FontWeight.bold),
  //                               textAlign: TextAlign.left),
  //                           Text(clinica.locacion,
  //                               style: TextStyle(fontSize: 12),
  //                               textAlign: TextAlign.left),
  //                           Text(clinica.pais,
  //                               style: TextStyle(fontSize: 12),
  //                               textAlign: TextAlign.left),
  //                           SizedBox(
  //                             height: 5,
  //                           ),
  //                           StreamBuilder<QuerySnapshot>(
  //                               stream: FirebaseFirestore.instance
  //                                   .collection("Aliados")
  //                                   .doc(clinica.aliadoId)
  //                                   .collection("Especialidades")
  //                                   .snapshots(),
  //                               builder: (context, dataSnapshot) {
  //                                 if (!dataSnapshot.hasData) {
  //                                   return Center(
  //                                     child: CircularProgressIndicator(),
  //                                   );
  //                                 }
  //                                 return Container(
  //                                   width: 100,
  //                                   child: ListView.builder(
  //                                       physics: NeverScrollableScrollPhysics(),
  //                                       itemCount:
  //                                           dataSnapshot.data.docs.length,
  //                                       shrinkWrap: true,
  //                                       itemBuilder: (
  //                                         context,
  //                                         index,
  //                                       ) {
  //                                         EspecialidadesModel especialidades =
  //                                             EspecialidadesModel.fromJson(
  //                                                 dataSnapshot.data.docs[index]
  //                                                     .data());
  //                                         return Column(
  //                                           children: [
  //                                             Text(
  //                                               especialidades.especialidad,
  //                                               style: TextStyle(
  //                                                 color: Colors.grey,
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         );
  //                                       }),
  //                                 );
  //                               }),
  //
  //                           // Row(
  //                           //   children: [
  //                           //     Flexible(child: Text(clinica.ciudad, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
  //                           //     Flexible(child: Text(clinica.pais, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
  //                           //   ],
  //                           // ),
  //                           // Flexible(child: Text(clinica.horario, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

  Widget sourceInfo2(
    ServiceModel servicio,
    BuildContext context,
  ) {
    double totalD = 0;
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

                  // calculateDistance(userLatLong.latitude, userLatLong.longitude, location.location.latitude, location.location.longitude);
                  if (userLatLong != null && location.location != null) {
                    totalD = Geolocator.distanceBetween(
                            userLatLong.latitude,
                            userLatLong.longitude,
                            location.location.latitude,
                            location.location.longitude) /
                        1000;
                  }
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
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CitaHome(
                                            petModel: model,
                                            serviceModel: servicio,
                                            aliadoModel: aliado,
                                            locationModel: location,
                                            defaultChoiceIndex:
                                                widget.defaultChoiceIndex,
                                            userLatLong: userLatLong)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              aliado.avatar,
                                              width: 75.0,
                                              height: 80.0,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                height: 92,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            aliado
                                                                .nombreComercial,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign:
                                                                TextAlign.left),
                                                        location.mapAddress !=
                                                                null
                                                            ? Text(
                                                                location
                                                                    .mapAddress,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left)
                                                            : Text(
                                                                location
                                                                    .direccionLocalidad,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left),
                                                      ],
                                                    ),
                                                    StreamBuilder<
                                                            QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Aliados")
                                                            .doc(servicio
                                                                .aliadoId)
                                                            .collection(
                                                                "Especialidades")
                                                            .snapshots(),
                                                        builder: (context,
                                                            dataSnapshot) {
                                                          if (dataSnapshot
                                                              .hasData) {
                                                            if (dataSnapshot
                                                                    .data
                                                                    .docs
                                                                    .length ==
                                                                0) {
                                                              return Center(
                                                                  child:
                                                                      Container());
                                                            }
                                                          }
                                                          if (!dataSnapshot
                                                              .hasData) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          }
                                                          return ListView
                                                              .builder(
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemCount:
                                                                      dataSnapshot
                                                                          .data
                                                                          .docs
                                                                          .length,
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemBuilder: (
                                                                    context,
                                                                    index,
                                                                  ) {
                                                                    EspecialidadesModel
                                                                        especialidades =
                                                                        EspecialidadesModel.fromJson(dataSnapshot
                                                                            .data
                                                                            .docs[index]
                                                                            .data());

                                                                    return Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          especialidades
                                                                              .especialidad,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                        }),
                                                    aliado.tipoAliado !=
                                                            'Médico'
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                servicio.titulo,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                              totalD != 0
                                                  ? SizedBox(
                                                      child: Column(
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
                                                            height: 3,
                                                          ),
                                                          Text(
                                                              totalD < 500
                                                                  ? '${totalD.toStringAsFixed(1)} Km'
                                                                  : '+500 Km',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      )),
                                ),
                              );
                            });
                      });
                });
          }),
    );
  }
}
