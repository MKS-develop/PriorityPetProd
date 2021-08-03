import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'confirmcancel.dart';

class NewOrdenesDetalle extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final OrderModel orderModel;
  final int defaultChoiceIndex;

  NewOrdenesDetalle(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.orderModel,
      this.defaultChoiceIndex});

  @override
  _NewOrdenesDetalleState createState() => _NewOrdenesDetalleState();
}

class _NewOrdenesDetalleState extends State<NewOrdenesDetalle> {
  PetModel model;
  CartModel cart;
  Producto producto;
  OrderModel order;
  bool _value = true;
  bool _value2 = false;
  bool _value3 = false;
  bool _isChecked = false;

  List<String> _texts = [
    "I have confirm the data is correct",
    "I have agreed to terms and conditions.",
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeOrd(widget.orderModel);
  }

  @override
  Widget build(BuildContext context) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    String formatted = formatter.format(widget.orderModel.createdOn.toDate());
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
                        "Detalles de la orden",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.91,
                  decoration: BoxDecoration(
                      color: Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.orderModel.tipoOrden == 'Servicio' ||
                                widget.orderModel.tipoOrden == 'Plan'
                            ? StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Mascotas')
                                    .doc(widget.orderModel.mid)
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
                                        PetModel model = PetModel.fromJson(
                                            dataSnapshot.data.data());
                                        return Row(
                                          children: [
                                            Stack(
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0)),
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      backgroundImage: model ==
                                                              null
                                                          ? NetworkImage(PetshopApp
                                                              .sharedPreferences
                                                              .getString(PetshopApp
                                                                  .userAvatarUrl))
                                                          : NetworkImage(model
                                                              .petthumbnailUrl),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Nombre: ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      model.nombre,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Mascota: ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      model.especie,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Raza: ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      model.raza,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF57419D),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                })
                            : Container(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Número de orden: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.orderModel.oid,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          'Fecha de la orden: $formatted',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Monto total de la orden: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.orderModel.precio.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        widget.orderModel.tipoOrden != 'Plan'
                            ? StreamBuilder(
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
                                        AliadoModel ali = AliadoModel.fromJson(
                                            dataSnapshot.data.data());
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('Proveedor: '),
                                                Text(ali.nombreComercial),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('Teléfono móvil: '),
                                                Text(ali.telefono),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('Correo: '),
                                                Text(ali.email),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                })
                            : Container(),
                        SizedBox(
                          height: 10.0,
                        ),
                        widget.orderModel.tipoOrden == 'Plan'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Plan facturado: ',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.left),
                                  Text(widget.orderModel.tipoPlan,
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.left),
                                ],
                              )
                            : Container(),
                        widget.orderModel.tipoOrden != 'Plan'
                            ? StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Ordenes')
                                    .doc(widget.orderModel.oid)
                                    .collection('Items')
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
                                        ItemModel item = ItemModel.fromJson(
                                            dataSnapshot.data.docs[index]
                                                .data());
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(widget
                                                    .orderModel.tipoOrden),
                                                Text(' :'),
                                                Expanded(
                                                    child: Text(item.titulo)),
                                              ],
                                            ),
                                            widget.orderModel.tipoOrden !=
                                                    'Producto'
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(item.fecha !=
                                                                      null
                                                                  ? 'Fecha desde: '
                                                                  : ''),
                                                              Text(item.fecha !=
                                                                      null
                                                                  ? item.fecha
                                                                  : ''),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 30.0,
                                                          ),
                                                          // Text('hasta: $formatted'),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(item.hora != null
                                                              ? 'Hora: '
                                                              : ''),
                                                          Text(item.hora != null
                                                              ? item.hora
                                                              : ''),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            Row(
                                              children: [
                                                Text(
                                                    'Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}'),
                                                Text(item.precio.toString()),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            item.tieneDelivery == true
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Recoger mascota: Sí'),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              'Recoger mascota monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}'),
                                                          Text(item.delivery
                                                              .toString()),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                    ],
                                                  )
                                                : Container(),
                                            item.tieneDomicilio == true
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Servicio a domicilio: Sí'),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              'Monto del servicio a domicilio: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}'),
                                                          Text(item.domicilio
                                                              .toString()),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        );
                                      });
                                })
                            : Container(),
                        widget.orderModel.tieneDelivery == true
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tiene delivery: Sí'),
                                  Row(
                                    children: [
                                      Text(
                                          'Monto del delivery: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}'),
                                      Text(widget.orderModel.delivery
                                          .toString()),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                ],
                              )
                            : Container(),
                        widget.orderModel.tipoOrden != 'Plan'
                            ? Row(
                                children: [
                                  Text('Estatus: '),
                                  Text(widget.orderModel.status),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 15),
                        widget.orderModel.tipoOrden != 'Plan'
                            ? Row(
                                children: [
                                  Text('Petpoints Acreditados: '),
                                  Text(widget.orderModel.ppGeneradosD == null
                                      ? '0'
                                      : widget.orderModel.ppGeneradosD
                                          .toString()),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 15),
                        widget.orderModel.status != 'Cancelada'
                            ? SizedBox(
                                width: 100,
                                height: 30,
                                child: RaisedButton(
                                  onPressed: () {
                                    Timestamp stamp = widget.orderModel.date;
                                    DateTime date = stamp.toDate();
                                    DateTime now =
                                        DateTime.now(); // current time
                                    if (now.isBefore(date)) {
                                      popUp();
                                    } else {}
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Colors.red,
                                  padding: EdgeInsets.all(0.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Cancelar',
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Colors.white,
                                              fontSize: 14.0)),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),

                // widget.orderModel.tipoOrden!='Producto'?
                // StreamBuilder(
                //     stream: FirebaseFirestore.instance.collection('Mascotas').doc(widget.orderModel.mid).snapshots(),
                //     builder: (context, dataSnapshot) {
                //       if (!dataSnapshot.hasData) {
                //         return Center(
                //           child: CircularProgressIndicator(),
                //         );
                //       }
                //       return ListView.builder(
                //           physics: NeverScrollableScrollPhysics(),
                //           itemCount: 1,
                //           shrinkWrap: true,
                //           itemBuilder: (context, index,) {
                //             PetModel model = PetModel.fromJson(
                //                 dataSnapshot.data.data);
                //             return sourceInfo(model, context);
                //           }
                //         );
                //       }
                //     ) : StreamBuilder<QuerySnapshot>(
                //     stream: FirebaseFirestore.instance.collection('Ordenes').doc(widget.orderModel.oid).collection('Items').snapshots(),
                //     builder: (context, dataSnapshot) {
                //       if (!dataSnapshot.hasData) {
                //         return Center(
                //           child: CircularProgressIndicator(),
                //         );
                //       }
                //       return ListView.builder(
                //           physics: NeverScrollableScrollPhysics(),
                //           itemCount: dataSnapshot.data.docs.length,
                //           shrinkWrap: true,
                //           itemBuilder: (context, index,) {
                //             ItemModel item = ItemModel.fromJson(
                //                 dataSnapshot.data.docs[index].data());
                //             return sourceInfo2(item, context);
                //           }
                //       );
                //     }
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

  changeOrd(nuevo) {
    setState(() {
      order = nuevo;
    });

    return nuevo;
  }

  popUp() {
    showDialog(
        builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            // title: Text('Su pago ha sido aprobado.'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Text('¿Estas seguro que deseas cancelar la orden?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: RaisedButton(
                                onPressed: () {
                                  // confirmaCancel();
                                  // showConfirmationDialog(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConfirmCancel(
                                              orderModel: order,
                                              petModel: widget.petModel,
                                              defaultChoiceIndex:
                                                  widget.defaultChoiceIndex,
                                            )),
                                  );

                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFFEB9448),
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Text("Si",
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: RaisedButton(
                                onPressed: () {
                                  // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);

                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFF57419D),
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Text("No",
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ]))), context: context);
  }

  confirmaCancel() {
    showDialog(
        builder: (context) => AlertDialog(
            // title: Text('Su pago ha sido aprobado.'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                      '¿Cuál es el motivo por el que estás cancelando la Orden?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '1) ¿Seleccionaste el producto o servicio incorrecto? S/N',
                  ),
                  Row(
                    children: [
                      Text('Si', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )),
        ]))), context: context);
  }

  showConfirmationDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: ListView(
                padding: EdgeInsets.all(8.0),
                children: _texts
                    .map((text) => CheckboxListTile(
                          activeColor: Colors.pink,
                          title: Text(text),
                          value: _isChecked,
                          onChanged: (val) {
                            setState(() {
                              _isChecked = val;
                            });
                          },
                        ))
                    .toList(),
              ),
              actions: <Widget>[
                SizedBox(
                    width: 300,
                    child: RaisedButton(
                      color: Colors.blue,
                      onPressed: () => () {
                        debugPrint("upload image");
                      },
                      child: Text('Upload'),
                    ))
              ],
            );
          },
        );
      },
    );
  }

  Widget sourceInfo(
    PetModel model,
    BuildContext context,
  ) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    String formatted = formatter.format(widget.orderModel.createdOn.toDate());

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          decoration: BoxDecoration(
              color: Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: <Widget>[
                        Material(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: model == null
                                  ? NetworkImage(PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userAvatarUrl))
                                  : NetworkImage(model.petthumbnailUrl),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Nombre: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.nombre,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Mascota: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.especie,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Raza: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.raza,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Número de orden: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.orderModel.oid,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'Fecha de la orden: $formatted',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Proveedor: '),
                                    Text(ali.nombreComercial),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Teléfono móvil: '),
                                    Text(ali.telefono),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Correo: '),
                                    Text(ali.email),
                                  ],
                                ),
                              ],
                            );
                          });
                    }),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(widget.orderModel.tipoOrden),
                    Text(' :'),
                    Text(widget.orderModel.titulo),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(widget.orderModel.fecha != null
                            ? 'Fecha desde: '
                            : ''),
                        Text(widget.orderModel.fecha != null
                            ? widget.orderModel.fecha
                            : ''),
                      ],
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    // Text('hasta: $formatted'),
                  ],
                ),
                Row(
                  children: [
                    Text(widget.orderModel.hora != null ? 'Hora: ' : ''),
                    Text(widget.orderModel.hora != null
                        ? widget.orderModel.hora
                        : ''),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text('Monto: \$'),
                    Text(widget.orderModel.precio.toString()),
                  ],
                ),
                Row(
                  children: [
                    Text('Estatus: '),
                    Text(widget.orderModel.status),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: RaisedButton(
                    onPressed: () {
                      Timestamp stamp = widget.orderModel.date;
                      DateTime date = stamp.toDate();
                      DateTime now = DateTime.now(); // current time

                      if (now.isBefore(date)) {
                        popUp();
                      } else {}
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Colors.red,
                    padding: EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Cancelar',
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 14.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo2(
    ItemModel item,
    BuildContext context,
  ) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    String formatted = formatter.format(widget.orderModel.createdOn.toDate());

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          decoration: BoxDecoration(
              color: Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Aliados')
                        .doc(item.aliadoId)
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Proveedor: '),
                                    Text(ali.nombreComercial),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Teléfono móvil: '),
                                    Text(ali.telefono),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Correo: '),
                                    Text(ali.email),
                                  ],
                                ),
                              ],
                            );
                          });
                    }),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(widget.orderModel.tipoOrden),
                    Text(' :'),
                    Text(item.titulo),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text('Monto: \$'),
                    Text(item.precio.toString()),
                  ],
                ),
                Row(
                  children: [
                    Text('Estatus: '),
                    Text(widget.orderModel.status),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
