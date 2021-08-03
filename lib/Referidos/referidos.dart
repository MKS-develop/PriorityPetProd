import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:contact_picker/contact_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

class ReferidosPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  ReferidosPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _ReferidosPageState createState() => _ReferidosPageState();
}

class _ReferidosPageState extends State<ReferidosPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  String userEmail;
  var contactNumber;
  String userName;
  String response;
  String aliadoUsername;
  String aliadoId;
  String aliadoCodigo;
  String buttonText = "Enviar invitación";
  String message =
      'Hey, únete a Priority Pet Dueños y/o Aliados y disfruta de todo lo que tenemos para ofrecer\n \n🐶🐱🐷🐨🐤🐸\n \nSi eres un proveedor de servicios o productos usa este enlace:\nhttps://play.google.com/store/apps/details?id=com.ppa.ppet_aliado\n \nSi eres dueño de una mascota usa este otro enlace:\nhttps://play.google.com/store/apps/details?id=com.ppd.prioritypet\n \nEn ambos casos usa el código \nCODIGO\n para que apoyes al aliado o dueño de mascota';
  List<bool> isSelected = [true, false, false];
  var referidos = [];

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    _getData();
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // User user = FirebaseAuth.instance.currentUser;
    double width = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // aliadoUsername = snapshot.data['nombre'];
            // aliadoId = snapshot.data['aliadoId'];

            return Scaffold(
              drawer: MyDrawer(
                petModel: widget.petModel,
                defaultChoiceIndex: widget.defaultChoiceIndex,
              ),
              appBar: AppBarCustomAvatar(
                  context, widget.petModel, widget.defaultChoiceIndex),
              body: Container(
                  child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Color(0xFF57419D)),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          Text(
                            "Invita a un amigo",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 19.0),
                          )
                        ]),
                  ),
                  SizedBox(height: 25.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Invita a tus amigos para que descarguen la APP Priority Pet Club y puedan formar parte de nuestra gran comunidad. Por cada amigo que se afilie te regalaremos 100 Puntos",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: primaryColor,
                                fontWeight: FontWeight.w300,
                              )),
                          SizedBox(height: 30.0),
                          ToggleButtons(
                            children: [
                              Icon(Icons.email),
                              Icon(Icons.message),
                              Icon(Icons.share),
                            ],
                            constraints: BoxConstraints(
                                minWidth: width * 0.29,
                                minHeight: 50.0,
                                maxWidth: width * 0.29),
                            borderRadius: BorderRadius.circular(10.0),
                            selectedColor: Colors.white,
                            fillColor: primaryColor,
                            color: primaryColor,
                            disabledColor: primaryColor,
                            selectedBorderColor: primaryColor,
                            onPressed: (int index) {
                              setState(() {
                                for (int buttonIndex = 0;
                                    buttonIndex < isSelected.length;
                                    buttonIndex++) {
                                  if (buttonIndex == index) {
                                    isSelected[buttonIndex] = true;
                                    print(isSelected[buttonIndex]);
                                  } else {
                                    isSelected[buttonIndex] = false;
                                    print(isSelected[buttonIndex]);
                                  }
                                }
                              });
                            },
                            isSelected: isSelected,
                          ),
                          SizedBox(height: 30.0),
                          isSelected[0]
                              ? Column(
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nombre del invitado',
                                            style: TextStyle(
                                                color: Color(0xFF7F9D9D),
                                                fontSize: 17.0,
                                                fontFamily: 'Product Sans'),
                                          ),
                                          SizedBox(height: 15.0),
                                          Container(
                                            width: width,
                                            height: 55.0,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color:
                                                    textColor.withOpacity(0.5),
                                                width: 1.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: TextFormField(
                                              validator: (val) => val.isEmpty
                                                  ? "Nombre de la persona a la que deseas invitar"
                                                  : null,
                                              onChanged: (val) =>
                                                  userName = val,
                                              decoration: InputDecoration(
                                                  // filled: true,
                                                  // fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.all(1.0),
                                                  labelStyle: TextStyle(
                                                    color: textColor,
                                                  ),
                                                  hintText:
                                                      "Nombre de la persona a la que deseas invitar",
                                                  errorStyle: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 16.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  )),
                                            ),
                                          ),
                                        ]),
                                    SizedBox(height: 30.0),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                                color: Color(0xFF7F9D9D),
                                                fontSize: 17.0,
                                                fontFamily: 'Product Sans'),
                                          ),
                                          SizedBox(height: 15.0),
                                          Container(
                                            width: width,
                                            height: 55.0,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color:
                                                    textColor.withOpacity(0.5),
                                                width: 1.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: TextFormField(
                                              validator: (val) => val.isEmpty
                                                  ? "Email de la persona a la que deseas invitar"
                                                  : null,
                                              onChanged: (val) =>
                                                  userEmail = val,
                                              decoration: InputDecoration(
                                                  // filled: true,
                                                  // fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.all(1.0),
                                                  labelStyle: TextStyle(
                                                    color: textColor,
                                                  ),
                                                  hintText:
                                                      "Email de la persona a la que deseas invitar",
                                                  errorStyle: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 16.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  )),
                                            ),
                                          ),
                                        ]),
                                  ],
                                )
                              : isSelected[1]
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Abrir libreta de contactos',
                                          style: TextStyle(
                                              color: Color(0xFF7F9D9D),
                                              fontSize: 17.0,
                                              fontFamily: 'Product Sans'),
                                        ),
                                        SizedBox(height: 15.0),
                                        GestureDetector(
                                          onTap: () {
                                            openContactBook();
                                          },
                                          child: Container(
                                              width: width,
                                              height: 55.0,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: textColor
                                                      .withOpacity(0.5),
                                                  width: 1.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                contactNumber ??
                                                    "Seleccionar contacto",
                                                style: TextStyle(
                                                    color: primaryColor),
                                              )),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          onPressed: () {
                                            String m = message.replaceAll(
                                                "CODIGO",
                                                aliadoCodigo.toString());
                                            FlutterShareMe()
                                                .shareToWhatsApp(msg: m);
                                          },
                                          minWidth:
                                              MediaQuery.of(context).size.width,
                                          height: 55.0,
                                          color: Color(0xFF128C7E),
                                          child: Text("Compartir en WhatsApp",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Product Sans',
                                                  fontSize: 18.0)),
                                        ),
                                      ],
                                    ),
                          SizedBox(height: 30.0),
                          isSelected[2]
                              ? Container()
                              : FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    isSelected[0] ? sendEmail() : _sendSMS();
                                  },
                                  minWidth: MediaQuery.of(context).size.width,
                                  height: 55.0,
                                  color: primaryColor,
                                  child: Text("Enviar",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Product Sans',
                                          fontSize: 18.0)),
                                ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
              bottomNavigationBar: CustomBottomNavigationBar(),
            );
          } else {
            return Container();
          }
        });
  }

  Future sendEmail() async {
    if (referidos.contains(userEmail)) {
      response = "Ya se invito a esta persona";
      dialogError(context, response);
    } else if (userEmail == null ||
        userName == null ||
        !userEmail.contains("@")) {
      response = "Ingrese los datos correctamente";
      dialogError(context, response);
    } else {
      try {
        setState(() {
          buttonText = "Invitando...";
        });

        var res = await http.get(Uri.parse(
            'https://us-central1-priority-pet.cloudfunctions.net/sendInvitationEmail?dest=$userEmail&aliado=$aliadoUsername&username=$userName'));
        await FirebaseFirestore.instance
            .collection('Referidos')
            .doc(userEmail)
            .set({
          "aliadoId": aliadoId,
          "referidoEmail": userEmail,
          "registrado": false
        });
        setState(() {
          response = res.body;
          dialog(context, response);
          print(response);
          buttonText = "Enviar invitación";
        });
      } catch (e) {
        print(e.message);
        return null;
      }
    }
  }

  Future<void> dialog(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: primaryColor, size: 60.0),
                    SizedBox(height: 20.0),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
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

  Future check() async {
    // datasnapshot.data.containsValue("nova")
    User user = await FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Dueños")
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot datasnapshot) {
      if (datasnapshot.data().containsKey("codigoReferido")) {
        print("Si contiene codigo");
        setState(() {
          aliadoCodigo = datasnapshot.data()['codigoReferido'];
        });
      } else {
        print("No contiene codigo");
        var rng = new Random();
        var n = rng.nextInt(1000);
        var a = datasnapshot.data()['nombre'].toLowerCase();
        var b = a.replaceAll(" ", "");
        setState(() {
          aliadoCodigo = b + n.toString();
        });
        FirebaseFirestore.instance.collection('Dueños').doc(user.uid).update({
          "codigoReferido": aliadoCodigo,
        });
        FirebaseFirestore.instance
            .collection('Referidos')
            .doc(aliadoCodigo)
            .set({
          "uid": user.uid,
          "codigoReferidos": aliadoCodigo,
          "tipoUsuario": "Aliado",
          "createdOn": FieldValue.serverTimestamp(),
          "aliadoId": "",
        });
      }
    });
  }

  Future<void> dialogError(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60.0),
                    SizedBox(height: 20.0),
                    Text(
                      msg,
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

  void _sendSMS() async {
    // var rng = new Random();
    // var n = rng.nextInt(1000);
    // var a = PetshopApp.sharedPreferences
    //     .getString(PetshopApp.userNombre)
    //     .toLowerCase();
    // var b = a.replaceAll(" ", "");
    // var c = b + n.toString();
    // setState(() {
    //   aliadoCodigo = c.trim();
    // });
    // List<String> recipients = [contactNumber];
    // String m = message.replaceAll("CODIGO", aliadoCodigo.toString());
    // String _result =
    //     await sendSMS(message: m, recipients: recipients).catchError((onError) {
    //   print(onError);
    // });
    // print(_result);
  }

  Future<String> openContactBook() async {
    // Contact contact = await ContactPicker().selectContact();
    // if (contact != null) {
    //   var phoneNumber = contact.phoneNumber.number
    //       .toString()
    //       .replaceAll(new RegExp(r"\s+"), "");
    //   print(phoneNumber);
    //   setState(() {
    //     contactNumber = phoneNumber;
    //   });
    //   // return phoneNumber;
    // }
    // return "";
  }

  Future<List<dynamic>> _getData() async {
    referidos = [];
    try {
      await FirebaseFirestore.instance
          .collection('Referidos')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((referido) {
                  setState(() {
                    referidos.add(referido.id.toString());
                  });
                })
              });
      print(referidos.length);
    } catch (e) {
      print(e);
    }
    return referidos;
  }

  Stream<DocumentSnapshot> getData() async* {
    // ignore: await_only_futures
    User user = await FirebaseAuth.instance.currentUser;
    yield* FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .snapshots();
  }
}
