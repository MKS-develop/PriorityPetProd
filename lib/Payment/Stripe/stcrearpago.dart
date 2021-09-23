import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/Card.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Payment/Stripe/stnuevatarjeta.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

class STCrearPago extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  final dynamic totalPrice;
  final String tituloCategoria;
  final Future<void> Function(String, String, dynamic) onSuccess;
  
  const STCrearPago({
    this.petModel,
    this.defaultChoiceIndex,
    this.totalPrice,
    this.tituloCategoria,
    this.onSuccess
  }) : super();

  @override
  _STCrearPagoState createState() => _STCrearPagoState();
}

class _STCrearPagoState extends State<STCrearPago> {

  String _publishableKey;
  String _secretKey;
  String _url;
  String obscurecard;
  String selectedCardToken;
  String selectedobscurecard;
  int selectedIndex;
  String date = DateTime.now().toString();
  String epDate;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    _cargarConfigStripe();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    // CulqiTokenizer tokenizer = CulqiTokenizer(card);
    // _token(tokenizer);
    String dateSplit = date.split(" ")[0];
    setState(() {
      epDate = dateSplit.replaceAll(new RegExp(r'[^\w\s]+'), '');
    });

    print(epDate);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar: CustomBottomNavigationBar(
          //petModel: widget.petModel,
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
                      color: Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFBDD7D6),
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                          .collection("Dueños")
                          .doc(PetshopApp.sharedPreferences
                            .getString(PetshopApp.userUID))
                          .collection('Metodos de pago')
                          .where("pasarela", isEqualTo: "Stripe")
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
                                  dataSnapshot.data.docs[index].data()
                                );
                                obscurecard =
                                  '****' + (card.cardNumber).substring(14);
                                return ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:CrossAxisAlignment.start,
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
                                            fontSize: 12
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 0.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    tileColor: selectedIndex == index
                                        ? Color(0xFFEB9448)
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        selectedCardToken = card.cardToken;
                                        selectedobscurecard = '****' +
                                            (card.cardNumber).substring(14);
                                        print(card.cardNumber);
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
                                builder: (context) => STNuevaTarjetaPage(
                                    petModel: widget.petModel,
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

                                                            // TODO Revisar caso particular de apadrinamiento
                                                            /*if(widget.tituloCategoria!='Apadrinar'){
                                                              addCulqi();
                                                            }
                                                            else{
                                                              addCulqiApadrinar();
                                                            }*/

                                                            _registrarPago(selectedCardToken);


                                                            /*Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            _loadingDialog(
                                                                context);*/
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

  void _registrarPago(String cardToken) async {
    Map<String, dynamic> formMap = {
      "payment_method": "$cardToken",
      "currency": "MXN",
      "amount": (widget.totalPrice * 100).toString()
    };

    http.Response response = await http.post(
      _url + "payment_intents",
      body: formMap,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_secretKey"
      },
      encoding: Encoding.getByName("utf-8"),
    );

    if(response.statusCode == 200) {
      widget.onSuccess("code", PagoEnum.pagoAprobado, widget.totalPrice);
    } else {
      Navigator.pop(context);
    }
    // TODO Programar función para registrar el pago 
  }

  void _checkCustomerId() async{
    var userStripe = 
      PetshopApp.sharedPreferences.getString(PetshopApp.userStripe);

      var nombre = PetshopApp.sharedPreferences.getString(PetshopApp.userNombre) + " " + 
        PetshopApp.sharedPreferences.getString(PetshopApp.userApellido);
    
    // Si no tiene id de stripe, hay que registrar el dueño en Stripe
    if(userStripe == null || userStripe.isEmpty) {
      Map<String, dynamic> formMap = {
        "email": PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        "name": nombre
      };

      http.Response response = await http.post(
        _url + "customers",
        body: jsonEncode(formMap),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $_secretKey"
        },
        encoding: Encoding.getByName("utf-8"),
      );

      if(response.statusCode == 200) {
        var mapResponse = jsonDecode(response.body);
        var userStripe = mapResponse["id"];
        db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .set({
            "id_stripe": userStripe,
          });
        print("Registró con éxito al usuario");
      } else {
        var mapResponse = jsonDecode(response.body);
        print(mapResponse);
      }
    }
  }

  void _cargarConfigStripe() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Stripe").doc("config");
    documentReference.get().then((dataSnapshot) {
      var config = dataSnapshot.data();
      _publishableKey = dataSnapshot.data()["publishableKey"];
      _secretKey = (dataSnapshot.data()["secretKey"]);
      _url = (dataSnapshot.data()["url"]);
      _checkCustomerId();
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
            borderRadius: BorderRadius.circular(20.0)
          ), //this right here
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
                      fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}