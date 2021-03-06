import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
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
import 'package:pet_shop/Ordenes/ordeneshome.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

import 'newordeneshome.dart';

class ConfirmCancel extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final OrderModel orderModel;
  final int defaultChoiceIndex;

  ConfirmCancel(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.orderModel,
      this.defaultChoiceIndex});

  @override
  _ConfirmCancelState createState() => _ConfirmCancelState();
}

class _ConfirmCancelState extends State<ConfirmCancel> {
  PetModel model;
  CartModel cart;
  Producto producto;
  OrderModel order;
  bool _value = false;
  bool _value2 = false;
  bool _value3 = false;
  bool _value4 = false;
  bool _value5 = false;
  bool _value6 = false;
  bool _value7 = true;
  bool _value8 = false;
  bool _isChecked = false;
  String username = 'TPP3-EC-SERVER';
  String secretKey = 'JdXTDl2d0o0B8ANZ1heJOq7tf62PC6';
  dynamic time;
  String basicAuth;
  String uniq;


  @override
  void initState() {
    super.initState();
    // _getOrderStatus();
    setState(() {
      var timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      time = timestamp.toString();


      print('el tiempoooooo $time');

      uniq = sha256.convert(utf8.encode(secretKey+time)).toString();
      basicAuth = base64Encode(utf8.encode('$username;$time;$uniq'));
      print(basicAuth);
    });

  }

