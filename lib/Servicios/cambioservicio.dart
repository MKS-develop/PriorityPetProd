import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/daymodel.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Ordenes/ordeneshome.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Store/eventospendientes.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'package:intl/date_symbol_data_local.dart';

int cantidad = 1;

double width;

class CambioServicio extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final OrderModel orderModel;
  final int defaultChoiceIndex;

  CambioServicio(
      {this.petModel,
      this.serviceModel,
      this.aliadoModel,
      this.locationModel,
      this.orderModel,
      this.defaultChoiceIndex});

  @override
  _CambioServicioState createState() => _CambioServicioState();
}

class _CambioServicioState extends State<CambioServicio> {
  final pushProvider = PushNotificationsProvider();
  bool _checked = false;
  Timestamp date;
  double totalPet = 0;
  String hora;
  String fecha;
  int recojo = 0;
  int delivery = 0;
  int _defaultChoiceIndex;
  int _2defaultChoiceIndex;
  bool _value = false;
  bool _value2 = false;
  AliadoModel ali;
  LocationModel location;
  DateTime selectedDate = DateTime.now();
  ServiceModel servicio;
  PetModel model;
  PromotionModel pro;
  CartModel cart;
  bool select = false;
  bool uploading = false;
  String petImageUrl = "";
  String downloadUrl = "";
  BuildContext dialogContext;
  int ppAcumulados = 0;
  int ppCanjeados = 0;
  double ppvalor = 0;

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    changePro(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);

    deleteDate();

