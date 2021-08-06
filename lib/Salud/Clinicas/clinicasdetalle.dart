import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/clinicas.dart';
import 'package:pet_shop/Models/daymodel.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Ordenes/ordeneshome.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Salud/Citas/citaspage.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

int cantidad = 1;

double width;

class ClinicasDetalle extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final ClinicasModel clinicasModel;
  final int defaultChoiceIndex;

  ClinicasDetalle(
      {this.petModel,
      this.serviceModel,
      this.aliadoModel,
      this.locationModel,
      this.clinicasModel,
      this.defaultChoiceIndex});

  @override
  _ClinicasDetalleState createState() => _ClinicasDetalleState();
}

class _ClinicasDetalleState extends State<ClinicasDetalle> {
  String _categoria;
  bool _checked = false;
  Timestamp date;
  double totalPet = 0;
  String hora;
  String fecha = '0';
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
  String tituloCategoria = "Servicio";

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    changePet(widget.petModel);
    changePro(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);

    deleteDate();

    super.initState();
  }

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
                        "Clinicas",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.clinicasModel.nombreComercial,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.clinicasModel.avatar,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stacktrace) {
                              return Container();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: 100.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(widget.clinicasModel.direccion,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.left),
                              Text(widget.clinicasModel.telefono,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.left),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Horario de atención",
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        SizedBox(
                          child: RaisedButton(
                            onPressed: () {},
                            color: Color(0xFFBDD7D6),
                            child: Text(
                              'Pronto',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Servicios",
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: _screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("CategoriasServicios")
                                  .doc('Salud')
                                  .collection('Servicios')
                                  .where('categoriaId', isEqualTo: 'Salud')
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (!dataSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  List<DropdownMenuItem> list = [];
                                  for (int i = 0;
                                      i < dataSnapshot.data.docs.length;
                                      i++) {
                                    DocumentSnapshot product =
                                        dataSnapshot.data.docs[i];

                                    list.add(
                                      DropdownMenuItem(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              50, 0, 0, 0),
                                          child: Text(
                                            product.id,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        value: "${product.id}",
                                      ),
                                    );
                                  }
                                  return Container(
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
                                                  'Elige el servicio',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              items: list,
                                              isExpanded: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  _categoria = value;
                                                });
                                              },
                                              value: _categoria),
                                          Container(
                                            width: 20,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 10),
                                            // child: Image.asset(
                                            //   'diseñador/drawable/Grupo197.png',
                                            // )
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }),
                          SizedBox(
                            height: 5.0,
                          ),
                          Center(
                            child: Container(
                              width: 200,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CitasPage(
                                            petModel: widget.petModel)),
                                  );
                                },
                                // uploading ? null : ()=> uploadImageAndSavePetInfo(),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Color(0xFFEB9448),
                                padding: EdgeInsets.all(6.0),
                                child: Text("Ver médicos",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        color: Colors.white,
                                        fontSize: 15.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
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

  AddOrder(String itemID, BuildContext context) async {
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference.collection('Items').doc(itemID).set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": widget.serviceModel.titulo,
      "oid": productId,
      "aliadoId": widget.serviceModel.aliadoId,
      "servicioid": itemID,
      "date": date,
      "hora": hora,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "precio": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "mid": widget.petModel.mid,
      "tieneDelivery": _value2,
      "delivery": delivery,
      "tieneDomicilio": _value,
      "domicilio": recojo,
      "nombre": widget.petModel.nombre,
    });
    databaseReference.set({
      "aliadoId": widget.serviceModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "tipoOrden": 'Servicio',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "ppGeneradosD": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "date": date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "localidadId": widget.locationModel.localidadId,
    });
    // then((value) => databaseReference.snapshots().listen(onData));
    // sendEmail(
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //     productId,
    //     ali.avatar);
    // sendEmail(PetshopApp.sharedPreferences.getString(PetshopApp.userEmail), PetshopApp.sharedPreferences.getString(PetshopApp.userName), productId, ali.avatar);
    // var val=[];   //blank list for add elements which you want to delete
    // val.add(hora);
    // db.collection("Localidades").doc(widget.serviceModel.localidadId).collection("Servicios").doc(widget.serviceModel.servicioId)
    //     .collection("Agenda").doc(fecha).updateData({
    //
    //   "horasDia":FieldValue.arrayRemove(val) });

    // var result = await MercadoPagoMobileCheckout.startCheckout("TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3", "698748168-e3a21e6a-6e36-43d3-911f-8eff284f782e");
  }

