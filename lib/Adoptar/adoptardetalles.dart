import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Adoptar/adoptarconfirmar.dart';
import 'package:pet_shop/Adoptar/apadrinarconfirmar.dart';
import 'package:pet_shop/Adoptar/historiaadopcion.dart';
import 'package:pet_shop/Chat/ChatPage.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/mascotas/mascotashome.dart';
import '../Widgets/myDrawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/Store/storehome.dart';

double width;

class AdoptarDetalles extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  AdoptarDetalles({this.petModel, this.defaultChoiceIndex});

  @override
  _AdoptarDetallesState createState() => _AdoptarDetallesState();
}

class _AdoptarDetallesState extends State<AdoptarDetalles>
    with AutomaticKeepAliveClientMixin<AdoptarDetalles> {
  final TextEditingController _namepetTextEditingController =
      TextEditingController();
  final TextEditingController _datepetTextEditingController =
      TextEditingController();
  final TextEditingController _date2petTextEditingController =
      TextEditingController();
  final TextEditingController _aboutpetTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _petformKey = GlobalKey<FormState>();
  bool check = false;
  String _categoria;
  String _raza;
  String _sexo;
  DateTime selectedDate = DateTime.now();
  PetModel model;
  String imageDownloadUrl;

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  String petImageUrl = "";

  bool get wantKeepAlive => true;
  PickedFile file;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFavorites();
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    if (widget.petModel.nombre != null) {
      _namepetTextEditingController.value =
          TextEditingValue(text: widget.petModel.nombre);
    }
    if (widget.petModel.fechanac != null) {
      String timeString = DateFormat.yMd('es_VE')
          .format(widget.petModel.fechanac.toDate())
          .toString();
      _datepetTextEditingController.value = TextEditingValue(text: timeString);
      _date2petTextEditingController.value = TextEditingValue(
          text: (widget.petModel.fechanac.toDate()).toString());
    }
    if (widget.petModel.especie != null) {
      _categoria = widget.petModel.especie;
    }
    if (widget.petModel.raza != null) {
      _raza = widget.petModel.raza;
    }
    if (widget.petModel.sexo != null) {
      _sexo = widget.petModel.sexo;
    }
    if (widget.petModel.acerca != null) {
      _aboutpetTextEditingController.value =
          TextEditingValue(text: widget.petModel.acerca);
    }
  }

  getFavorites() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Mascotas")
        .doc(widget.petModel.mid)
        .collection('Favoritos')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        check = (dataSnapshot.data()["like"]);
      });

      print(check);
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return new Scaffold(
      appBar: AppBarCustomAvatar(
          context, widget.petModel, widget.defaultChoiceIndex),
      drawer: MyDrawer(
        petModel: widget.petModel,
        defaultChoiceIndex: widget.defaultChoiceIndex,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        petmodel: widget.petModel,
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
          child: Column(
            children: <Widget>[
              Form(
                key: _petformKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Text(
                            "Mi historia",
                            style: TextStyle(
                              color: Color(0xFF57419D),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.petModel.petthumbnailUrl,
                            height: 155,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stacktrace) {
                              return Container();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 25.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: 170.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Text("Me interesa",
                              //     style: TextStyle(
                              //         fontSize: 17,
                              //         color: Color(0xFF57419D),
                              //         fontWeight: FontWeight.bold),
                              //     textAlign: TextAlign.left),
                              //
                              // SizedBox(
                              //   height: 10,
                              // ),
                              SizedBox(
                                width: 160,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ApadrinarConfirmar(
                                                  petModel: widget.petModel,
                                                  defaultChoiceIndex: widget
                                                      .defaultChoiceIndex)),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Color(0xFFEB9448),
                                  padding: EdgeInsets.all(6.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Apadrinar",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Colors.black,
                                              fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: 160,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AdoptarConfirmar(
                                                  petModel: widget.petModel,
                                                  defaultChoiceIndex: widget
                                                      .defaultChoiceIndex)),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(6.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Adoptar",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Colors.white,
                                              fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: 160,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              aliado: widget.petModel.aliadoId,
                                              defaultChoiceIndex:
                                                  widget.defaultChoiceIndex)),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Color(0xFF7F9D9D),
                                  padding: EdgeInsets.all(6.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Enviar mensaje",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Colors.white,
                                              fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Nombre: ${widget.petModel.nombre}'),
                    Text('Sexo: ${widget.petModel.sexo}'),
                    Text(
                        'Raza: ${widget.petModel.raza == null ? 'Mestizo' : ''}'),
                    Text(widget.petModel.edadMascota),
                    Text('${widget.petModel.tamanoMascota}'),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: check
                                  ? Icon(Icons.favorite)
                                  : Icon(Icons.favorite_border_outlined),
                              color: Color(0xFF7F9D9D),
                              iconSize: 40,
                              onPressed: () {
                                setState(() {
                                  if (check) {
                                    check = false;

                                    FirebaseFirestore.instance
                                        .collection("Mascotas")
                                        .doc(widget.petModel.mid)
                                        .collection('Favoritos')
                                        .doc(PetshopApp.sharedPreferences
                                            .getString(PetshopApp.userUID))
                                        .set({
                                      'like': false,
                                      'uid': PetshopApp.sharedPreferences
                                          .getString(PetshopApp.userUID),
                                    }).then((result) {
                                      print("new USer true");
                                    }).catchError((onError) {
                                      print("onError");
                                    });
                                  } else {
                                    check = true;

                                    FirebaseFirestore.instance
                                        .collection("Mascotas")
                                        .doc(widget.petModel.mid)
                                        .collection('Favoritos')
                                        .doc(PetshopApp.sharedPreferences
                                            .getString(PetshopApp.userUID))
                                        .set({
                                      'like': true,
                                      'uid': PetshopApp.sharedPreferences
                                          .getString(PetshopApp.userUID),
                                    }).then((result) {
                                      print("new USer true");
                                    }).catchError((onError) {
                                      print("onError");
                                    });
                                  }
                                });
                              },
                            ),
                            Text(
                              "Me gusta",
                              style: TextStyle(
                                color: Color(0xFF7F9D9D),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                    Text("Esta es mi historia",
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                    SizedBox(height: 20),
                    Text('${widget.petModel.historia}'),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 200,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoriaAdopcion(
                              petModel: widget.petModel,
                              defaultChoiceIndex: widget.defaultChoiceIndex)),
                    );
                  },
                  // uploading ? null : ()=> uploadImageAndSavePetInfo(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Color(0xFF7F9D9D),
                  padding: EdgeInsets.all(6.0),
                  child: Text("Expediente médico",
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.white,
                          fontSize: 15.0)),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  savePetInfo(String downloadUrl) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection('Mascotas').doc(widget.petModel.mid).set({
      "nombre": _namepetTextEditingController.text.trim(),
      "petthumbnailUrl": downloadUrl,
      "fechanac": DateTime.parse(_date2petTextEditingController.text),
      "especie": _categoria,
      "raza": _raza,
      "sexo": _sexo,
      "acerca": _aboutpetTextEditingController.text.trim(),
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
    });

    setState(() {
      Route route = MaterialPageRoute(
          builder: (c) => MascotasHome(
              petModel: widget.petModel,
              defaultChoiceIndex: widget.defaultChoiceIndex));
      Navigator.pushReplacement(context, route);
    });
  }
}
