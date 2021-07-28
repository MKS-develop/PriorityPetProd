import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/mascotas/registromascota.dart';

import 'editarmascota.dart';

class MascotasHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  MascotasHome({this.petModel, this.defaultChoiceIndex});

  @override
  _MascotasHomeState createState() => _MascotasHomeState();
}

class _MascotasHomeState extends State<MascotasHome> {
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
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          height: _screenHeight,
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
                        "Mis mascotas",
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
                  height: 100.0,
                  width: double.infinity,
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
                        child: Column(
                          children: [
                            Image.asset(
                              'diseñador/drawable/Grupo78.png',
                              fit: BoxFit.contain,
                              height: 65,
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text('Nueva mascota'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _screenWidth,
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: db
                              .collection("Mascotas")
                              .where("uid",
                                  isEqualTo: PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userUID))
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
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10),
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
          height: 75.0,
          width: 75.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditarMascota(
                                petModel: model,
                                defaultChoiceIndex: widget.defaultChoiceIndex)),
                      );
                    },
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      child: Container(
                        height: 60,
                        width: 60,
                        color: Colors.transparent,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            model.petthumbnailUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  Text(model.nombre),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
