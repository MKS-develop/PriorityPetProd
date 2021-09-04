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
import 'package:pet_shop/Ordenes/ordenesdetalle.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class OrdenesHome extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  OrdenesHome(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _OrdenesHomeState createState() => _OrdenesHomeState();
}

class _OrdenesHomeState extends State<OrdenesHome> {
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
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar: CustomBottomNavigationBar(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
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
                        "Mis órdenes",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // StreamBuilder<QuerySnapshot>(
                //     stream: FirebaseFirestore.instance.collection("Ordenes").where('uid', isEqualTo: PetshopApp.sharedPreferences.getString(PetshopApp.userUID).toString()).orderBy('createdOn', descending: true)
                //         .snapshots(),
                //     builder: (context, dataSnapshot) {
                //       if (!dataSnapshot.hasData) {
                //         return Center(
                //           child: CircularProgressIndicator(),
                //         );
                //       }
                //       return ListView.builder(
                //           physics: NeverScrollableScrollPhysics(),
                //           itemCount: dataSnapshot.data.docs.length,
                //           shrinkWrap: true,
                //           itemBuilder: (context, index,) {
                //             OrderModel order = OrderModel.fromJson(
                //                 dataSnapshot.data.docs[index].data());
                //             return sourceInfo(order, context);
                //           }
                //         );
                //       }
                //     ),
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
    OrderModel order,
    BuildContext context,
  ) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMd('es_VE');
    String formatted = formatter.format(order.createdOn.toDate());

    return InkWell(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrdenesDetalle(
                      orderModel: order,
                      petModel: widget.petModel,
                      defaultChoiceIndex: widget.defaultChoiceIndex,
                    )),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.91,
            decoration: BoxDecoration(
                color: Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFBDD7D6),
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Orden N°',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            order.oid,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '\$',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            order.precio.toString(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha orden: $formatted',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.fecha != null ? order.fecha : '',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF57419D)),
                      ),
                      Text(
                        order.hora != null ? order.hora : '',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF57419D)),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      Text(
                        order.titulo,
                        style: TextStyle(
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Aliados')
                          .doc(order.aliadoId)
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
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(ali.nombreComercial,
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.left),
                                ],
                              );
                            });
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 30,
                        child: RaisedButton(
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: Color(0xFF57419D),
                          padding: EdgeInsets.all(0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(order.status,
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      color: Colors.white,
                                      fontSize: 14.0)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50.0,
                        height: 50.0,
                        // child: StreamBuilder(
                        //      stream: FirebaseFirestore.instance.collection('Mascotas').doc(order.mid).snapshots(),
                        //      builder: (context, dataSnapshot) {
                        //        if (!dataSnapshot.hasData) {
                        //          return Center(
                        //            child: CircularProgressIndicator(),
                        //          );
                        //        }
                        //        return ListView.builder(
                        //            itemCount: 1,
                        //            shrinkWrap: true,
                        //            itemBuilder: (context, index,) {
                        //              PetModel model = PetModel.fromJson(
                        //                  dataSnapshot.data.data);
                        //              return Stack(
                        //                  children: <Widget> [
                        //              Material(
                        //              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        //              child: Container(
                        //              height: 50,
                        //              width: 50,
                        //              child: CircleAvatar(
                        //              backgroundColor: Colors.transparent,
                        //              backgroundImage: model  == null ? NetworkImage(PetshopApp.sharedPreferences.getString(PetshopApp.userAvatarUrl)) : NetworkImage(model.petthumbnailUrl),
                        //              ),
                        //              ),
                        //              ),
                        //              ],
                        //              );
                        //            }
                        //        );
                        //      }
                        //  ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
