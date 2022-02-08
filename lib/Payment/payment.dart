import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_culqi/flutter_culqi.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/Card.dart';
import 'package:http/http.dart' as http;
import 'package:pet_shop/Models/PaymentezCard.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/carrito.dart';
import 'package:pet_shop/Models/culqiUser.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Models/plan.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Ordenes/newordeneshome.dart';
import 'package:pet_shop/Payment/Paymentez/pmtarjeta.dart';
import 'package:pet_shop/Payment/addcreditcard.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/usuario/usuarioinfo.dart';
import 'package:shortid/shortid.dart';

import 'AikonsPay/apcrearpago.dart';

class PaymentPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final ServiceModel serviceModel;
  final LocationModel locationModel;
  final AliadoModel aliadoModel;
  final String tituloCategoria;
  final String nombreComercial;
  final dynamic totalPrice;
  final String hora;
  final String fecha;
  final dynamic recojo;
  final dynamic delivery;
  final bool value;
  final bool value2;
  final bool value3;
  final Timestamp date;
  final PromotionModel promotionModel;
  final PlanModel planModel;
  final int defaultChoiceIndex;
  final Function(String, String, dynamic) onSuccess;

  PaymentPage({
    this.promotionModel,
    this.petModel,
    this.productoModel,
    this.cartModel,
    this.serviceModel,
    this.locationModel,
    this.aliadoModel,
    this.tituloCategoria,
    this.totalPrice,
    this.hora,
    this.recojo,
    this.delivery,
    this.fecha,
    this.value2,
    this.value3,
    this.value,
    this.date,
    this.planModel,
    this.defaultChoiceIndex,
    this.onSuccess,
    this.nombreComercial,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final pushProvider = PushNotificationsProvider();
  PlanModel plan;
  LocationModel location;
  ServiceModel service;
  PromotionModel pro;
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  int selectedIndex;
  String _prk;
  String selectedCardToken;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  String Date = DateTime.now().toString();

  String obscurecard;
  String selectedobscurecard;
  dynamic ppAcumulados = 0;
  dynamic ppCanjeados = 0;
  dynamic ppvalor = 0;
  // bool card = false;
  String outcomeMsg = 'Procesada';
  String type;
  String cardType;
  String cardBrand, cardNumLast;
  String pagoId, authCode;
  String outcomeMsgError = 'Hubo un problema con su pago';
  List _cartResults = [];
  String epDate;
  String formapag;
  String idCulqi;
  bool registroCompleto;
  int val = -1;
  String tarjetas;
  String clientes;
  String username = 'TPP3-EC-SERVER';
  String secretKey = 'JdXTDl2d0o0B8ANZ1heJOq7tf62PC6';
  dynamic time;
  String basicAuth;
  String uniq;
  List allResults = [];


  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // var mes = prueba[0]+prueba[1];
    // var ano = '20'+prueba.substring(3);
    // print('El año de la tarjeta es: $mes y $ano');
    changePet(widget.petModel);
    changeDet(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);
    changePro(widget.promotionModel);
    changeCart(widget.cartModel);
    changePlan(widget.planModel);
    _getPetpoints();
    _checkRegistro();
    setState(() {
      var timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      time = timestamp.toString();


      print('el tiempoooooo $time');

      uniq = sha256.convert(utf8.encode(secretKey+time)).toString();
      basicAuth = base64Encode(utf8.encode('$username;$time;$uniq'));
      print(basicAuth);
    });

    _getprK();
    showCards();

  }
  showCards() async {
    try {
      var url =
      ("https://ccapi-stg.paymentez.com/v2/card/list?uid=${PetshopApp.sharedPreferences.getString(PetshopApp.userUID)}");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Auth-Token": basicAuth,
      };
      Response res = await http.get(Uri.parse(url), headers: headers);
      int statusCode = await res.statusCode;
      var nuevo = await jsonDecode(res.body);
      PaymentezCardModel card = await PaymentezCardModel.fromJson(nuevo);

      Map<String, dynamic> data = jsonDecode(res.body);
      setState(() {
        // response = statusCode.toString();
        clientes = res.body;
        print(statusCode);
        print('el cuerpo es ${res.body}');
        print('Tarjetaaaa ${data['cards'][0]['bin']}');
        // print(card.cards[0].status);
      });

      // for (int i = 0; i < card.result_size; i++) {
      //   print(card.cards[i].status);
      allResults.add(PaymentezCardModel.fromJson(data));

      // }


    } catch (e) {
      print(e.message);
      return null;
    }
  }

  deletePaymentezCard(String token) async {
    try {
      var json = '{"card": {"token": "$token"},"user":{"id":"${PetshopApp.sharedPreferences.getString(PetshopApp.userUID)}"}}';
      var url =
      ("https://ccapi-stg.paymentez.com/v2/card/delete/");
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
        clientes = res.body;
        print(statusCode);
        print('el cuerpo es ${res.body}');

        // print(card.cards[0].status);
      });

      // for (int i = 0; i < card.result_size; i++) {
      //   print(card.cards[i].status);


      // }
      Navigator.of(context, rootNavigator: true).pop();
      // 'Se ha eliminado tu tarjeta ${selectedobscurecard}'
      OrderMessage(context, nuevo['message'] == 'card deleted' ? 'Se ha eliminado tu tarjeta ${selectedobscurecard}' : '${nuevo['error']['description']}');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentPage(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
      );
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  Widget sourceInfo2(PaymentezCardModel card, BuildContext context) {
    dynamic totalD = 0;
    double rating = 0;

    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: card.result_size,
            itemBuilder: (BuildContext context, int i) {
              return

              ListTile(
                leading: Radio(
                  value: i,
                  groupValue: val,
                  onChanged: (value) {
                    setState(() {
                      val = value;
                      selectedIndex = i;
                      selectedCardToken = card.cards[i].token;
                      selectedobscurecard = '****' + (card.cards[i].number);
                      print(selectedobscurecard);
                    });
                  },
                  activeColor: secondaryColor,
                ),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      card.cards[i].type == 'vi' ?
                      Image.asset(
                        'assets/images/visa.png',
                        fit: BoxFit.contain,
                        height: 40,
                        width: 60,
                      ) : card.cards[i].type == 'di' ?
                      Image.asset(
                        'assets/images/diners.png',
                        fit: BoxFit.contain,
                        height: 40,
                        width: 60,
                      ) : card.cards[i].type == 'mc' ?
                      Image.asset(
                        'assets/images/mastercard.png',
                        fit: BoxFit.contain,
                        height: 40,
                        width: 60,
                      ) : card.cards[i].type == 'ax' ?
                      Image.asset(
                        'assets/images/amex.png',
                        fit: BoxFit.contain,
                        height: 40,
                        width: 60,
                      ) : Icon(Icons.credit_card, size: 35,),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                          '**** ${card.cards[i].number}',
                            style: TextStyle(
                              color: Color(0xFF57419D),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Exp ${card.cards[i].expiry_month}/${card.cards[i].expiry_year}',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      selectedIndex == i ?
                      SizedBox(
                        width: 25.0,
                        height: 32,
                        child: RaisedButton(
                          onPressed: () {
                            showDialog(
                                builder: (context) => AlertDialog(
                                  // title: Text('Su pago ha sido aprobado.'),
                                    content: SingleChildScrollView(
                                        child:
                                        ListBody(children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                children: [
                                                  Text(
                                                      '¿Desea eliminar su tarjeta? terminada en $selectedobscurecard',
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                        child: SizedBox(
                                                          width:
                                                          MediaQuery.of(context).size.width * 0.25,
                                                          child: RaisedButton(
                                                            onPressed: () {
                                                              // AddOrder(productId, context, widget.planModel.montoMensual, widget.planModel.planid);
                                                              // deleteCard(card);
                                                              deletePaymentezCard(card.cards[i].token);
                                                              Navigator.of(
                                                                  context,
                                                                  rootNavigator:
                                                                  true)
                                                                  .pop();
                                                              _loadingDialog(
                                                                  context);
                                                            },
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                            color:
                                                            Color(0xFFEB9448),
                                                            padding:
                                                            EdgeInsets.all(
                                                                10.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Text("Confirmar",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                        'Product Sans',
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                        16.0)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                        child: SizedBox(
                                                          width:
                                                          MediaQuery.of(context).size.width * 0.25,
                                                          child: RaisedButton(
                                                            onPressed: () {
                                                              // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                                                              Navigator.of(
                                                                  context,
                                                                  rootNavigator:
                                                                  true)
                                                                  .pop();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    5)),
                                                            color:
                                                            Color(0xFF57419D),
                                                            padding:
                                                            EdgeInsets.all(
                                                                10.0),
                                                            child: Column(
                                                              children: [
                                                                Text("Cancelar",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                        'Product Sans',
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                        16.0)),
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
                          color: Colors.red,
                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text("Eliminar",
                              //     style: TextStyle(
                              //       fontFamily: 'Product Sans',
                              //       color: Colors.white,
                              //       fontSize: 14.0,
                              //     )),
                              Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ): Container(),
                    ],
                  ),
                )
              )
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                //   child: Container(
                //     width: MediaQuery.of(context)
                //         .size
                //         .width *
                //         0.91,
                //     height: 60,
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius:
                //         BorderRadius.circular(10),
                //         border: Border.all(
                //           color: Colors.white,
                //         )),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           // Container(width: MediaQuery.of(context).size.width * 0.28, child: Text(plan.coberturas[i]['tipo'], style: TextStyle(fontSize: 15,color: primaryColor, ),),),
                //           Icon(Icons.check_circle, color: secondaryColor, size: 30,),
                //           SizedBox(width: 8,),
                //           Container(width: MediaQuery.of(context).size.width * 0.6, child: Text(card.cards[i].status, style: TextStyle(fontSize: 15,color: primaryColor, fontWeight: FontWeight.bold),)),
                //
                //
                //         ],
                //       ),
                //     ),
                //   ),
                // )


              ;


            }),
      ),
    );
  }

  getAliadoSnapshots(aliadoId) async {
    var data = await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .get();
    setState(() {
      _cartResults = data.docs;
    });
    addAllItemsToOrder(_cartResults);

    return data.docs;
  }

  Future<List<ItemModel>> getAllSnapshots(aliadoId) async {
    var data = await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .get();

    var documentos = data.docs;
    List<ItemModel> listaItems = [];
    documentos.forEach((doc) {
      ItemModel item = ItemModel.fromJson(doc.data());
      listaItems.add(item);
    });

    return listaItems;
  }



  @override
  Widget build(BuildContext context) {
    if (PetshopApp.esPeru()) {
      return _culqiWidget(context);
    } else if (PetshopApp.esVenezuela()) {
      return APCrearPago(
        aliadoModel: widget.aliadoModel,
        petModel: widget.petModel,
        defaultChoiceIndex: widget.defaultChoiceIndex,
        totalPrice: widget.totalPrice,
        onSuccess: widget.onSuccess
      );
    } else if (PetshopApp.esEcuador()) {
      return _paymentezWidget(context);
    }

    else {
      return Container();
    }
  }

  Widget _culqiWidget(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    // CulqiTokenizer tokenizer = CulqiTokenizer(card);
    // _token(tokenizer);
    String DateSplit = Date.split(" ")[0];
    setState(() {
      epDate = DateSplit.replaceAll(new RegExp(r'[^\w\s]+'), '');
    });

    print(epDate);
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
          color: Color(0xFFf4f6f8),
          // decoration: new BoxDecoration(
          //   image: new DecorationImage(
          //     colorFilter: new ColorFilter.mode(
          //         Colors.white.withOpacity(0.3), BlendMode.dstATop),
          //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
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
                        "Método de pago",
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
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text('Puedes pagar con tu tarjeta de débito o crédito'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.91,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Dueños")
                              .doc(PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userUID))
                              .collection('Metodos de pago')
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (dataSnapshot.hasData) {
                              // if (dataSnapshot.data.docs.length == 0) {
                              //   card = true;
                              //   return Center(child: Text(''));
                              // }
                            }
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Container(
                              width: _screenWidth,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: dataSnapshot.data.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  CardModel card = CardModel.fromJson(
                                      dataSnapshot.data.docs[index].data());
                                  obscurecard =
                                      '****' + (card.cardNumber).substring(14);
                                  return ListTile(
                                    leading: Radio(
                                       value: index,
                                       groupValue: val,
                                      onChanged: (value) {
                                        setState(() {
                                          val = value;
                                          selectedIndex = index;
                                          selectedCardToken = card.cardToken;
                                          selectedobscurecard = '****' + (card.cardNumber).substring(14);
                                          print(card.cardNumber);
                                        });
                                      },
                                      activeColor: secondaryColor,
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          card.cardBrand == 'Diners' ?
                                          Image.asset(
                                            'assets/images/diners.png',
                                            fit: BoxFit.contain,
                                            height: 40,
                                            width: 60,
                                          ) :
                                          card.cardBrand == 'Amex' ?
                                          Image.asset(
                                            'assets/images/amex.png',
                                            fit: BoxFit.contain,
                                            height: 40,
                                            width: 60,
                                          ) : card.cardBrand == 'MasterCard' ?
                                          Image.asset(
                                            'assets/images/mastercard.png',
                                            fit: BoxFit.contain,
                                            height: 40,
                                            width: 60,
                                          ) : card.cardBrand == 'Visa' ?
                                          Image.asset(
                                            'assets/images/visa.png',
                                            fit: BoxFit.contain,
                                            height: 40,
                                            width: 60,
                                          ) : Icon(Icons.credit_card, size: 35,),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                obscurecard,
                                                style: TextStyle(
                                                  color: Color(0xFF57419D),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Exp ${card.expiryDate}',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          selectedIndex == index ?
                                          SizedBox(
                                            width: 25.0,
                                            height: 32,
                                            child: RaisedButton(
                                              onPressed: () {
                                                showDialog(
                                                    builder: (context) => AlertDialog(
                                                      // title: Text('Su pago ha sido aprobado.'),
                                                        content: SingleChildScrollView(
                                                            child:
                                                            ListBody(children: <Widget>[
                                                              Container(
                                                                  width: MediaQuery.of(context)
                                                                      .size
                                                                      .width,
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                          '¿Desea eliminar su tarjeta? terminada en $selectedobscurecard',
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.bold)),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(
                                                                                6.0),
                                                                            child: SizedBox(
                                                                              width:
                                                                              _screenWidth * 0.25,
                                                                              child: RaisedButton(
                                                                                onPressed: () {
                                                                                  // AddOrder(productId, context, widget.planModel.montoMensual, widget.planModel.planid);
                                                                                  deleteCard(card);

                                                                                  Navigator.of(
                                                                                      context,
                                                                                      rootNavigator:
                                                                                      true)
                                                                                      .pop();
                                                                                  _loadingDialog(
                                                                                      context);
                                                                                },
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                                                color:
                                                                                Color(0xFFEB9448),
                                                                                padding:
                                                                                EdgeInsets.all(
                                                                                    10.0),
                                                                                child: Column(
                                                                                  crossAxisAlignment:
                                                                                  CrossAxisAlignment
                                                                                      .center,
                                                                                  children: [
                                                                                    Text("Confirmar",
                                                                                        style: TextStyle(
                                                                                            fontFamily:
                                                                                            'Product Sans',
                                                                                            color: Colors
                                                                                                .white,
                                                                                            fontSize:
                                                                                            16.0)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                            child: SizedBox(
                                                                              width:
                                                                              _screenWidth * 0.25,
                                                                              child: RaisedButton(
                                                                                onPressed: () {
                                                                                  // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                                                                                  Navigator.of(
                                                                                      context,
                                                                                      rootNavigator:
                                                                                      true)
                                                                                      .pop();
                                                                                },
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                        5)),
                                                                                color:
                                                                                Color(0xFF57419D),
                                                                                padding:
                                                                                EdgeInsets.all(
                                                                                    10.0),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Text("Cancelar",
                                                                                        style: TextStyle(
                                                                                            fontFamily:
                                                                                            'Product Sans',
                                                                                            color: Colors
                                                                                                .white,
                                                                                            fontSize:
                                                                                            16.0)),
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
                                              color: Colors.red,
                                              padding: EdgeInsets.all(0.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Text("Eliminar",
                                                  //     style: TextStyle(
                                                  //       fontFamily: 'Product Sans',
                                                  //       color: Colors.white,
                                                  //       fontSize: 14.0,
                                                  //     )),
                                                  Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.white,
                                                    size: 19,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ): Container(),
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white,
                                            width: 0.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    tileColor: Colors.transparent,
                                    // selectedIndex == index
                                    //     ? Color(0xFFEB9448)
                                    //     : null,
                                    onTap: () {
                                      setState(() {
                                        // selectedIndex = index;
                                        // selectedCardToken = card.cardToken;
                                        // selectedobscurecard = '****' + (card.cardNumber).substring(14);
                                        // print(card.cardNumber);
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                          }),
                    ),
                  ),
                ),





                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.add_box),
                        color: Color(0xFF277EB6),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCreditCardPage(
                                    petModel: model,
                                    aliadoModel: ali,
                                    serviceModel: service,
                                    locationModel: location,
                                    tituloCategoria: widget.tituloCategoria,
                                    totalPrice: widget.totalPrice,
                                    defaultChoiceIndex:
                                        widget.defaultChoiceIndex)),
                          );
                        }),
                    Text(
                      'Agregar tarjeta',
                      style: TextStyle(color: Color(0xFF277EB6)),
                    )
                  ],
                ),
                widget.totalPrice != null
                    ? SizedBox(
                        width: _screenWidth * 0.9,
                        child: RaisedButton(
                          onPressed: () {
                            if (selectedobscurecard != null) {
                              showDialog(
                                  builder: (context) => AlertDialog(
                                          // title: Text('Su pago ha sido aprobado.'),
                                          content: SingleChildScrollView(
                                              child:
                                                  ListBody(children: <Widget>[
                                        Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              children: [
                                                Text(
                                                    '¿Desea confirmar su compra? ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice.toStringAsFixed(2)} serán debitados de la tarjeta $selectedobscurecard',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: SizedBox(
                                                        width:
                                                            _screenWidth * 0.25,
                                                        child: RaisedButton(
                                                          onPressed: () {
                                                            // AddOrder(productId, context, widget.planModel.montoMensual, widget.planModel.planid);
                                                            if(widget.tituloCategoria!='Apadrinar'){
                                                              addCulqi();
                                                            }
                                                            else{
                                                              addCulqiApadrinar();
                                                            }


                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            _loadingDialog(
                                                                context);
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          color:
                                                              Color(0xFFEB9448),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text("Confirmar",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Product Sans',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16.0)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        width:
                                                            _screenWidth * 0.25,
                                                        child: RaisedButton(
                                                          onPressed: () {
                                                            // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          color:
                                                              Color(0xFF57419D),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Column(
                                                            children: [
                                                              Text("Cancelar",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Product Sans',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16.0)),
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
                            } else {
                              showDialog(
                                  builder: (context) =>
                                      new ChoosePetAlertDialog(
                                        message:
                                            "Por favor seleccione un método de pago.",
                                      ),
                                  context: context);
                            }

                            // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => StoreHome(
                            //         petModel: model,
                            //       )),
                            // );
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: Color(0xFFEB9448),
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text("Pagar",
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      color: Colors.white,
                                      fontSize: 16.0)),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentezWidget(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    // CulqiTokenizer tokenizer = CulqiTokenizer(card);
    // _token(tokenizer);
    String DateSplit = Date.split(" ")[0];
    setState(() {
      epDate = DateSplit.replaceAll(new RegExp(r'[^\w\s]+'), '');
    });

    print(epDate);
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
          color: Color(0xFFf4f6f8),
          // decoration: new BoxDecoration(
          //   image: new DecorationImage(
          //     colorFilter: new ColorFilter.mode(
          //         Colors.white.withOpacity(0.3), BlendMode.dstATop),
          //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
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
                        "Método de pago",
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
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Text('Puedes pagar con tu tarjeta de débito o crédito'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.91,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                     child: Container(

                        // height: _screenHeight * 0.51,
                        width: _screenWidth,
                        child: ListView.builder(
                          // controller: _scrollController,
                          // physics: NeverScrollableScrollPhysics(),
                            itemCount: allResults.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return sourceInfo2(
                                  allResults[index], context);
                            }),
                      ),
                    ),
                  ),
                ),





                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.add_box),
                        color: Color(0xFF277EB6),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PmTarjeta(
                                    petModel: model,
                                    aliadoModel: ali,
                                    serviceModel: service,
                                    locationModel: location,
                                    tituloCategoria: widget.tituloCategoria,
                                    totalPrice: widget.totalPrice,
                                    defaultChoiceIndex:
                                    widget.defaultChoiceIndex)

                            ),
                          );
                        }),
                    Text(
                      'Agregar tarjeta',
                      style: TextStyle(color: Color(0xFF277EB6)),
                    )
                  ],
                ),
                widget.totalPrice != null
                    ? SizedBox(
                  width: _screenWidth * 0.9,
                  child: RaisedButton(
                    onPressed: () {
                      if (selectedobscurecard != null) {
                        showDialog(
                            builder: (context) => AlertDialog(
                              // title: Text('Su pago ha sido aprobado.'),
                                content: SingleChildScrollView(
                                    child:
                                    ListBody(children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                          child: Column(
                                            children: [
                                              Text(
                                                  '¿Desea confirmar su compra? ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice.toStringAsFixed(2)} serán debitados de la tarjeta $selectedobscurecard',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold)),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        6.0),
                                                    child: SizedBox(
                                                      width:
                                                      _screenWidth * 0.25,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          // AddOrder(productId, context, widget.planModel.montoMensual, widget.planModel.planid);
                                                          if(widget.tituloCategoria!='Apadrinar'){
                                                            addPaymentez();
                                                          }
                                                          else{
                                                            // addCulqiApadrinar();
                                                          }


                                                          Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                              true)
                                                              .pop();
                                                          _loadingDialog(
                                                              context);
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                5)),
                                                        color:
                                                        Color(0xFFEB9448),
                                                        padding:
                                                        EdgeInsets.all(
                                                            10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text("Confirmar",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Product Sans',
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                    16.0)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        8.0),
                                                    child: SizedBox(
                                                      width:
                                                      _screenWidth * 0.25,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                                                          Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                              true)
                                                              .pop();
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                5)),
                                                        color:
                                                        Color(0xFF57419D),
                                                        padding:
                                                        EdgeInsets.all(
                                                            10.0),
                                                        child: Column(
                                                          children: [
                                                            Text("Cancelar",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Product Sans',
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                    16.0)),
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
                      } else {
                        showDialog(
                            builder: (context) =>
                            new ChoosePetAlertDialog(
                              message:
                              "Por favor seleccione un método de pago.",
                            ),
                            context: context);
                      }

                      // AddOrder(productId, context, widget.planModel.montoAnual, widget.planModel.planid);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => StoreHome(
                      //         petModel: model,
                      //       )),
                      // );
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Color(0xFFEB9448),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text("Pagar",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 16.0)),
                      ],
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    CardModel card,
    BuildContext context,
  ) {
    return InkWell(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obscurecard,
                    style: TextStyle(
                      color: Color(0xFF57419D),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Exp ${card.expiryDate}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
  deleteCard(CardModel card) async {
    try {
      var url =
      ("https://api.culqi.com/v2/cards/${card.cardToken}");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": _prk
      };
      Response res = await http.delete(Uri.parse(url), headers: headers);
      int statusCode = await res.statusCode;

      setState(() {
        // response = statusCode.toString();
        tarjetas = res.body;
        print(statusCode);
        print('el cuerpo es ${res.body}');
      });

      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Metodos de pago')
          .doc(card.cardId)
          .delete();

      Navigator.of(context, rootNavigator: true).pop();

      OrderMessage(context, 'Se ha eliminado tu tarjeta ${selectedobscurecard}');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentPage(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
      );

    } catch (e) {
      print(e.message);
      showDialog(
          builder: (context) => new ChoosePetAlertDialog(
            message:   "Hubo un problema al eliminar su tarjeta, por favor intente luego"
            ,
          ),
          context: context);
      return null;
    }
  }

  addCulqi() async {
    var precio2 = widget.totalPrice * 100;
    dynamic precio = precio2.toInt();
    print('el precio es $precio');
    try {
      var json =
          '{"email": "${PetshopApp.sharedPreferences.getString(PetshopApp.userEmail)}","currency_code": "PEN", "amount": "$precio","source_id":"$selectedCardToken"}';
      var url = ("https://api.culqi.com/v2/charges");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "$_prk"
      };

      Response res =
          await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = res.statusCode;
      var nuevo = await jsonDecode(res.body);
      //
      CulqiUserModel culqi = await CulqiUserModel.fromJson(nuevo);
      print(res.body);
      print(nuevo['outcome']['type']);

      // print(culqi.state);
      // print(culqi.object);
      // print('la marca de tarjeta es ${culqi.card_brand}');
      setState(() {
        // response = statusCode.toString();
        pagoId = culqi.id;
        type = nuevo['source']['source']['type'];
        cardType = nuevo['source']['source']['iin']['card_type'];
        cardBrand = nuevo['source']['source']['iin']['card_brand'];
        cardNumLast = nuevo['source']['source']['last_four'];
        outcomeMsg = nuevo['outcome']['user_message'];
        outcomeMsgError = nuevo['user_message'];

        print(statusCode);
      });
      if (cardType == 'credito') {
        setState(() {
          formapag = '003';
        });
        if (cardType == 'debito') {
          setState(() {
            formapag = '004';
          });
        }
      }

      if (nuevo['outcome']['type'] == 'venta_exitosa') {
        if (widget.tituloCategoria == 'Servicio') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
          addServiceToOrders();
        }
        if (widget.tituloCategoria == 'Donar') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addDonationToOrders();
        }
        if (widget.tituloCategoria == 'Adopción') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addAdoptionToOrders();
        }
        if (widget.tituloCategoria == 'Promocion') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
          addPromoToOrders();
        }
        if (widget.tituloCategoria == 'Plan Mensual' ||
            widget.tituloCategoria == 'Plan Anual') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
          AddPlanToOrder();
        }
        if (widget.tituloCategoria == 'Videoconsulta') {
          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
          addVideoToOrders();
        }

        if (widget.tituloCategoria == 'Producto') {
          getAliadoSnapshots(widget.cartModel.aliadoId);

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
          AddCartOrder(context, widget.cartModel);

        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        ErrorMessage(context, outcomeMsgError);
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      ErrorMessage(context, outcomeMsgError);
      print('Error');
      return null;
    }
  }


  addCulqiApadrinar() async {
    var precio2 = widget.totalPrice * 100;
    dynamic precio = precio2.toInt();
    print('el precio es $precio');
    try {
      var json =
          '{"card_id":"$selectedCardToken", "plan_id": "pln_live_7zWRuX8lNcFO6zX9",}';
      var url = ("https://api.culqi.com/v2/subscriptions");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "$_prk"
      };

      Response res =
      await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = res.statusCode;
      var nuevo = await jsonDecode(res.body);
      //
      CulqiUserModel culqi = await CulqiUserModel.fromJson(nuevo);
      print('el bodyyyyyyyyyyyyyyyy ${res.body}');
      print('los ultimos digitos de la tarjeta son:${nuevo['source']['source']['last_four']}');

      // print(culqi.state);
      // print(culqi.object);
      // print('la marca de tarjeta es ${culqi.card_brand}');
      setState(() {
        // response = statusCode.toString();
        pagoId = culqi.id;
        type = nuevo['source']['source']['type'];
        cardType = nuevo['source']['source']['iin']['card_type'];
        cardBrand = nuevo['source']['source']['iin']['card_brand'];
        cardNumLast = nuevo['source']['source']['last_four'];
        outcomeMsg = nuevo['outcome']['user_message'];
        outcomeMsgError = nuevo['user_message'];

        print(statusCode);
      });
      if (cardType == 'credito') {
        setState(() {
          formapag = '003';
        });
        if (cardType == 'debito') {
          setState(() {
            formapag = '004';
          });
        }
      }

      if (nuevo['outcome']['type'] == 'venta_exitosa') {
        if (widget.tituloCategoria == 'Apadrinar') {

          Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addApadrinarToOrders();
        }

      } else {
        Navigator.of(context, rootNavigator: true).pop();
        ErrorMessage(context, outcomeMsgError);
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      ErrorMessage(context, outcomeMsgError);
      print('Error');
      return null;
    }
  }
  addApadrinarToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, outcomeMsg);
    var databaseReference =
    FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference.set({

      "aliadoId": widget.petModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Apadrinar',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,

      "ppGeneradosD": double.parse((widget.totalPrice).toString()),

      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,

      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "pagoId": pagoId,
    });
    databaseReference
        .collection('Items')
        .doc(widget.petModel.mid)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": 'Donación',
      "oid": productId,
      "aliadoId": widget.petModel.aliadoId,


      "precio": widget.totalPrice,
      "mid": widget.petModel.mid,

      "nombre": widget.petModel.nombre,
    });


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
          (Route<dynamic> route) => false,
    );
    // sendEmail(
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //     productId,
    //     ali.avatar);

    // pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);


    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }

  AddPlanToOrder() async {
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    var addplan = FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Plan')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    var date = new DateTime.now();
    var newDateYear = new DateTime(date.year + 1, date.month, date.day);
    var newDateMonth = new DateTime(date.year, date.month + 1, date.day);
    addplan.set({
      "pagoId": pagoId,
      "status": 'Activo',
      "precio": widget.totalPrice,
      "createdOn": DateTime.now(),
      "tipoPlan": widget.planModel.nombrePlan,
      "oid": productId,
      // "mid": widget.petModel.mid,
      "vigencia_desde": DateTime.now(),
      "vigencia_hasta":
          widget.tituloCategoria == 'Plan Mensual' ? newDateMonth : newDateYear,
      "planId": widget.planModel.planId,
    });
    databaseReference.set({
      "pagoId": pagoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Plan',
      'createdOn': DateTime.now(),
      "tipoPlan": widget.planModel.nombrePlan,
      // "mid": widget.petModel.mid,
      "vigencia_desde": DateTime.now(),
      "vigencia_hasta":
          widget.tituloCategoria == 'Plan Mensual' ? newDateMonth : newDateYear,
      // "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "planId": widget.planModel.planId,
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Afiliación al Plan ${widget.planModel.nombrePlan} de Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por afiliarte a nuestro plan ${widget.planModel.nombrePlan} y por ser parte de la comunidad Priority Pet.</p><p>A partir de este momento podrás disfrutar de los siguientes beneficios:</p><p>- Descuentos exclusivos<br>- Obtener Pet Points<br>- Participación en foros<br>- Consultas gratuitas<br>- Sorteos para afiliados</p><p>Fecha de compra: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode} <br><p>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi'? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }
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
    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, outcomeMsg);
  }

  addPromoToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, outcomeMsg);
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference
        .collection('Items')
        .doc(widget.promotionModel.promoid)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": widget.promotionModel.titulo,
      "oid": productId,
      "aliadoId": widget.promotionModel.aliadoid,
      "promoid": widget.promotionModel.promoid,
      "date": widget.date,
      "hora": widget.hora,
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "precio": widget.totalPrice,
      "mid": widget.petModel.mid,
      "tieneDelivery": widget.value2,
      "delivery": widget.delivery,
      "tieneDomicilio": widget.value,
      "domicilio": widget.recojo,
      "nombre": widget.petModel.nombre,
    });
    databaseReference.set({
      "pagoId": pagoId,
      "aliadoId": widget.promotionModel.aliadoid,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": widget.promotionModel.tipoPromocion == 'Producto'
          ? 'Promoción'
          : 'Servicio',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "ppGeneradosD": int.parse((widget.totalPrice).toString()),
      "date": widget.date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu compra:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: ${widget.promotionModel.tipoPromocion == 'Producto' ? 'Promoción' : 'Servicio'}<br>Detalle: ${widget.promotionModel.titulo}<br>Día del servicio: ${widget.fecha}<br>Hora del servicio: ${widget.hora != null ? '${widget.hora}': 'Horario libre'}<br>Dirección: ${widget.locationModel.direccionLocalidad}<br>Para tu mascota: ${widget.petModel.nombre}<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>En las próximas horas, el Aliado ${widget.aliadoModel.nombreComercial} te confirmará la cita a través de la APP. Puedes ingresar en Mis Órdenes para ver el estatus de tu servicio.</p><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi'? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }
    });

    // try {
    //   var json =
    //       '{"filial": "01","id": "$productId","cliente": "${PetshopApp.sharedPreferences.getString(PetshopApp.userDocId)}","proveedor": "${widget.promotionModel.aliadoid}","emision": "$epDate","formapag": "$formapag","moneda": "PEN","items": [{ "producto": "${widget.promotionModel.promoid}","cantidad": 1,"precio": ${widget.totalPrice}] }';
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
    // FirebaseFirestore.instance
    //     .collection('Ordenes')
    //     .doc(productId)
    //     .updateData({'preference_id': FieldValue.delete()}).whenComplete(() {});

    // showDialog(
    //   context: context,
    //   child: AlertDialog(
    //     // title: Text('Su pago ha sido aprobado.'),
    //     content: SingleChildScrollView(
    //       child: ListBody(
    //         children: <Widget>[
    //           Container(
    //             width: MediaQuery.of(context).size.width * 0.91,
    //             decoration: BoxDecoration(
    //                 color: Color(0xFF57419D),
    //                 borderRadius: BorderRadius.circular(10),
    //                 border: Border.all(
    //                   color: Color(0xFFBDD7D6),
    //                 )),
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 children: [
    //                   Text(
    //                     'Tu pago ha sido procesado con éxito.',
    //                     style: TextStyle(
    //                         color: Colors.white,
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 12),
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text(
    //                       'Pronto recibirás un correo con la confirmación de tu compra.. ',
    //                       style: TextStyle(color: Colors.white, fontSize: 12)),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Container(
    //             width: MediaQuery.of(context).size.width * 0.91,
    //             decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(10),
    //                 border: Border.all(
    //                   color: Color(0xFFBDD7D6),
    //                 )),
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'Metodo de pago',
    //                     style: TextStyle(
    //                         color: Color(0xFF57419D),
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 12),
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(type == 'card' ? 'Tarjeta ' : type, style: TextStyle(color: Colors.black, fontSize: 12)),
    //                       Text('$cardType: ', style: TextStyle(color: Colors.black, fontSize: 12)),
    //                       SizedBox(
    //                         width: 10,
    //                       ),
    //                       Text(cardBrand,
    //                           style: TextStyle(
    //                               color: Colors.black, fontSize: 12)),
    //                     ],
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(
    //                         'Orden N°',
    //                         style: TextStyle(
    //                             fontSize: 12,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Text(
    //                         productId,
    //                         style: TextStyle(
    //                             fontSize: 12, fontWeight: FontWeight.bold),
    //                       ),
    //                     ],
    //                   ),
    //                   StreamBuilder<QuerySnapshot>(
    //                       stream: FirebaseFirestore.instance
    //                           .collection("Ordenes")
    //                           .doc(productId)
    //                           .collection('Items')
    //                           .where('uid',
    //                               isEqualTo: PetshopApp.sharedPreferences
    //                                   .getString(PetshopApp.userUID)
    //                                   .toString())
    //                           .snapshots(),
    //                       builder: (context, dataSnapshot) {
    //                         if (!dataSnapshot.hasData) {
    //                           return Center(
    //                             child: CircularProgressIndicator(),
    //                           );
    //                         }
    //                         return ListView.builder(
    //                             physics: NeverScrollableScrollPhysics(),
    //                             itemCount: dataSnapshot.data.docs.length,
    //                             shrinkWrap: true,
    //                             itemBuilder: (
    //                               context,
    //                               index,
    //                             ) {
    //                               ItemModel item = ItemModel.fromJson(
    //                                   dataSnapshot.data.docs[index].data());
    //                               return Column(
    //                                 children: [
    //                                   SizedBox(
    //                                     child: Column(
    //                                       children: [
    //                                         Row(
    //                                           mainAxisAlignment:
    //                                               MainAxisAlignment
    //                                                   .spaceBetween,
    //                                           children: [
    //                                             Expanded(
    //                                                 child: Text(item.titulo,
    //                                                     style: TextStyle(
    //                                                         fontSize: 10,
    //                                                         color: Color(
    //                                                             0xFF57419D),
    //                                                         fontWeight:
    //                                                             FontWeight
    //                                                                 .bold),
    //                                                     textAlign:
    //                                                         TextAlign.left)),
    //                                             Row(
    //                                               children: [
    //                                                 Text(
    //                                                   'S/',
    //                                                   style: TextStyle(
    //                                                       fontSize: 10,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                   textAlign: TextAlign.left,
    //                                                 ),
    //                                                 Text(item.precio.toString(),
    //                                                     style: TextStyle(
    //                                                         fontSize: 16,
    //                                                         color: Color(
    //                                                             0xFF57419D),
    //                                                         fontWeight:
    //                                                             FontWeight
    //                                                                 .bold),
    //                                                     textAlign:
    //                                                         TextAlign.left),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                   Row(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.start,
    //                                     children: [
    //                                       Text(item.nombreComercial,
    //                                           style: TextStyle(fontSize: 10),
    //                                           textAlign: TextAlign.left),
    //                                     ],
    //                                   ),
    //                                   widget.value2 != null
    //                                       ? Row(
    //                                           mainAxisAlignment:
    //                                               MainAxisAlignment
    //                                                   .spaceBetween,
    //                                           children: [
    //                                             Text(
    //                                               'Delivery',
    //                                               style: TextStyle(
    //                                                   fontSize: 12.0,
    //                                                   color: Color(0xFF57419D),
    //                                                   fontWeight:
    //                                                       FontWeight.bold),
    //                                             ),
    //                                             Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.end,
    //                                               children: [
    //                                                 Text(
    //                                                   'S/ ',
    //                                                   style: TextStyle(
    //                                                       fontSize: 12.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                                 Text(
    //                                                   (widget.delivery)
    //                                                       .toString(),
    //                                                   style: TextStyle(
    //                                                       fontSize: 18.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         )
    //                                       : widget.value != null
    //                                           ? Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Text(
    //                                                   'Domicilio',
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
    //                                                       (widget.recojo)
    //                                                           .toString(),
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
    //                                           : Container(),
    //                                   Divider(
    //                                     indent: 20,
    //                                     endIndent: 20,
    //                                     color:
    //                                         Color(0xFF57419D).withOpacity(0.5),
    //                                   ),
    //                                 ],
    //                               );
    //                             });
    //                       }),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         'Petpoints Acreditados',
    //                         style: TextStyle(
    //                             fontSize: 12.0,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             (widget.totalPrice).toString(),
    //                             style: TextStyle(
    //                                 fontSize: 18.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                   SizedBox(
    //                     height: 8,
    //                   ),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         'Tu cargo',
    //                         style: TextStyle(
    //                             fontSize: 12.0,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             'S/ ',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Text(
    //                             (widget.totalPrice).toString(),
    //                             style: TextStyle(
    //                                 fontSize: 18.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
      (Route<dynamic> route) => false,
    );
    sendEmail(
        PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        PetshopApp.sharedPreferences.getString(PetshopApp.userName),
        productId,
        ali.avatar);
    pushProvider.sendNotificaction(widget.promotionModel.aliadoid, productId);
    var val = []; //blank list for add elements which you want to delete
    val.add(widget.hora);
    db
        .collection("Promociones")
        .doc(widget.promotionModel.promoid)
        .collection("Agenda")
        .doc(widget.fecha)
        .update({
      "horasDia": FieldValue.arrayRemove(val),
      "horasReservadas": FieldValue.arrayUnion(val),
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }

  addServiceToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, outcomeMsg);
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    databaseReference
        .collection('Items')
        .doc(widget.serviceModel.servicioId)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": widget.serviceModel.titulo,
      "oid": productId,
      "aliadoId": widget.serviceModel.aliadoId,
      "servicioid": widget.serviceModel.servicioId,
      "date": widget.date,
      "hora": widget.hora,
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "precio": widget.totalPrice,
      "mid": widget.petModel.mid,
      "tieneDelivery": widget.value2,
      "delivery": widget.delivery,
      "tieneDomicilio": widget.value,
      "domicilio": widget.recojo,
      "nombre": widget.petModel.nombre,
    });
    databaseReference.set({
      "pagoId": pagoId,
      "aliadoId": widget.serviceModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Servicio',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "ppGeneradosD": int.parse((widget.totalPrice).toString()),
      "date": widget.date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "localidadId": widget.locationModel.localidadId,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu compra:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: Servicio<br>Detalle: ${widget.serviceModel.titulo}<br>Día del servicio: ${widget.fecha}<br>Hora del servicio: ${widget.hora != null ? '${widget.hora}': 'Horario libre'}<br>Dirección: ${widget.locationModel.direccionLocalidad}<br>Para tu mascota: ${widget.petModel.nombre}<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>En las próximas horas, el Aliado ${widget.aliadoModel.nombreComercial} te confirmará la cita a través de la APP. Puedes ingresar en Mis Órdenes para ver el estatus de tu cita.</p><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi'? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }

    });
    // try {
    //   var json =
    //       '{"filial": "01","id": "$productId","cliente": "${PetshopApp.sharedPreferences.getString(PetshopApp.userDocId)}","proveedor": "${widget.serviceModel.aliadoId}","emision": "$epDate","formapag": "$formapag","moneda": "PEN","items": [{ "producto": "${widget.serviceModel.servicioId}","cantidad": 1,"precio": ${widget.totalPrice}] }';
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

    // FirebaseFirestore.instance
    //     .collection('Ordenes')
    //     .doc(productId)
    //     .updateData({'preference_id': FieldValue.delete()}).whenComplete(() {});

    // showDialog(
    //   context: context,
    //   child: AlertDialog(
    //     // title: Text('Su pago ha sido aprobado.'),
    //     content: SingleChildScrollView(
    //       child: ListBody(
    //         children: <Widget>[
    //           Container(
    //             width: MediaQuery.of(context).size.width * 0.91,
    //             decoration: BoxDecoration(
    //                 color: Color(0xFF57419D),
    //                 borderRadius: BorderRadius.circular(10),
    //                 border: Border.all(
    //                   color: Color(0xFFBDD7D6),
    //                 )),
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 children: [
    //                   Text(
    //                     'Tu pago ha sido procesado con éxito.',
    //                     style: TextStyle(
    //                         color: Colors.white,
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 12),
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Text(
    //                       'Pronto recibirás un correo con la confirmación de tu compra.. ',
    //                       style: TextStyle(color: Colors.white, fontSize: 12)),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           SizedBox(
    //             height: 10,
    //           ),
    //           Container(
    //             width: MediaQuery.of(context).size.width * 0.91,
    //             decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(10),
    //                 border: Border.all(
    //                   color: Color(0xFFBDD7D6),
    //                 )),
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'Metodo de pago',
    //                     style: TextStyle(
    //                         color: Color(0xFF57419D),
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 12),
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(type == 'card' ? 'Tarjeta ' : type, style: TextStyle(color: Colors.black, fontSize: 12)),
    //                       Text('$cardType: ', style: TextStyle(color: Colors.black, fontSize: 12)),
    //                       SizedBox(
    //                         width: 10,
    //                       ),
    //                       Text(cardBrand,
    //                           style: TextStyle(
    //                               color: Colors.black, fontSize: 12)),
    //                     ],
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(
    //                         'Orden N°',
    //                         style: TextStyle(
    //                             fontSize: 12,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Text(
    //                         productId,
    //                         style: TextStyle(
    //                             fontSize: 12, fontWeight: FontWeight.bold),
    //                       ),
    //                     ],
    //                   ),
    //                   StreamBuilder<QuerySnapshot>(
    //                       stream: FirebaseFirestore.instance
    //                           .collection("Ordenes")
    //                           .doc(productId)
    //                           .collection('Items')
    //                           .where('uid',
    //                               isEqualTo: PetshopApp.sharedPreferences
    //                                   .getString(PetshopApp.userUID)
    //                                   .toString())
    //                           .snapshots(),
    //                       builder: (context, dataSnapshot) {
    //                         if (!dataSnapshot.hasData) {
    //                           return Center(
    //                             child: CircularProgressIndicator(),
    //                           );
    //                         }
    //                         return ListView.builder(
    //                             physics: NeverScrollableScrollPhysics(),
    //                             itemCount: dataSnapshot.data.docs.length,
    //                             shrinkWrap: true,
    //                             itemBuilder: (
    //                               context,
    //                               index,
    //                             ) {
    //                               ItemModel item = ItemModel.fromJson(
    //                                   dataSnapshot.data.docs[index].data());
    //                               return Column(
    //                                 children: [
    //                                   SizedBox(
    //                                     child: Column(
    //                                       children: [
    //                                         Row(
    //                                           mainAxisAlignment:
    //                                               MainAxisAlignment
    //                                                   .spaceBetween,
    //                                           children: [
    //                                             Expanded(
    //                                                 child: Text(item.titulo,
    //                                                     style: TextStyle(
    //                                                         fontSize: 10,
    //                                                         color: Color(
    //                                                             0xFF57419D),
    //                                                         fontWeight:
    //                                                             FontWeight
    //                                                                 .bold),
    //                                                     textAlign:
    //                                                         TextAlign.left)),
    //                                             Row(
    //                                               children: [
    //                                                 Text(
    //                                                   'S/',
    //                                                   style: TextStyle(
    //                                                       fontSize: 10,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                   textAlign: TextAlign.left,
    //                                                 ),
    //                                                 Text(item.precio.toString(),
    //                                                     style: TextStyle(
    //                                                         fontSize: 16,
    //                                                         color: Color(
    //                                                             0xFF57419D),
    //                                                         fontWeight:
    //                                                             FontWeight
    //                                                                 .bold),
    //                                                     textAlign:
    //                                                         TextAlign.left),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                   Row(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.start,
    //                                     children: [
    //                                       Text(item.nombreComercial,
    //                                           style: TextStyle(fontSize: 10),
    //                                           textAlign: TextAlign.left),
    //                                     ],
    //                                   ),
    //                                   widget.value2 != null
    //                                       ? Row(
    //                                           mainAxisAlignment:
    //                                               MainAxisAlignment
    //                                                   .spaceBetween,
    //                                           children: [
    //                                             Text(
    //                                               'Delivery',
    //                                               style: TextStyle(
    //                                                   fontSize: 12.0,
    //                                                   color: Color(0xFF57419D),
    //                                                   fontWeight:
    //                                                       FontWeight.bold),
    //                                             ),
    //                                             Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.end,
    //                                               children: [
    //                                                 Text(
    //                                                   'S/ ',
    //                                                   style: TextStyle(
    //                                                       fontSize: 12.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                                 Text(
    //                                                   (widget.delivery)
    //                                                       .toString(),
    //                                                   style: TextStyle(
    //                                                       fontSize: 18.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         )
    //                                       : widget.value != null
    //                                           ? Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Text(
    //                                                   'Domicilio',
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
    //                                                       (widget.recojo)
    //                                                           .toString(),
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
    //                                           : Container(),
    //                                   Divider(
    //                                     indent: 20,
    //                                     endIndent: 20,
    //                                     color:
    //                                         Color(0xFF57419D).withOpacity(0.5),
    //                                   ),
    //                                 ],
    //                               );
    //                             });
    //                       }),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         'Petpoints Acreditados',
    //                         style: TextStyle(
    //                             fontSize: 12.0,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             (widget.totalPrice).toString(),
    //                             style: TextStyle(
    //                                 fontSize: 18.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                   SizedBox(
    //                     height: 8,
    //                   ),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         'Tu cargo',
    //                         style: TextStyle(
    //                             fontSize: 12.0,
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold),
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             'S/ ',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Text(
    //                             (widget.totalPrice).toString(),
    //                             style: TextStyle(
    //                                 fontSize: 18.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
      (Route<dynamic> route) => false,
    );
    sendEmail(
        PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        PetshopApp.sharedPreferences.getString(PetshopApp.userName),
        productId,
        ali.avatar);
    pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    var val = []; //blank list for add elements which you want to delete
    val.add(widget.hora);
    db
        .collection("Localidades")
        .doc(widget.serviceModel.localidadId)
        .collection("Servicios")
        .doc(widget.serviceModel.servicioId)
        .collection("Agenda")
        .doc(widget.fecha)
        .update({
      "horasDia": FieldValue.arrayRemove(val),
      "horasReservadas": FieldValue.arrayUnion(val),
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }
  addAdoptionToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, 'Tu adopción ha sido un exito, tu nueva mascota se agregará a "Mis mascotas" a partir de este momento.');
    var databaseReference =
    FirebaseFirestore.instance.collection('Ordenes').doc(productId);
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    databaseReference.set({

      "aliadoId": widget.petModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Adopción',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,

      "ppGeneradosD": double.parse((widget.totalPrice).toString()),

      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.nombreComercial != null ? widget.nombreComercial : '',

      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "pagoId": pagoId,
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu adopción:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: Donación<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }
    });
    databaseReference
        .collection('Items')
        .doc(widget.petModel.mid)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.nombreComercial != null ? widget.nombreComercial : '',
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": 'Adopción',
      "oid": productId,
      "aliadoId": widget.petModel.aliadoId,


      "precio": widget.totalPrice,
      "mid": widget.petModel.mid,

      "nombre": widget.petModel.nombre,
    });


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => NewOrdenesHome()),
          (Route<dynamic> route) => false,
    );
    // sendEmail(
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //     productId,
    //     ali.avatar);

    // pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    var adopt = db
        .collection("Mascotas")
        .doc(widget.petModel.mid);

    adopt.update({
      'adoptadoStatus': true,
      'newPet': false,
      'uid': PetshopApp.sharedPreferences.getString(PetshopApp.userUID),


    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }

  addDonationToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    OrderMessage(context, outcomeMsg);
    var databaseReference =
    FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference.set({

      "aliadoId": widget.petModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Donación',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "ppGeneradosD": double.parse((widget.totalPrice).toString()),
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "pagoId": pagoId,
    });
    databaseReference
        .collection('Items')
        .doc(widget.petModel.mid)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": 'Donación',
      "oid": productId,
      "aliadoId": widget.petModel.aliadoId,
      "precio": widget.totalPrice,
      "mid": widget.petModel.mid,
      "nombre": widget.petModel.nombre,
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu donación:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: Donación<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }
    });


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
          (Route<dynamic> route) => false,
    );
    // sendEmail(
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //     productId,
    //     ali.avatar);

    // pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);


    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }

  addVideoToOrders() async {
    Navigator.of(context, rootNavigator: true).pop();
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    OrderMessage(context, outcomeMsg);
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);
    final id = shortid.generate();
    databaseReference
        .collection('Items')
        .doc(widget.serviceModel.servicioId)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel != null
          ? widget.petModel.petthumbnailUrl
          : PetshopApp.sharedPreferences.getString(PetshopApp.userAvatarUrl),
      "titulo": widget.serviceModel.titulo,
      "oid": productId,
      "aliadoId": widget.serviceModel.aliadoId,
      "servicioid": widget.serviceModel.servicioId,
      "date": widget.date,
      "hora": widget.hora,
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "precio": widget.totalPrice,
      "mid": widget.petModel != null ? widget.petModel.mid : 'Dueño',
      // "tieneDelivery": widget.value2,
      // "delivery": widget.delivery,
      // "tieneDomicilio": widget.value,
      // "domicilio": widget.recojo,
      "nombre": widget.petModel != null
          ? widget.petModel.nombre
          : PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    });
    databaseReference.set({
      "videoId": id,
      "pagoId": pagoId,
      "aliadoId": widget.serviceModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Videoconsulta',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel != null ? widget.petModel.mid : 'Dueño',
      "fecha": widget.fecha == null ? widget.fecha : widget.fecha.trim(),
      "ppGeneradosD": int.parse((widget.totalPrice).toString()),
      "date": widget.date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "localidadId": widget.locationModel.localidadId,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu compra:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: Videoconsulta<br>Detalle: ${widget.serviceModel.titulo}<br>Día del servicio: ${widget.fecha}<br>Hora del servicio: ${widget.hora != null ? '${widget.hora}': 'Horario libre'}<br>Para tu mascota: ${widget.petModel.nombre}<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>En las próximas horas, el Aliado ${widget.aliadoModel.nombreComercial} te confirmará la cita a través de la APP. Puedes ingresar en Mis Órdenes para ver el estatus de tu cita.</p><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,
      }
    });
    // try {
    //   var json =
    //       '{"filial": "01","id": "$productId","cliente": "${PetshopApp.sharedPreferences.getString(PetshopApp.userDocId)}","proveedor": "${widget.serviceModel.aliadoId}","emision": "$epDate","formapag": "$formapag","moneda": "PEN","items": [{ "producto": "${widget.serviceModel.servicioId}","cantidad": 1,"precio": ${widget.totalPrice}] }';
    //   var url = ("https://epcloud.ebc.pe.grupoempodera.com/api/?cliente");
    //   Map<String, String> headers = {"Content-type": "application/json"};
    //   Response res = await http.post(url, headers: headers, body: json);
    //   int statusCode = res.statusCode;
    //   setState(() {
    //     // response = statusCode.toString();
    //     print(statusCode);
    //   });
    // } catch (e) {
    //   print(e.message);
    //   return null;
    // }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
      (Route<dynamic> route) => false,
    );
    sendEmail(
        PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        PetshopApp.sharedPreferences.getString(PetshopApp.userName),
        productId,
        ali.avatar);
    pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    var val = []; //blank list for add elements which you want to delete
    val.add(widget.hora);
    db
        .collection("Localidades")
        .doc(widget.serviceModel.localidadId)
        .collection("Servicios")
        .doc(widget.serviceModel.servicioId)
        .collection("Agenda")
        .doc(widget.fecha)
        .update({
      "horasDia": FieldValue.arrayRemove(val),
      "horasReservadas": FieldValue.arrayUnion(val),
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
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
        ppAcumulados = (dataSnapshot["ppAcumulados"]).toInt();
        ppCanjeados = (dataSnapshot["ppCanjeados"]).toInt();
      });
      print('Valor Acumulado: $ppAcumulados');
      print('Valor canjeados: $ppCanjeados');
    });
  }

  _getprK() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Culqi").doc("Priv");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _prk = (dataSnapshot["prk"]);
      });
    });
  }

  _checkRegistro() async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));

    documentReference.get().then((dataSnapshot) {
      setState(() {
        registroCompleto = (dataSnapshot["registroCompleto"]);

        print(registroCompleto);
        if (registroCompleto == false) {
          print('el registro esta en $registroCompleto');
          ErrorMessage(context, 'Debe completar los datos de su registro');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UsuarioInfo(
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
        }
      });
    });
  }

  changePlan(otro) {
    setState(() {
      plan = otro;
    });
    return otro;
  }

  changeCart(otro) {
    setState(() {
      cart = otro;
    });
    return otro;
  }

  changePro(otro) {
    setState(() {
      pro = otro;
    });
    return otro;
  }

  changeLoc(Det) {
    setState(() {
      location = Det;
    });

    return Det;
  }

  changeAli(Al) {
    setState(() {
      ali = Al;
    });

    return Al;
  }

  changeDet(Det) {
    setState(() {
      service = Det;
    });

    return Det;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  sendEmail(_email, nombreCompleto, orderId, aliadoAvatar) async {
    await http.get(Uri.parse(
        'https://us-central1-priority-pet.cloudfunctions.net/sendOrderDuenoEmail?dest=$_email&username=$nombreCompleto&orderId=$orderId&logoAliado=$aliadoAvatar'));
    print('$_email $nombreCompleto $orderId $aliadoAvatar');
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

  Future<void> OrderMessage(BuildContext context, String error) async {
    // Navigator.of(context, rootNavigator: true).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 55.0),
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

  Future<void> _loadingDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
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
                    CircularProgressIndicator(),
                    SizedBox(height: 20.0),
                    Text(
                      "Procesando...",
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

  AddCartOrder(BuildContext context, CartModel cart) async {


    Navigator.of(context, rootNavigator: true).pop();
    OrderMessage(context, outcomeMsg);
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    await databaseReference.set({
      "aliadoId": widget.cartModel.aliadoId,
      "pagoId": pagoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.totalPrice,
      "tipoOrden": 'Producto',
      "createdOn": DateTime.now(),
      "status": 'Por Confirmar',
      "ppGeneradosD": widget.totalPrice,
      "tieneDelivery": widget.value2,
      "delivery": widget.delivery,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.cartModel.nombreComercial,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
      "to": [PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),],
      "message": {
        "subject": '¡Gracias por comprar en Priority Pet!',
        "text": 'Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><h3>Hola, ${PetshopApp.sharedPreferences.getString(PetshopApp.userNombre)}</h3><p>Gracias por tu pedido, y por ser parte de la comunidad Priority Pet.</p><p>A continuación, te mostramos el detalle de tu compra:</p><p>Fecha de la orden: ${formatted}<br>Facturado a: Tarjeta ${cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand}, número ****${cardNumLast}</p><p>N. Orden: ${productId}<br>TRANSACTION_ID: ${pagoId}<br>AUTHORIZATION_CODE: ${authCode}  <br>Proveedor: ${widget.aliadoModel.nombreComercial}<br>Tipo: Producto<br>Detalle: Items<br>Monto: ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)}${widget.totalPrice}</p><br><p>¡Buenas Noticias! Con esta compra has ganado ${widget.totalPrice} Pet Points. </p><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente,</p><br><p>Equipo de Priority Pet</p></body></html>',
      },
      "payment": {
        "cardBrand": cardBrand == 'vi' ? 'Visa' : cardBrand == 'di' ? 'Dinners' : cardBrand == 'mc' ? 'Mastercard': cardBrand == 'ax' ? 'Amex' : cardBrand,
        "cardNumLast": cardNumLast,
        "TRANSACTION_ID": pagoId,
        "AUTHORIZATION_CODE": authCode,

      }
    });
    // try {
    //   var json =
    //       '{"filial": "01","id": "$productId","cliente": "${PetshopApp.sharedPreferences.getString(PetshopApp.userDocId)}","proveedor": "${widget.cartModel.aliadoId}","emision": "$epDate","formapag": "$formapag","moneda": "PEN","items": [{ "producto": "Productos","cantidad": 1,"precio": ${widget.totalPrice}] }';
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

    setState(() {
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(widget.cartModel.aliadoId)
          .collection('Items')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
        ;
      });
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(widget.cartModel.aliadoId)
          .delete();
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(widget.totalPrice),
      'ppCanjeados': widget.value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }

  Future addAllItemsToOrder(_cartResults) async {
    _cartResults.forEach((allPasteService) async {
      //Pegar la copia del servicio a esta nueva localidad
      await db
          .collection('Ordenes')
          .doc(productId)
          .collection('Items')
          .doc(CarritoModel.fromSnapshot(allPasteService).productoId)
          .set({
        "aliadoId": CarritoModel.fromSnapshot(allPasteService).aliadoId,
        "iId": CarritoModel.fromSnapshot(allPasteService).iId,
        "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
        "precio": CarritoModel.fromSnapshot(allPasteService).precio,
        "cantidad": CarritoModel.fromSnapshot(allPasteService).cantidad,
        "productoId": CarritoModel.fromSnapshot(allPasteService).productoId,
        "titulo": CarritoModel.fromSnapshot(allPasteService).titulo,
        "nombreComercial":
            CarritoModel.fromSnapshot(allPasteService).nombreComercial,
      });
    });
  }




  addPaymentez() async {
    var precio2 = widget.totalPrice * 100;
    dynamic precio = precio2.toInt();
    print('el precio es ${widget.totalPrice*0.12}');
    try {
      var json =
          '{"user":{"id":"${PetshopApp.sharedPreferences.getString(PetshopApp.userUID)}","email": "${PetshopApp.sharedPreferences.getString(PetshopApp.userEmail)}"},"order": {"amount": ${widget.totalPrice}, "description": "${widget.tituloCategoria}","dev_reference": "referencia","vat": 0, "tax_percentage": 0},"card": {"token": "$selectedCardToken"}}';
      var url = ("https://ccapi-stg.paymentez.com/v2/transaction/debit/");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Auth-Token": basicAuth,
      };

      Response res =
      await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = res.statusCode;
      var nuevo = await jsonDecode(res.body);
      //
      // CulqiUserModel culqi = await CulqiUserModel.fromJson(nuevo);
      print(res.body);
      // print(nuevo['outcome']['type']);

      // print(culqi.state);
      // print(culqi.object);
      // print('la marca de tarjeta es ${culqi.card_brand}');
      setState(() {
        // response = statusCode.toString();
        pagoId = nuevo['transaction']['id'];
        authCode = nuevo['transaction']['authorization_code'];
        // type = nuevo['source']['source']['type'];
        // cardType = nuevo['source']['source']['iin']['card_type'];
        cardBrand = nuevo['card']['type'];
        cardNumLast = nuevo['card']['number'];
        //
        // outcomeMsg = nuevo['outcome']['user_message'];
        // outcomeMsgError = nuevo['user_message'];

        print(statusCode);
      });
      // if (cardType == 'credito') {
      //   setState(() {
      //     formapag = '003';
      //   });
      //   if (cardType == 'debito') {
      //     setState(() {
      //       formapag = '004';
      //     });
      //   }
      // }


      if (nuevo['transaction']['status'] == 'success') {
        if (widget.tituloCategoria == 'Servicio') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addServiceToOrders();
        }
        if (widget.tituloCategoria == 'Donar') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addDonationToOrders();
        }
        if (widget.tituloCategoria == 'Adopción') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addAdoptionToOrders();
        }
        if (widget.tituloCategoria == 'Promocion') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addPromoToOrders();
        }
        if (widget.tituloCategoria == 'Plan Mensual' ||
            widget.tituloCategoria == 'Plan Anual') {

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          AddPlanToOrder();
        }
        if (widget.tituloCategoria == 'Videoconsulta') {
          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          addVideoToOrders();
        }

        if (widget.tituloCategoria == 'Producto') {
          getAliadoSnapshots(widget.cartModel.aliadoId);

          // Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreHome(
                  petModel: widget.petModel,
                  defaultChoiceIndex: widget.defaultChoiceIndex,
                )),
          );
          AddCartOrder(context, widget.cartModel);

        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        ErrorMessage(context, outcomeMsgError);
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      ErrorMessage(context, outcomeMsgError);
      print('Error');
      return null;
    }
  }
}
