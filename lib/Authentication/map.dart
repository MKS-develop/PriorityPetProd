import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class MapHome extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;
  final LocationModel locationModel;
  final AliadoModel aliadoModel;
  final GeoPoint userLatLong;

  MapHome(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex,
      this.locationModel,
      this.aliadoModel,
      this.userLatLong});

  @override
  _MapHomeState createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  PetModel model;
  CartModel cart;
  Producto producto;
  List<Marker> customMarkers = [];
  final Set<Marker> _markers = Set();
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(26.8206, 30.8025));
  Completer<GoogleMapController> _controller = Completer();
  final double _zoom = 14;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    bitmaps.asMap().forEach((mid, bmp) {
      customMarkers.add(Marker(
        markerId: MarkerId("${widget.aliadoModel.nombreComercial}"),
        position: LatLng(widget.locationModel.location.latitude,
            widget.locationModel.location.longitude),
        icon: BitmapDescriptor.fromBytes(bmp),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _goToNewYork();
    print(widget.locationModel.location.longitude);
  }

  Future<void> _goToNewYork() async {
    double lat = widget.locationModel.location.latitude;
    double long = widget.locationModel.location.longitude;
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(widget.locationModel.location.latitude,
            widget.locationModel.location.longitude),
        _zoom));
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('${widget.aliadoModel.nombreComercial}'),
            position: LatLng(widget.locationModel.location.latitude,
                widget.locationModel.location.longitude),
            infoWindow: InfoWindow(
                title: '${widget.aliadoModel.nombreComercial}',
                snippet: '${widget.locationModel.mapAddress}')),
      );
    });
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
        // bottomNavigationBar: CustomBottomNavigationBar(petModel: widget.petModel, defaultChoiceIndex: widget.defaultChoiceIndex,),
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
            horizontal: 0.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Row(
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
                          "Ubicación",
                          style: TextStyle(
                            color: Color(0xFF57419D),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: _screenHeight * 0.75,
                  width: _screenWidth,
                  child: GoogleMap(
                    markers: _markers,
                    onMapCreated: _onMapCreated,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.userLatLong.latitude,
                          widget.userLatLong.longitude),
                      zoom: 12.0,
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
}
