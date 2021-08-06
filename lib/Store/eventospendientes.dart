import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/especialidades.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Servicios/cambioservicio.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/videocita/videocita.dart';
import 'package:pet_shop/videocita/videolobby.dart';

class EventosPendientesHome extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  EventosPendientesHome(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _EventosPendientesHomeState createState() => _EventosPendientesHomeState();
}

class _EventosPendientesHomeState extends State<EventosPendientesHome> {
  PetModel model;
  CartModel cart;
  Producto producto;
  bool confirmada = false;
  bool cancelada = false;
  String statuscita;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMMMEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    print(formatted);
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
                        "Eventos pendientes",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // .where('fecha', isGreaterThanOrEqualTo: formatted)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Ordenes")
                        .where('date', isGreaterThan: DateTime.now())
                        // .where('tipoOrden', isEqualTo: 'Servicio')
                        .where('uid',
                            isEqualTo: PetshopApp.sharedPreferences
                                .getString(PetshopApp.userUID)
                                .toString())
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dataSnapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            OrderModel order = OrderModel.fromJson(
                                dataSnapshot.data.docs[index].data());
                            return sourceInfo(order, context);
                          });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    OrderModel order,
    BuildContext context,
  ) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMMMEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    statuscita = order.statusCita;

    return InkWell(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //
          //   MaterialPageRoute(builder: (context) => OrdenesDetalle(orderModel: order)),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.91,
            decoration: BoxDecoration(
                color: Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFBDD7D6),
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Ordenes')
                          .doc(order.oid)
                          .collection('Items')
                          .snapshots(),
                      builder: (context, dataSnapshot) {
                        if (dataSnapshot.hasData) {
                          if (dataSnapshot.data.docs.length == 0) {
                            return Center(child: Text(''));
                          }
                        }
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
                              ItemModel item = ItemModel.fromJson(
                                  dataSnapshot.data.docs[index].data());
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.fecha,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7F9D9D)),
                                      ),
                                      Text(
                                        item.hora != null
                                            ? item.hora
                                            : 'Horario libre',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7F9D9D)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 150,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.titulo,
                                              style: TextStyle(
                                                  color: Color(0xFF57419D),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Orden:',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            order.oid,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('Aliados')
                                          .doc(order.aliadoId)
                                          .snapshots(),
                                      builder: (context, dataSnapshot) {
                                        if (!dataSnapshot.hasData) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            shrinkWrap: true,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              AliadoModel ali =
                                                  AliadoModel.fromJson(
                                                      dataSnapshot.data.data());
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(ali.nombreComercial,
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                      textAlign:
                                                          TextAlign.left),
                                                ],
                                              );
                                            });
                                      }),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('Aliados')
                                          .doc(order.aliadoId)
                                          .collection("Especialidades")
                                          .snapshots(),
                                      builder: (context, dataSnapshot) {
                                        if (dataSnapshot.hasData) {
                                          if (dataSnapshot.data.docs.length ==
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
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            shrinkWrap: true,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              EspecialidadesModel
                                                  especialidades =
                                                  EspecialidadesModel.fromJson(
                                                      dataSnapshot
                                                          .data.docs[index]
                                                          .data());

                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      especialidades
                                                          .especialidad,
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                      textAlign:
                                                          TextAlign.left),
                                                ],
                                              );
                                            });
                                      }),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 30,
                                        child: RaisedButton(
                                          onPressed: () {
                                            _planModalBottomSheet(
                                                context, order);
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          color:
                                              order.statusCita == 'Confirmada'
                                                  ? Color(0xFF57419D)
                                                  : order.statusCita ==
                                                          'Por confirmar'
                                                      ? Color(0xFFEB9448)
                                                      : order.statusCita ==
                                                              'Cancelada'
                                                          ? Colors.grey
                                                          : Color(0xFFEB9448),
                                          padding: EdgeInsets.all(0.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(order.statusCita,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontSize: 14.0)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110.0,
                                        height: 50.0,
                                        child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Mascotas')
                                                .doc(order.mid)
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  itemCount: 1,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    PetModel model =
                                                        PetModel.fromJson(
                                                            dataSnapshot.data
                                                                .data());
                                                    return Row(
                                                      children: <Widget>[
                                                        Material(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20.0)),
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              backgroundImage: model ==
                                                                      null
                                                                  ? Image(
                                                                      image: NetworkImage(
                                                                        PetshopApp
                                                                        .sharedPreferences
                                                                        .getString(
                                                                          PetshopApp.userAvatarUrl
                                                                        )
                                                                      ),
                                                                      errorBuilder: (context, object, stacktrace) {
                                                                        return Container();
                                                                      },
                                                                    ).image
                                                                  : Image(
                                                                      image: NetworkImage(model.petthumbnailUrl),
                                                                      errorBuilder: (context, object, stacktrace) {
                                                                        return Container();
                                                                      },
                                                                    ).image
                                                            ),
                                                          ),
                                                        ),
                                                        order.videoId != null
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => VideoLobby(petModel: model, itemModel: item, orderModel: order)));
                                                                      },
                                                                      child: Image
                                                                          .asset(
                                                                        'diseñador/drawable/Grupo234.png',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        height:
                                                                            45,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Container(),
                                                      ],
                                                    );
                                                  });
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void countDocuments() async {
    final QuerySnapshot qSnap = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .get();
    final int documents = qSnap.docs.length;
    print(documents);

    QuerySnapshot _myDoc = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    print(_myDocCount.length);

    // Count of Documents in Collection
  }

  void _planModalBottomSheet(BuildContext context, OrderModel order) {
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
                      color: Color(0xFF57419D),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
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
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            '¿Qué deseas hacer?',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEB9448)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirmar cita',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.check_circle),
                            color: Color(0xFFEB9448),
                            iconSize: 32,
                            onPressed: () {
                              setState(() {
                                FirebaseFirestore.instance
                                    .collection('Ordenes')
                                    .doc(order.oid)
                                    .update({
                                  "statusCita": "Confirmada"
                                }).then((result) {
                                  print("new USer true");
                                }).catchError((onError) {
                                  print("onError");
                                });

                                statuscita = 'Confirmada';
                                confirmada = true;
                                cancelada = false;
                                print(statuscita);
                                Navigator.pop(context);
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cancelar cita',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            color: Colors.white,
                            iconSize: 32,
                            onPressed: () {
                              setState(() {
                                FirebaseFirestore.instance
                                    .collection('Ordenes')
                                    .doc(order.oid)
                                    .update({
                                  "statusCita": "Cancelada"
                                }).then((result) {
                                  print("new USer true");
                                }).catchError((onError) {
                                  print("onError");
                                });
                                statuscita = 'Cancelada';
                                confirmada = false;
                                cancelada = true;
                                Navigator.pop(context);
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cambiar cita',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            color: Color(0xFFEB9448),
                            iconSize: 32,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CambioServicio(
                                        petModel: model, orderModel: order)),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  )));
        });
  }
}
