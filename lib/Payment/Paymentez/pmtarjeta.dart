import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_paymentez/flutter_paymentez.dart';
import 'package:flutter_paymentez/models/addCardResponse.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Models/plan.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Widgets/navbar.dart';

import '../payment.dart';


class PmTarjeta extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final ServiceModel serviceModel;
  final LocationModel locationModel;
  final AliadoModel aliadoModel;
  final String tituloCategoria;
  final dynamic totalPrice;
  final PromotionModel promotionModel;
  final PlanModel planModel;
  final int defaultChoiceIndex;

  PmTarjeta(
  {
    this.petModel,
    this.productoModel,
    this.cartModel,
    this.serviceModel,
    this.locationModel,
    this.aliadoModel,
    this.promotionModel,
    this.tituloCategoria,
    this.totalPrice,
    this.planModel,
    this.defaultChoiceIndex
}
);
  @override
  _PmTarjetaState createState() => _PmTarjetaState();
}

class _PmTarjetaState extends State<PmTarjeta> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _platformVersion = 'Unknown';

  final FlutterPaymentez _pymntz = FlutterPaymentez();

  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _cardTextController = TextEditingController();
  TextEditingController _dateTextController = TextEditingController();
  TextEditingController _cvcTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPaymentez.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: Color(0xFF57419D)),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                const Text('Agregar tarjeta'),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            petModel: widget.petModel,
            defaultChoiceIndex: widget.defaultChoiceIndex,
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameTextController,
                  decoration: InputDecoration(
                      hintText: "Nombre de la tarjeta",
                      icon: Icon(Icons.person),
                      border: InputBorder.none),
                  //obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Campo obligatorio";
                    }
                    /*else if (value.length < 6) {
                  return "the password has to be at least 6 characters long";
                }*/
                    return null;
                  },
                ),
                TextFormField(
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(16),
                    WhitelistingTextInputFormatter.digitsOnly,
                    BlacklistingTextInputFormatter.singleLineFormatter
                  ],
                  controller: _cardTextController,
                  decoration: InputDecoration(
                      hintText: "Número de la tarjeta",
                      icon: Icon(Icons.credit_card),
                      border: InputBorder.none),
                  //obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Campo obligatorio";
                    }
                    /*else if (value.length < 6) {
                  return "the password has to be at least 6 characters long";
                }*/
                    return null;
                  },
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(4),
                          WhitelistingTextInputFormatter.digitsOnly,
                          BlacklistingTextInputFormatter.singleLineFormatter
                        ],
                        controller: _dateTextController,
                        decoration: InputDecoration(
                            hintText: "Fecha de expiración",
                            icon: Icon(Icons.calendar_today),
                            border: InputBorder.none),
                        //obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Campo obligatorio";
                          }
                          /*else if (value.length < 6) {
                    return "the password has to be at least 6 characters long";
                  }*/
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(4),
                          WhitelistingTextInputFormatter.digitsOnly,
                          BlacklistingTextInputFormatter.singleLineFormatter
                        ],
                        controller: _cvcTextController,
                        decoration: InputDecoration(
                            hintText: "Código de seguridad",
                            icon: Icon(Icons.lock),
                            border: InputBorder.none),
                        //obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Campo obligatorio";
                          }
                          /*else if (value.length < 6) {
                    return "the password has to be at least 6 characters long";
                  }*/
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color.fromRGBO(0, 40, 75, 1.0),
                    elevation: 0.0,
                    child: SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _addCard();
                          }
                          //SystemChannels.textInput.invokeMethod('TextInput.hide');
                          //handlePayment(_nameTextController.text, _cardTextController.text, _dateTextController.text, _cvcTextController.text);
                        },
                        //minWidth: MediaQuery.of(context).size.width,
                        child: Text(
                          "Agregar Tarjeta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )

        /*Center(
          child: Text('Running on: $_platformVersion\n'),
        ),*/

      ),
    );
  }

  void _addCard() async{
    final AddCardResponseModel response = await _pymntz.addCard(
      uid: PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      email: PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
      name: _nameTextController.text,
      cardNumber: _cardTextController.text,
      expiryMonth: _dateTextController.text.substring(0,2),
      expiryYear: _dateTextController.text.substring(2),
      cvc: _cvcTextController.text,
      clientAppCode: "TPP3-EC-CLIENT",
      clientAppKey: "ZfapAKOk4QFXheRNvndVib9XU3szzg",
      /*clientAppCode: "Client_App_Code",
      clientAppKey: "Client_App_Key",*/
      isTestMode: true.toString(),
    );
    _loadingDialog(context);
    print("Respuesta desde plugin: "+ response.status +" "+ response.message);
    Message(context, response.status == 'valid'? 'Tarjeta agregada satisfactoriamente.' : '${response.status}: ${response.message}');

    response.status == 'valid'?
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PaymentPage(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,
              aliadoModel: widget.aliadoModel,
              serviceModel: widget.serviceModel,
              locationModel: widget.locationModel,
              tituloCategoria: widget.tituloCategoria,
              totalPrice: widget.totalPrice,)),
    ): Container();
    //Fluttertoast.showToast(msg: "Error al iniciar sesión :'(",backgroundColor: Colors.black, textColor: Colors.white);
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

}


// clientAppCode: "TPP3-EC-CLIENT",
// clientAppKey: "ZfapAKOk4QFXheRNvndVib9XU3szzg",