// addItemtoCart(String itemID, String cant, String precio, BuildContext context)
// {
//
//   final databaseReference = FirebaseFirestore.instance;
//   databaseReference.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).collection('Cart').doc(productId)
//       .setData({
//     "aliadoid": widget.aliadoModel.aliadoId,
//     "oid": productId,
//     "uid":  PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
//     "precio": int.parse(precio),
//     "cantidad": int.parse(cant),
//     "productoId": itemID,
//     "mid": widget.petModel.mid,
//     "createdOn": DateTime.now(),
//     "promoid": widget.promotionModel.promoid,
//     "status": "Por confirmar",
//
//
//   });
//
//   setState(() {
//     productId = DateTime.now().millisecondsSinceEpoch.toString();
//   });

// List tempCartList = PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList);
// tempCartList.add(itemID);
//
// PetshopApp.firestore.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).updateData({
//   PetshopApp.userCartList: tempCartList,
// }).then((v){
//  Fluttertoast.showToast(msg: "Se ha agregado su producto al carrito.");
//  PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, tempCartList);
// });
// }
//
//
//
//
// }
//
//

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

    print(event.data);
    // if (event.data['preference_id'] != null) {
    //   // Navigator.pop(dialogContext);
    //   // Navigator.of(context, rootNavigator: true).pop();
    //   var result = await MercadoPagoMobileCheckout.startCheckout(
    //       "TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3",
    //       event.data['preference_id']);
    //
    //   print(result);
    //
    //   if (result.status == 'approved') {
    //     sendEmail(
    //         PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //         PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //         productId,
    //         ali.avatar);
    //     pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    //     var val = []; //blank list for add elements which you want to delete
    //     val.add(hora);
    //     db
    //         .collection("Localidades")
    //         .doc(widget.serviceModel.localidadId)
    //         .collection("Servicios")
    //         .doc(widget.serviceModel.servicioId)
    //         .collection("Agenda")
    //         .doc(fecha)
    //         .updateData({
    //       "horasDia": FieldValue.arrayRemove(val),
    //       "horasReservadas": FieldValue.arrayUnion(val),
    //     });
    //
    //     var likeRef = db
    //         .collection("Dueños")
    //         .doc(
    //             PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
    //         .collection("Petpoints")
    //         .doc(
    //             PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    //     likeRef.updateData({
    //       'ppAcumulados':
    //           FieldValue.increment(int.parse(result.transactionAmount)),
    //       'ppCanjeados': _value == true
    //           ? FieldValue.increment(ppAcumulados)
    //           : FieldValue.increment(0),
    //     });
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
    //                           'Pronto recibirás un correo con la confirmación de tu compra.. ',
    //                           style:
    //                               TextStyle(color: Colors.white, fontSize: 12)),
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
    //                                       ? 'Tarjeta de debito:'
    //                                       : result.paymentTypeId,
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
    //                       StreamBuilder<QuerySnapshot>(
    //                           stream: FirebaseFirestore.instance
    //                               .collection("Ordenes")
    //                               .doc(productId)
    //                               .collection('Items')
    //                               .where('uid',
    //                                   isEqualTo: PetshopApp.sharedPreferences
    //                                       .getString(PetshopApp.userUID)
    //                                       .toString())
    //                               .snapshots(),
    //                           builder: (context, dataSnapshot) {
    //                             if (!dataSnapshot.hasData) {
    //                               return Center(
    //                                 child: CircularProgressIndicator(),
    //                               );
    //                             }
    //                             return ListView.builder(
    //                                 physics: NeverScrollableScrollPhysics(),
    //                                 itemCount:
    //                                     dataSnapshot.data.docs.length,
    //                                 shrinkWrap: true,
    //                                 itemBuilder: (
    //                                   context,
    //                                   index,
    //                                 ) {
    //                                   ItemModel item = ItemModel.fromJson(
    //                                       dataSnapshot
    //                                           .data.documents[index].data);
    //                                   return Column(
    //                                     children: [
    //                                       SizedBox(
    //                                         child: Column(
    //                                           children: [
    //                                             Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Expanded(
    //                                                     child: Text(item.titulo,
    //                                                         style: TextStyle(
    //                                                             fontSize: 10,
    //                                                             color: Color(
    //                                                                 0xFF57419D),
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold),
    //                                                         textAlign: TextAlign
    //                                                             .left)),
    //                                                 Row(
    //                                                   children: [
    //                                                     Text(
    //                                                       'S/',
    //                                                       style: TextStyle(
    //                                                           fontSize: 10,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                       textAlign:
    //                                                           TextAlign.left,
    //                                                     ),
    //                                                     Text(
    //                                                         item.precio
    //                                                             .toString(),
    //                                                         style: TextStyle(
    //                                                             fontSize: 16,
    //                                                             color: Color(
    //                                                                 0xFF57419D),
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold),
    //                                                         textAlign:
    //                                                             TextAlign.left),
    //                                                   ],
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                       Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.start,
    //                                         children: [
    //                                           Text(item.nombreComercial,
    //                                               style:
    //                                                   TextStyle(fontSize: 10),
    //                                               textAlign: TextAlign.left),
    //                                         ],
    //                                       ),
    //                                       _value2 != null
    //                                           ? Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Text(
    //                                                   'Delivery',
    //                                                   style: TextStyle(
    //                                                       fontSize: 12.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                                 Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment.end,
    //                                                   children: [
    //                                                     Text(
    //                                                       'S/ ',
    //                                                       style: TextStyle(
    //                                                           fontSize: 12.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                     Text(
    //                                                       (delivery).toString(),
    //                                                       style: TextStyle(
    //                                                           fontSize: 18.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ],
    //                                             )
    //                                           : _value != null
    //                                               ? Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment
    //                                                           .spaceBetween,
    //                                                   children: [
    //                                                     Text(
    //                                                       'Domicilio',
    //                                                       style: TextStyle(
    //                                                           fontSize: 12.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                     Row(
    //                                                       mainAxisAlignment:
    //                                                           MainAxisAlignment
    //                                                               .end,
    //                                                       children: [
    //                                                         Text(
    //                                                           'S/ ',
    //                                                           style: TextStyle(
    //                                                               fontSize:
    //                                                                   12.0,
    //                                                               color: Color(
    //                                                                   0xFF57419D),
    //                                                               fontWeight:
    //                                                                   FontWeight
    //                                                                       .bold),
    //                                                         ),
    //                                                         Text(
    //                                                           (recojo)
    //                                                               .toString(),
    //                                                           style: TextStyle(
    //                                                               fontSize:
    //                                                                   18.0,
    //                                                               color: Color(
    //                                                                   0xFF57419D),
    //                                                               fontWeight:
    //                                                                   FontWeight
    //                                                                       .bold),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                                   ],
    //                                                 )
    //                                               : Container(),
    //                                       Divider(
    //                                         indent: 20,
    //                                         endIndent: 20,
    //                                         color: Color(0xFF57419D)
    //                                             .withOpacity(0.5),
    //                                       ),
    //                                     ],
    //                                   );
    //                                 });
    //                           }),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             'Petpoints Acreditados',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.end,
    //                             children: [
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

  void _planModalBottomSheet(BuildContext context) {
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
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sub total',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'S/ ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (widget.serviceModel.precio +
                                          recojo +
                                          delivery)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Pet Points',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 70.0,
                                  child: RaisedButton(
                                    onPressed: () {},
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    color: Color(0xFFBBD7D6),
                                    padding: EdgeInsets.all(0.0),
                                    child: Text(
                                        (ppAcumulados - ppCanjeados).toString(),
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Color(0xFF57419D),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Text(
                                '=',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xFF57419D),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 70.0,
                              child: RaisedButton(
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFFBBD7D6),
                                padding: EdgeInsets.all(0.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("S/",
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Color(0xFF57419D),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        (ppvalor * (ppAcumulados - ppCanjeados))
                                            .toStringAsPrecision(3),
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Color(0xFF57419D),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(
                                '¿Aplicar?',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xFF57419D),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Checkbox(
                                value: _value,
                                activeColor: Color(0xFF57419D),
                                onChanged: (bool value) {
                                  setState(() {
                                    _value = value;
                                    if (value) {
                                      totalPet = ppvalor *
                                          (ppAcumulados - ppCanjeados);
                                      setState(() {
                                        _value = true;
                                      });
                                    } else {
                                      _value = false;
                                      totalPet = 0;
                                    }
                                  });
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Descuento por PetPoints',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'S/ ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (totalPet).toStringAsPrecision(3),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total a cancelar',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'S/ ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (widget.serviceModel.precio +
                                          recojo +
                                          delivery -
                                          totalPet)
                                      .toStringAsPrecision(3),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )));
        });
  }
}
