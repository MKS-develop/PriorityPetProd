import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pet_shop/Adoptar/adoptarhome.dart';
import 'package:pet_shop/Beneficios/planeshome.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/contenido.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Productos/productoshome.dart';
import 'package:pet_shop/Salud/saludhome.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Servicios/servicioshome.dart';
import 'package:pet_shop/Store/eventospendientes.dart';
import 'package:pet_shop/Store/signuphelpscreen.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/contenido/contenidohome.dart';
import 'package:pet_shop/mascotas/registromascota.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/quehay/promos.dart';
import 'package:pet_shop/usuario/usuarioinfo.dart';
import '../Widgets/myDrawer.dart';

double width;

class StoreHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  StoreHome({this.petModel, this.defaultChoiceIndex});
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  List allResults = [];
  PetModel model;
  ContenidoModel contenido;
  AliadoModel aliado;
  List ordenes = [];
  int ratingC = 0;
  int _defaultChoiceIndex;
  bool home = true;
  bool noti = false;
  bool carrito = false;

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  bool bienvenida;

  @override
  void initState() {
    _getUserData();

    super.initState();
    setState(() {
      home = true;
      noti = false;
      carrito = false;
      model = widget.petModel;
    });
    print(
        'la clave del usuario esssssss ${PetshopApp.sharedPreferences.getString(PetshopApp.userUID)}');
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        bienvenida = (dataSnapshot.data()["bienvenida"]);
        bienvenidaNueva(bienvenida);
      });
      print('la bienvenida esta en: $bienvenida');
    });

    _getOrderStatus();
    // if(model !=null){
    print('La vaina es $model');

    setState(() {
      _defaultChoiceIndex = widget.defaultChoiceIndex;

    });

  }

  _getUserData() async {
    if (PetshopApp.sharedPreferences.getString(PetshopApp.userUID) == null) {
      User user = FirebaseAuth.instance.currentUser;
      setState(() {
        PetshopApp.sharedPreferences.setString(PetshopApp.userUID, user.uid);
        PetshopApp.sharedPreferences
            .setString(PetshopApp.userEmail, user.email);
      });

      DocumentReference documentReference =
      FirebaseFirestore.instance.collection("Dueños").doc(user.uid);
      await documentReference.get().then((dataSnapshot) {
        setState(() {
          PetshopApp.sharedPreferences.setString(
              PetshopApp.userDocId, dataSnapshot.data()[PetshopApp.userDocId]);
          PetshopApp.sharedPreferences.setString(PetshopApp.userApellido,
              dataSnapshot.data()[PetshopApp.userApellido]);
          PetshopApp.sharedPreferences.setString(PetshopApp.userNombre,
              dataSnapshot.data()[PetshopApp.userNombre]);
          PetshopApp.sharedPreferences.setString(PetshopApp.userAvatarUrl,
              dataSnapshot.data()[PetshopApp.userAvatarUrl]);

          PetshopApp.sharedPreferences.setString(PetshopApp.userTelefono,
              dataSnapshot.data()[PetshopApp.userTelefono]);
          PetshopApp.sharedPreferences.setString(PetshopApp.userDireccion,
              dataSnapshot.data()[PetshopApp.userDireccion]);
          PetshopApp.sharedPreferences.setString(
              PetshopApp.userPais, dataSnapshot.data()[PetshopApp.userPais]);
          PetshopApp.sharedPreferences.setString(PetshopApp.userGenero,
              dataSnapshot.data()[PetshopApp.userGenero]);
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
          PetshopApp.sharedPreferences.setString(
              PetshopApp.userName, dataSnapshot.data()[PetshopApp.userName]);
          FirebaseFirestore.instance
              .collection("Ciudades")
              .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
              .get()
              .then((dataSnapshot) {
            PetshopApp.sharedPreferences.setString(
                PetshopApp.Moneda, dataSnapshot.data()[PetshopApp.Moneda]);
            PetshopApp.sharedPreferences.setString(PetshopApp.simboloMoneda,
                dataSnapshot.data()[PetshopApp.simboloMoneda]);
          });
        });
      });
    }
  }

  _modelA() {
    print('La vaina es $model');
  }

  bienvenidaNueva(bienvenida) {
    if (bienvenida == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpHelpScreen()),
      );
    }
  }

  Future<List<dynamic>> _getOrderStatus() async {
    List list = await FirebaseFirestore.instance
        .collection('Ordenes')
        .where("uid",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .where("calificacion", isEqualTo: false)
        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list.length; i++) {
      FirebaseFirestore.instance
          .collection('Ordenes')
          .where('oid', isEqualTo: list[i].documentID.toString())
          .where('date', isLessThan: DateTime.now())
          .snapshots()
          .listen(CreateList);
    }
    return list;
  }

  CreateList(QuerySnapshot snapshot) async {
    ordenes = [];
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        allResults.add(OrderModel.fromJson(Doc.data()));
        OrderModel order = OrderModel.fromJson(Doc.data());
        ordenes.add(order);
      });
    }
    search();
  }

  search() {
    for (int i = 0; i < ordenes.length; i++) {
      var nombreComercial = ordenes[i].nombreComercial;
      var usuario = PetshopApp.sharedPreferences.getString(PetshopApp.userName);
      //   for(OrderModel order in allResults){
      showDialog(
        builder: (context) => AlertDialog(
          // title: Text('Su pago ha sido aprobado.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '$usuario,',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  'Nos gustaría que calificaras tu último servicio con $nombreComercial, tu opinión nos importa.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 14,
                ),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingC = int.parse(rating.toStringAsFixed(0));
                    });

                    print(ratingC.toStringAsFixed(0));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      updateFields(ordenes[i].aliadoId, ordenes[i].oid);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Color(0xFF57419D),
                    padding: EdgeInsets.all(10.0),
                    child: Text("Enviar calificación",
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
      );
    }
  }

  updateFields(aliadoId, oid) async {
    var ratingSum = await db.collection('Aliados').doc(aliadoId);
    ratingSum.update({
      'totalRatings':
      FieldValue.increment(int.parse(ratingC.toStringAsFixed(0))),
      'countRatings': FieldValue.increment(1),
    });

    var checkRef = await db.collection('Ordenes').doc(oid);
    checkRef.update({
      'calificacion': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90.0),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 20,
              right: 16.0,
            ),
            child: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.transparent, //No more green
              elevation: 0.0,
              //Shadow gone

              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoreHome(petModel: widget.petModel, defaultChoiceIndex: _defaultChoiceIndex,)),
                  );
                },
                child: Image.asset(
                  'diseñador/logo.png',
                  fit: BoxFit.contain,
                  height: 40,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UsuarioInfo(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        child: Container(
                          height: 50,
                          width: 50,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: Image.network(
                              PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userAvatarUrl) ??
                                  'Cargando',
                              errorBuilder: (context, object, stacktrace) {
                                return Container();
                              },
                            ).image,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
        CustomBottomNavigationBar(home: home, cart: carrito, noti: noti, petmodel: model, defaultChoiceIndex: _defaultChoiceIndex),
        drawer: MyDrawer(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text(
                        "Tus mascotas",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Text(PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)),
                // Text(PetshopApp.sharedPreferences.getString(PetshopApp.Moneda)),
                Container(
                  height: 100.0,
                  // width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistroMascota()),
                          );
                        },
                        child: Image.asset(
                          'diseñador/drawable/Grupo78.png',
                          fit: BoxFit.contain,
                          height: 72,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: db
                              .collection("Mascotas")
                              .where("uid",
                              isEqualTo: PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userUID))
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Container(
                              child: Expanded(
                                child: ListView.builder(
                                  itemCount: dataSnapshot.data.docs.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (
                                      context,
                                      index,
                                      ) {
                                    PetModel model = PetModel.fromJson(
                                        dataSnapshot.data.docs[index].data());
                                    return ChoiceChip(
                                      label: sourceInfo(model, context),
                                      disabledColor: Colors.transparent,
                                      labelPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      selected: _defaultChoiceIndex == index,
                                      selectedColor: Color(0xFF57419D),
                                      onSelected: (bool selected) {
                                        changePet(model);
                                        print(model.nombre);
                                        setState(() {
                                          _defaultChoiceIndex =
                                          selected ? index : 0;
                                          print(_defaultChoiceIndex);
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      labelStyle:
                                      TextStyle(color: Colors.transparent),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (model == null) {
                                {
                                  showDialog(
                                      builder: (context) => new ChoosePetAlertDialog(
                                        message:
                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      ), context: context);
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SaludHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex)),
                                );
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'diseñador/drawable/Home2/Trazado.png',
                                  fit: BoxFit.contain,
                                  height: 68,
                                ),
                                Image.asset(
                                  'diseñador/drawable/Home2/salud2x.png',
                                  fit: BoxFit.contain,
                                  height: 42,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Salud",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (model == null) {
                                {
                                  showDialog(
                                      builder: (context) => new ChoosePetAlertDialog(
                                        message:
                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      ), context: context);
                                }
                              }
                              if (PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userPais) ==
                                  "Perú" &&
                                  model != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlanesHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                                );
                              }
                              if (PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userPais) !=
                                  "Perú") {
                                showDialog(
                                    builder: (context) => new ChoosePetAlertDialog(
                                      message:
                                      "No estan disponibles planes para tu pais",
                                    ), context: context);
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'diseñador/drawable/Home2/Trazado.png',
                                  fit: BoxFit.contain,
                                  height: 68,
                                ),
                                Image.asset(
                                  'diseñador/drawable/Home2/beneficios2x.png',
                                  fit: BoxFit.contain,
                                  height: 42,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Beneficios",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (model == null) {
                                {
                                  showDialog(
                                      builder: (context) => new ChoosePetAlertDialog(
                                        message:
                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      ), context: context);
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PromoHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                                );
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'diseñador/drawable/Home2/Trazado.png',
                                  fit: BoxFit.contain,
                                  height: 68,
                                ),
                                Image.asset(
                                  'diseñador/drawable/Home2/quehay2x.png',
                                  fit: BoxFit.contain,
                                  height: 42,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Que hay hoy",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (model == null) {
                                {
                                  showDialog(
                                      builder: (context) => new ChoosePetAlertDialog(
                                        message:
                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      ), context: context);
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ServiciosHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                                );
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'diseñador/drawable/Home2/Trazado.png',
                                  fit: BoxFit.contain,
                                  height: 68,
                                ),
                                Image.asset(
                                  'diseñador/drawable/Home2/servicios2x.png',
                                  fit: BoxFit.contain,
                                  height: 42,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Servicios",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductosHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'diseñador/drawable/Home2/Trazado.png',
                                fit: BoxFit.contain,
                                height: 68,
                              ),
                              Image.asset(
                                'diseñador/drawable/Home2/productos2x.png',
                                fit: BoxFit.contain,
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Productos",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EventosPendientesHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'diseñador/drawable/Home2/Trazado.png',
                                fit: BoxFit.contain,
                                height: 68,
                              ),
                              Image.asset(
                                'diseñador/drawable/Home2/eventospendientes2x.png',
                                fit: BoxFit.contain,
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Eventos",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Pendientes",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AdoptarHome(petModel: model, defaultChoiceIndex: _defaultChoiceIndex,)),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'diseñador/drawable/Home2/Trazado.png',
                                fit: BoxFit.contain,
                                height: 68,
                              ),
                              Image.asset(
                                'diseñador/drawable/Home2/adoptar2x.png',
                                fit: BoxFit.contain,
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Adoptar",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                builder: (context) => new ChoosePetAlertDialog(
                                  message:
                                  "Esta función estará disponible próximamente...",
                                ), context: context);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'diseñador/drawable/Home2/Trazado.png',
                                fit: BoxFit.contain,
                                height: 68,
                              ),
                              Image.asset(
                                'assets/images/patas.png',
                                fit: BoxFit.contain,
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Comunidad",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contenido",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Ver todos",
                      style: TextStyle(
                        color: Color(0xFF57419D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: <Widget>[
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("Contenido")
                                    .where("pais",
                                    isEqualTo: PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userPais))
                                    .where("isApproved", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, dataSnapshot) {
                                  if (!dataSnapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return Container(
                                    height: 160,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                        dataSnapshot.data.docs.length,
                                        shrinkWrap: true,
                                        itemBuilder: (
                                            context,
                                            index,
                                            ) {
                                          ContenidoModel contenido =
                                          ContenidoModel.fromJson(
                                              dataSnapshot.data.docs[index]
                                                  .data());
                                          return sourceInfo2(
                                              contenido, context);
                                        }),
                                  );
                                }),

                            // Container(
                            //   width: 200,
                            //   margin: EdgeInsets.only(right: 20),
                            //   height: 150,
                            //   decoration: BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.all(Radius.circular(20.0))),
                            //   child: Container(
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(12.0),
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: <Widget>[
                            //           Text(
                            //             "Bravecto",
                            //             style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                            //           ),
                            //           SizedBox(
                            //             height: 10,
                            //           ),
                            //           Text(
                            //             "¿La mejor solución?",
                            //             style: TextStyle(fontSize: 16, color: Colors.white),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            // Container(
                            //   width: 200,
                            //   margin: EdgeInsets.only(right: 20),
                            //   height: 150,
                            //   decoration: BoxDecoration(color: Colors.lightBlueAccent.shade400, borderRadius: BorderRadius.all(Radius.circular(20.0))),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(12.0),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: <Widget>[
                            //         Text(
                            //           "Perros y Gatos",
                            //           style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                            //         ),
                            //         SizedBox(
                            //           height: 10,
                            //         ),
                            //         Text(
                            //           "Claves para la convivencia",
                            //           style: TextStyle(fontSize: 16, color: Colors.white),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
      PetModel model,
      BuildContext context,
      ) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Container(
          height: 72.0,
          width: 72.0,
          child: Row(
            children: [
              Material(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                child: Container(
                  height: 72,
                  width: 72,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: Image.network(
                      model.petthumbnailUrl,
                      errorBuilder: (context, object, stacktrace) {
                        return Container();
                      },
                    ).image,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sourceInfo2(
      ContenidoModel contenido,
      BuildContext context,
      ) {
    return InkWell(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Aliados")
                .where("aliadoId", isEqualTo: contenido.aliadoId)
                .snapshots(),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.hasData) {
                if (dataSnapshot.data.docs.length == 0) {
                  return Center(child: Text(''));
                }
              }
              if (!dataSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                height: 150.0,
                width: 250,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 1,
                    shrinkWrap: true,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      AliadoModel aliado = AliadoModel.fromJson(
                          dataSnapshot.data.docs[index].data());
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContenidoHome(
                                  petModel: model,
                                  contenidoModel: contenido,
                                  aliadoModel: aliado, defaultChoiceIndex: _defaultChoiceIndex,)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                image: new DecorationImage(
                                  colorFilter: new ColorFilter.mode(
                                      Colors.black.withOpacity(0.6),
                                      BlendMode.dstATop),
                                  image: Image.network(
                                    contenido.urlImagen, 
                                    errorBuilder: (context, object, stacktrace) {
                                      return Container(height: 0.0, width: 0.0,);
                                    },
                                  ).image,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    contenido.titulo,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }));
  }

  changeAl(cont) {
    setState(() {
      aliado = cont;
    });

    return cont;
  }

  changeCont(cont) {
    setState(() {
      contenido = cont;
    });

    return cont;
  }

  changePet(otro) {
    setState(() {
      model = otro;
      print(model.nombre);
    });

    return otro;
  }
}
