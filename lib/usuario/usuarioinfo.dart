import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/culqiUser.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Widgets/AppBarCustom.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/location.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

double width;

class UsuarioInfo extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;


  UsuarioInfo({this.petModel, this.defaultChoiceIndex});
  @override
  _UsuarioInfoState createState() => _UsuarioInfoState();
}

class _UsuarioInfoState extends State<UsuarioInfo>
    with AutomaticKeepAliveClientMixin<UsuarioInfo> {
  final TextEditingController _nameTextEditingController =
  TextEditingController();
  final TextEditingController _lastnameTextEditingController =
  TextEditingController();
  final TextEditingController _idTextEditingController =
  TextEditingController();
  final TextEditingController _addressTextEditingController =
  TextEditingController();
  final TextEditingController _tlfTextEditingController =
  TextEditingController();
  final TextEditingController _dateTextEditingController =
  TextEditingController();
  final TextEditingController _date2TextEditingController =
  TextEditingController();
  final TextEditingController _tipoDocuTextEditingController =
  TextEditingController();
  final GlobalKey<FormState> _petformKey = GlobalKey<FormState>();
  LocationResult _pickedLocation;
  DateTime selectedDate = DateTime.now();
  List<dynamic> ciudades = [];
  String _categoria;
  String ciudad;

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  String telefono;
  String petImageUrl = "";
  bool bienvenida = false;
  String get apiKey => "AIzaSyDmb3pc-t9K9aC_mKnZBfIPQ7Il4OClCN0";
  String codigoTexto;
  GeoPoint location;

  bool get wantKeepAlive => true;
  PickedFile _imageFile;
  String _paises;
  String _pais;
  String _sexo;
  String _prk;
  String culqiId;
  String imageDownloadUrl =
  PetshopApp.sharedPreferences.getString(PetshopApp.userAvatarUrl);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCountrySymbol(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    // setState(() {
    //   codigoTexto =
    //       PetshopApp.sharedPreferences.getString(PetshopApp.codigoTexto);
    // });
    _getprK();
    _getGeo();
    getCiudades(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));

    if (PetshopApp.sharedPreferences.getString(PetshopApp.userNombre) != null) {
      _nameTextEditingController.value = TextEditingValue(
          text: PetshopApp.sharedPreferences.getString(PetshopApp.userNombre));
    }
    if (PetshopApp.sharedPreferences.getString(PetshopApp.tipoDocumento) !=
        null) {
      ciudad = PetshopApp.sharedPreferences.getString(PetshopApp.tipoDocumento);
      _categoria =
          PetshopApp.sharedPreferences.getString(PetshopApp.tipoDocumento);
      // _tipoDocuTextEditingController.value = TextEditingValue(text: PetshopApp.sharedPreferences.getString(PetshopApp.tipoDocumento));
    }
    if (PetshopApp.sharedPreferences.getString(PetshopApp.userApellido) !=
        null) {
      _lastnameTextEditingController.value = TextEditingValue(
          text:
          PetshopApp.sharedPreferences.getString(PetshopApp.userApellido));
    }
    if (PetshopApp.sharedPreferences.getString(PetshopApp.userDocId) != null) {
      _idTextEditingController.value = TextEditingValue(
          text: PetshopApp.sharedPreferences.getString(PetshopApp.userDocId));
    }
    print('valor');
    print(PetshopApp.sharedPreferences.getString(PetshopApp.userPais));

    if (PetshopApp.sharedPreferences.getString(PetshopApp.userPais) != "") {
      _paises = PetshopApp.sharedPreferences.getString(PetshopApp.userPais);
    }
    if (PetshopApp.sharedPreferences.getString(PetshopApp.userGenero) != "") {
      _sexo = PetshopApp.sharedPreferences.getString(PetshopApp.userGenero);
    }
    if (PetshopApp.sharedPreferences.getString(PetshopApp.userDireccion) !=
        null) {
      _addressTextEditingController.value = TextEditingValue(
          text:
          PetshopApp.sharedPreferences.getString(PetshopApp.userDireccion));
    }

    if (PetshopApp.sharedPreferences.getString(PetshopApp.userTelefono) !=
        null) {
      _tlfTextEditingController.value = TextEditingValue(
          text:
          PetshopApp.sharedPreferences.getString(PetshopApp.userTelefono));
    }

    if (PetshopApp.sharedPreferences.getString(PetshopApp.userFechaNac) != '') {
      var formatter = DateFormat.yMd('es_VE');

      if (PetshopApp.sharedPreferences.getString(PetshopApp.userFechaNac) !=
          null) {
        String formatted = formatter.format(DateTime.parse(
            PetshopApp.sharedPreferences.getString(PetshopApp.userFechaNac)));
        print(formatted);
        _dateTextEditingController.value = TextEditingValue(text: formatted);

        _date2TextEditingController.value = TextEditingValue(
            text: PetshopApp.sharedPreferences
                .getString(PetshopApp.userFechaNac));
      }
    }

    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        bienvenida = (dataSnapshot.data()["bienvenida"]);
        culqiId = (dataSnapshot.data()["id_culqi"]);
        // codigoTexto = dataSnapshot.data()["codigoTexto"];
      });
    });
  }

  Future<dynamic> getCountrySymbol(p) async {
    try {
      await FirebaseFirestore.instance
          .collection('Ciudades')
          .doc(p)
          .get()
          .then((DocumentSnapshot documentSnapshot) => {
        setState(() {
          codigoTexto = documentSnapshot.data()["codigoTexto"];
          print(codigoTexto);
        })
      });
    } catch (e) {
      print(e);
    }
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
  _getGeo() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Dueños").doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        location = (dataSnapshot.data()["location"]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return new Scaffold(

      appBar: AppBarCustom(context, widget.petModel, widget.defaultChoiceIndex),
      drawer: MyDrawer(),
      bottomNavigationBar: CustomBottomNavigationBar(petmodel: widget.petModel),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
              Form(
                key: _petformKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Color(0xFF57419D)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                Text(
                                  "Información personal",
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        uploading ? linearProgress() : Text(""),
                        InkWell(
                            onTap: _selectAndPickImage,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF86A3A3),
                              radius: 38,
                              child: _imageFile != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  File(_imageFile.path),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : CircleAvatar(
                                  radius: _screenWidth * 0.1,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(PetshopApp
                                      .sharedPreferences
                                      .getString(
                                      PetshopApp.userAvatarUrl))),
                            )),

                        // CircleAvatar(
                        //   backgroundColor: Color(0xFF7F9D9D),
                        //   radius: _screenWidth * 0.09,
                        //   child: CircleAvatar(
                        //     radius: _screenWidth * 0.085,
                        //     backgroundColor: Colors.white,
                        //     backgroundImage:
                        //         file == null ? null : FileImage(file),
                        //     child: file == null
                        //         ? CircleAvatar(
                        //             radius: _screenWidth * 0.085,
                        //             backgroundColor: Colors.white,
                        //             backgroundImage: NetworkImage(PetshopApp
                        //                 .sharedPreferences
                        //                 .getString(PetshopApp.userAvatarUrl)))
                        //         : null,
                        //   ),
                        // ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Nombre',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      controller: _nameTextEditingController,
                      hintText: ("Escribe tu nombre"),
                      isObsecure: false,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Apellido',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      controller: _lastnameTextEditingController,
                      hintText: ("Escribe tu apellido"),
                      isObsecure: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Fecha de nacimiento',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () => _planModalBottomSheet(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _dateTextEditingController,
                          keyboard: TextInputType.datetime,
                          hintText: "¿Cuando nació?",
                          isObsecure: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Género',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
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
                            width: _screenWidth * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("SexoPersona")
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
                                          DocumentSnapshot razas =
                                          dataSnapshot.data.docs[i];
                                          list.add(
                                            DropdownMenuItem(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.fromLTRB(
                                                    15, 0, 0, 0),
                                                child: Text(
                                                  razas.id,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              value: "${razas.id}",
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
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Text(
                                                          'Indica tu género',
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color: Color(
                                                                  0xFF7f9d9D))),
                                                    ),
                                                    items: list,
                                                    isExpanded: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _sexo = value;
                                                      });
                                                    },
                                                    value: _sexo),
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

                    // CustomTextField(
                    //   controller: _sexTextEditingController,
                    //
                    //   hintText: "Indica tu género",
                    //   isObsecure: false,
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Documento de identidad',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          width: _screenWidth * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Color(0xFF7f9d9D),
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                                ),
                                padding: EdgeInsets.all(0.0),
                                margin: EdgeInsets.all(5.0),
                                child: DropdownButtonHideUnderline(
                                  child: Stack(
                                    children: <Widget>[
                                      DropdownButton(
                                          hint: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 0, 0),
                                            child: Text(
                                              'Tipo de documento',
                                              style: TextStyle(
                                                color: Colors.black,
                                                // fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          items: ciudades.map((dynamic value) {
                                            return DropdownMenuItem<dynamic>(
                                              value: value,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.fromLTRB(
                                                    8, 0, 0, 0),
                                                child: Text(value),
                                              ),
                                            );
                                          }).toList(),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              _categoria = value;
                                              ciudad = value;
                                              // _tipoDocuTextEditingController.value = value;
                                            });
                                          },
                                          value: ciudad),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: _screenWidth * 0.5,
                          child: CustomTextField(
                            controller: _idTextEditingController,
                            keyboard: TextInputType.number,
                            hintText: 'Indica tu número de identidad',
                            isObsecure: false,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'País',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
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
                            width: _screenWidth * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("Ciudades")
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
                                          DocumentSnapshot ciudad =
                                          dataSnapshot.data.docs[i];
                                          list.add(
                                            DropdownMenuItem(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.fromLTRB(
                                                    15, 0, 0, 0),
                                                child: Text(
                                                  ciudad.id,
                                                  style: TextStyle(
                                                    color: Colors.black,
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
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Text(
                                                          'País de residencia',
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color: Color(
                                                                  0xFF7f9d9D))),
                                                    ),
                                                    items: list,
                                                    isExpanded: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _paises = value;
                                                        // _tipoDocuTextEditingController.value = value;
                                                        // getCountrySymbol(value);
                                                        ciudad = null;
                                                        getCiudades(_paises);
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

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Geolocalización',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 360,
                        child: RaisedButton(
                          onPressed: () async {
                            LocationResult result = await showLocationPicker(context, apiKey,
                              // initialCenter: LatLng(32.4219971, -123.0839996),
                              automaticallyAnimateToCurrentLocation: true,
                              // mapStylePath: 'assets/mapStyle.json',
                              myLocationButtonEnabled: true,
                              requiredGPS: true,
                              layersButtonEnabled: true,
                              language: 'es',
                              // countries: ['AE', 'NG']

//                      resultCardAlignment: Alignment.bottomCenter,
                              desiredAccuracy: LocationAccuracy.best,
                            );
                            print("result = $result");
                            setState(() => _pickedLocation = result);
                            // showDialog(
                            //     context: context,
                            //     child: new ChoosePetAlertDialog(
                            //       message:
                            //       "Esta función estará disponible próximamente...",
                            //     ));
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => Location(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
                            // );
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Color(0xFF57419D),
                          padding: EdgeInsets.all(15.0),
                          child: Icon(Icons.map, color: Colors.white,),
                          // Text("Locación",
                          //     style: TextStyle(
                          //         fontFamily: 'Product Sans',
                          //         color: Colors.white,
                          //         fontSize: 18.0)),
                        ),
                      ),
                    ),
                    _pickedLocation != null ?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: primaryColor,),
                          Expanded(
                            child: Text(
                              _pickedLocation.address,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ): PetshopApp.sharedPreferences.getString(PetshopApp.geoAddress) != null ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: primaryColor,),
                          Expanded(
                            child: Text(
                              PetshopApp.sharedPreferences.getString(PetshopApp.geoAddress),
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ) : Container(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Dirección',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      controller: _addressTextEditingController,
                      hintText: "Coloca tu dirección de habitación",
                      isObsecure: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Teléfono móvil',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF7F9D9D)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          12,
                          0,
                        ),
                        child: IntlPhoneField(
                            searchText: "Buscar por país",
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Este campo es requerido';
                              }
                            },
                            controller: _tlfTextEditingController,
                            onChanged: (val) {
                              print(val.countryISOCode + val.completeNumber);
                              setState(() {
                                codigoTexto = val.countryISOCode;
                              });
                              print('el pais es $codigoTexto');
                            },
                            onSaved: (val) {
                              setState(() {
                                codigoTexto = val.countryISOCode;
                                telefono = val.completeNumber.toString();
                                _tlfTextEditingController.value =
                                    TextEditingValue(text: telefono);
                              });
                            },
                            decoration: InputDecoration(
                              focusColor: Color(0xFF7f9d9D),
                              fillColor: Colors.white,
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                borderSide:
                                BorderSide(color: Color(0xFF7f9d9D)),
                              ),
                              focusedBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                borderSide:
                                BorderSide(color: Color(0xFF7f9d9D)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(
                                  fontSize: 15.0, color: Color(0xFF7f9d9D)),
                              hintText: 'Número de teléfono',
                            ),
                            // initialCountryCode: 'PE',
                            initialCountryCode: PetshopApp.sharedPreferences
                                .getString(PetshopApp.codigoTexto)),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: 360,
                child: RaisedButton(
                  onPressed: () {
                    if (_dateTextEditingController.text == '') {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message:
                            "Por favor indique su fecha de nacimiento.",
                          ));
                    }
                    if (_nameTextEditingController.text == '') {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message: "Por favor indique su nombre.",
                          ));
                    }
                    if (_lastnameTextEditingController.text == '') {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message: "Por favor indique su apellido.",
                          ));
                    }
                    if (_idTextEditingController.text == '') {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message: "Por favor indique su identificación.",
                          ));
                    }

                    if (_addressTextEditingController.text == '') {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message: "Por favor indique su dirección.",
                          ));
                    }
                    if (ciudad == null) {
                      showDialog(
                          context: context,
                          child: new ChoosePetAlertDialog(
                            message: "Por favor indique su tipo de documento.",
                          ));
                    } else {
                      if (_nameTextEditingController.text.isNotEmpty &&
                          _lastnameTextEditingController.text.isNotEmpty &&
                          _dateTextEditingController.text.isNotEmpty &&
                          _idTextEditingController.text.isNotEmpty &&
                          _addressTextEditingController.text.isNotEmpty) {
                        uploadImageAndSavePetInfo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StoreHome(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
                        );
                      }
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Color(0xFF57419D),
                  padding: EdgeInsets.all(15.0),
                  child: Text("Completar el perfil",
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.white,
                          fontSize: 18.0)),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 10);

    setState(() {
      _imageFile = imageFile;
      print(imageFile);
    });
  }

  uploadImageAndSavePetInfo() async {
    setState(() {
      uploading = true;
    });

    if (_imageFile != null) {
      imageDownloadUrl = await uploadPetImage(File(_imageFile.path));
    }

    savePetInfo(imageDownloadUrl);
  }

  Future<String> uploadPetImage(mFileImage) async {
    if (mFileImage == null) {
      String downloadUrl =
      PetshopApp.sharedPreferences.getString(PetshopApp.userAvatarUrl);
      return downloadUrl;
    } else {
      final Reference reference =
      FirebaseStorage.instance.ref().child("Dueños");
      UploadTask uploadTask =
      reference.child("dueño_$productId.jpg").putFile(mFileImage);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    }
  }

  savePetInfo(String downloadUrl) async {
    {
      // try {
      //   var json =
      //       '{"filial": "01","documento": "${_idTextEditingController.text.trim()}","nombre": "${_nameTextEditingController.text.trim() + _lastnameTextEditingController.text.trim()}","direccion": "${_addressTextEditingController.text.trim()}","complemento": "","ubigeo": "101010","dpto": "${_addressTextEditingController.text.trim()}","provincia": "${_addressTextEditingController.text.trim()}","distrito": "${_addressTextEditingController.text.trim()}","telefono": "${_tlfTextEditingController.text.trim()}","email": "${PetshopApp.sharedPreferences.getString(PetshopApp.userEmail)}"}';
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
        if(_paises=='Perú' && culqiId == null) {
          try {
            var json =
                '{"first_name": "${_nameTextEditingController
                .text}","last_name": "${_lastnameTextEditingController
                .text}","address": "${_addressTextEditingController
                .text}","phone_number": "${_tlfTextEditingController
                .text}","email": "${PetshopApp.sharedPreferences.getString(
                PetshopApp.userEmail)}", "address_city": "Lima", "country_code": "PE", "metadata": {"$ciudad": "${_idTextEditingController.text}"}}';
            var url = ("https://api.culqi.com/v2/customers");
            Map<String, String> headers = {
              "Content-type": "application/json",
              "Authorization": _prk,
            };
            Response res = await http.post(url, headers: headers, body: json);
            int statusCode = await res.statusCode;
            final nuevo = jsonDecode(res.body);

            CulqiUserModel culqi = CulqiUserModel.fromJson(nuevo);

            setState(() {
              // response = statusCode.toString();
              culqiId = culqi.id;
              print(culqi.id);
               print(statusCode);
               print('el cuerpo es ${res.body}');
            });
          } catch (e) {
            print(e.message);
            return null;
          }
        }
      // try {
      //   var url =
      //       ("https://api.culqi.com/v2/customers/cus_test_Dlk8IUQw4PXGYbVQ");
      //   Map<String, String> headers = {
      //     "Content-type": "application/json",
      //     'Authorization': 'Bearer sk_test_7c6b926b8a7d65eb'
      //   };
      //   Response res = await http.get(url, headers: headers);
      //   var statusCode = await res.body;
      //   final nuevo = jsonDecode(res.body);
      //
      //   CulqiUserModel culqi = CulqiUserModel.fromJson(nuevo);
      //
      //   setState(() {
      //     // response = statusCode.toString();
      //     culqiId = culqi.id;
      //     print(statusCode);
      //     print(culqi.id);
      //   });
      // } catch (e) {
      //   print(e.message);
      //   return null;
      // }

      print(telefono);
      final databaseReference = FirebaseFirestore.instance;
      databaseReference
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .set({
        "nombre": _nameTextEditingController.text.trim(),
        "apellido": _lastnameTextEditingController.text.trim(),
        "docid": _idTextEditingController.text.trim(),
        "pais": _paises,
        "genero": _sexo,
        "direccion": _addressTextEditingController.text.trim(),
        "fechaNacimiento": DateTime.parse(_date2TextEditingController.text),
        "telefono": _tlfTextEditingController.text.trim(),
        "email": PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
        "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
        "url": downloadUrl,
        "token": PetshopApp.sharedPreferences.getString(PetshopApp.userToken),
        "bienvenida": bienvenida,
        "id_culqi": culqiId,
        "registroCompleto": true,
        "tipoDocumento": ciudad,
        "codigoTexto": codigoTexto == null
            ? PetshopApp.sharedPreferences.getString(PetshopApp.codigoTexto)
            : codigoTexto,
        "geolocation": _pickedLocation != null ? _pickedLocation.latLng.toString() : PetshopApp.sharedPreferences.getString(PetshopApp.geolocation),
        "geoAddress": _pickedLocation != null ? _pickedLocation.address : PetshopApp.sharedPreferences.getString(PetshopApp.geoAddress),
        "location": _pickedLocation != null ? new GeoPoint(_pickedLocation.latLng.latitude, _pickedLocation.latLng.longitude) : location,
      });

      PetshopApp.sharedPreferences.setString(
          "uid", PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
      PetshopApp.sharedPreferences.setString(PetshopApp.userEmail,
          PetshopApp.sharedPreferences.getString(PetshopApp.userEmail));
      PetshopApp.sharedPreferences.setString(PetshopApp.userName,
          PetshopApp.sharedPreferences.getString(PetshopApp.userName));
      PetshopApp.sharedPreferences
          .setString(PetshopApp.userAvatarUrl, downloadUrl);
      PetshopApp.sharedPreferences.setString(PetshopApp.userToken,
          PetshopApp.sharedPreferences.getString(PetshopApp.userToken));
      PetshopApp.sharedPreferences.setString(PetshopApp.userCulqi, culqiId);
      PetshopApp.sharedPreferences
          .setString(PetshopApp.tipoDocumento, ciudad);

      if (codigoTexto != null) {
        PetshopApp.sharedPreferences
            .setString(PetshopApp.codigoTexto, codigoTexto);
      }
        if (_pickedLocation != null) {
          PetshopApp.sharedPreferences.setString(PetshopApp.geolocation, _pickedLocation.latLng.toString());
          PetshopApp.sharedPreferences.setString(PetshopApp.geoAddress, _pickedLocation.address.toString());
        }

      PetshopApp.sharedPreferences
          .setString(PetshopApp.userNombre, _nameTextEditingController.text);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userApellido, _lastnameTextEditingController.text);
      PetshopApp.sharedPreferences
          .setString(PetshopApp.userDocId, _idTextEditingController.text);
      PetshopApp.sharedPreferences.setString(PetshopApp.userPais, _paises);
      PetshopApp.sharedPreferences.setString(PetshopApp.userGenero, _sexo);
      PetshopApp.sharedPreferences.setString(
          PetshopApp.userDireccion, _addressTextEditingController.text);
      PetshopApp.sharedPreferences
          .setString(PetshopApp.userFechaNac, _date2TextEditingController.text);
      PetshopApp.sharedPreferences
          .setString(PetshopApp.userTelefono, _tlfTextEditingController.text);

      FirebaseFirestore.instance
          .collection("Dueños")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .get()
          .then((dataSnapshot) {
        PetshopApp.sharedPreferences.setString(PetshopApp.userAvatarUrl,
            dataSnapshot.data()[PetshopApp.userAvatarUrl]);
      });
      await FirebaseFirestore.instance
          .collection("Ciudades")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
          .get()
          .then((dataSnapshot) {
        PetshopApp.sharedPreferences.setString(
            PetshopApp.Moneda, dataSnapshot.data()[PetshopApp.Moneda]);
        PetshopApp.sharedPreferences.setString(PetshopApp.simboloMoneda,
            dataSnapshot.data()[PetshopApp.simboloMoneda]);
      });

      // setState(() {
      //   Route route = MaterialPageRoute(builder: (c) => StoreHome());
      //   Navigator.pushReplacement(context, route);
      // });
        Message(context,
            'Se han agregado los datos a su perfil.');
    }
  }
  Future<void> Message(BuildContext context, String error) async {
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
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1940, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        var formatter = DateFormat.yMd('es_VE');
        String newtime = formatter.format(picked).toString();
        String timeString = picked.toString();
        _dateTextEditingController.value = TextEditingValue(text: newtime);
        _date2TextEditingController.value =
            TextEditingValue(text: timeString.split(" ")[0]);
        print(_date2TextEditingController.text);
      });
  }

  Future<List<dynamic>> getCiudades(pais) async {
    ciudades = [];
    try {
      await FirebaseFirestore.instance
          .collection('Ciudades')
          .where("paisId", isEqualTo: pais)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((paisA) {
          setState(() {
            ciudades = paisA["idPersonaNatural"].toList();
          });
        })
      });
      ciudades.sort();
      print(ciudades.length);
    } catch (e) {
      print(e);
    }
    return ciudades;
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * .40,

            color: Color(0xFF737373), //could change this to Color(0xFF737373),
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
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 70.0,
                        height: 5.0,
                        child: Image.asset(
                          'diseñador/drawable/Rectangulo308.png',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        // maximumDate: DateTime.now(),
                        onDateTimeChanged: (datetime) {
                          setState(() {
                            selectedDate = datetime;

                            String timeString = (datetime).toString();

                            var formatter = DateFormat.yMd('es_VE');

                            String newtime =
                            formatter.format(datetime).toString();

                            _dateTextEditingController.value =
                                TextEditingValue(text: newtime);
                            _date2TextEditingController.value =
                                TextEditingValue(
                                    text: timeString.split(" ")[0]);
                          });
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: RaisedButton(
                    //     onPressed: () {
                    //       Navigator.of(context, rootNavigator: true).pop();
                    //     },
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(5)),
                    //     color: Color(0xFFEB9448),
                    //     padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Text("Seleccionar fecha",
                    //             style: TextStyle(
                    //                 fontFamily: 'Product Sans',
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 18.0)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
          );
        });
  }
}
