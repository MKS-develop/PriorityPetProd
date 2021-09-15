
import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';


double width;

class DonarConfirmar extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  final AliadoModel aliadoModel;

  DonarConfirmar({this.petModel, this.defaultChoiceIndex, this.aliadoModel});

  @override
  _DonarConfirmarState createState() => _DonarConfirmarState();
}

class _DonarConfirmarState extends State<DonarConfirmar> {
  DateTime selectedDate = DateTime.now();

  final TextEditingController _donarTextEditingController = TextEditingController();

  PetModel model;

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  String tituloCategoria = "Donar";

  @override
  void initState() {
    super.initState();
    changePet(widget.petModel);

  }

  ScrollController controller = ScrollController();


  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    // DateTime birthday = widget.petModel.fechanac.toDate();
    // DateTime today = DateTime.now(); //2020/1/24
    // AgeDuration age;
    // age = Age.dateDifference(
    //     fromDate: birthday, toDate: today, includeToDate: false);
    //
    // print(age.years);
    // print(DateFormat('yyyy-MM-dd').format(widget.petModel.fechanac.toDate()));
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
                height: MediaQuery.of(context).size.height,
                // decoration: new BoxDecoration(
                //   image: new DecorationImage(
                //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
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
                            "Donar",
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
                    Text("¡Gracias por querer ayudar a ${widget.petModel.nombre}!",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    SizedBox(
                      height: 15,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.petModel.petthumbnailUrl,
                        height: 150,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, object, stacktrace) {
                          return Container();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: _screenWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                  "Tu aporte voluntario ayudará a los albergues a seguir cumpliendo su misión. Tu donación para ${widget.petModel.nombre}, será destinada para contribuir con su alimentación, salud y darle una mejor calidad de vida. Gracias por ayudarnos a seguir rescatando animales en abandono, ellos nos necesitan."),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(3.0),
                            //   child: Text(
                            //       "El aporte requerido es de  S/100 por mes. Recibirás fotos, un Boletín mensual con noticias del albergue, cuponera con descuento. "),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(3.0),
                            //   child: Text(
                            //       "Después de su recuperación, estará lista para adopción!  Si esto ocurre, te notificaremos para que apadrines a otra mascota o para que tu aportación mensual sea suspendida."),
                            // ),
                          ],
                        )),
                    SizedBox(
                      height: 15,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Monto que deseas donar:",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: primaryColor,
                                fontSize: 15.0)),

                        Container(
                          width: 100,
                          height: 35,
                          child: TextField(
                            controller: _donarTextEditingController,
                            autocorrect: true,
                            autofocus: false,
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 17, color: primaryColor, fontWeight:
                            FontWeight.bold),
                            decoration: InputDecoration(
                              // hintText: '0',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 9, 0, 0),
                                child: Text(PetshopApp.sharedPreferences
                                    .getString(PetshopApp
                                    .simboloMoneda), style: TextStyle(
                                                  fontFamily:
                                                  'Product Sans',
                                                  color: Color(0xFF57419D),
                                                  fontSize: 18.0,
                                                  fontWeight:
                                                  FontWeight.bold)),
                              ),

                              hintStyle: TextStyle(color: Colors.grey),
                              // filled: true,
                              // fillColor: Colors.white70,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color:primaryColor, width: 2),
                              ), ),),
                        ),




                        // SizedBox(
                        //   width: 90.0,
                        //   child: RaisedButton(
                        //     onPressed: () {},
                        //     shape: RoundedRectangleBorder(
                        //         side: BorderSide(color: primaryColor),
                        //         borderRadius:
                        //         BorderRadius.circular(5)),
                        //     color: Colors.white,
                        //     padding: EdgeInsets.all(0.0),
                        //     child: Row(
                        //       mainAxisAlignment:
                        //       MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //             '${PetshopApp.sharedPreferences
                        //                 .getString(PetshopApp
                        //                 .simboloMoneda)} ${widget.petModel.costroApadrinar}',
                        //             style: TextStyle(
                        //                 fontFamily:
                        //                 'Product Sans',
                        //                 color: Color(0xFF57419D),
                        //                 fontSize: 18.0,
                        //                 fontWeight:
                        //                 FontWeight.bold)),
                        //
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 200,
                      child: RaisedButton(
                        onPressed: () {
                          if(_donarTextEditingController.text.isNotEmpty){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    petModel: widget.petModel,
                                    defaultChoiceIndex:
                                    widget.defaultChoiceIndex, totalPrice: double.parse(_donarTextEditingController.text), tituloCategoria: tituloCategoria, aliadoModel: widget.aliadoModel,)),
                            );
                          }
                          else{
                            showDialog(
                                builder: (context) =>
                                new ChoosePetAlertDialog(
                                  message:
                                  "Por favor ingrese el monto a donar.",
                                ),
                                context: context);
                          }

                        },
                        // uploading ? null : ()=> uploadImageAndSavePetInfo(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Color(0xFF57419D),
                        padding: EdgeInsets.all(6.0),
                        child: Text("Aceptar y donar",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 15.0)),
                      ),
                    ),
                  ]),
                ))));
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
