import 'dart:io';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/Models/plan.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

double width;

class PlanBasicoHome extends StatefulWidget {
  final PetModel petModel;
  final PlanModel planModel;
  final int defaultChoiceIndex;
  PlanBasicoHome({this.petModel, this.planModel, this.defaultChoiceIndex});

  @override
  _PlanBasicoHomeState createState() => _PlanBasicoHomeState();
}

class _PlanBasicoHomeState extends State<PlanBasicoHome> {
  PetModel model;
  Color color;
  bool _isSelected;
  List<String> _choices;
  int _defaultChoiceIndex;
  File _imageFile;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  String tituloCategoria = "Plan";
  PlanModel plan;
  String _tituloCategoriaOrden;
  dynamic _totalPrice;

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    changePlan(widget.planModel);
    _isSelected = false;
    _defaultChoiceIndex = 0;
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
                        widget.planModel.planid,
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
                  width: _screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                widget.planModel.detallesCompletos.length,
                            itemBuilder: (BuildContext context, int i) {
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                // child: Expanded(
                                child: Text(
                                    widget.planModel.detallesCompletos[i],
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontSize: 16.0)),
                                // ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                widget.planModel.planid != 'Plan Gratis'
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xFFBDD7D6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFFBDD7D6),
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tarifa Mensual',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'S/',
                                              style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            Text(
                                              (widget.planModel.montoMensual *
                                                          0.11 +
                                                      widget.planModel
                                                          .montoMensual)
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tarifa Anual',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'S/',
                                              style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            Text(
                                              (widget.planModel.montoAnual *
                                                          0.11 +
                                                      widget
                                                          .planModel.montoAnual)
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tarifa mensual por pago anual',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'S/',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              (widget.planModel.montoMensual)
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tarifa anual con descuento',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'S/',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              (widget.planModel.montoAnual)
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      )
                    : Container(),
                widget.planModel.planid != 'Plan Gratis'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: _screenWidth * 0.4,
                              child: RaisedButton(
                                onPressed: () {
                                  // AddOrder(context, cart);

                                  // Navigator.push(
                                  //   context,
                                  //
                                  //   MaterialPageRoute(builder: (context) => StoreHome()),
                                  // );

                                  showDialog(
                                      builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          // title: Text('Su pago ha sido aprobado.'),
                                          content: SingleChildScrollView(
                                              child: ListBody(
                                                  children: <Widget>[
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                            'Indique su opción de pago preferida',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6.0),
                                                              child: SizedBox(
                                                                width:
                                                                    _screenWidth *
                                                                        0.29,
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () {
                                                                    // AddOrder(productId, context, widget.planModel.montoMensual, widget.planModel.planid);
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                    _totalPrice = widget
                                                                        .planModel
                                                                        .montoMensual
                                                                        .toInt();
                                                                    _tituloCategoriaOrden =
                                                                        'Plan Mensual';
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PaymentPage(
                                                                                petModel: model,
                                                                                planModel: plan,
                                                                                tituloCategoria: _tituloCategoriaOrden,
                                                                                totalPrice: _totalPrice,
                                                                                defaultChoiceIndex: widget.defaultChoiceIndex,
                                                                                onSuccess: _respuestaPago,
                                                                              )),
                                                                    );
                                                                  },
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  color: Color(
                                                                      0xFFEB9448),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                          "Pago mensual",
                                                                          style: TextStyle(
                                                                              fontFamily: 'Product Sans',
                                                                              color: Colors.white,
                                                                              fontSize: 15.0)),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              'S/',
                                                                              style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold)),
                                                                          Text(
                                                                              widget.planModel.montoMensual.toString(),
                                                                              style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                width:
                                                                    _screenWidth *
                                                                        0.29,
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () {
                                                                    // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                    _totalPrice = widget
                                                                        .planModel
                                                                        .montoAnual
                                                                        .toInt();
                                                                    _tituloCategoriaOrden =
                                                                        'Plan Anual';
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PaymentPage(
                                                                                petModel: widget.petModel,
                                                                                planModel: widget.planModel,
                                                                                tituloCategoria: _tituloCategoriaOrden,
                                                                                totalPrice: _totalPrice,
                                                                                onSuccess: _respuestaPago,
                                                                              )),
                                                                    );
                                                                  },
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  color: Color(
                                                                      0xFF57419D),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10.0),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                          "Pago anual",
                                                                          style: TextStyle(
                                                                              fontFamily: 'Product Sans',
                                                                              color: Colors.white,
                                                                              fontSize: 15.0)),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              'S/',
                                                                              style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold)),
                                                                          Text(
                                                                              widget.planModel.montoAnual.toString(),
                                                                              style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                              ]))),
                                      context: context);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFFEB9448),
                                padding: EdgeInsets.all(10.0),
                                child: Text("Contratar Plan",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        color: Colors.white,
                                        fontSize: 18.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: _screenWidth * 0.4,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFF57419D),
                                padding: EdgeInsets.all(10.0),
                                child: Text("Volver",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        color: Colors.white,
                                        fontSize: 18.0)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: _screenWidth * 0.4,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            color: Color(0xFF57419D),
                            padding: EdgeInsets.all(10.0),
                            child: Text("Volver",
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white,
                                    fontSize: 18.0)),
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

  Future<void> _respuestaPago(
      String pagoId, String estadoPago, dynamic montoAprobado) async {
    String estadoOrden;
    if (estadoPago == PagoEnum.pagoAprobado) {
      estadoOrden = OrdenEnum.aprobada;
    } else {
      estadoOrden = OrdenEnum.pendiente;
    }

    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    var addplan = FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Plan')
        .doc(widget.petModel.mid);
    var date = new DateTime.now();
    var newDateYear = new DateTime(date.year + 1, date.month, date.day);
    var newDateMonth = new DateTime(date.year, date.month + 1, date.day);
    addplan.set({
      "pagoId": pagoId,
      "status": 'Activo',
      "precio": _totalPrice,
      "createdOn": DateTime.now(),
      "tipoPlan": widget.planModel.planid,
      "oid": productId,
      "mid": widget.petModel.mid,
      "vigencia_desde": DateTime.now(),
      "vigencia_hasta":
          _tituloCategoriaOrden == 'Plan Mensual' ? newDateMonth : newDateYear,
    });
    databaseReference.set({
      "pagoId": pagoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": _totalPrice,
      "status": estadoOrden,
      "tipoOrden": 'Plan',
      'createdOn': DateTime.now(),
      "tipoPlan": widget.planModel.planid,
      "mid": widget.petModel.mid,
      "vigencia_desde": DateTime.now(),
      "vigencia_hasta":
          _tituloCategoriaOrden == 'Plan Mensual' ? newDateMonth : newDateYear,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
    });
    // try {
    //   var json =
    //       '{"filial": "01","id": "$productId","cliente": "${PetshopApp.sharedPreferences.getString(PetshopApp.userDocId)}","proveedor": "20606516453","emision": "$epDate","formapag": "$formapag","moneda": "PEN","items": [{ "producto": "${widget.planModel.planid}","cantidad": 1,"precio": ${widget.totalPrice}] }';
    //   var url = ("https://epcloud.ebc.pe.grupoempodera.com/api/?cliente");
    //   Map<String, String> headers = {"Content-type": "application/json"};
    //   Response res = await http.post(Uri.parse(url), headers: headers, body: json);
    //   int statusCode = res.statusCode;
    //   setState(() {
    //     // response = statusCode.toString();
    //     print(statusCode);
    //   });
    // } catch (e) {
    //   print(e.message);
    //   return null;
    // }
    //OrderMessage(context, outcomeMsg);
  }

  AddOrder(String itemID, BuildContext context, int precio, planid) async {
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    var addplan = FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Plan')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));

    // databaseReference.collection('Items').doc(itemID).setData({
    //   "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
    //   "nombreComercial": widget.aliadoModel.nombreComercial,
    //   "petthumbnailUrl": widget.petModel.petthumbnailUrl,
    //   "titulo": widget.serviceModel.titulo,
    //   "oid": productId,
    //   "aliadoId": widget.serviceModel.aliadoId,
    //   "servicioid": itemID,
    //   "date": date,
    //   "hora": hora,
    //   "fecha": fecha == null ? fecha : fecha.trim(),
    //   "precio": int.parse(
    //       (widget.serviceModel.precio + recojo + delivery).toString()),
    //   "mid": widget.petModel.mid,
    //   "tieneDelivery": _value2,
    //   "delivery": delivery,
    //   "tieneDomicilio": _value,
    //   "domicilio": recojo,
    // });
    addplan.set({
      "status": 'Activo',
      "precio": int.parse((precio).toString()),
      "createdOn": DateTime.now(),
      "tipoPlan": planid,
      "oid": productId,
    });
    databaseReference.set({
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse((precio).toString()),
      "tipoOrden": 'Plan',
      'createdOn': DateTime.now(),
      "tipoPlan": planid,
    }).then((value) => databaseReference.snapshots().listen(onData));

    // var val=[];   //blank list for add elements which you want to delete
    // val.add(hora);
    // db.collection("Localidades").doc(widget.serviceModel.localidadId).collection("Servicios").doc(widget.serviceModel.servicioId)
    //     .collection("Agenda").doc(fecha).updateData({
    //
    //   "horasDia":FieldValue.arrayRemove(val) });

    // var result = await MercadoPagoMobileCheckout.startCheckout("TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3", "698748168-e3a21e6a-6e36-43d3-911f-8eff284f782e");
  }

  void onData(DocumentSnapshot event) async {
    // if(event.data['status'] == 'pagada') {
    //   setState(() {
    //     _loading = false;
    //     _message = event.data['message'];
    //   });
    // }
    //  setState(() {
    //    procesando = true;
    //  });
    //
    //  if(procesando == true) {
    //    showDialog(context: context, child:
    //    new ChoosePetAlertDialog(message: "Procesando su pago, por favor espere...",)
    //    );
    //  }
    // showDialog(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (BuildContext context) {
    //     dialogContext = context;
    //     return Dialog(
    //       child: SizedBox(
    //         height: 100,
    //         child: new Column(
    //           children: [
    //             new SizedBox(height: 30,),
    //             new CircularProgressIndicator(),
    //             new SizedBox(height: 10,),
    //             new Text("Procesando su orden, por favor espere..."),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );

    // print(event.data);
    // if (event.data['preference_id'] != null) {
    //   // Navigator.pop(dialogContext);
    //   // Navigator.of(context, rootNavigator: true).pop();
    //   // var result = await MercadoPagoMobileCheckout.startCheckout(
    //   //     "TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3",
    //   //     event.data['preference_id']);
    //
    //   print(result);
    //
    //   if (result.status == 'approved') {
    //
    //     FirebaseFirestore.instance.collection('Ordenes').doc(productId).updateData(
    //         {'preference_id': FieldValue.delete()}).whenComplete(() {});
    //
    //     showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         // title: Text('Su pago ha sido aprobado.'),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Container(
    //                 width: MediaQuery.of(context).size.width * 0.91,
    //                 decoration: BoxDecoration(
    //                     color: Color(0xFF57419D),
    //                     borderRadius: BorderRadius.circular(10),
    //                     border: Border.all(
    //                       color: Color(0xFFBDD7D6),
    //                     )),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Column(
    //                     children: [
    //                       Text(
    //                         'Tu pago ha sido procesado con éxito.',
    //                         style: TextStyle(
    //                             color: Colors.white,
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 12),
    //                       ),
    //                       SizedBox(
    //                         height: 10,
    //                       ),
    //                       Text(
    //                           'Pronto recibirás un correo con la confirmación de tu compra.. Tu afiliación ha si registrada exitosamente, ya podrás disfrutar de los beneficios de tu plan',
    //                           style:
    //                           TextStyle(color: Colors.white, fontSize: 12)),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               // Container(
    //               //   width: MediaQuery.of(context).size.width*0.91,
    //               //   decoration: BoxDecoration(
    //               //       color: Colors.white,
    //               //       borderRadius: BorderRadius.circular(10),
    //               //       border: Border.all(color: Color(0xFFBDD7D6),)),
    //               //   child: Padding(
    //               //     padding: const EdgeInsets.all(8.0),
    //               //     child: Column(
    //               //       crossAxisAlignment: CrossAxisAlignment.start,
    //               //       children: [
    //               //         Text('Items', style: TextStyle(color: Color(0xFF57419D), fontWeight: FontWeight.bold, fontSize: 12),),
    //               //         SizedBox(height: 10,),
    //               //         Row(
    //               //           children: [
    //               //
    //               //
    //               //           ],
    //               //         ),
    //               //       ],
    //               //     ),
    //               //   ),
    //               //
    //               // ),
    //               // SizedBox(height: 10,),
    //               Container(
    //                 width: MediaQuery.of(context).size.width * 0.91,
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(10),
    //                     border: Border.all(
    //                       color: Color(0xFFBDD7D6),
    //                     )),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         'Metodo de pago',
    //                         style: TextStyle(
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 12),
    //                       ),
    //                       SizedBox(
    //                         height: 10,
    //                       ),
    //                       Row(
    //                         children: [
    //                           Text(
    //                               result.paymentTypeId == 'credit_card'
    //                                   ? 'Tarjeta de credito:'
    //                                   : result.paymentTypeId == 'debit_card'
    //                                   ? 'Tarjeta de debito:'
    //                                   : result.paymentTypeId,
    //                               style: TextStyle(
    //                                   color: Colors.black, fontSize: 12)),
    //                           SizedBox(
    //                             width: 10,
    //                           ),
    //                           Text(result.paymentMethodId,
    //                               style: TextStyle(
    //                                   color: Colors.black, fontSize: 12)),
    //                         ],
    //                       ),
    //                       Row(
    //                         children: [
    //                           Text(
    //                             'Orden N°',
    //                             style: TextStyle(
    //                                 fontSize: 12,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Text(
    //                             productId,
    //                             style: TextStyle(
    //                                 fontSize: 12, fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //
    //                       SizedBox(
    //                         height: 8,
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             'Tu cargo',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.end,
    //                             children: [
    //                               Text(
    //                                 'S/ ',
    //                                 style: TextStyle(
    //                                     fontSize: 12.0,
    //                                     color: Color(0xFF57419D),
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                               Text(
    //                                 (result.transactionAmount).toString(),
    //                                 style: TextStyle(
    //                                     fontSize: 18.0,
    //                                     color: Color(0xFF57419D),
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   }
    //   if (result.status != 'approved') {
    //     showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         title: Row(
    //           children: [
    //             Icon(
    //               Icons.cancel,
    //               color: Colors.red,
    //             ),
    //             SizedBox(
    //               width: 10,
    //             ),
    //             Text(
    //               'Su pago ha sido rechazado.',
    //               style: TextStyle(fontSize: 14),
    //             ),
    //           ],
    //         ),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               // Text('This is a demo alert dialog.'),
    //               // Text('Would you like to approve of this message?'),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //
    //     setState(() {
    //       db
    //           .collection('Ordenes')
    //           .doc(productId)
    //           .collection('Items')
    //           .getDocuments()
    //           .then((snapshot) {
    //         for (DocumentSnapshot doc in snapshot.documents) {
    //           doc.reference.delete();
    //         }
    //         ;
    //       });
    //       db.collection('Ordenes').doc(productId).delete();
    //     });
    //   }
    // }
  }

  changePlan(otro) {
    setState(() {
      plan = otro;
    });
    return otro;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
