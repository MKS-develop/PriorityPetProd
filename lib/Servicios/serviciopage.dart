import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Servicio.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Servicios/detalleservicio.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'serviciodetalle.dart';

double width;

class ServicioPage extends StatefulWidget {
  final PetModel petModel;
  final String tituloDetalle;
  final ServicioModel servicioModel;
  final ServiceModel serviceModel;

  ServicioPage(
      {this.petModel,
        this.servicioModel,
        this.serviceModel,
        Key key,
        @required this.tituloDetalle})
      : super(key: key);

  @override
  _ServicioPageState createState() => _ServicioPageState();
}

class _ServicioPageState extends State<ServicioPage> {
  List<dynamic> ciudades = [];
  String ciudad;
  List _allResults = [];
  List _resultsList = [];
  static List<ServiceModel> finalServicesList = [];
  Future resultsLoaded;

  DateTime selectedDate = DateTime.now();
  String _categoria;
  TextEditingController _searchTextEditingController =
  new TextEditingController();

  ServiceModel servicio;
  PetModel model;



  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    _allResults = [];
    finalServicesList = [];
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
  }

  MastersList() async {

    List list_of_locations = await FirebaseFirestore.instance
        .collection("Localidades")
        .where("serviciosContiene", isEqualTo: true)
        .where("pais", isEqualTo: PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .where("ciudad", isEqualTo: ciudad)
        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list_of_locations.length; i++) {
      FirebaseFirestore.instance
          .collection("Localidades")
          .doc(list_of_locations[i].documentID.toString())
          .collection("Servicios")
          .where("categoria", isEqualTo: widget.tituloDetalle)
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

  // getCategoriesSnapshots() async {
  //   var data = await db.collection("Servicios")
  //       .where('categoria', isEqualTo: widget.tituloDetalle)
  //       .where('ciudad', isEqualTo: _categoria)
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
        appBar: AppBarCustomAvatar(context, widget.petModel),
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: MyDrawer(),
        body: Container(
          height: _screenHeight,
          decoration: new BoxDecoration(
            image: new DecorationImage(
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
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("CategoriasServicios")
                        .doc(widget.tituloDetalle)
                        .collection('Servicios')
                        .where('categoriaId', isEqualTo: widget.tituloDetalle)
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        List<String> cat = [];
                        for (int i = 0;
                        i < dataSnapshot.data.docs.length;
                        i++) {
                          DocumentSnapshot categoria =
                          dataSnapshot.data.docs[i];

                          cat.add(
                            categoria.id,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xFF7f9d9D),
                                width: 1.0,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: DropDownField(
                              controller: _searchTextEditingController,
                              hintText: 'Buscar servicio',
                              hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xFF7f9d9D),
                                  fontWeight: FontWeight.normal),
                              icon: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Image.asset(
                                  'diseñador/drawable/Alimento1/search1.png',
                                ),
                              ),
                              enabled: true,
                              onValueChanged: (value) {
                                value = value.toLowerCase();
                                setState(() {
                                  // _searchTextEditingController = value;
                                });
                              },
                              textStyle: TextStyle(
                                  backgroundColor: Colors.transparent,
                                  fontWeight: FontWeight.bold),
                              items: cat,
                            ),
                          ),
                        );
                      }
                    }),

                // Padding(
                //   padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //
                //       Container(
                //         width: _screenWidth*0.9,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Stack(
                //               children: [
                //                 Container(
                //                   decoration: BoxDecoration(
                //                     color: Colors.white,
                //                     border: Border.all(color: Color(0xFF7f9d9D), width: 1.0,),
                //                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //                   ),
                //                   padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                //                   margin: EdgeInsets.all(5.0),
                //                   child: TextField(
                //
                //                     controller: _searchTextEditingController,
                //
                //                     keyboardType: TextInputType.text,
                //                     decoration: InputDecoration(
                //                       hintText: 'Buscar',
                //                       border: InputBorder.none,
                //                       hintStyle: TextStyle(fontSize: 15.0, color: Color(0xFF7f9d9D)),
                //                     ),
                //
                //                     onChanged: (text) {
                //                       text = text.toLowerCase();
                //                       setState(() {
                //                       });
                //                     },
                //                   ),
                //                 ),
                //                 Container(
                //                     padding: EdgeInsets.fromLTRB(320, 12, 0, 0),
                //                     margin: EdgeInsets.all(5.0),
                //                     child:  Image.asset('diseñador/drawable/Alimento1/search1.png',)),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

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
                                          padding:
                                          const EdgeInsets.fromLTRB(
                                              50, 0, 0, 0),
                                          child: Text(
                                            'Ciudad',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                        items: ciudades.map((dynamic value) {
                                          return DropdownMenuItem<dynamic>(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
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
                                          vertical: 15, horizontal: 10),
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
                // Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 10.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //
                //         FormField<dynamic>(
                //           builder: (FormFieldState<dynamic> state) {
                //             return InputDecorator(
                //               decoration: InputDecoration(
                //                   filled: true,
                //                   fillColor: Colors.white,
                //                   labelStyle: TextStyle(
                //                     color: textColor,
                //                   ),
                //                   errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                //                   hintText: 'Selecciona la ciudad',
                //                   enabledBorder: OutlineInputBorder(
                //                     borderSide: BorderSide(color: Color(0xFF7f9d9D), width: 1.0),
                //                     borderRadius: BorderRadius.circular(10.0),
                //                   ),
                //                   disabledBorder: OutlineInputBorder(
                //                     borderSide: BorderSide(color: textColor, width: 1.0),
                //                     borderRadius: BorderRadius.circular(10.0),
                //                   ),
                //                   border: OutlineInputBorder(
                //                     borderRadius: BorderRadius.circular(30.0),
                //                   )
                //               ),
                //               isEmpty: ciudad == '',
                //               child: DropdownButtonHideUnderline(
                //                 child: DropdownButton<dynamic>(
                //                   hint: Text(
                //                     'Ciudad',
                //                     style: TextStyle(
                //                       fontSize: 14.0,
                //                     ),
                //                   ),
                //                   value: ciudad,
                //                   isDense: true,
                //                   onChanged: (dynamic newValue) {
                //                     setState(() {
                //                       ciudad = newValue;
                //                       state.didChange(newValue);
                //                       _allResults = [];
                //                      MastersList();
                //                     });
                //                   },
                //                   items: ciudades.map((dynamic value) {
                //                     return DropdownMenuItem<dynamic>(
                //                       value: value,
                //                       child: Text(value),
                //                     );
                //                   }).toList(),
                //                 ),
                //               ),
                //             );
                //           },
                //         ),
                //         // SizedBox(
                //         //   height: 30.0
                //         // ),
                //       ],
                //     )
                // ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _categoria != null ? _categoria : 'Nuestra selección',
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  height: _screenHeight,
                  width: _screenWidth,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          height: double.infinity,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget sourceInfo2(ServiceModel servicio, BuildContext context) {
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
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetallesServicio(
                                            petModel: model,
                                            serviceModel: servicio,
                                            aliadoModel: aliado,
                                            locationModel: location)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.62,
                                          height: 70,
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
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color:
                                                          Color(0xFF57419D),
                                                          fontWeight:
                                                          FontWeight.bold),
                                                      textAlign:
                                                      TextAlign.left),
                                                  Text(
                                                      location
                                                          .direccionLocalidad,
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
                                                      (aliado.totalRatings /
                                                          aliado
                                                              .countRatings)
                                                          .toString() !=
                                                          'NaN'
                                                          ? (aliado.totalRatings /
                                                          aliado
                                                              .countRatings)
                                                          .toStringAsPrecision(
                                                          2)
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
                                      ],
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

  changeDet(Det) {
    setState(() {
      servicio = Det;
    });

    return Det;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });
    return otro;
  }
  Future<List<dynamic>> getCiudades(pais) async {
    ciudades = [];
    try{
      await FirebaseFirestore.instance.collection('Ciudades').where("paisId", isEqualTo: PetshopApp.sharedPreferences.getString(PetshopApp.userPais)).get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((paisA) {
          setState((){
            ciudades = paisA["ciudades"].toList();
          });

        })
      });
      print(ciudades.length);
    }catch(e){
      print(e);
    }
    return ciudades;
  }

  Widget sourceInfo(BuildContext context, DocumentSnapshot document) {
    final servicio = ServicioModel.fromSnapshot(document);

    return InkWell(
      child: Column(
        children: [
          Container(
            height: 70.0,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicioDetalle(
                          petModel: model, servicioModel: servicio),
                    ));
              },
              child: Container(
                child: Row(
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
                            offset: Offset(
                                2.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      child: Image.network(
                        servicio.urlImagen,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Container(
                      height: 90.0,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(servicio.titulo,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
// Widget sourceInfo(ProductModel product, BuildContext context,
//     ) {
//   return InkWell(
//     child: Row(
//       children: [
//         Container(
//           height: 180.0,
//           width: 100.0,
//           child: Column(
//             children: [
//               Container(
//                 height: 80,
//                 child: Image.network(
//                   product.urlImagen, fit: BoxFit.cover,),
//               ),
//               SizedBox(height: 3.0,),
//               Container(
//                 height: 90.0,
//                 width: 100.0,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Flexible(child: Text(product.titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
//                     Flexible(child: Text(product.dirigido, style: TextStyle(fontSize: 12), textAlign: TextAlign.left)),
//                     SizedBox(height: 8.0),
//                     Row(
//                       children: [
//                         Text('\$', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
//                         Text(product.precio.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(width: 10.0),
//       ],
//     ),
//   );
// }
//
//

}
