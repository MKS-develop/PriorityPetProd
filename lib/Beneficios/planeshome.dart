import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/plan.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Beneficios/planbasico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'package:intl/date_symbol_data_local.dart';

double width;

class PlanesHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  PlanesHome({this.petModel, this.defaultChoiceIndex});

  @override
  _PlanesHomeState createState() => _PlanesHomeState();
}

class _PlanesHomeState extends State<PlanesHome> {
  PlanModel plan;
  PetModel model;
  Color color;
  int ppAcumulados = 0;
  int ppCanjeados = 0;
  String status = 'Inactivo';
  String tipoPlan;
  Timestamp vigenciaDesde;
  Timestamp vigenciaHasta;
  String formattedDesde;
  String formattedHasta;
  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    _statusPlan();
    _getPetpoints();
    //initializeDateFormatting("es_VE", null).then((_) {});
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  _statusPlan() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Plan")
        .doc(widget.petModel.mid);
    documentReference.get().then((dataSnapshot) {
      setState(() {
        var formatter = DateFormat.yMd('es_VE');

        status = (dataSnapshot.data()["status"]);
        tipoPlan = (dataSnapshot.data()["tipoPlan"]);
        vigenciaDesde = (dataSnapshot.data()["vigencia_desde"]);
        vigenciaHasta = (dataSnapshot.data()["vigencia_hasta"]);
        formattedDesde = formatter.format(vigenciaDesde.toDate());
        formattedHasta = formatter.format(vigenciaHasta.toDate());
      });
    });
  }

  _getPetpoints() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        ppAcumulados = (dataSnapshot.data()["ppAcumulados"]);
        ppCanjeados = (dataSnapshot.data()["ppCanjeados"]);
      });
      print('Valor Acumulado: $ppAcumulados');
      print('Valor canjeados: $ppCanjeados');
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
              children: [
                status != 'Activo'
                    ? Column(
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
                                  "Planes",
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Container(
                                    //   width: MediaQuery.of(context).size.width *
                                    //       .80,
                                    //   child: Text(
                                    //     'Sabemos que tu mascota forma parte de tu familia y siempre quieres darle lo mejor.',
                                    //     style: TextStyle(
                                    //         fontSize: 15.0,
                                    //         color: Color(0xFF1A3E4D)),
                                    //     // )
                                    //   ),
                                    // ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'HOLA PETLOVER,',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Color(0xFF1A3E4D),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // )
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Sabemos que tu mascota forma parte de tu familia y siempre quieres darle lo mejor.',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Color(0xFF1A3E4D)),
                                              // )
                                            ),
                                          ),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   children: [
                                          //     Padding(
                                          //       padding: EdgeInsets.fromLTRB(
                                          //           15, 20, 0, 5),
                                          //       child: Text(
                                          //         "Descuentos en servicios y productos",
                                          //         style: TextStyle(
                                          //           color: Color(0xFF1A3E4D),
                                          //           fontSize: 16,
                                          //           fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   children: [
                                          //     Padding(
                                          //       padding: EdgeInsets.fromLTRB(
                                          //           15, 5, 0, 5),
                                          //       child: Text(
                                          //         "Historial médico completo",
                                          //         style: TextStyle(
                                          //           color: Color(0xFF1A3E4D),
                                          //           fontSize: 16,
                                          //           fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   children: [
                                          //     Padding(
                                          //       padding: EdgeInsets.fromLTRB(
                                          //           15, 5, 0, 20),
                                          //       child: Text(
                                          //         "Chip con GPS para tu mascota",
                                          //         style: TextStyle(
                                          //           color: Color(0xFF1A3E4D),
                                          //           fontSize: 16,
                                          //           fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Por eso te mostramos los planes y beneficios que tenemos para tu mascota:',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Color(0xFF1A3E4D)),
                                              // )
                                            ),
                                          ),
                                          SizedBox(
                                            height: 110,
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Planes")
                                                  .orderBy('descuento',
                                                      descending: false)
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return ListView.builder(
                                                    itemCount: dataSnapshot
                                                        .data.docs.length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      PlanModel plan =
                                                          PlanModel.fromJson(
                                                              dataSnapshot.data
                                                                  .docs[index]
                                                                  .data());
                                                      return sourceInfo(
                                                          plan, context);
                                                    });
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
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
                                  "Beneficios",
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Planes")
                                  .where('planid', isEqualTo: tipoPlan)
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
                                      PlanModel plan = PlanModel.fromJson(
                                          dataSnapshot.data.docs[index].data());
                                      return Column(children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 20, 10),
                                              child: RaisedButton(
                                                onPressed: () {
                                                  _planModalBottomSheet(
                                                      context, plan);
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                color: Color(0xFFEB9448),
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 0, 18, 0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text("Ver plan",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Product Sans',
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      plan.planid,
                                                      style: TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 160.0,
                                                      child: FlatButton(
                                                          onPressed: () {},
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          color:
                                                              Color(0xFF57419D),
                                                          child: Text(
                                                            "1 mascota",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tienes disponibles',
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 160.0,
                                                      child: FlatButton(
                                                          onPressed: () {},
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          color:
                                                              Color(0xFF57419D),
                                                          child: Text(
                                                            "$ppAcumulados pet points",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.91,
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF4F6F8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Color(0xFFBDD7D6),
                                              )),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Vigencia desde: ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      '$formattedDesde',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Vigencia hasta: ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      '$formattedHasta',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ]);
                                    });
                              }),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    PlanModel plan,
    BuildContext context,
  ) {
    return InkWell(
      child: Column(children: [
        Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: RaisedButton(
              onPressed: () {
                _planModalBottomSheet(context, plan);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PlanBasicoHome()),
                // );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Color(0xFFEB9448),
              padding: EdgeInsets.fromLTRB(18, 13, 18, 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    // height: 50,
                    child: Text(plan.planid,
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF1A3E4D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0)),
                  ),
                  // Row(
                  //   children: [
                  //     Text(plan.descuento.toString(),
                  //         style: TextStyle(
                  //             fontFamily: 'Product Sans', fontSize: 17.0)),
                  //     Text("% Desct.",
                  //         style: TextStyle(
                  //             fontFamily: 'Product Sans', fontSize: 17.0)),
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Text("S/",
                  //         style: TextStyle(
                  //             fontFamily: 'Product Sans',
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 17.0)),
                  //     Text(plan.montoMensual.toString(),
                  //         style: TextStyle(
                  //             fontFamily: 'Product Sans',
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 17.0)),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _planModalBottomSheet(BuildContext context, PlanModel plan) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: MediaQuery.of(context).size.height * .60,
              color:
                  Color(0xFF737373), //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor

              child: Container(
                  width: 60.0,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new AssetImage("diseñador/Grupo592.png"),
                        fit: BoxFit.fill,
                      ),
                      color: Color(0xFF737373),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: 70.0,
                              height: 5.0,
                              child: Image.asset(
                                'diseñador/drawable/Rectangulo308.png',
                              ),
                            ),
                          ),
                          Text(plan.planid,
                              style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 27.0)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: plan.detallesBasicos.length,
                            itemBuilder: (BuildContext context, int i) {
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(plan.detallesBasicos[i],
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0)),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("S/",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 42.0)),
                            Text(plan.montoMensual.toString(),
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 42.0)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlanBasicoHome(
                                    petModel: model,
                                    planModel: plan,
                                    defaultChoiceIndex:
                                        widget.defaultChoiceIndex)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text("Ver detalle",
                              style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0)),
                        ),
                      ),
                    ],
                  )));
        });
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
