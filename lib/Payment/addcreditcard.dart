import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_culqi/flutter_culqi.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:http/http.dart' as http;
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/culqiUser.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Models/plan.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart';

class AddCreditCardPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final ServiceModel serviceModel;
  final LocationModel locationModel;
  final AliadoModel aliadoModel;
  final String tituloCategoria;
  final int totalPrice;
  final PromotionModel promotionModel;
  final PlanModel planModel;
  final int defaultChoiceIndex;

  AddCreditCardPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.serviceModel,
      this.locationModel,
      this.aliadoModel,
      this.promotionModel,
      this.tituloCategoria,
      this.totalPrice,
      this.planModel,
      this.defaultChoiceIndex});

  @override
  _AddCreditCardPageState createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends State<AddCreditCardPage> {
  PromotionModel pro;
  PlanModel plan;
  ServiceModel service;
  LocationModel location;
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String expirationMonth;
  String expirationYear;
  String ccToken = '';
  String culqiId;
  String cardBrand = '';
  String _publicKey;
  String _prk;

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);
    changeDet(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);
    changePro(widget.promotionModel);
    changeCart(widget.cartModel);
    changePlan(widget.planModel);
    _getprK();
    _getpuK();
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
                        "Añadir tarjeta",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                ),
                CreditCardForm(
                  formKey: formKey,
                  obscureCvv: true,
                  obscureNumber: true,
                  cardNumberDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Número de la tarjeta',
                    hintText: 'XXXX XXXX XXXX XXXX',
                  ),
                  expiryDateDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Fecha de expiración',
                    hintText: 'XX/XX',
                  ),
                  cvvCodeDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CVV',
                    hintText: 'XXX',
                  ),
                  cardHolderDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre de la tarjeta',
                  ),
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
                SizedBox(
                  width: _screenWidth * 0.8,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: const Text(
                        'Agregar tarjeta',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.white,
                          fontSize: 16.0,
                          package: 'flutter_credit_card',
                        ),
                      ),
                    ),
                    color: const Color(0xFF57419D),
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        _loadingDialog(context);

                        print('valid!');
                        print((cardNumber.replaceAll(' ', '')));
                        CulqiCard card = CulqiCard(
                          cardNumber: (cardNumber.replaceAll(' ', '')),
                          cvv: cvvCode,
                          expirationMonth: int.parse(expirationMonth),
                          expirationYear: int.parse(expirationYear),
                          email: PetshopApp.sharedPreferences
                              .getString(PetshopApp.userEmail),
                        );
                        CulqiTokenizer tokenizer = CulqiTokenizer(card);
                        _token(tokenizer);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                  petModel: model,
                                  aliadoModel: ali,
                                  serviceModel: service,
                                  locationModel: location,
                                  tituloCategoria: widget.tituloCategoria,
                                  totalPrice: widget.totalPrice,
                                  defaultChoiceIndex:
                                      widget.defaultChoiceIndex)),
                        );
                      } else {
                        print('invalid!');
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  addCreditCardToDatabase(ccToken) async {
    try {
      var json =
          '{"customer_id": "${PetshopApp.sharedPreferences.getString(PetshopApp.userCulqi)}","token_id": "$ccToken"}';
      var url = ("https://api.culqi.com/v2/cards");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "$_prk"
      };

      Response res = await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = res.statusCode;
      final nuevo = jsonDecode(res.body);
      //
      CulqiUserModel culqi = CulqiUserModel.fromJson(nuevo);
      print(nuevo['source']['iin']['card_brand']);

      setState(() {
        // response = statusCode.toString();
        culqiId = culqi.id;
        cardBrand = nuevo['source']['iin']['card_brand'];
        print(culqi.id);
        print(cardBrand);
        print(statusCode);
      });

      Navigator.of(context, rootNavigator: true).pop();
      print('la marca de tarjeta es $cardBrand');
    } catch (e) {
      print(e.message);
      return null;
    }

    db
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Metodos de pago')
        .doc(productId)
        .set({
      "cardBrand": cardBrand,
      "cardId": productId,
      "cardToken": culqiId,
      "createdOn": DateTime.now(),
      "cardNumber": cardNumber,
      "expiryDate": expiryDate,
    });
    showDialog(
        builder: (context) => new ChoosePetAlertDialog(
          message: "Tarjeta añadida exitosamente",
        ), context: context);
    setState(() {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      print(creditCardModel.brand);
      cardBrand = creditCardModel.brand;
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      expirationMonth = (expiryDate[0] + expiryDate[1]);
      expirationYear = ('20' + expiryDate.substring(3));
    });
  }

  _token(tokenizer) async {
    var result = await tokenizer.getToken(publicKey: '$_publicKey');
    if (result is CulqiToken) {
      print(result.token);
      Message(context, result.toString());

      setState(() {
        ccToken = result.token;
        Navigator.of(context, rootNavigator: true).pop();
      });
      print('Esta verga es el= $ccToken');
      addCreditCardToDatabase(ccToken);
    } else if (result is CulqiError) {
      print('buenaaaaaaaa');
      print(result);
      Message(context, result.errorMessage);
    }
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

  changeCart(otro) {
    setState(() {
      cart = otro;
    });
    return otro;
  }

  changePlan(otro) {
    setState(() {
      plan = otro;
    });
    return otro;
  }

  _getprK() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Culqi").doc("Priv");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _prk = (dataSnapshot.data()["prk"]);
      });
    });
  }

  _getpuK() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Culqi").doc("Pub");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _publicKey = (dataSnapshot.data()["puk"]);
      });
    });
  }

  Future<void> _loadingDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: true,
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
                      "Registrando...",
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

  Future<void> Message(BuildContext context, String error) async {
    Navigator.of(context, rootNavigator: true).pop();
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
                    Icon(Icons.cancel, color: Colors.red, size: 55.0),
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
}
