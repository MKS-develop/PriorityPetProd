import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/clinicas.dart';
import 'package:pet_shop/Salud/Clinicas/clinicasdetalle.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'package:pet_shop/Models/expediente.dart';

double width;

class ClinicasPage extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  ClinicasPage({this.petModel, this.defaultChoiceIndex});

  @override
  _ClinicasPageState createState() => _ClinicasPageState();
}

class _ClinicasPageState extends State<ClinicasPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController _searchTextEditingController =
      new TextEditingController();
  String _categoria;
  List _allResults = [];
  List _resultsList = [];
  Future resultsLoaded;
  List<dynamic> ciudades = [];
  String ciudad;

  PetModel model;
  ExpedienteModel exp;
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  File _imageFile;
  bool select = false;
  bool uploading = false;

  String petImageUrl = "";
  String downloadUrl = "";

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    // getAllSnapshots();
    MastersList();
    getCiudades(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));
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

  MastersList() {
    FirebaseFirestore.instance
        .collection("Aliados")
        .where('tipoAliado', isEqualTo: "Clinica")
        .where("pais",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .where("ciudad", isEqualTo: _categoria)
        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(ClinicasModel.fromFirestore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    if (_searchTextEditingController.text != "") {
      for (var tituloSnapshot in _allResults) {
        var titulo = tituloSnapshot.nombre.toLowerCase();
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
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar: CustomBottomNavigationBar(),
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
                        "Clínicas",
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
                                      color: Color(0xFF7f9d9D),
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
                                Container(
                                    padding: EdgeInsets.fromLTRB(320, 12, 0, 0),
                                    margin: EdgeInsets.all(5.0),
                                    child: Image.asset(
                                      'diseñador/drawable/Alimento1/search1.png',
                                    )),
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
                            // StreamBuilder<QuerySnapshot>(
                            //     stream: FirebaseFirestore.instance
                            //         .collection("Ciudades")
                            //         .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
                            //         .collection("Ciudades")
                            //         .snapshots(),
                            //     builder: (context, dataSnapshot) {
                            //       if (!dataSnapshot.hasData) {
                            //         return Center(
                            //           child: CircularProgressIndicator(),
                            //         );
                            //       } else {
                            //         List<DropdownMenuItem> list = [];
                            //         for (int i = 0;
                            //         i < dataSnapshot.data.docs.length;
                            //         i++) {
                            //           DocumentSnapshot product =
                            //           dataSnapshot.data.docs[i];
                            //
                            //           list.add(
                            //             DropdownMenuItem(
                            //               child: Padding(
                            //                 padding: const EdgeInsets.fromLTRB(
                            //                     50, 0, 0, 0),
                            //                 child: Text(
                            //                   product.id,
                            //                   style: TextStyle(
                            //                       color: Colors.black,
                            //                       fontWeight: FontWeight.bold),
                            //                 ),
                            //               ),
                            //               value: "${product.id}",
                            //             ),
                            //           );
                            //         }
                            //         return Container(
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             border: Border.all(
                            //               color: Color(0xFF7f9d9D),
                            //               width: 1.0,
                            //             ),
                            //             borderRadius: BorderRadius.all(
                            //                 Radius.circular(10.0)),
                            //           ),
                            //           padding: EdgeInsets.all(0.0),
                            //           margin: EdgeInsets.all(5.0),
                            //           child: DropdownButtonHideUnderline(
                            //             child: Stack(
                            //               children: <Widget>[
                            //                 DropdownButton(
                            //                     hint: Padding(
                            //                       padding:
                            //                       const EdgeInsets.fromLTRB(
                            //                           50, 0, 0, 0),
                            //                       child: Text(
                            //                         'Ciudad',
                            //                         style: TextStyle(
                            //                             color: Colors.black,
                            //                             fontWeight:
                            //                             FontWeight.bold),
                            //                       ),
                            //                     ),
                            //                     items: list,
                            //                     isExpanded: true,
                            //                     onChanged: (value) {
                            //                       setState(() {
                            //                         _categoria = value;
                            //                       });
                            //                     },
                            //                     value: _categoria),
                            //                 Container(
                            //                     width: 20,
                            //                     margin: EdgeInsets.symmetric(
                            //                         vertical: 15,
                            //                         horizontal: 10),
                            //                     child: Image.asset(
                            //                       'diseñador/drawable/Grupo197.png',
                            //                     )),
                            //               ],
                            //             ),
                            //           ),
                            //         );
                            //       }
                            //     }),

                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              height: 99 *
                                  double.parse(_resultsList.length.toString()),
                              width: _screenWidth,
                              child: Container(
                                child: ListView.builder(
                                    itemCount: _resultsList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) =>
                                        sourceInfo(
                                            context, _resultsList[index])),
                              ),
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

  Widget sourceInfo(BuildContext context, ClinicasModel clinica) {
    // var clinica = ClinicasModel.fromSnapshot(document);

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClinicasDetalle(
                          petModel: model,
                          clinicasModel: clinica,
                        )),
              );
            },
            child: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clinica.nombreComercial,
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF57419D),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          clinica.avatar,
                          width: 70.0,
                          height: 70.0,
                          fit: BoxFit.fill,
                          errorBuilder: (context, object, stacktrace) {
                            return Container();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinica.direccion,
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.left),
                          Text(clinica.pais,
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.left),
                          // Row(
                          //   children: [
                          //     Flexible(child: Text(clinica.ciudad, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
                          //     Flexible(child: Text(clinica.pais, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
                          //   ],
                          // ),
                          // Flexible(child: Text(clinica.horario, style: TextStyle(fontSize: 13), textAlign: TextAlign.left)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