  refundPaymentezCard() async {
    try {
      var json = '{"transaction": {"id": "${widget.orderModel.pagoId}"},"more_info": true}';
      var url =
      ("https://ccapi-stg.paymentez.com/v2/transaction/refund/");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Auth-Token": basicAuth,
      };
      Response res =
      await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = await res.statusCode;
      var nuevo = await jsonDecode(res.body);


      setState(() {
        // response = statusCode.toString();
        // clientes = res.body;
        print(statusCode);
        print('el cuerpo es ${res.body}');


      });


      if (nuevo['status'] == 'success') {

        FirebaseFirestore.instance
            .collection('Ordenes')
            .doc(widget.orderModel.oid)
            .update({"status": "Cancelada"}).then((result) {
          print("Orden Cancelada");
        }).catchError((onError) {
          print("onError");
        });

        Navigator.of(context, rootNavigator: true).pop();
        // 'Se ha eliminado tu tarjeta ${selectedobscurecard}'
        var orden = widget.orderModel.oid;
        var precio = widget.orderModel.precio;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewOrdenesHome(
                defaultChoiceIndex: widget.defaultChoiceIndex,
                petModel: widget.petModel,
              )),
        );
        showDialog(
          builder: (context) => AlertDialog(
            // title: Text('Su pago ha sido aprobado.'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.91,
                    decoration: BoxDecoration(
                        color: Color(0xFF57419D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFBDD7D6),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                              'Tu Orden N.$orden por ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}$precio ha sido CANCELADA. En las pr??ximas horas recibir??s tu devoluci??n del monto.',
                              style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          context: context,
        );
      }
      else{
        ErrorMessage(context, nuevo['error']['type']);

      }

      // }

    } catch (e) {
      print(e.message);
      return null;
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        "Cancelar orden",
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
                  height: _screenHeight * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                              '??Cu??l es el motivo por el que est??s cancelando la Orden?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                  child: Text(
                                      '1) ??Seleccionaste el producto o servicio incorrecto? S/N',
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Si',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value = value;
                                      if (value == true) {
                                        _value2 = false;
                                      } else {}
                                    });
                                  }),
                              Text('No',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value2,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value2 = value;
                                      if (value == true) {
                                        _value = false;
                                      } else {}
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                  child: Text(
                                      '2) ??Mala experiencia con el proveedor? S/N',
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Si',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value3,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value3 = value;
                                      if (value == true) {
                                        _value4 = false;
                                      } else {}
                                    });
                                  }),
                              Text('No',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value4,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value4 = value;
                                      if (value == true) {
                                        _value3 = false;
                                      } else {}
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                  child: Text(
                                      '3) ??Est??s inconforme con el precio? S/N',
                                      style: TextStyle(fontSize: 16))),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Si',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value5,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value5 = value;
                                      if (value == true) {
                                        _value6 = false;
                                      } else {}
                                    });
                                  }),
                              Text('No',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Checkbox(
                                  value: _value6,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value6 = value;
                                      if (value == true) {
                                        _value5 = false;
                                      } else {}
                                    });
                                  }),
                            ],
                          ),





                          PetshopApp.sharedPreferences.getString(PetshopApp.userPais) == 'Ecuador' ?
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                      child: Text(
                                          '4) ??Quieres la devoluci??n en Pet Points para futuras compras ?? la devoluci??n del dinero a tu tarjeta?',
                                          style: TextStyle(fontSize: 16))),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Pet Points',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Checkbox(
                                      value: _value7,
                                      activeColor: Color(0xFF57419D),
                                      onChanged: (bool value) {
                                        setState(() {
                                          _value7 = value;
                                          if (value == true) {
                                            _value8 = false;
                                          } else {}
                                        });
                                      }),
                                  Text('Devoluci??n de dinero',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Checkbox(
                                      value: _value8,
                                      activeColor: Color(0xFF57419D),
                                      onChanged: (bool value) {
                                        setState(() {
                                          _value8 = value;
                                          if (value == true) {
                                            _value7 = false;
                                          } else {}
                                        });
                                      }),
                                ],
                              ),
                            ],
                          ) : Container(),


                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 360,
                  child: RaisedButton(
                    onPressed: () {
                      if ((_value == true || _value2 == true) &&
                          (_value3 == true || _value4 == true) &&
                          (_value5 == true || _value6 == true)&&
                          (_value7 == true || _value8 == true)) {
                        if(_value7== true){
                          CancelOrden();
                        }
                        if(_value8== true){
                          refundPaymentezCard();
                        }

                      } else {
                        ErrorMessage(
                            context, 'Por favor seleccione todos los campos');
                      }
                    },
                    // uploading ? null : ()=> uploadImageAndSavePetInfo(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.red,
                    padding: EdgeInsets.all(15.0),
                    child: Text("Cancelar orden",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Colors.white,
                            fontSize: 22.0)),
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

  Future<void> ErrorMessage(BuildContext context, String error) async {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 170,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red, size: 55.0),
                    SizedBox(height: 20.0),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  CancelOrden() {
    setState(() {
      FirebaseFirestore.instance
          .collection('Ordenes')
          .doc(widget.orderModel.oid)
          .update({"status": "Cancelada"}).then((result) {
        print("Orden Cancelada");
      }).catchError((onError) {
        print("onError");
      });
      double acumulado =
          (widget.orderModel.precio / 0.01) - widget.orderModel.precio;
      var likeRef = FirebaseFirestore.instance
          .collection("Due??os")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection("Petpoints")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
      likeRef.update({
        'ppAcumulados': FieldValue.increment(acumulado.round().toInt()),
      });
      var orden = widget.orderModel.oid;
      var precio = widget.orderModel.precio;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewOrdenesHome(
              defaultChoiceIndex: widget.defaultChoiceIndex,
              petModel: widget.petModel,
            )),
      );
      showDialog(
        builder: (context) => AlertDialog(
          // title: Text('Su pago ha sido aprobado.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.91,
                  decoration: BoxDecoration(
                      color: Color(0xFF57419D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFBDD7D6),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                            'Tu Orden N.$orden por ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}$precio ha sido CANCELADA. En las pr??ximas horas recibir??s tu devoluci??n en Pet Points, para que puedas comprar otro servicio, producto o promoci??n cuando desees',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        context: context,
      );
    });
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
                          '??Cu??l es el motivo por el que est??s cancelando la Orden?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '1) ??Seleccionaste el producto o servicio incorrecto? S/N',
                      ),
                      Row(
                        children: [
                          Text('Si',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )),
            ]))),
        context: context);
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
                                  ? Image.network(
                                      PetshopApp.sharedPreferences
                                          .getString(PetshopApp.userAvatarUrl),
                                      errorBuilder:
                                          (context, object, stacktrace) {
                                        return Container();
                                      },
                                    ).image
                                  : Image.network(
                                      model.petthumbnailUrl,
                                      errorBuilder:
                                          (context, object, stacktrace) {
                                        return Container();
                                      },
                                    ).image,
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
                      'N??mero de orden: ',
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
                                    Text('Tel??fono m??vil: '),
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
                    onPressed: () {},
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
                                    Text('Tel??fono m??vil: '),
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
                // SizedBox(
                //   width: 100,
                //   height: 30,
                //   child: RaisedButton(
                //     onPressed: () {
                //
                //     },
                //
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5)),
                //     color: Colors.red,
                //
                //     padding: EdgeInsets.all(0.0),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children:
                //       [
                //         Text('Cancelar', style: TextStyle(
                //             fontFamily: 'Product Sans',
                //             color: Colors.white,
                //             fontSize: 14.0)),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
