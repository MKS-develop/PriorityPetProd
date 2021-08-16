import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Adoptar/adoptardetalles.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/favoritos.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/mascotas/registromascota.dart';

class AdoptarHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  AdoptarHome({this.petModel, this.defaultChoiceIndex});

  @override
  _AdoptarHomeState createState() => _AdoptarHomeState();
}

class _AdoptarHomeState extends State<AdoptarHome> {
  PetModel model;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar:
            CustomBottomNavigationBar(petmodel: widget.petModel),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
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
                        "Adopta o apadrina",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                              child: GridView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: dataSnapshot.data.docs.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.7),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  PetModel model = PetModel.fromJson(
                                      dataSnapshot.data.docs[index].data());
                                  return sourceInfo(model, context);
                                },
                              ),
                            );
                          }),
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

  Widget sourceInfo(
    PetModel model,
    BuildContext context,
  ) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(0),
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
                  GestureDetector(
                    onTap: () {
                      var likeRef = db.collection("Mascotas").doc(model.mid);
                      likeRef.update({
                        'views': FieldValue.increment(1),
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdoptarDetalles(
                                petModel: model,
                                defaultChoiceIndex: widget.defaultChoiceIndex)),
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
                            style: TextStyle(
                                color: Color(0xFF57419D), fontSize: 12)),
                        Row(
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
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
