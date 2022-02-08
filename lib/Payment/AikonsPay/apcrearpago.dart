import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

class APCrearPago extends StatefulWidget {
  final PetModel petModel;
  final dynamic totalPrice;
  final AliadoModel aliadoModel;
  final Future<void> Function(String, String, dynamic) onSuccess;
  final int defaultChoiceIndex;
  final String moneda;

  const APCrearPago(
      {@required this.petModel,
      @required this.totalPrice,
      @required this.aliadoModel,
      @required this.defaultChoiceIndex,
      @required this.onSuccess,
      this.moneda = MonedaEnum.dolar
    });

  @override
  _APCrearPagoState createState() => _APCrearPagoState();
}

class _APCrearPagoState extends State<APCrearPago> {
  TextEditingController _nombrePagadorController = TextEditingController();
  TextEditingController _apellidoPagadorController = TextEditingController();
  TextEditingController _referenciaController = TextEditingController();
  String _apiKey =
      "2210d88da6603d941145cfdd60a47e246ce1142b3db9eba07ba63a46e99f00f9";
  String _serviceUrl = "https://aikonspay.com/api/pasarela/ppcv";
  String _titularCuenta = "";
  String _correoCuenta = "";
  String _montoTexto = "Monto que debes transferir";
  String _correoTexto =
      "Debes realizar el pago zelle a la dirección de correo electrónico.";
  String _pagoMovilTexto =
      "Debes realizar el pago movil a la siguiente cuenta";
  String _titularTexto = "a nombre del titular de la cuenta";
  String _referencia;
  HttpClient client;


