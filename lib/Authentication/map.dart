import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class MapHome extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  MapHome({this.petModel, this.productoModel, this.cartModel, this.defaultChoiceIndex});

  @override
  _MapHomeState createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  PetModel model;
  CartModel cart;
  Producto producto;

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
              title: GestureDetector(
                onTap: () {
                  print(DateTime.now());
                  Route route = MaterialPageRoute(builder: (c) => StoreHome());
                  Navigator.pushReplacement(context, route);
                },
                child: Image.asset(
                  'diseñador/logo.png',
                  fit: BoxFit.contain,
                  height: 40,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                Stack(
                  children: <Widget>[
                    Material(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: widget.petModel == null
                              ? Image.network(
                                  PetshopApp.sharedPreferences
                                    .getString(PetshopApp.userAvatarUrl),
                                  errorBuilder: (context, object, stacktrace) {
                                    return Container();
                                  },
                                ).image
                              : Image.network(
                                  widget.petModel.petthumbnailUrl,
                                  errorBuilder: (context, object, stacktrace) {
                                    return Container();
                                  },
                                ).image,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                        "Map",
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
                    // height: _screenHeight,
                    // width: _screenWidth,
                    // child: GoogleMap(
                    //   initialCameraPosition: CameraPosition(
                    //     target: LatLng(10.4806, -66.9036),
                    //     zoom: 12.0,
                    //   ),
                    // ),

                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
