import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/errorDialog.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/comentarioscontenido.dart';
import 'package:pet_shop/Models/contenido.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

double width;

class ContenidoHome extends StatefulWidget {
  final PetModel petModel;
  final ContenidoModel contenidoModel;
  final AliadoModel aliadoModel;
  ContenidoHome({this.petModel, this.contenidoModel, this.aliadoModel});

  @override
  _ContenidoHomeState createState() => _ContenidoHomeState();
}

class _ContenidoHomeState extends State<ContenidoHome> {
  final TextEditingController _comentarioTextEditingController =
      TextEditingController();
  int countLike = 0;
  PetModel model;
  ContenidoModel contenido;
  bool check = false;
  bool comment = false;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  void initState() {
    changePet(widget.petModel);
    changeCon(widget.contenidoModel);
    super.initState();
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Contenido")
        .doc(widget.contenidoModel.postId)
        .collection('Likes')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        check = (dataSnapshot.data()["like"]);
      });

      print(check);
    });
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.MMMd('es_VE');
    String formatted = formatter.format(widget.contenidoModel != null
        ? widget.contenidoModel.createdOn.toDate()
        : DateTime.now());
    int countLike = widget.contenidoModel.likes;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(context, widget.petModel),
        drawer: MyDrawer(),
        bottomNavigationBar: CustomBottomNavigationBar(),
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
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Color(0xFF57419D)),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text(
                        "Contenido",
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
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // child: Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.aliadoModel.nombreComercial,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatted,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F9D9D)),
                      ),
                    ],
                  ),
                ),
                // ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFF57419D).withOpacity(0.5),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    // child: Flexible(
                    child:
                        // Expanded(
                        //     child:
                        Text(
                      widget.contenidoModel.titulo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                    // ),

                    ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: _screenWidth,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: new DecorationImage(
                          image:
                              new NetworkImage(widget.contenidoModel.urlImagen),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.contenidoModel.descripcion,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFF57419D).withOpacity(0.5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: comment
                                ? Icon(Icons.insert_comment)
                                : Icon(Icons.insert_comment_outlined),
                            color: Color(0xFF57419D),
                            iconSize: 40,
                            onPressed: () {
                              setState(() {
                                if (comment) {
                                  comment = false;
                                } else {
                                  comment = true;
                                }
                              });
                            }),

                        // Text(widget.contenidoModel.likes.toString(), style: TextStyle(color: Color(0xFF7F9D9D))),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: check
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border_outlined),
                          color: Color(0xFF57419D),
                          iconSize: 40,
                          onPressed: () {
                            setState(() {
                              if (check) {
                                check = false;

                                FirebaseFirestore.instance
                                    .collection("Contenido")
                                    .doc(widget.contenidoModel.postId)
                                    .collection('Likes')
                                    .doc(PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userUID))
                                    .setData({
                                  'like': false,
                                  'uid': PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userUID),
                                }).then((result) {
                                  print("new USer true");
                                }).catchError((onError) {
                                  print("onError");
                                });
                                var likeRef = db
                                    .collection("Contenido")
                                    .doc(widget.contenidoModel.postId);
                                likeRef.updateData({
                                  'likes': FieldValue.increment(-1),
                                });
                              } else {
                                check = true;

                                FirebaseFirestore.instance
                                    .collection("Contenido")
                                    .doc(widget.contenidoModel.postId)
                                    .collection('Likes')
                                    .doc(PetshopApp.sharedPreferences
                                        .getString(PetshopApp.userUID))
                                    .setData({
                                  'like': true,
                                  'uid': PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userUID),
                                }).then((result) {
                                  print("new USer true");
                                }).catchError((onError) {
                                  print("onError");
                                });
                                var likeRef = db
                                    .collection("Contenido")
                                    .doc(widget.contenidoModel.postId);
                                likeRef.updateData({
                                  'likes': FieldValue.increment(1),
                                });
                              }
                            });
                          },
                        ),
                        Container(
                          height: 20,
                          width: 20,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Contenido')
                                  .doc(widget.contenidoModel.postId)
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (!dataSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                    itemCount: 1,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      ContenidoModel contenido =
                                          ContenidoModel.fromJson(
                                              dataSnapshot.data.data());
                                      return Text(contenido.likes.toString(),
                                          style: TextStyle(
                                              color: Color(0xFF7F9D9D)));
                                    });
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFF57419D).withOpacity(0.5),
                ),
                comment == true
                    ? Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Contenido")
                                  .doc(widget.contenidoModel.postId)
                                  .collection('Comentarios')
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (!dataSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Container(
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: dataSnapshot.data.docs.length,
                                      shrinkWrap: true,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        ComentariosModel comentario =
                                            ComentariosModel.fromJson(
                                                dataSnapshot.data.docs[index]
                                                    .data());
                                        initializeDateFormatting("es_VE", null)
                                            .then((_) {});
                                        var formatter =
                                            DateFormat.MMMd('es_VE');
                                        String formatted = formatter.format(
                                            comentario.createdOn.toDate());
                                        print(formatted);
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Respuesta de '),
                                                    Text(
                                                      comentario.usuarioNombre,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Text(formatted),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // Expanded(
                                                  //     child:
                                                  Text(comentario.descripcion)
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              indent: 20,
                                              endIndent: 20,
                                              color: Color(0xFF57419D)
                                                  .withOpacity(0.5),
                                            ),
                                          ],
                                        );
                                      }),
                                );
                              }),
                          CustomTextField(
                            controller: _comentarioTextEditingController,
                            hintText: ("Escribe un comentario"),
                            isObsecure: false,
                          ),
                          Container(
                            width: _screenWidth * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: RaisedButton(
                                onPressed: () {
                                  _comentarioTextEditingController
                                          .text.isNotEmpty
                                      ? uploadComentario()
                                      : showDialog(
                                          context: context,
                                          builder: (c) {
                                            return ErrorAlertDialog(
                                              message:
                                                  "Ingrese su comentario...",
                                            );
                                          });

                                  //   Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => ContenidoHome()),
                                  // );
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                color: Color(0xFF57419D),
                                padding: EdgeInsets.fromLTRB(18, 5, 18, 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Enviar",
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  uploadComentario() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Contenido')
        .doc(widget.contenidoModel.postId)
        .collection('Comentarios')
        .doc(productId)
        .setData({
      "usuarioNombre":
          PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "comentarioId": productId,
      'createdOn': DateTime.now(),
      'uid': PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      'descripcion': _comentarioTextEditingController.text.trim(),
    });

    setState(() {
      productId = DateTime.now().millisecondsSinceEpoch.toString();
      _comentarioTextEditingController.clear();
    });
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  changeCon(otro) {
    setState(() {
      contenido = otro;
    });

    return otro;
  }
}