  @override
  void initState() {
    _getKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var simbolo =
        PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda);
    double screenWidth = MediaQuery.of(context).size.width,
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
        drawer: MyDrawer(),
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
            child: widget.moneda == MonedaEnum.dolar ? 
            dolarWidget(context, screenWidth, simbolo) : bolivarWidget(context, screenWidth, simbolo),  
          ),
        ),
      ),
    );
  }

  void _getKey() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Aikonspay").doc("config");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _apiKey = dataSnapshot["key"];
        _serviceUrl = (dataSnapshot["ruta"]);
        _titularCuenta = (dataSnapshot["titular"]);
        _correoCuenta = (dataSnapshot["correo"]);
      });
    });
  }

  void _registrarPago() async {
    try {
      var nombre =
          PetshopApp.sharedPreferences.getString(PetshopApp.userNombre);
      var apellido =
          PetshopApp.sharedPreferences.getString(PetshopApp.userApellido);
      var numeroDocumento =
          PetshopApp.sharedPreferences.getString(PetshopApp.userDocId);
      //var tipoDocument = PetshopApp.sharedPreferences.getString(PetshopApp.);

      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        /*final isValidHost = host == "api.my_app";
        return isValidHost;*/
        return true;
      });

      client.connectionTimeout = Duration(seconds: 10);

      Map<String, String> headers = {
        "Content-type": "application/json",
        "x-api-key": _apiKey
      };

      double totalPrice = 0;
      if (widget.totalPrice is int)
        totalPrice = widget.totalPrice.toDouble();
      else if (widget.totalPrice is String)
        totalPrice = double.parse(widget.totalPrice);
      else
        totalPrice = widget.totalPrice;
      String moneda = "";
      String metodoDePago = "";
      String nombreZelle = "";
      String apellidoZelle = "";
      String referencia = "";

      if(widget.moneda == MonedaEnum.dolar) {
        moneda = "USD";
        metodoDePago = "ZELLE";
        nombreZelle = _nombrePagadorController.text;
        apellidoZelle = _apellidoPagadorController.text;
        referencia = "";
      } else {
        moneda = "VES";
        metodoDePago = "PAGO MOVIL";
        nombreZelle = nombre;
        apellidoZelle = apellido;
        referencia = _referenciaController.text;
      }

      Map<String, dynamic> jsonPago = {
        "moneda": moneda,
        "metodo": metodoDePago,
        "caja": widget.aliadoModel.email,
        "nombre": nombre,
        "apellido": apellido,
        "documento": numeroDocumento,
        "monto": totalPrice,
        "nombreZelle": _nombrePagadorController.text,
        "apellidoZelle": _apellidoPagadorController.text,
        "tipoDocumento": "v"
      };

      /*var response = await http.post(_serviceUrl, headers: headers, body: jsonEncode(jsonPago))
        .timeout(
          Duration(seconds: 10), 
          onTimeout: () {
            _mostrarMensaje(
              "La pasarela de pago no se encuentra disponible. Intenta nuevamente",
              "Continuar",
              false
            );

            return Response("", 500);
          }
        );*/
      HttpClientRequest request = await client.postUrl(Uri.parse(_serviceUrl));

      request.headers.set('content-type', 'application/json');

      request.headers.set('x-api-key', _apiKey);

      request.add(utf8.encode(json.encode(jsonPago)));

      HttpClientResponse response = await request.close();

      response.transform(utf8.decoder).listen((responseBody) {
        int statusCode = response.statusCode;
        var bodyResponse = jsonDecode(responseBody);
        if (statusCode == 200) {
          _referencia = bodyResponse["referencia"];
          _mostrarMensaje(
              "$nombre, tu pago ha sido registrado con éxito. Te notificaremos cuando este sea aprobado",
              "Continuar",
              true);
        } else {
          _mostrarMensaje(
              "Se ha producido un error en la operación. Intenta nuevamente",
              "Continuar",
              false);
        }
      });
    } on Exception catch (exception) {
      _mostrarMensaje(
          "La pasarela de pago no se encuentra disponible. Intenta nuevamente",
          "Continuar",
          false);
    }
  }

  Widget bolivarWidget(BuildContext context, double screenWidth, String simbolo) {
    return Column(
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
                "Pago móvil",
                style: TextStyle(
                  color: Color(0xFF57419D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _montoTexto,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          widget.totalPrice.toStringAsFixed(2) + " " + simbolo,
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _pagoMovilTexto,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text("04165554433",
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left
        ),
        SizedBox(
          height: 5,
        ),
        Text("Banplus",
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left
        ),
        SizedBox(
          height: 5,
        ),
        Text("J-887744223",
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Por último, debes ingresar los últimos 4 dígitos de la referencia de pago que te arroje el banco.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Container(
            width: screenWidth * 0.82,
            child: CustomTextField(
              controller: _referenciaController,
              hintText: "Nombre del titular",
              isObsecure: false,
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        SizedBox(
          width: screenWidth * 0.8,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: const Text(
                'Registrar pago',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            color: const Color(0xFF57419D),
            onPressed: () {
              _registrarPago();
              /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StoreHome(
                          petModel: widget.petModel,
                      defaultChoiceIndex: widget
                          .defaultChoiceIndex,
                        )),
              );*/
            },
          ),
        )
      ],
    );
  }

  Widget dolarWidget(BuildContext context, double screenWidth, String simbolo) {
    return Column(
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
                "Zelle",
                style: TextStyle(
                  color: Color(0xFF57419D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _montoTexto,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          widget.totalPrice.toStringAsFixed(2) + " " + simbolo,
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _correoTexto,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text(_correoCuenta,
            style: TextStyle(
              color: Color(0xFF57419D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _titularTexto,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          _titularCuenta,
          style: TextStyle(
            color: Color(0xFF57419D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Por último, debes ingresar el nombre apellido del titular de la cuenta desde la cual estás realizando el pago.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Container(
            width: screenWidth * 0.82,
            child: CustomTextField(
              controller: _nombrePagadorController,
              hintText: "Nombre del titular",
              isObsecure: false,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Center(
          child: Container(
            width: screenWidth * 0.82,
            child: CustomTextField(
              controller: _apellidoPagadorController,
              hintText: "Apellido del titular",
              isObsecure: false,
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        SizedBox(
          width: screenWidth * 0.8,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: const Text(
                'Registrar pago',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            color: const Color(0xFF57419D),
            onPressed: () {
              _registrarPago();
              /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StoreHome(
                          petModel: widget.petModel,
                      defaultChoiceIndex: widget
                          .defaultChoiceIndex,
                        )),
              );*/
            },
          ),
        )
      ],
    );
  }

  void _mostrarMensaje(String mensaje, String textoBoton, bool success) async {
    await showDialog(
      builder: (context) => AlertDialog(
        // title: Text('Su pago ha sido aprobado.'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                mensaje,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 14,
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    //
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  color: Color(0xFF57419D),
                  padding: EdgeInsets.all(10.0),
                  child: Text(textoBoton,
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.white,
                          fontSize: 18.0)),
                ),
              ),
            ],
          ),
        ),
      ), context: context,
      barrierColor: Colors.white.withOpacity(0),
    ).then((result) {
      if (success) widget.onSuccess(_referencia, PagoEnum.pagoPendiente, 0);
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
