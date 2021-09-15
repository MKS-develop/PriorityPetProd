import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_shop/Adoptar/adoptardetalles.dart';
import 'package:pet_shop/Adoptar/adoptarhome.dart';
import 'package:pet_shop/Beneficios/planeshome.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/contenido.dart';
import 'package:pet_shop/Models/favoritos.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Models/prod.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/PetFriendly/petfriendlyhome.dart';
import 'package:pet_shop/Productos/alimentodetalle.dart';
import 'package:pet_shop/Productos/alimentohome.dart';
import 'package:pet_shop/Productos/productoshome.dart';
import 'package:pet_shop/Salud/saludhome.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Servicios/detalleservicio.dart';
import 'package:pet_shop/Servicios/servicioshome.dart';
import 'package:pet_shop/Store/eventospendientes.dart';
import 'package:pet_shop/Store/signuphelpscreen.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/contenido/comunidadhome.dart';
import 'package:pet_shop/contenido/contenidohome.dart';
import 'package:pet_shop/mascotas/registromascota.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/quehay/detallespromos.dart';
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
  List petResults = [];
  List pet = [];
  PetModel model;
  ContenidoModel contenido;
  AliadoModel aliado;
  List ordenes = [];
  int ratingC = 0;
  int _defaultChoiceIndex;
  bool home = true;
  bool noti = false;
  bool carrito = false;
  String quality;
  String nombreComercial;
  TextEditingController _searchTextEditingController =
  new TextEditingController();
  bool busqueda = false;
  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  bool bienvenida;
  GeoPoint userLatLong;
  List _allResults = [];
  List _resultsList = [];
  List _allProductResults = [];
  List _resultsProductList = [];
  static List<ServiceModel> finalServicesList = [];

  @override
  void initState() {
    _getUserData();
    _getQuality();
    _getOrderStatus();
    _getPetStatus();
    _searchTextEditingController.addListener(_onSearchChanged);
    _allResults = [];
    _allProductResults = [];
    MastersList();
    MastersList2();

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
        userLatLong = (dataSnapshot.data()["location"]);
        bienvenida = (dataSnapshot.data()["bienvenida"]);
        bienvenidaNueva(bienvenida);
      });
      print('la bienvenida esta en: $bienvenida');
    });


    // if(model !=null){
    print('La vaina es $model');

    setState(() {
      _defaultChoiceIndex = widget.defaultChoiceIndex;
    });
  }

  MastersList2() {
    FirebaseFirestore.instance
        .collection("Productos")
        .where("pais",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .snapshots()
        .listen(createListofServices2);
  }

  createListofServices2(QuerySnapshot snapshot2) async {
    var docs2 = snapshot2.docs;
    for (var Doc2 in docs2) {
      setState(() {
        _allProductResults.add(ProductoModel.fromFireStore(Doc2));
        print(_allProductResults);
      });
    }
    searchResultsList2();
  }
  // for (ServiceModel tituloSnapshot in _allResults) {

  searchResultsList2() {
    var showResults2 = [];
    if (_searchTextEditingController.text != "") {
      for (var tituloSnapshot2 in _allProductResults) {
        var titulo = tituloSnapshot2.titulo.toLowerCase();
        if (titulo.contains(_searchTextEditingController.text.toLowerCase())) {
          showResults2.add(tituloSnapshot2);
        }
      }
    } else {
      showResults2 = List.from(_allProductResults);
    }

    setState(() {
      _resultsProductList = showResults2;
    });
  }
  _getQuality(){
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Configuraciones")
        .doc('3yqqjyVkTHHkg8yDIdS1');
    documentReference.get().then((dataSnapshot) {

      quality = (dataSnapshot.data()["quality"]);
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
    for (int i = 0; i <= ordenes.length; i++) {
      var nombreComercial = ordenes[i].nombreComercial;
      var usuario = PetshopApp.sharedPreferences.getString(PetshopApp.userNombre);
      var aliadoId = ordenes[i].aliadoId;
      var oid = ordenes[i].oid;
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
                  initialRating: 0,
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
                      // Navigator.of(context, rootNavigator: true).pop(context);
                       Navigator.pop(context, true);
                      // updateFields(aliadoId, oid);
                      // var ratingSum = db.collection('Aliados').doc(aliadoId);
                      // ratingSum.update({
                      //   'totalRatings':
                      //   FieldValue.increment(int.parse(ratingC.toStringAsFixed(0))),
                      //   'countRatings': FieldValue.increment(1),
                      // });
                      //
                      // var checkRef = db.collection('Ordenes').doc(oid);
                      // checkRef.update({
                      //   'calificacion': true,
                      // });
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
        ),
        context: context,
        barrierColor: Colors.white.withOpacity(0),
      ).then((value) {
        if(value){
          var ratingSum = db.collection('Aliados').doc(aliadoId);
          ratingSum.update({
            'totalRatings':
            FieldValue.increment(int.parse(ratingC.toStringAsFixed(0))),
            'countRatings': FieldValue.increment(1),
          });

          var checkRef = db.collection('Ordenes').doc(oid);
          checkRef.update({
            'calificacion': true,
          });
          // updateFields(aliadoId, oid);
        }
      });
    }
  }

  updateFields(aliadoId, oid) async {
    // Navigator.of(context, rootNavigator: true).pop();
    // Navigator.pop(context);
    // Navigator.pop(context);
    // Navigator.pop(context);
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


  Future<List<dynamic>> _getPetStatus() async {
    List list = await FirebaseFirestore.instance
        .collection('Mascotas')
        .where("newOwner",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .where("newPet", isEqualTo: true)

        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list.length; i++) {
      FirebaseFirestore.instance
          .collection('Mascotas')
          .where("newOwner",
          isEqualTo:
          PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .where("newPet", isEqualTo: true)
          .where('pais', isEqualTo: PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
          .snapshots()
          .listen(PetList);
    }
    return list;
  }

  PetList(QuerySnapshot snapshot) async {
    pet = [];
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        petResults.add(PetModel.fromJson(Doc.data()));
        PetModel petModel = PetModel.fromJson(Doc.data());
        pet.add(petModel);
      });
    }
    adopDialog();
  }

  adopDialog() {
    for (int i = 0; i <= pet.length; i++) {
      var nombreMascota = pet[i].nombre;
      var petthumbnailUrl = pet[i].petthumbnailUrl;
      var usuario = PetshopApp.sharedPreferences.getString(PetshopApp.userNombre);
      var aliadoId = pet[i].aliadoId;
      var costoAdulto = pet[i].costoAdulto;
      var costoCachorro = pet[i].costoCachorro;
      var edadMascota = pet[i].edadMascota;





      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("Aliados")
          .doc(aliadoId);
      documentReference.get().then((dataSnapshot) {
        setState(() {
          nombreComercial = (dataSnapshot.data()["nombreComercial"]);
        });



      });
      // var oid = pet[i].oid;
      //   for(OrderModel order in allResults){
      showDialog(
        builder: (context) => AlertDialog(
          // title: Text('Su pago ha sido aprobado.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$usuario,',
                      style: TextStyle(fontSize: 16),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        petthumbnailUrl,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  'Hola, soy $nombreMascota, gracias por adoptarme, si pudiera hablar te diría que es el día más feliz de mi vida, gracias a ti tendré un nuevo hogar. Para proceder con el pago del aporte presiona "Continuar".',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 14,
                ),

                SizedBox(
                  child: RaisedButton(
                    onPressed: () {
                      // Navigator.of(context, rootNavigator: true).pop(context);
                      Navigator.pop(context, true);
                      // updateFields(aliadoId, oid);
                      // var ratingSum = db.collection('Aliados').doc(aliadoId);
                      // ratingSum.update({
                      //   'totalRatings':
                      //   FieldValue.increment(int.parse(ratingC.toStringAsFixed(0))),
                      //   'countRatings': FieldValue.increment(1),
                      // });
                      //
                      // var checkRef = db.collection('Ordenes').doc(oid);
                      // checkRef.update({
                      //   'calificacion': true,
                      // });
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
        context: context,
        barrierColor: Colors.white.withOpacity(0),
      ).then((value) {
        if(value){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentPage(
                  petModel: petResults[i],
                  defaultChoiceIndex:
                  widget.defaultChoiceIndex, totalPrice: edadMascota == 'Adulto' ? costoAdulto: costoCachorro, tituloCategoria: 'Adopción', nombreComercial: nombreComercial,)),
          );
          // updateFields(aliadoId, oid);
        }
      });
    }
  }


  @override
  void dispose() {
    _searchTextEditingController.removeListener(_onSearchChanged);
    _searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  MastersList() async {
    List list_of_locations = await FirebaseFirestore.instance
        .collection("Localidades")
        .where("serviciosContiene", isEqualTo: true)
        .where("pais",
        isEqualTo:
        PetshopApp.sharedPreferences.getString(PetshopApp.userPais))

        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list_of_locations.length; i++) {
      FirebaseFirestore.instance
          .collection("Localidades")
          .doc(list_of_locations[i].documentID.toString())
          .collection("Servicios")
          // .where("categoria", isEqualTo: "Salud")

          .snapshots()
          .listen(CreateListofServices);
    }
    return list_of_locations;
  }

  CreateListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        finalServicesList.add(ServiceModel.fromFireStore(Doc));
        _allResults.add(ServiceModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchTextEditingController.text != "") {
      for (ServiceModel tituloSnapshot in _allResults) {
        var titulo = tituloSnapshot.titulo.toLowerCase();

        if (titulo.contains(_searchTextEditingController.text.toLowerCase())) {
          showResults.add(tituloSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  _onSearchChanged() {
    searchResultsList();
    searchResultsList2();
    print(_searchTextEditingController.text);
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
                    MaterialPageRoute(
                        builder: (context) => StoreHome(
                              petModel: widget.petModel,
                              defaultChoiceIndex: _defaultChoiceIndex,
                            )),
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
                      MaterialPageRoute(
                          builder: (context) => UsuarioInfo(
                                petModel: model,
                                defaultChoiceIndex: _defaultChoiceIndex,
                              )),
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
        bottomNavigationBar: CustomBottomNavigationBar(
            home: home,
            cart: carrito,
            noti: noti,
            petModel: model,
            defaultChoiceIndex: _defaultChoiceIndex),
        drawer: MyDrawer(
          petModel: model,
          defaultChoiceIndex: _defaultChoiceIndex,
          quality: quality,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     Padding(
                //       padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                //       child: Text(
                //         "Tus mascotas",
                //         style: TextStyle(
                //           color: Color(0xFF57419D),
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
                          height: 65,
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
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
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF3F2F9),
                                    border: Border.all(
                                      color: Colors.transparent,
                                      // color: Color(0xFF7f9d9D),
                                      width: 1.0,
                                    ),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  margin: EdgeInsets.all(5.0),
                                  child: TextField(
                                    enableSuggestions: true,
                                    autocorrect: true,
                                    controller: _searchTextEditingController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      icon: new Icon(Icons.search),
                                      hintText: '¿Qué necesita tu mascota?',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Color(0xFF7f9d9D)),
                                    ),
                                    onChanged: (text) {
                                      text = text.toLowerCase();
                                      setState(() {
                                        busqueda = true;
                                      });
                                    },
                                  ),
                                ),
                                // Container(
                                //   padding: EdgeInsets.fromLTRB(295, 15, 0, 0),
                                //   margin: EdgeInsets.all(5.0),
                                //   child: Icon(
                                //     Icons.search,
                                //     color: Color(0xFF7f9d9D),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _searchTextEditingController.text.isNotEmpty ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: Icon(Icons.close), onPressed: (){
                      setState(() {
                        busqueda = false;
                        _searchTextEditingController.clear();
                      });
                    }),
                  ],
                ): Container(),
                _searchTextEditingController.text.isEmpty ?
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      child:SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                              builder: (context) =>
                                                  new ChoosePetAlertDialog(
                                                    message:
                                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                                  ),
                                              context: context);
                                        }
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SaludHome(
                                                  petModel: model,
                                                  defaultChoiceIndex:
                                                      _defaultChoiceIndex)),
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
                            SizedBox(width: 20,),
                            // Padding(
                            //   padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                            //   child: Column(
                            //     children: [
                            //       GestureDetector(
                            //         onTap: () {
                            //           if (model == null) {
                            //             {
                            //               showDialog(
                            //                   builder: (context) =>
                            //                       new ChoosePetAlertDialog(
                            //                         message:
                            //                             "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                            //                       ),
                            //                   context: context);
                            //             }
                            //           }
                            //           if (PetshopApp.sharedPreferences
                            //                       .getString(PetshopApp.userPais) ==
                            //                   "Perú" &&
                            //               model != null) {
                            //             Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                   builder: (context) => PlanesHome(
                            //                         petModel: model,
                            //                         defaultChoiceIndex:
                            //                             _defaultChoiceIndex,
                            //                       )),
                            //             );
                            //           }
                            //           if (PetshopApp.sharedPreferences
                            //                   .getString(PetshopApp.userPais) !=
                            //               "Perú") {
                            //             showDialog(
                            //                 builder: (context) =>
                            //                     new ChoosePetAlertDialog(
                            //                       message:
                            //                           "No estan disponibles planes para tu pais",
                            //                     ),
                            //                 context: context);
                            //           }
                            //         },
                            //         child: Stack(
                            //           alignment: Alignment.center,
                            //           children: [
                            //             Image.asset(
                            //               'diseñador/drawable/Home2/Trazado.png',
                            //               fit: BoxFit.contain,
                            //               height: 68,
                            //             ),
                            //             Image.asset(
                            //               'diseñador/drawable/Home2/beneficios2x.png',
                            //               fit: BoxFit.contain,
                            //               height: 42,
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       SizedBox(
                            //         height: 10,
                            //       ),
                            //       Text(
                            //         "Beneficios",
                            //         style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 14,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(width: 20,),

                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (model == null) {
                                        {
                                          showDialog(
                                              builder: (context) =>
                                                  new ChoosePetAlertDialog(
                                                    message:
                                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                                  ),
                                              context: context);
                                        }
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ServiciosHome(
                                                    petModel: model,
                                                    defaultChoiceIndex:
                                                        _defaultChoiceIndex,
                                                  )),
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
                            SizedBox(width: 20,),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductosHome(
                                            petModel: model,
                                            defaultChoiceIndex: _defaultChoiceIndex,
                                          )),
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
                            SizedBox(width: 20,),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // if (model == null) {
                                      //   {
                                      //     showDialog(
                                      //         builder: (context) =>
                                      //             new ChoosePetAlertDialog(
                                      //               message:
                                      //                   "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      //             ),
                                      //         context: context);
                                      //   }
                                      // }
                                      // else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PetfriendlyHome(
                                              petModel: model,
                                              defaultChoiceIndex:
                                              _defaultChoiceIndex,
                                            )),
                                      );
                                      // }
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
                                    "Pet Friendly",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20,),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EventosPendientesHome(
                                            petModel: model,
                                            defaultChoiceIndex: _defaultChoiceIndex,
                                          )),
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
                            SizedBox(width: 20,),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdoptarHome(
                                            petModel: model,
                                            defaultChoiceIndex: _defaultChoiceIndex,
                                          )),
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

                            SizedBox(width: 20,),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ComunidadHome(
                                            petModel: model,
                                            defaultChoiceIndex: _defaultChoiceIndex,
                                          )),
                                    );
                                    // showDialog(
                                    //     builder: (context) => new ChoosePetAlertDialog(
                                    //       message:
                                    //       "Esta función estará disponible próximamente...",
                                    //     ),
                                    //     context: context);
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
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Promociones",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            if (model == null) {
                              {
                                showDialog(
                                    builder: (context) =>
                                    new ChoosePetAlertDialog(
                                      message:
                                      "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                    ),
                                    context: context);
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PromoHome(
                                      petModel: model,
                                      defaultChoiceIndex:
                                      _defaultChoiceIndex,
                                    )),
                              );
                            }
                          },
                          child: Text(
                            "Ver todas",
                            style: TextStyle(
                              color: Color(0xFF5B618F),
                              fontSize: 14,

                            ),
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
                              vertical: 15, horizontal: 0),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            alignment: Alignment.topCenter,
                            child: Row(
                              children: <Widget>[
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("Promociones")
                                        .where("pais",
                                        isEqualTo: PetshopApp.sharedPreferences
                                            .getString(PetshopApp.userPais))
                                        .orderBy('createdOn', descending: true)
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return Container(

                                        height: 115,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: dataSnapshot.data.docs.length > 7 ? 7:dataSnapshot.data.docs.length,
                                            // dataSnapshot.data.docs.length,
                                            shrinkWrap: true,
                                            itemBuilder: (
                                                context,
                                                index,
                                                ) {
                                              PromotionModel promo =
                                              PromotionModel.fromJson(
                                                  dataSnapshot.data.docs[index]
                                                      .data());
                                              return sourceInfo3(promo, context);
                                            }),
                                      );
                                    }),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Adoptar",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdoptarHome(
                                    petModel: model,
                                    defaultChoiceIndex: _defaultChoiceIndex,
                                  )),
                            );
                          },
                          child: Text(
                            "Ver todas",
                            style: TextStyle(
                              color: Color(0xFF5B618F),
                              fontSize: 14,

                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      width: _screenWidth,
                      child: Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                              stream: db
                                  .collection("Mascotas")
                                  .where("pais",
                                  isEqualTo: PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userPais))
                                  .where("apadrinadoStatus", isEqualTo: false)
                                  .where("adoptadoStatus", isEqualTo: false)
                                  .orderBy('createdOn', descending: true)
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
                                  width: double.infinity,
                                  height: 150,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:dataSnapshot.data.docs.length > 7 ? 7:dataSnapshot.data.docs.length,
                                    // dataSnapshot.data.docs.length,

                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (
                                        context,
                                        index,
                                        ) {
                                      PetModel model = PetModel.fromJson(
                                          dataSnapshot.data.docs[index].data());
                                      return sourceInfo4(model, context);
                                    },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Publicaciones",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ComunidadHome(
                                    petModel: model,
                                    defaultChoiceIndex: _defaultChoiceIndex,
                                  )),
                            );
                          },
                          child: Text(
                            "Ver todas",
                            style: TextStyle(
                              color: Color(0xFF57419D),
                              fontSize: 14,
                            ),
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
                                        .orderBy('createdOn', descending: true)
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
                                            dataSnapshot.data.docs.length > 7 ? 7:dataSnapshot.data.docs.length,
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
                ): _resultsList.length == 0 && _resultsProductList.length == 0
                    ? Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: _screenHeight * 0.3,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image:
                          new AssetImage("images/perritotriste.png"),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                    Text(
                      'No disponible',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _resultsList.length != 0 ?
                    Text(
                      "Servicios",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 17,

                        fontWeight: FontWeight.bold,
                      ),textAlign: TextAlign.start,
                    ): Container(),
                    Container(
                      height: 115 * double.parse(_resultsList.length > 7 ? '7' : _resultsList.length.toString()),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [

                          Expanded(
                            child: Container(
                              height:
                              115 * double.parse(_resultsList.length.toString()),
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _resultsList.length > 7 ? 7 : _resultsList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return sourceInfo5(_resultsList[index], context);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _resultsProductList.length != 0 ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Productos",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,

                            fontWeight: FontWeight.bold,
                          ),textAlign: TextAlign.start,
                        ),
                        // GestureDetector(
                        //   onTap: (){
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => AlimentoHome(
                        //             petModel: model,
                        //             defaultChoiceIndex: _defaultChoiceIndex,
                        //           )),
                        //     );
                        //   },
                        //   child: Text(
                        //     "Ver todos",
                        //     style: TextStyle(
                        //       color: Color(0xFF57419D),
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ): Container(),
                    Container(
                      height: 115 * double.parse(_resultsProductList.length > 7 ? '7' : _resultsProductList.length.toString()),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              height:
                              100 * double.parse(_resultsProductList.length.toString()),
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _resultsProductList.length > 7 ? 7 :_resultsProductList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return sourceInfo6(context, _resultsProductList[index]);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Column(
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => ProductosHome(
                //                         petModel: model,
                //                         defaultChoiceIndex: _defaultChoiceIndex,
                //                       )),
                //             );
                //           },
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Image.asset(
                //                 'diseñador/drawable/Home2/Trazado.png',
                //                 fit: BoxFit.contain,
                //                 height: 68,
                //               ),
                //               Image.asset(
                //                 'diseñador/drawable/Home2/productos2x.png',
                //                 fit: BoxFit.contain,
                //                 height: 42,
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10,
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "Productos",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //             Text(
                //               "",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => EventosPendientesHome(
                //                         petModel: model,
                //                         defaultChoiceIndex: _defaultChoiceIndex,
                //                       )),
                //             );
                //           },
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Image.asset(
                //                 'diseñador/drawable/Home2/Trazado.png',
                //                 fit: BoxFit.contain,
                //                 height: 68,
                //               ),
                //               Image.asset(
                //                 'diseñador/drawable/Home2/eventospendientes2x.png',
                //                 fit: BoxFit.contain,
                //                 height: 42,
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10,
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "Eventos",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //             Text(
                //               "Pendientes",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => AdoptarHome(
                //                         petModel: model,
                //                         defaultChoiceIndex: _defaultChoiceIndex,
                //                       )),
                //             );
                //           },
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Image.asset(
                //                 'diseñador/drawable/Home2/Trazado.png',
                //                 fit: BoxFit.contain,
                //                 height: 68,
                //               ),
                //               Image.asset(
                //                 'diseñador/drawable/Home2/adoptar2x.png',
                //                 fit: BoxFit.contain,
                //                 height: 42,
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10,
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "Adoptar",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //             Text(
                //               "",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //     Column(
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             showDialog(
                //                 builder: (context) => new ChoosePetAlertDialog(
                //                       message:
                //                           "Esta función estará disponible próximamente...",
                //                     ),
                //                 context: context);
                //           },
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Image.asset(
                //                 'diseñador/drawable/Home2/Trazado.png',
                //                 fit: BoxFit.contain,
                //                 height: 68,
                //               ),
                //               Image.asset(
                //                 'assets/images/patas.png',
                //                 fit: BoxFit.contain,
                //                 height: 42,
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10,
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "Comunidad",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //             Text(
                //               "",
                //               style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 14,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ],
                // ),


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
          height: 62.0,
          width: 62.0,
          child: Row(
            children: [
              Material(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                child: Container(
                  height: 62,
                  width: 62,
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
                height: 120.0,
                width: 230,
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
                                      aliadoModel: aliado,
                                      defaultChoiceIndex: _defaultChoiceIndex,
                                    )),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
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
                                    errorBuilder:
                                        (context, object, stacktrace) {
                                      return Container(
                                        height: 0.0,
                                        width: 0.0,
                                      );
                                    },
                                  ).image,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
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

  Widget sourceInfo3(
      PromotionModel promo,
      BuildContext context,
      ) {
    return InkWell(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Aliados")
                .where("aliadoId", isEqualTo: promo.aliadoid)
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
                height: 110.0,
                width: 200,
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
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Localidades")
                              .where("aliadoId", isEqualTo: aliado.aliadoId)
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 1,
                                shrinkWrap: true,
                                itemBuilder: (
                                    context,
                                    index,
                                    ) {
                                  LocationModel location =
                                  LocationModel.fromJson(
                                      dataSnapshot.data.docs[index].data());
                          return GestureDetector(
                            onTap: () {
                              if (model == null) {
                                {
                                  showDialog(
                                      builder: (context) =>
                                      new ChoosePetAlertDialog(
                                        message:
                                        "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                      ),
                                      context: context);
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetallesPromo(
                                        petModel: model,
                                        promotionModel: promo,
                                        aliadoModel: aliado,
                                        locationModel: location,
                                        defaultChoiceIndex: _defaultChoiceIndex,)),
                                );
                              }






                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                              child: Container(
                                width: 195,
                                height: 100,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    image: new DecorationImage(
                                      colorFilter: new ColorFilter.mode(
                                          Colors.black.withOpacity(0.6),
                                          BlendMode.dstIn),
                                      image: new NetworkImage(promo.urlImagen),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Container(
                                              width: 70,
                                              height: 18,

                                              decoration: BoxDecoration(
                                                  color: Colors.greenAccent.shade100,
                                                  borderRadius: BorderRadius.circular(5)

                                              ),

                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        PetshopApp.sharedPreferences
                                                            .getString(PetshopApp.simboloMoneda),
                                                        style: TextStyle(
                                                            color: Colors.blueGrey,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        promo.precio != null ? (promo.precio).toStringAsFixed(2): '0',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.blueGrey,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                     Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.network(
                                                aliado.avatar,
                                                height: 35,
                                                width: 35,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, object, stacktrace) {
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1.0,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 40.0,
                                                  width: 120,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceAround,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(aliado.nombreComercial,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.white,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign: TextAlign.left),
                                                      Flexible(
                                                          child: Text(promo.descripcion,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style:
                                                              TextStyle(fontSize: 9, color: Colors.white,),
                                                              textAlign: TextAlign.left)),


                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      );
                    });
              }));
            }));
  }
  Widget sourceInfo4(
      PetModel model,
      BuildContext context,
      ) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Container(
          // color: Colors.grey,
          height: 98.0,
          width: 75.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 140.0,
                    width: 75.0,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Aliados')
                            .doc(model.aliadoId)
                            .snapshots(),
                        builder: (context, dataSnapshot) {
                          if (!dataSnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 1,
                              shrinkWrap: true,
                              itemBuilder: (context,
                                  index,) {
                                AliadoModel ali = AliadoModel.fromJson(
                                    dataSnapshot.data.data());
                                return GestureDetector(
                                  onTap: () {
                                    var likeRef = db.collection("Mascotas").doc(model.mid);
                                    likeRef.update({
                                      'views': FieldValue.increment(1),
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AdoptarDetalles(
                                                petModel: model,
                                                defaultChoiceIndex: widget.defaultChoiceIndex, aliadoModel: ali,)),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          model.petthumbnailUrl,
                                          height: 90,
                                          width: 75,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, object, stacktrace) {
                                            return Container();
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(model.nombre,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xFF57419D), fontSize: 11)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(

                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.remove_red_eye,
                                                size: 17,
                                                color: Color(0xFF7F9D9D),
                                              ),
                                              Text(
                                                  model.views != null
                                                      ? model.views.toString()
                                                      : '0',
                                                  style: TextStyle(color: Color(0xFF7F9D9D))),
                                            ],
                                          ),
                                          Container(
// color: Colors.purple,
                                            height: 30.0,
                                            width: 40.0,

                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection('Mascotas')
                                                    .doc(model.mid)
                                                    .collection('Favoritos')
                                                    .where('uid',
                                                    isEqualTo: PetshopApp
                                                        .sharedPreferences
                                                        .getString(PetshopApp.userUID))
                                                    .snapshots(),
                                                builder: (context, dataSnapshot) {
                                                  if (!dataSnapshot.hasData) {
                                                    return Row(
                                                      children: [
                                                        CircularProgressIndicator(),
                                                      ],
                                                    );
                                                  }
                                                  if (dataSnapshot.data.docs.length < 1) {
                                                    return Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                      children: [
                                                        Icon(
                                                          Icons.favorite_border_outlined,
                                                          size: 17,
                                                          color: Color(0xFF7F9D9D),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  return ListView.builder(
                                                      physics: NeverScrollableScrollPhysics(),
                                                      itemCount: 1,
                                                      shrinkWrap: true,
                                                      itemBuilder: (context,
                                                          index,) {
                                                        FavoritosModel favorito =
                                                        FavoritosModel.fromJson(
                                                            dataSnapshot.data.docs[index]
                                                                .data());
                                                        return Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            IconButton(
                                                              icon: favorito.like
                                                                  ? Icon(Icons.favorite)
                                                                  : Icon(Icons
                                                                  .favorite_border_outlined),
                                                              color: Color(0xFF57419D),
                                                              iconSize: 17,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (favorito.like) {
                                                                    favorito.like = false;

                                                                    FirebaseFirestore.instance
                                                                        .collection(
                                                                        'Mascotas')
                                                                        .doc(model.mid)
                                                                        .collection(
                                                                        'Favoritos')
                                                                        .doc(PetshopApp
                                                                        .sharedPreferences
                                                                        .getString(
                                                                        PetshopApp
                                                                            .userUID))
                                                                        .set({
                                                                      'like': false,
                                                                      'uid': PetshopApp
                                                                          .sharedPreferences
                                                                          .getString(
                                                                          PetshopApp
                                                                              .userUID),
                                                                    }).then((result) {
                                                                      print("new USer true");
                                                                    }).catchError((onError) {
                                                                      print("onError");
                                                                    });
                                                                  } else {
                                                                    favorito.like = true;

                                                                    FirebaseFirestore.instance
                                                                        .collection(
                                                                        'Mascotas')
                                                                        .doc(model.mid)
                                                                        .collection(
                                                                        'Favoritos')
                                                                        .doc(PetshopApp
                                                                        .sharedPreferences
                                                                        .getString(
                                                                        PetshopApp
                                                                            .userUID))
                                                                        .set({
                                                                      'like': true,
                                                                      'uid': PetshopApp
                                                                          .sharedPreferences
                                                                          .getString(
                                                                          PetshopApp
                                                                              .userUID),
                                                                    }).then((result) {
                                                                      print("new USer true");
                                                                    }).catchError((onError) {
                                                                      print("onError");
                                                                    });
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                            SizedBox(
                                                              height: 100,
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        }),
                  )],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget sourceInfo5(ServiceModel servicio, BuildContext context) {
    double totalD = 0;
    double rating = 0;

    return InkWell(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Localidades")
              .where("localidadId", isEqualTo: servicio.localidadId)
              .snapshots(),
          builder: (context, dataSnapshot) {
            if (!dataSnapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 1,
                shrinkWrap: true,
                itemBuilder: (
                    context,
                    index,
                    ) {
                  LocationModel location = LocationModel.fromJson(
                      dataSnapshot.data.docs[index].data());
                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Aliados")
                          .where("aliadoId", isEqualTo: location.aliadoId)
                          .snapshots(),
                      builder: (context, dataSnapshot) {
                        if (!dataSnapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            shrinkWrap: true,
                            itemBuilder: (
                                context,
                                index,
                                ) {
                              AliadoModel aliado = AliadoModel.fromJson(
                                  dataSnapshot.data.docs[index].data());
                              if (location.location != null) {
                                totalD = Geolocator.distanceBetween(
                                    userLatLong.latitude,
                                    userLatLong.longitude,
                                    location.location.latitude,
                                    location.location.longitude) /
                                    1000;
                              }
                              if (aliado.totalRatings != null) {
                                rating =
                                    aliado.totalRatings / aliado.countRatings;
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (model == null) {
                                    {
                                      showDialog(
                                          builder: (context) =>
                                          new ChoosePetAlertDialog(
                                            message:
                                            "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                                          ),
                                          context: context);
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetallesServicio(
                                              petModel: model,
                                              serviceModel: servicio,
                                              aliadoModel: aliado,
                                              defaultChoiceIndex:
                                              widget.defaultChoiceIndex,
                                              locationModel: location,
                                              userLatLong: userLatLong)),
                                    );
                                  }










                                },
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(2, 5, 2, 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)

                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.network(
                                                servicio.urlImagen,
                                                height: 70,
                                                width: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, object, stacktrace) {
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.65,
                                              height: 85,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Text(servicio.titulo,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                              Color(0xFF57419D),
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign:
                                                          TextAlign.left),
                                                      Text(aliado.nombreComercial,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                              Color(0xFF57419D),
                                                              fontWeight:
                                                              FontWeight.bold),
                                                          textAlign:
                                                          TextAlign.left),
                                                      location.mapAddress != null
                                                          ? Text(
                                                          location.mapAddress,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                          textAlign:
                                                          TextAlign.left)
                                                          : Text(
                                                          location.mapAddress !=
                                                              null
                                                              ? location
                                                              .mapAddress
                                                              : location
                                                              .direccionLocalidad,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                          textAlign:
                                                          TextAlign.left),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      totalD != 0
                                                          ? SizedBox(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          children: [
                                                            Icon(
                                                              Icons.location_on_rounded,
                                                              color: secondaryColor,
                                                              size: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                                totalD < 500
                                                                    ? '${totalD.toStringAsFixed(1)} Km'
                                                                    : '+500 Km',
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                                textAlign:
                                                                TextAlign.center),
                                                          ],
                                                        ),
                                                      )
                                                          : Container(),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              rating.toString() != 'NaN'
                                                                  ? rating
                                                                  .toStringAsPrecision(
                                                                  1)
                                                                  : '0',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors.orange),
                                                              textAlign:
                                                              TextAlign.left),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.orange,
                                                            size: 16,
                                                          )
                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      });
                });
          }),
    );
  }

  Widget sourceInfo6(BuildContext context, ProductoModel product) {
    // final product = Producto.fromSnapshot(snapshot);
    double totalD = 0;
    return InkWell(
      child: Row(
        children: [
          Container(
            height: 115.0,
            width: MediaQuery.of(context).size.width * 0.89,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Aliados')
                    .doc(product.aliadoId)
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      shrinkWrap: true,
                      itemBuilder: (context,
                          index,) {
                        AliadoModel ali =
                        AliadoModel.fromJson(dataSnapshot.data.data());
                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Localidades")
                                .where("localidadId",
                                isEqualTo: product.localidadId)
                                .snapshots(),
                            builder: (context, dataSnapshot) {
                              if (!dataSnapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  shrinkWrap: true,
                                  itemBuilder: (context,
                                      index,) {
                                    LocationModel location =
                                    LocationModel.fromJson(dataSnapshot
                                        .data.docs[index]
                                        .data());
                                    if (userLatLong != null &&
                                        location.location != null) {
                                      totalD = Geolocator.distanceBetween(
                                          userLatLong.latitude,
                                          userLatLong.longitude,
                                          location.location.latitude,
                                          location.location.longitude) /
                                          1000;
                                    }

                                    // var totalD = 0;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AlimentoDetalle(
                                                    petModel: model,
                                                    productoModel: product,
                                                    aliadoModel: ali,
                                                    defaultChoiceIndex:
                                                    widget.defaultChoiceIndex,
                                                    locationModel: location,
                                                  ),
                                            ));
                                      },
                                      child: Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                10)

                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius
                                                    .circular(8.0),
                                                child: Image.network(
                                                  product.urlImagen,
                                                  height: 77,
                                                  width: 66,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                      object, stacktrace) {
                                                    return Container();
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 7.0,
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    height: 91.0,
                                                    width:
                                                    MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width *
                                                        0.6,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(product.titulo,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xFF57419D),
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                            textAlign: TextAlign
                                                                .left),
                                                        // Flexible(
                                                        //     child: Text(product
                                                        //         .dirigido,
                                                        //         style:
                                                        //         TextStyle(
                                                        //             fontSize: 12),
                                                        //         textAlign: TextAlign
                                                        //             .left)),
                                                        Text(ali.nombreComercial,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                Color(0xFF57419D),
                                                                fontWeight:
                                                                FontWeight.bold),
                                                            textAlign:
                                                            TextAlign.left),
                                                        location.mapAddress != null
                                                            ? Text(
                                                            location.mapAddress,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                            textAlign:
                                                            TextAlign.left)
                                                            : Text(
                                                            location.mapAddress !=
                                                                null
                                                                ? location
                                                                .mapAddress
                                                                : location
                                                                .direccionLocalidad,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                            textAlign:
                                                            TextAlign.left),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                PetshopApp
                                                                    .sharedPreferences
                                                                    .getString(
                                                                    PetshopApp
                                                                        .simboloMoneda),
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color:
                                                                    Color(
                                                                        0xFF57419D),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                                textAlign: TextAlign
                                                                    .left),
                                                            Text(product.precio
                                                                .toStringAsFixed(
                                                                2),
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color:
                                                                    Color(
                                                                        0xFF57419D),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                                textAlign: TextAlign
                                                                    .left),
                                                          ],
                                                        ),
                                                        totalD != 0
                                                            ? SizedBox(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 7,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .location_on_rounded,
                                                                color:
                                                                secondaryColor,
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Text(
                                                                  totalD <
                                                                      500
                                                                      ? '${totalD.toStringAsFixed(1)} Km'
                                                                      : '+500 Km',
                                                                  style:
                                                                  TextStyle(
                                                                    fontSize:
                                                                    10,
                                                                  ),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center),
                                                            ],
                                                          ),
                                                        )
                                                            : Container(),

                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              );
                            });
                      });
                }),
          )],
      ),
    );
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
