import 'package:flutter/material.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class EPCrearPago extends StatefulWidget {
  final PetModel petModel;
  final int totalPrice;
  final AliadoModel aliadoModel;
  final Function(String, String, int) onSuccess;
  final int defaultChoiceIndex;

  const EPCrearPago(
      {@required this.petModel,
      @required this.totalPrice,
      @required this.aliadoModel,
      @required this.defaultChoiceIndex,
      this.onSuccess});

  @override
  _EPCrearPagoState createState() => _EPCrearPagoState();
}

class _EPCrearPagoState extends State<EPCrearPago> {
  @override
  Widget build(BuildContext context) {
    var simbolo =
        PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda);
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
            child:
                Container() /*SingleChildScrollView(
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
                    Expanded(child: Padding(
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
                  widget.totalPrice.toString() + " " + simbolo,
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
                    Expanded(child: Padding(
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
                Text(
                  _correoCuenta,
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
                    Expanded(child: Padding(
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
                    Expanded(child: Padding(
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
                    width: _screenWidth * 0.82,
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
                    width: _screenWidth * 0.82,
                    child: CustomTextField(
                      controller: _apellidoPagadorController,
                      hintText: "Apellido del titular",
                      isObsecure: false,
                    ),
                  ),
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
                    },
                  ),
                )
              ],
            ),
          ),*/
            ),
      ),
    );
  }

  void _getKey() {
    /*DocumentReference documentReference =
      FirebaseFirestore.instance.collection("Aikonspay").doc("config");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _apiKey = dataSnapshot.data()["key"];
        _serviceUrl = (dataSnapshot.data()["ruta"]);
        _titularCuenta = (dataSnapshot.data()["titular"]);
        _correoCuenta = (dataSnapshot.data()["correo"]);
      });
    });*/
  }

  void _registrarPago() async {
    /*try {
      var nombre = PetshopApp.sharedPreferences.getString(PetshopApp.userNombre);
      var apellido = PetshopApp.sharedPreferences.getString(PetshopApp.userApellido);
      var cedula = PetshopApp.sharedPreferences.getString(PetshopApp.userDocId);
      
      Map<String, String> headers = {
        "Content-type": "application/json",
        "x-api-key": _apiKey
      };

      Map<String, String> jsonPago = {
        "moneda": "USD",
        "metodo": "ZELLE",
        "nombre": nombre,
        "apellido": apellido,
        "documento": cedula,
        "monto": widget.totalPrice.toString(),
        "nombreZelle": _nombrePagadorController.text,
        "apellidoZelle": _apellidoPagadorController.text,
        "tipoDocumento": "v"
      };

      Response response = await http.post(_serviceUrl, headers: headers, body: jsonEncode(jsonPago));
      int statusCode = response.statusCode;
      var bodyResponse = await jsonDecode(response.body);
      if(statusCode == 200) {
        
        if(widget.onSuccess != null) {
          showDialog(
            context: context,
            barrierColor: Colors.white.withOpacity(0),
            child: AlertDialog(
              // title: Text('Su pago ha sido aprobado.'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      "$nombre, tu pago ha sido registrado con éxito. Te notificaremos cuando este sea aprobado.",
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
                        child: Text("Continuar",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 18.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).then((result) {
            widget.onSuccess(bodyResponse["referencia"], "Pendiente",  0);
          });
          
        }
      }
    } on Exception catch(exception) {

    }*/
  }
}
