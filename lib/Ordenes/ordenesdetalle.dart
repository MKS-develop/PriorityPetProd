import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class OrdenesDetalle extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final OrderModel orderModel;
  final int defaultChoiceIndex;

  OrdenesDetalle(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.orderModel,
      this.defaultChoiceIndex});

  @override
  _OrdenesDetalleState createState() => _OrdenesDetalleState();
}

class _OrdenesDetalleState extends State<OrdenesDetalle> {
  PetModel model;
  CartModel cart;
  Producto producto;
  OrderModel order;

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
                        "Detalles de la orden",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Mascotas')
                        .doc(widget.orderModel.mid)
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
                            PetModel model =
                                PetModel.fromJson(dataSnapshot.data.data);
                            return sourceInfo(model, context);
                          });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  Widget sourceInfo(
    PetModel model,
    BuildContext context,
  ) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    String formatted = formatter.format(widget.orderModel.createdOn.toDate());
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          decoration: BoxDecoration(
              color: Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: <Widget>[
                        Material(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: model == null
                                  ? NetworkImage(PetshopApp.sharedPreferences
                                      .getString(PetshopApp.userAvatarUrl))
                                  : NetworkImage(model.petthumbnailUrl),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Nombre: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.nombre,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Mascota: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.especie,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Raza: ',
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.raza,
                              style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Número de orden: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.orderModel.oid,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'Fecha de la orden: $formatted',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Aliados')
                        .doc(widget.orderModel.aliadoId)
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
                            AliadoModel ali =
                                AliadoModel.fromJson(dataSnapshot.data.data);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Proveedor: '),
                                    Text(ali.nombreComercial),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Teléfono móvil: '),
                                    Text(ali.telefono),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Correo: '),
                                    Text(ali.email),
                                  ],
                                ),
                              ],
                            );
                          });
                    }),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(widget.orderModel.tipoOrden),
                    Text(' :'),
                    Text(widget.orderModel.titulo),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(widget.orderModel.fecha != null
                            ? 'Fecha desde: '
                            : ''),
                        Text(widget.orderModel.fecha != null
                            ? widget.orderModel.fecha
                            : ''),
                      ],
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    // Text('hasta: $formatted'),
                  ],
                ),
                Row(
                  children: [
                    Text(widget.orderModel.hora != null ? 'Hora: ' : ''),
                    Text(widget.orderModel.hora != null
                        ? widget.orderModel.hora
                        : ''),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text('Monto: \$'),
                    Text(widget.orderModel.precio.toString()),
                  ],
                ),
                Row(
                  children: [
                    Text('Estatus: '),
                    Text(widget.orderModel.status),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: RaisedButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Colors.red,
                    padding: EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Cancelar',
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 14.0)),
                      ],
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
