import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:pet_shop/Authentication/resetpassword.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Store/pdf.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/DialogBox/errorDialog.dart';
import 'package:pet_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_shop/Widgets/loadingWidget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

class AutenticacionPage extends StatefulWidget {
  @override
  _AutenticacionPageState createState() => _AutenticacionPageState();
}

class _AutenticacionPageState extends State<AutenticacionPage> {
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _cPasswordTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl;
  PickedFile _imageFile;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String token;
  bool registro = false;
  bool _value = false;
  bool bienvenida;
  String errorMessage;
  static final int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;

  String _paises;
  var referidos = [];
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  final db = FirebaseFirestore.instance;
  UserCredential userCredential;

  bool uploading = false;

  Future<void> _selectAndPickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 10);
    setState(() {
      _imageFile = imageFile;
      registro = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getToken();
    _getData();
  }

  @override
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                registro == true
                    ? Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'diseñador/logo.png',
                              fit: BoxFit.contain,
                              height: 50,
                            ),
                            Column(
                              children: [
                                uploading ? linearProgress() : Text(""),
                                InkWell(
                                  onTap: _selectAndPickImage,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Color(0xFF86A3A3),
                                    child: _imageFile != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.file(
                                              File(_imageFile.path),
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            width: 55,
                                            height: 55,
                                            child: Icon(
                                              Icons.add_photo_alternate,
                                              color: Color(0xFF86A3A3),
                                            ),
                                          ),
                                  ),

                                  // CircleAvatar(
                                  //   backgroundColor: Color(0xFF7F9D9D),
                                  //   radius: _screenWidth * 0.09,
                                  //   child: CircleAvatar(
                                  //     radius: _screenWidth * 0.085,
                                  //     backgroundColor: Colors.white,
                                  //     backgroundImage: _imageFile == null
                                  //         ? null
                                  //         : FileImage(_imageFile),
                                  //     child: _imageFile == null
                                  //         ? Icon(Icons.add_photo_alternate,
                                  //             size: _screenWidth * 0.08,
                                  //             color: Color(0xFF7F9D9D))
                                  //         : null,
                                  //   ),
                                  // ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Dueño de mascotas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF86A3A3),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 90,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'diseñador/logo.png',
                                    fit: BoxFit.contain,
                                    height: 50,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                registro = true;
                              });
                            },
                            minWidth: _screenWidth * 0.41,
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.zero,
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.zero,
                              ),
                            ),
                            child: Text(
                              'Registro',
                              style: TextStyle(
                                  color: registro
                                      ? Colors.white
                                      : Color(0xFF57419D),
                                  fontSize: 20),
                            ),
                            color: registro
                                ? Color(0xFF57419D)
                                : Color(0xFFBDD7D6)),
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                registro = false;
                              });
                            },
                            minWidth: _screenWidth * 0.41,
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.zero,
                                topRight: Radius.circular(10.0),
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                  color: registro
                                      ? Color(0xFF57419D)
                                      : Colors.white,
                                  fontSize: 20),
                            ),
                            color: registro
                                ? Color(0xFFBDD7D6)
                                : Color(0xFF57419D)),
                      ],
                    ),
                  ),
                ),
                registro == true
                    ? Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Container(
                              //     child: Text(
                              //       'Nombre de usuario',
                              //       style: TextStyle(
                              //           fontSize: 16, color: Color(0xFF1A3E4D)),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Center(
                              //   child: Container(
                              //     width: _screenWidth * 0.82,
                              //     child: CustomTextField(
                              //       controller: _nameTextEditingController,
                              //       hintText: ("Escribe el nombre de usuario"),
                              //       isObsecure: false,
                              //     ),
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'País',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1A3E4D)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: _screenWidth * 0.82,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Ciudades")
                                                  .snapshots(),
                                              builder: (context, dataSnapshot) {
                                                if (!dataSnapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  List<DropdownMenuItem> list =
                                                      [];
                                                  for (int i = 0;
                                                      i <
                                                          dataSnapshot
                                                              .data.docs.length;
                                                      i++) {
                                                    DocumentSnapshot ciudad =
                                                        dataSnapshot
                                                            .data.docs[i];
                                                    list.add(
                                                      DropdownMenuItem(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  15, 0, 0, 0),
                                                          child: Text(
                                                            ciudad.id,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        value: "${ciudad.id}",
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF7f9d9D),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    margin: EdgeInsets.all(5.0),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: Stack(
                                                        children: <Widget>[
                                                          DropdownButton(
                                                              hint: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        15,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                    'País de residencia',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        color: Color(
                                                                            0xFF7f9d9D))),
                                                              ),
                                                              items: list,
                                                              isExpanded: true,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _paises =
                                                                      value;
                                                                });
                                                              },
                                                              value: _paises),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Text(
                                    'Correo electronico',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF1A3E4D)),
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
                                    controller: _emailTextEditingController,
                                    keyboard: TextInputType.emailAddress,
                                    hintText: "Coloca tu correo electrónico",
                                    isObsecure: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Text(
                                    'Contraseña',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF1A3E4D)),
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
                                    controller: _passwordTextEditingController,
                                    hintText: "Crea una contraseña",
                                    isObsecure: true,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Text(
                                    'Repite la contraseña',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF1A3E4D)),
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
                                    controller: _cPasswordTextEditingController,
                                    hintText: "Repite la contraseña creada",
                                    isObsecure: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                        value: _value,
                                        activeColor: Color(0xFF57419D),
                                        onChanged: (bool value) {
                                          setState(() {
                                            _value = value;
                                            if (value == true) {
                                            } else {}
                                          });
                                        }),
                                    Text('Acepto los términos y condiciones'),
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      alignment: Alignment.center,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.info_outline,
                                        ),
                                        iconSize: 30,
                                        color: Color(0xFF57419D),
                                        splashColor: Color(0xFF57419D),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MyApp()),
                                          );

                                          // showDialog(
                                          //     builder: (context) => new ChoosePetAlertDialog(
                                          //       message:
                                          //           "Se reserva el derecho de editar, actualizar, modificar, suspender, eliminar o finalizar los servicios ofrecidos por la Aplicación, incluyendo todo o parte de su contenido, sin necesidad de previo aviso, así como de modificar la forma o tipo de acceso a esta.",
                                          //     ), context: context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Text(
                                    'Usuario',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF1A3E4D)),
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
                                    controller: _emailTextEditingController,
                                    keyboard: TextInputType.emailAddress,
                                    hintText: "Coloca tu correo electrónico",
                                    isObsecure: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Text(
                                    'Contraseña',
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFF1A3E4D)),
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
                                    controller: _passwordTextEditingController,
                                    hintText: "Ingresa la contraseña",
                                    isObsecure: true,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                registro == true
                    ? Column(
                        children: [
                          Container(
                              width: _screenWidth * 0.84,
                              child: RaisedButton(
                                onPressed:
                                    _value ? () => uploadAndSaveImage() : null,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Color(0xFF57419D),
                                padding: EdgeInsets.all(15.0),
                                child: Text("Regístrate",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        color: Colors.white,
                                        fontSize: 20.0)),
                              )),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: _screenWidth * 0.84,
                          child: RaisedButton(
                            onPressed: () {
                              _emailTextEditingController.text.isNotEmpty &&
                                      EmailValidator.validate(
                                          (_emailTextEditingController.text)
                                              .replaceAll(' ', '')) &&
                                      _passwordTextEditingController
                                          .text.isNotEmpty
                                  ? loginUser()
                                  : ErrorMessage(context,
                                      'Por favor ingrese un correo válido y su contraseña...');

                              // showDialog(
                              //         context: context,
                              //         builder: (c) {
                              //           return ErrorAlertDialog(
                              //             message:
                              //                 "Por favor ingrese un correo válido y su contraseña...",
                              //           );
                              //         });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Color(0xFF57419D),
                            padding: EdgeInsets.all(15.0),
                            child: Text("Iniciar sesión",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0)),
                          ),
                        ),
                      ),

                registro == false
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ResetPassword()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 24, 0),
                                  child: Text("¿Olvidaste tu contraseña?",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),

                // registro == false
                //     ? Container(
                //     margin: const EdgeInsets.fromLTRB(14, 4.0, 14, 14),
                //     padding: const EdgeInsets.only(top: 10),
                //     // decoration: BoxDecoration(
                //     //   color: Colors.white,
                //     //   border: Border.all(color: Colors.grey[400]),
                //     //   borderRadius: BorderRadius.all(Radius.circular(25.0)),
                //     // ),
                //     child: Column(
                //       children: [
                //         Container(
                //           margin: EdgeInsets.only(left: 20, right: 20),
                //           child:
                //
                //           Text(
                //             " Inicia sesión con ",
                //             style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.grey[700]),
                //           ),
                //
                //
                //         ),
                //         SizedBox(height: 20),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: <Widget>[
                //             // Container(
                //             //   child: new RawMaterialButton(
                //             //     onPressed: () {
                //             //       setState(() {
                //             //         registro = true;
                //             //       });
                //             //     },
                //             //     child: new Icon(
                //             //       Icons.mail,
                //             //       color: Colors.white,
                //             //       size: 35.0,
                //             //     ),
                //             //     shape: new CircleBorder(),
                //             //     elevation: 2.0,
                //             //     fillColor: Colors.redAccent,
                //             //     padding: const EdgeInsets.all(15.0),
                //             //   ),
                //             //   margin: EdgeInsets.only(
                //             //       left: 10, right: 10, bottom: 14),
                //             // ),
                //             // Container(
                //             //   child: new RawMaterialButton(
                //             //     onPressed: () {
                //             //       // signUpWithFacebook();
                //             //     },
                //             //     child: Text(
                //             //       'f',
                //             //       style: TextStyle(
                //             //           color: Colors.white,
                //             //           fontSize: 40,
                //             //           fontWeight: FontWeight.bold),
                //             //     ),
                //             //     shape: new CircleBorder(),
                //             //     elevation: 2.0,
                //             //     fillColor: Colors.blue[900],
                //             //     padding: const EdgeInsets.all(8.0),
                //             //   ),
                //             //   margin: EdgeInsets.only(
                //             //       left: 10, right: 10, bottom: 14),
                //             // ),
                //             Container(
                //
                //               child: new RawMaterialButton(
                //                 onPressed: () {
                //                   // _googleSignUp();
                //                 },
                //                 child: Image.asset(
                //                   'assets/images/facebook2x.png',
                //                   fit: BoxFit.cover,
                //                   width: 45,
                //                   height: 45,
                //                 ),
                //                 // shape: new CircleBorder(),
                //                 // elevation: 2.0,
                //                 // fillColor: Colors.white,
                //                 // padding: const EdgeInsets.all(20.0),
                //               ),
                //               margin: EdgeInsets.only(
                //                   left: 10, right: 10, bottom: 14),
                //             ),
                //             Container(
                //               child: new RawMaterialButton(
                //                 onPressed: () {
                //                   // _googleSignUp();
                //                 },
                //                 child: Image.asset(
                //                   'assets/images/google2x.png',
                //                   fit: BoxFit.cover,
                //                   width: 55,
                //                   height: 55,
                //                 ),
                //                 // shape: new CircleBorder(),
                //                 // elevation: 2.0,
                //                 // fillColor: Colors.white,
                //                 // padding: const EdgeInsets.all(20.0),
                //               ),
                //               margin: EdgeInsets.only(
                //                   left: 10, right: 10, bottom: 14),
                //             ),
                //           ],
                //         )
                //       ],
                //     ))
                //     : Container(margin: const EdgeInsets.fromLTRB(14, 4.0, 14, 14),
                //     padding: const EdgeInsets.only(top: 10),
                //     // decoration: BoxDecoration(
                //     //   color: Colors.white,
                //     //   border: Border.all(color: Colors.grey[400]),
                //     //   borderRadius: BorderRadius.all(Radius.circular(25.0)),
                //     // ),
                //     child: Column(
                //       children: [
                //         Container(
                //           margin: EdgeInsets.only(left: 20, right: 20),
                //           child:
                //
                //           Text(
                //             " Registrate con ",
                //             style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.grey[700]),
                //           ),
                //
                //
                //         ),
                //         SizedBox(height: 20),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: <Widget>[
                //             // Container(
                //             //   child: new RawMaterialButton(
                //             //     onPressed: () {
                //             //       setState(() {
                //             //         registro = true;
                //             //       });
                //             //     },
                //             //     child: new Icon(
                //             //       Icons.mail,
                //             //       color: Colors.white,
                //             //       size: 35.0,
                //             //     ),
                //             //     shape: new CircleBorder(),
                //             //     elevation: 2.0,
                //             //     fillColor: Colors.redAccent,
                //             //     padding: const EdgeInsets.all(15.0),
                //             //   ),
                //             //   margin: EdgeInsets.only(
                //             //       left: 10, right: 10, bottom: 14),
                //             // ),
                //             // Container(
                //             //   child: new RawMaterialButton(
                //             //     onPressed: () {
                //             //       // signUpWithFacebook();
                //             //     },
                //             //     child: Text(
                //             //       'f',
                //             //       style: TextStyle(
                //             //           color: Colors.white,
                //             //           fontSize: 40,
                //             //           fontWeight: FontWeight.bold),
                //             //     ),
                //             //     shape: new CircleBorder(),
                //             //     elevation: 2.0,
                //             //     fillColor: Colors.blue[900],
                //             //     padding: const EdgeInsets.all(8.0),
                //             //   ),
                //             //   margin: EdgeInsets.only(
                //             //       left: 10, right: 10, bottom: 14),
                //             // ),
                //             Container(
                //
                //               child: new RawMaterialButton(
                //                 onPressed: () {
                //                   // _googleSignUp();
                //                 },
                //                 child: Image.asset(
                //                   'assets/images/facebook2x.png',
                //                   fit: BoxFit.cover,
                //                   width: 45,
                //                   height: 45,
                //                 ),
                //                 // shape: new CircleBorder(),
                //                 // elevation: 2.0,
                //                 // fillColor: Colors.white,
                //                 // padding: const EdgeInsets.all(20.0),
                //               ),
                //               margin: EdgeInsets.only(
                //                   left: 10, right: 10, bottom: 14),
                //             ),
                //             Container(
                //               child: new RawMaterialButton(
                //                 onPressed: () {
                //                   // _googleSignUp();
                //                 },
                //                 child: Image.asset(
                //                   'assets/images/google2x.png',
                //                   fit: BoxFit.cover,
                //                   width: 55,
                //                   height: 55,
                //                 ),
                //                 // shape: new CircleBorder(),
                //                 // elevation: 2.0,
                //                 // fillColor: Colors.white,
                //                 // padding: const EdgeInsets.all(20.0),
                //               ),
                //               margin: EdgeInsets.only(
                //                   left: 10, right: 10, bottom: 14),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                // ),

                // Container(
                //   height: 130,
                //
                //   decoration: new BoxDecoration(
                //     image: new DecorationImage(
                //       image: new AssetImage("diseñador/drawable/Patitas.png"),
                //       alignment: Alignment(1.3, 0),
                //     ),
                //   ),
                //
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _googleSignUp() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User user = (await _auth.signInWithCredential(credential)).user;
      // _checkExistUserFromFirebaseDB(user);
      return user;
    } catch (e) {
      displayDialog(e.message);
    }
  }

  Future<void> uploadAndSaveImage() async {
    if (_imageFile == null) {
      ErrorMessage(context, 'Por favor seleccione una imagen...');
    } else {
      _passwordTextEditingController.text ==
              _cPasswordTextEditingController.text
          ? _emailTextEditingController.text.isNotEmpty &&
                  EmailValidator.validate(
                      (_emailTextEditingController.text).replaceAll(' ', '')) &&
                  _passwordTextEditingController.text.isNotEmpty &&
                  _cPasswordTextEditingController.text.isNotEmpty &&
                  _paises.isNotEmpty
              ? uploadToStorage()
              : ErrorMessage(context,
                  'Por favor complete todos los campos correctamente...')
          : ErrorMessage(context, 'Las contraseñas no coinciden...');

      // : displayDialog(
      //         "Por favor complete todos los campos correctamente...")
      // : displayDialog("Las contraseñas no coinciden...");
    }
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message: msg,
          );
        });
  }

  uploadToStorage() async {
    _loadingDialog(context, 'Registrando sus datos, espere por favor...');
    // showDialog(
    //     context: context,
    //     builder: (c) {
    //       return LoadingAlertDialog(
    //         message: "Registrando sus datos, por favor espere...",
    //       );
    //     });
    _registerUser();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  void _registerUser() async {
    User user;
    print('loque seaaaa');
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailTextEditingController.text.trim().replaceAll(new RegExp(r"/^\s+|\s+$|\s+(?=\s)/g"), ""),
          password: _passwordTextEditingController.text.trim());

      String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child("Dueños");
      UploadTask uploadTask = reference
          .child("dueño_$imageFileName.jpg")
          .putFile(File(_imageFile.path));

      await (await uploadTask).ref.getDownloadURL().then((urlImage) {
        setState(() {
          userImageUrl = urlImage.toString();
        });
      });
      saveUserInfoToFireStore(userCredential.user).then((value) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoreHome(),
          ),
        );
      });
    } catch (e) {
      // Navigator.pop(context);
      switch (e.message) {
        case "The email address is badly formatted.":
          {
            setState(() {
              errorMessage = "Debes ingresar un email correcto";
            });
          }
          break;
        case "There is no user record corresponding to this identifier. The user may have been deleted.":
          {
            setState(() {
              errorMessage = "El usuario no existe";
            });
          }
          break;
        case "The password is invalid or the user does not have a password.":
          {
            setState(() {
              errorMessage =
                  "Contraseña incorrecta. Intenta ingresar la correcta";
            });
          }
          break;
        case "The email address is already in use by another account.":
          {
            setState(() {
              errorMessage =
                  "El correo ya esta en uso por otra cuenta, intenta con otro";
            });
          }
          break;
        default:
          {
            setState(() {
              errorMessage = "Ha ocurrido un error. Intenta de nuevo";
            });
          }
          break;
      }
      ErrorMessage(context, errorMessage);
      // showDialog(
      //     context: context,
      //     builder: (c) {
      //       return ErrorAlertDialog(
      //         message: errorMessage.toString(),
      //       );
      //     });

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AutenticacionPage(),
        ),
      );
    }

    if (user != null) {
      print('loque seaaaa');
    }
  }

  Future givePetPoints(email) async {
    try {
      await db
          .collection('Referidos')
          .doc(email)
          .get()
          .then((DocumentSnapshot documentSnapshot) => {
                db
                    .collection('Dueños')
                    .doc(documentSnapshot['uid'])
                    .collection("Petpoints")
                    .doc(documentSnapshot['uid'])
                    .update({
                  "ppAcumulados": FieldValue.increment(100),
                })
              });
    } catch (e) {
      print(e);
    }
    return;
  }

  saveUserInfoToFireStore(User fUser) async {
    FirebaseFirestore.instance.collection("Dueños").doc(fUser.uid).set({
      "uid": fUser.uid,
      "email": fUser.email,
      "user": _nameTextEditingController.text.trim(),
      "url": userImageUrl,
      "bienvenida": true,
      "token": token,
      "registroCompleto": false,
      "pais": _paises,
      "createdOn": productId,

    });

    FirebaseFirestore.instance.collection("welcomeUser").doc(fUser.uid).set({
      "createdOn": productId,
      "uid": fUser.uid,
      "to": [fUser.email],
      "message": {
        "subject": '¡Bienvenido a PRIORITY PET!',
        "text": 'Hola, ${fUser.email}.',
        "html": '<html lang="es"><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href=""><style>html,body {font-family:"Verdana",sans-serif}h1,h2,h3,h4,h5,h6 {font-family:"Segoe UI",sans-serif}</style><body><p>Hola, ${fUser.email}, bienvenido a Priority Pet, la comunidad más grande de beneficios para mascotas, nos complace que estes aquí.<br>A partir de este momento obtendrás los mejores productos y servicios para el control y el cuidado de tu mascota desde un solo lugar.</p><br><p>¿Necesitas ayuda? Contacta con nosotros a soporte@prioritypet.club</p><br><p>Atentamente, <br>Equipo de Priority Pet</p><img src="https://firebasestorage.googleapis.com/v0/b/priority-pet.appspot.com/o/Emaling-bienvenida-2.png?alt=media&token=a6f7c766-2387-4e2c-9f32-e7944cda9dca" alt="Priority Banner" width="100%" ></body></html>',
      },
    });

    FirebaseFirestore.instance
        .collection("Dueños")
        .doc(fUser.uid)
        .collection("Petpoints")
        .doc(fUser.uid)
        .set({
      "uid": fUser.uid,
      "ppAcumulados": int.parse('0'),
      "ppCanjeados": int.parse('0'),
      "ppGenerados": int.parse('0'),
    });
    setState(() {
      String _email = fUser.email;
      String nombreCompleto = _nameTextEditingController.text.trim();
      bienvenida = true;
    });

    await PetshopApp.sharedPreferences.setString("uid", fUser.uid);
    await PetshopApp.sharedPreferences
        .setString(PetshopApp.userEmail, fUser.email);
    await PetshopApp.sharedPreferences
        .setString(PetshopApp.userName, _nameTextEditingController.text);
    await PetshopApp.sharedPreferences
        .setString(PetshopApp.userAvatarUrl, userImageUrl);
    await PetshopApp.sharedPreferences.setString(PetshopApp.userToken, token);
    await PetshopApp.sharedPreferences.setString(PetshopApp.userPais, _paises);
    await PetshopApp.sharedPreferences
        .setStringList(PetshopApp.userCartList, ["garbageValue"]);
    await PetshopApp.sharedPreferences.setString(PetshopApp.userNombre, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userApellido, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userDocId, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userGenero, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userDireccion, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userFechaNac, "");
    await PetshopApp.sharedPreferences.setString(PetshopApp.userTelefono, "");

    await FirebaseFirestore.instance
        .collection("Ciudades")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .get()
        .then((dataSnapshot) {
      PetshopApp.sharedPreferences
          .setString(PetshopApp.Moneda, dataSnapshot.data()[PetshopApp.Moneda]);
      PetshopApp.sharedPreferences.setString(PetshopApp.simboloMoneda,
          dataSnapshot.data()[PetshopApp.simboloMoneda]);
    });
    // sendEmail(fUser.email, _nameTextEditingController.text.trim());
    if (referidos.contains(fUser.email)) {
      givePetPoints(fUser.email);
    }
  }

  // sendEmail(_email, nombreCompleto) async {
  //   await http.get(Uri.parse(
  //       'https://us-central1-priority-pet.cloudfunctions.net/sendWelcomeEmailDuenos?dest=$_email&username=$nombreCompleto'));
  // }

  void loginUser() async {
    // showDialog(
    //   context: context,
    //   builder: (c) {
    //     return LoadingAlertDialog(
    //       message: "Autenticando, espere por favor...",
    //     );
    //   },
    // );
    _loadingDialog(context, 'Autenticando, espere por favor...');

    User user;
    await _auth
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text
          .trim()
          .replaceAll(new RegExp(r"/^\s+|\s+$|\s+(?=\s)/g"), ""),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((authUser) {
      user = authUser.user;
    }).catchError((error) {
      // Navigator.pop(context);
      switch (error.message) {
        case "The email address is badly formatted.":
          {
            setState(() {
              errorMessage = "Debes ingresar un email correcto";
            });
          }
          break;
        case "There is no user record corresponding to this identifier. The user may have been deleted.":
          {
            setState(() {
              errorMessage = "El usuario no existe";
            });
          }
          break;
        case "The password is invalid or the user does not have a password.":
          {
            setState(() {
              errorMessage =
                  "Contraseña incorrecta. Intenta ingresar la correcta";
            });
          }
          break;
        case "The email address is already in use by another account.":
          {
            setState(() {
              errorMessage =
                  "El correo ya esta en uso por otra cuenta, intenta con otro";
            });
          }
          break;
        default:
          {
            setState(() {
              errorMessage = "Ha ocurrido un error. Intenta de nuevo";
            });
          }
          break;
      }

      // showDialog(
      //     context: context,
      //     builder: (c) {
      //       return ErrorAlertDialog(
      //         message: errorMessage.toString(),
      //       );
      //     });
      ErrorMessage(context, errorMessage);
    });

    if (user != null) {
      readData(user).then((s) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoreHome(),
          ),
        );
      });
    }
  }

  Future readData(User fUser) async {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    // String formatted = formatter.format(dataSnapshot.data()[PetshopApp.userFechaNac]);

    await FirebaseFirestore.instance
        .collection("Dueños")
        .doc(fUser.uid)
        .get()
        .then((dataSnapshot) {
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userEmail, dataSnapshot.data()[PetshopApp.userEmail]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userDocId, dataSnapshot.data()[PetshopApp.userDocId]);
      PetshopApp.sharedPreferences.setString(PetshopApp.userApellido,
          dataSnapshot.data()[PetshopApp.userApellido]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userNombre, dataSnapshot.data()[PetshopApp.userNombre]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userName, dataSnapshot.data()[PetshopApp.userName]);
      PetshopApp.sharedPreferences
          .setString("uid", dataSnapshot.data()[PetshopApp.userUID]);
      PetshopApp.sharedPreferences.setString(PetshopApp.userAvatarUrl,
          dataSnapshot.data()[PetshopApp.userAvatarUrl]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.codigoTexto, dataSnapshot.data()[PetshopApp.codigoTexto]);
      PetshopApp.sharedPreferences.setString(PetshopApp.tipoDocumento,
          dataSnapshot.data()[PetshopApp.tipoDocumento]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.geoAddress, dataSnapshot.data()[PetshopApp.geoAddress]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.geolocation, dataSnapshot.data()[PetshopApp.geolocation]);

      PetshopApp.sharedPreferences.setString(PetshopApp.userTelefono,
          dataSnapshot.data()[PetshopApp.userTelefono]);
      PetshopApp.sharedPreferences.setString(PetshopApp.userDireccion,
          dataSnapshot.data()[PetshopApp.userDireccion]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userPais, dataSnapshot.data()[PetshopApp.userPais]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userGenero, dataSnapshot.data()[PetshopApp.userGenero]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userToken, dataSnapshot.data()[PetshopApp.userToken]);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userCulqi, dataSnapshot.data()[PetshopApp.userCulqi]);

      if (dataSnapshot.data()[(PetshopApp.userFechaNac)] != null) {
        Timestamp time; //from firebase

        PetshopApp.sharedPreferences.setString(
            PetshopApp.userFechaNac,
            DateTime.fromMicrosecondsSinceEpoch(dataSnapshot
                    .data()[(PetshopApp.userFechaNac)]
                    .microsecondsSinceEpoch)
                .toString());

        // PetshopApp.sharedPreferences.setString(PetshopApp.userFechaNac, formatter.format((dataSnapshot.data()[(PetshopApp.userFechaNac)]).toDate()));

      }

      // List<String> cartList = dataSnapshot.data()[PetshopApp.userCartList].cast<String>();
      // await PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, cartList);
    });

    await FirebaseFirestore.instance
        .collection("Ciudades")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .get()
        .then((dataSnapshot) {
      PetshopApp.sharedPreferences
          .setString(PetshopApp.Moneda, dataSnapshot.data()[PetshopApp.Moneda]);
      PetshopApp.sharedPreferences.setString(PetshopApp.simboloMoneda,
          dataSnapshot.data()[PetshopApp.simboloMoneda]);
    });
  }

  Future<dynamic> _getToken() async {
    setState(() async {
      token = await _firebaseMessaging.getToken();
    });
  }

  Future<List<dynamic>> _getData() async {
    referidos = [];
    try {
      await db
          .collection('Referidos')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((referido) {
                  setState(() {
                    referidos.add(referido.id.toString());
                  });
                })
              });
    } catch (e) {
      print(e);
    }
    return [referidos];
  }

  Future<void> ErrorMessage(BuildContext context, String error) async {
    Navigator.of(context, rootNavigator: true).pop();
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

  Future<void> _loadingDialog(BuildContext context, String msg) async {
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
}