    super.initState();
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Ordenes')
        .doc(widget.orderModel.oid)
        .collection('Items')
        .doc("Precio");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        ppvalor = (dataSnapshot.data()["petpointPE"]);
      });
    });
  }

  // eliminarFecha(){
  //   var val=[];   //blank list for add elements which you want to delete
  //   val.add(day.horasDia[i]);
  //   FirebaseFirestore.instance.collection("INTERESTED").doc('documentID').updateData({
  //
  //     "Interested Request":FieldValue.arrayRemove(val) });
  // }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());

    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    // double rating =
    //     widget.aliadoModel.totalRatings / widget.aliadoModel.countRatings;

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
                        "Cambio de servicio",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Aliados')
                        .doc(widget.orderModel.aliadoId)
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
                                AliadoModel.fromJson(dataSnapshot.data.data);
                            return Column(children: [
                              Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(
                                      ali.avatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, object, stacktrace) {
                                        return Container();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                    height: 100.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(ali.nombreComercial,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left),
                                        // Text(widget.locationModel.direccionLocalidad,
                                        //     style: TextStyle(
                                        //       fontSize: 13,
                                        //     ),
                                        //     textAlign: TextAlign.left),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                (ali.totalRatings /
                                                                ali
                                                                    .countRatings)
                                                            .toString() !=
                                                        'NaN'
                                                    ? (ali.totalRatings /
                                                            ali.countRatings)
                                                        .toStringAsFixed(2)
                                                    : '0',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.orange),
                                                textAlign: TextAlign.left),
                                            Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              widget.orderModel.tipoOrden == 'Servicio'
                                  ? StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Ordenes')
                                          .doc(widget.orderModel.oid)
                                          .collection('Items')
                                          .snapshots(),
                                      builder: (context, dataSnapshot) {
                                        if (dataSnapshot.hasData) {
                                          if (dataSnapshot
                                                  .data.docs.length ==
                                              0) {
                                            return Center(child: Text(''));
                                          }
                                        }
                                        if (!dataSnapshot.hasData) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return ListView.builder(
                                            itemCount: 1,
                                            shrinkWrap: true,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              ItemModel item =
                                                  ItemModel.fromJson(
                                                      dataSnapshot
                                                          .data.docs[index]
                                                          .data());
                                              return Column(
                                                children: [
                                                  Container(
                                                    height: 100,
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: [
                                                        item.promoid == null
                                                            ? StreamBuilder<
                                                                    QuerySnapshot>(
                                                                stream: db
                                                                    .collection(
                                                                        "Localidades")
                                                                    .doc(widget
                                                                        .orderModel
                                                                        .localidadId)
                                                                    .collection(
                                                                        "Servicios")
                                                                    .doc(item
                                                                        .servicioid)
                                                                    .collection(
                                                                        "Agenda")
                                                                    .where(
                                                                        'date',
                                                                        isGreaterThan:
                                                                            DateTime
                                                                                .now())
                                                                    .snapshots(),
                                                                // .where('date', isGreaterThan: DateTime.now())

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
                                                                              Text('No data'));
                                                                    }
                                                                  }
                                                                  if (!dataSnapshot
                                                                      .hasData) {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    );
                                                                  }
                                                                  return Container(
                                                                    child:
                                                                        Expanded(
                                                                      child: ListView
                                                                          .builder(
                                                                        itemCount: dataSnapshot
                                                                            .data
                                                                            .docs
                                                                            .length,
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemBuilder:
                                                                            (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          PromotionModel
                                                                              pro =
                                                                              PromotionModel.fromJson(dataSnapshot.data.docs[index].data());
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(2.0),
                                                                            child:
                                                                                ChoiceChip(
                                                                              label: sourceInfo(pro, context),
                                                                              labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                              selected: _defaultChoiceIndex == index,
                                                                              selectedColor: Color(0xFFEB9448),
                                                                              onSelected: (bool selected) {
                                                                                setState(() {
                                                                                  _defaultChoiceIndex = selected ? index : 0;
                                                                                  print(pro.fecha);
                                                                                  fecha = pro.fecha;
                                                                                  date = pro.date;
                                                                                });
                                                                              },
                                                                              backgroundColor: Colors.transparent,
                                                                              shape: StadiumBorder(side: BorderSide(color: Color(0xFFBDD7D6))),
                                                                              labelStyle: TextStyle(color: Colors.transparent),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                })
                                                            : StreamBuilder<
                                                                    QuerySnapshot>(
                                                                stream: db
                                                                    .collection(
                                                                        "Promociones")
                                                                    .doc(item
                                                                        .promoid)
                                                                    .collection(
                                                                        "Agenda")
                                                                    .orderBy(
                                                                        'createdOn',
                                                                        descending:
                                                                            false)
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
                                                                              Text(''));
                                                                    }
                                                                  }
                                                                  if (!dataSnapshot
                                                                      .hasData) {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    );
                                                                  }
                                                                  return Container(
                                                                    child:
                                                                        Expanded(
                                                                      child: ListView
                                                                          .builder(
                                                                        itemCount: dataSnapshot
                                                                            .data
                                                                            .docs
                                                                            .length,
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemBuilder:
                                                                            (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          PromotionModel
                                                                              pro =
                                                                              PromotionModel.fromJson(dataSnapshot.data.docs[index].data());
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(2.0),
                                                                            child:
                                                                                ChoiceChip(
                                                                              label: sourceInfo(pro, context),
                                                                              labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                              selected: _defaultChoiceIndex == index,
                                                                              selectedColor: Color(0xFFEB9448),
                                                                              onSelected: (bool selected) {
                                                                                setState(() {
                                                                                  _defaultChoiceIndex = selected ? index : 0;
                                                                                  print(pro.fecha);
                                                                                  fecha = pro.fecha;
                                                                                  date = pro.date;
                                                                                });
                                                                              },
                                                                              backgroundColor: Colors.transparent,
                                                                              shape: StadiumBorder(side: BorderSide(color: Color(0xFFBDD7D6))),
                                                                              labelStyle: TextStyle(color: Colors.transparent),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                      ],
                                                    ),
                                                  ),
                                                  item.hora != null
                                                      ? Container(
                                                          width: _screenWidth,
                                                          child: Column(
                                                            children: [
                                                              item.promoid ==
                                                                      null
                                                                  ? StreamBuilder<
                                                                          QuerySnapshot>(
                                                                      stream: db
                                                                          .collection(
                                                                              "Localidades")
                                                                          .doc(widget
                                                                              .orderModel
                                                                              .localidadId)
                                                                          .collection(
                                                                              "Servicios")
                                                                          .doc(item
                                                                              .servicioid)
                                                                          .collection(
                                                                              "Agenda")
                                                                          .where(
                                                                              'fecha',
                                                                              isEqualTo:
                                                                                  fecha)
                                                                          .snapshots(),
                                                                      builder:
                                                                          (context,
                                                                              dataSnapshot) {
                                                                        if (dataSnapshot
                                                                            .hasData) {
                                                                          if (dataSnapshot.data.docs.length ==
                                                                              0) {
                                                                            return Center(child: Text(''));
                                                                          }
                                                                        }
                                                                        if (!dataSnapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                        return Container(
                                                                          child: ListView.builder(
                                                                              physics: NeverScrollableScrollPhysics(),
                                                                              itemCount: 1,
                                                                              shrinkWrap: true,
                                                                              itemBuilder: (
                                                                                context,
                                                                                index,
                                                                              ) {
                                                                                DayModel day = DayModel.fromJson(dataSnapshot.data.docs[index].data());
                                                                                return Container(
                                                                                  child: GridView.builder(
                                                                                    shrinkWrap: true,
                                                                                    scrollDirection: Axis.vertical,
                                                                                    itemCount: day.horasDia.length,
                                                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                                                                                    physics: BouncingScrollPhysics(),
                                                                                    itemBuilder: (BuildContext context, int i) {
                                                                                      return ChoiceChip(
                                                                                        label: sourceInfo2(context, day, i),
                                                                                        labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                        selected: _2defaultChoiceIndex == i,
                                                                                        selectedColor: Color(0xFFEB9448),
                                                                                        onSelected: (bool selected) {
                                                                                          setState(() {
                                                                                            if (selected) {
                                                                                              _2defaultChoiceIndex = i;
                                                                                              print(day.horasDia[i]);
                                                                                              hora = day.horasDia[i];
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        shape: StadiumBorder(side: BorderSide(color: Color(0xFFBDD7D6))),
                                                                                        backgroundColor: Colors.transparent,
                                                                                        labelStyle: TextStyle(color: Colors.white),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              }),
                                                                        );
                                                                      })
                                                                  : StreamBuilder<
                                                                          QuerySnapshot>(
                                                                      stream: db
                                                                          .collection(
                                                                              "Promociones")
                                                                          .doc(item
                                                                              .promoid)
                                                                          .collection(
                                                                              "Agenda")
                                                                          .where(
                                                                              'fecha',
                                                                              isEqualTo:
                                                                                  fecha)
                                                                          .snapshots(),
                                                                      builder:
                                                                          (context,
                                                                              dataSnapshot) {
                                                                        if (dataSnapshot
                                                                            .hasData) {
                                                                          if (dataSnapshot.data.docs.length ==
                                                                              0) {
                                                                            return Center(child: Text(''));
                                                                          }
                                                                        }
                                                                        if (!dataSnapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                        return Container(
                                                                          child: ListView.builder(
                                                                              physics: NeverScrollableScrollPhysics(),
                                                                              itemCount: 1,
                                                                              shrinkWrap: true,
                                                                              itemBuilder: (
                                                                                context,
                                                                                index,
                                                                              ) {
                                                                                DayModel day = DayModel.fromJson(dataSnapshot.data.docs[index].data());
                                                                                return Container(
                                                                                  child: GridView.builder(
                                                                                    shrinkWrap: true,
                                                                                    scrollDirection: Axis.vertical,
                                                                                    itemCount: day.horasDia.length,
                                                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                                                                                    physics: BouncingScrollPhysics(),
                                                                                    itemBuilder: (BuildContext context, int i) {
                                                                                      return ChoiceChip(
                                                                                        label: sourceInfo2(context, day, i),
                                                                                        labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                        selected: _2defaultChoiceIndex == i,
                                                                                        selectedColor: Color(0xFFEB9448),
                                                                                        onSelected: (bool selected) {
                                                                                          setState(() {
                                                                                            if (selected) {
                                                                                              _2defaultChoiceIndex = i;
                                                                                              print(day.horasDia[i]);
                                                                                              hora = day.horasDia[i];
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        shape: StadiumBorder(side: BorderSide(color: Color(0xFFBDD7D6))),
                                                                                        backgroundColor: Colors.transparent,
                                                                                        labelStyle: TextStyle(color: Colors.white),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              }),
                                                                        );
                                                                      }),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    width: 200.0,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        if (fecha == null &&
                                                            item.hora == null) {
                                                          showDialog(
                                                            builder: (context) => AlertDialog(
                                                              title: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .cancel,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    'Seleccione una fecha.',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ],
                                                              ),
                                                            ), context: context,
                                                          );
                                                        } else if (fecha !=
                                                                null &&
                                                            item.hora == null) {
                                                          AddOrder(
                                                              item, context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EventosPendientesHome(
                                                                          petModel:
                                                                              model,
                                                                        )),
                                                          );
                                                        } else if (item.hora !=
                                                            null) {
                                                          if (hora == null) {
                                                            showDialog(
                                                              builder: (context) => AlertDialog(
                                                                title: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Seleccione una hora.',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ), context: context,
                                                            );
                                                          }
                                                          if (fecha == null) {
                                                            showDialog(
                                                              builder: (context) => AlertDialog(
                                                                title: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Seleccione una fecha.',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ), context: context,
                                                            );
                                                          }
                                                          if (hora != null &&
                                                              fecha != null) {
                                                            AddOrder(
                                                                item, context);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => EventosPendientesHome(
                                                                      petModel:
                                                                          model,
                                                                      defaultChoiceIndex:
                                                                          widget
                                                                              .defaultChoiceIndex)),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                      color: Color(0xFFEB9448),
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text("Cambiar cita",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Product Sans',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      18.0)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      })
                                  : Container(),
                            ]);
                          });

                      // StreamBuilder(
                      // stream: FirebaseFirestore.instance.collection('Promociones').doc(widget.orderModel.promoid).snapshots(),
                      // builder: (context, dataSnapshot) {
                      //   if (!dataSnapshot.hasData) {
                      //     return Center(
                      //       child: CircularProgressIndicator(),
                      //     );
                      //   }
                      //   return ListView.builder(
                      //       physics: NeverScrollableScrollPhysics(),
                      //       itemCount: 1,
                      //       shrinkWrap: true,
                      //       itemBuilder: (context, index,) {
                      //         PromotionModel promo = PromotionModel.fromJson(
                      //             dataSnapshot.data.data);
                      //         return Column(
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 Text(promo.tipoPromocion == 'Producto' ? "" : promo.tipoAgenda == 'Slots' ? 'Seleccione día y hora disponibles' : 'Seleccione el día disponible', style: TextStyle(fontSize: 17, color: Color(0xFF57419D), fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                      //               ],
                      //             ),
                      //           ],
                      //         );
                      //       }
                      //   );
                      // }
                      // ),
                    }),
              ],
            ))),
      ),
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  changeAli(otro) {
    setState(() {
      ali = otro;
    });
    return otro;
  }

  changePro(otro) {
    setState(() {
      servicio = otro;
    });
    return otro;
  }

  changeLoc(Det) {
    setState(() {
      location = Det;
    });

    return Det;
  }

  Widget sourceInfo(PromotionModel pro, BuildContext context) {
    return InkWell(
      child: Container(
        height: 72.0,
        width: 72.0,
        child: Row(
          children: [
            Container(
              width: 68,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
                    child: Text(
                      pro.fecha,
                      style: TextStyle(
                          color: pro.fecha == fecha
                              ? Colors.white
                              : Color(0xFF7F9D9D),
                          fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sourceInfo2(BuildContext context, DayModel day, int i) {
    return InkWell(
      child: Container(
        height: 40.0,
        width: 70.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  day.horasDia[i],
                  style: TextStyle(
                      color: day.horasDia[i] == hora
                          ? Colors.white
                          : Color(0xFF7F9D9D),
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  deleteDate() {
    var a = DateTime.now();
    final b = a.toLocal();
    var dateFormat = DateFormat("yMMMMEEEEd");
    print(a);
    String tactualDate = dateFormat.format(b);
    print(tactualDate);
  }

  AddOrder(ItemModel item, BuildContext context) async {
    if (item.promoid == null) {
      var vale = []; //blank list for add elements which you want to delete
      vale.add(item.hora);
      db
          .collection("Localidades")
          .doc(widget.orderModel.localidadId)
          .collection("Servicios")
          .doc(item.servicioid)
          .collection("Agenda")
          .doc(item.fecha)
          .update({
        "horasDia": FieldValue.arrayUnion(vale),
        "horasReservadas": FieldValue.arrayRemove(vale),
      });
      var databaseReference = FirebaseFirestore.instance
          .collection('Ordenes')
          .doc(widget.orderModel.oid);

      databaseReference.update({
        "date": date,
        "hora": hora,
        "fecha": fecha == null ? fecha : fecha.trim(),
      });

      databaseReference.collection('Items').doc(item.servicioid).update({
        "date": date,
        "hora": hora,
        "fecha": fecha == null ? fecha : fecha.trim(),
      });
      var val = []; //blank list for add elements which you want to delete
      val.add(hora);
      db
          .collection("Localidades")
          .doc(widget.orderModel.localidadId)
          .collection("Servicios")
          .doc(item.servicioid)
          .collection("Agenda")
          .doc(fecha)
          .update({
        "horasDia": FieldValue.arrayRemove(val),
        "horasReservadas": FieldValue.arrayUnion(val),
      });

      // var val=[];   //blank list for add elements which you want to delete
      // val.add(hora);
      // db.collection("Localidades").doc(widget.serviceModel.localidadId).collection("Servicios").doc(widget.serviceModel.servicioId)
      //     .collection("Agenda").doc(fecha).updateData({
      //
      //   "horasDia":FieldValue.arrayRemove(val) });

      // var result = await MercadoPagoMobileCheckout.startCheckout("TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3", "698748168-e3a21e6a-6e36-43d3-911f-8eff284f782e");
    } else {
      var vale = []; //blank list for add elements which you want to delete
      vale.add(item.hora);
      db
          .collection("Promociones")
          .doc(item.promoid)
          .collection("Agenda")
          .doc(item.fecha)
          .update({
        "horasDia": FieldValue.arrayUnion(vale),
        "horasReservadas": FieldValue.arrayRemove(vale),
      });
      var databaseReference = FirebaseFirestore.instance
          .collection('Ordenes')
          .doc(widget.orderModel.oid);

      databaseReference.update({
        "date": date,
        "hora": hora,
        "fecha": fecha == null ? fecha : fecha.trim(),
      });

      databaseReference.collection('Items').doc(item.promoid).update({
        "date": date,
        "hora": hora,
        "fecha": fecha == null ? fecha : fecha.trim(),
      });
      var val = []; //blank list for add elements which you want to delete
      val.add(hora);
      db
          .collection("Promociones")
          .doc(item.promoid)
          .collection("Agenda")
          .doc(fecha)
          .update({
        "horasDia": FieldValue.arrayRemove(val),
        "horasReservadas": FieldValue.arrayUnion(val),
      });
    }
  }
}
