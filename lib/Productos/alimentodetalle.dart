import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/prod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:pet_shop/cart/cartfinal.dart';
import '../Widgets/myDrawer.dart';

int cantidad = 1;

double width;

class AlimentoDetalle extends StatefulWidget {
  final ProductModel productModel;
  final PetModel petModel;
  final ProductoModel productoModel;
  final CartModel cartModel;
  final AliadoModel aliadoModel;
  final int defaultChoiceIndex;

  AlimentoDetalle(
      {this.petModel,
      this.productModel,
      this.productoModel,
      this.cartModel,
      this.aliadoModel,
      this.defaultChoiceIndex});

  @override
  _AlimentoDetalleState createState() => _AlimentoDetalleState();
}

class _AlimentoDetalleState extends State<AlimentoDetalle> {
  bool check = false;
  int delivery = 0;
  bool _value2 = false;
  DateTime selectedDate = DateTime.now();
  PetModel model;
  AliadoModel ali;
  CartModel cart;
  bool select = false;
  bool uploading = false;
  String petImageUrl = "";
  String downloadUrl = "";
  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  dynamic sumaTotal = 0;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getFavorites();
    DocumentReference documentReference = db
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(widget.productoModel.aliadoId);
    documentReference.get().then((dataSnapshot) {
      setState(() {
        sumaTotal = (dataSnapshot.data()["sumaTotal"]);
      });

      print('Suma Total: $sumaTotal');
    });
  }

  getFavorites() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Productos")
        .doc(widget.productoModel.productoId)
        .collection('Favoritos')
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

  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    dynamic total = widget.productoModel.precio;
    total = total * cantidad;
    String precio = total.toString();
    String cant = cantidad.toString();
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
                        "Detalles",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: _screenWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: 140.0,
                                  width: 140,
                                  child: Image.network(
                                    widget.productoModel.urlImagen,
                                    errorBuilder: (context, object, stacktrace) {
                                      return Container();
                                    },
                                  )),
                              SizedBox(
                                height: 8.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 53.0,
                                    child: RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          cantidad--;
                                          if (cantidad < 1) {
                                            cantidad = 1;
                                          }
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      color: Color(0xFFBBD7D6),
                                      padding: EdgeInsets.all(0.0),
                                      child: Text("-",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Color(0xFF57419D),
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    child: Text(
                                      cantidad.toString(),
                                      style: TextStyle(
                                        color: Color(0xFF57419D),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 53.0,
                                    child: RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          cantidad++;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      color: Color(0xFFBBD7D6),
                                      padding: EdgeInsets.all(0.0),
                                      child: Text("+",
                                          style: TextStyle(
                                              fontFamily: 'Product Sans',
                                              color: Color(0xFF57419D),
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productoModel.titulo,
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(

                                  '${widget.productoModel.pesoValor} ${widget.productoModel.pesoUnidad}',
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.productoModel.dirigido,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  widget.aliadoModel.nombreComercial,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.aliadoModel.direccion,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  height: 9,
                                ),


                                Row(
                                  children: [
                                    Text("Marcar favorito"),
                                    IconButton(
                                      icon: check
                                          ? Icon(Icons.favorite)
                                          : Icon(
                                              Icons.favorite_border_outlined),
                                      color: Color(0xFF57419D),
                                      iconSize: 38,
                                      onPressed: () {
                                        setState(() {
                                          if (check) {
                                            check = false;

                                            FirebaseFirestore.instance
                                                .collection("Productos")
                                                .doc(widget
                                                    .productoModel.productoId)
                                                .collection('Favoritos')
                                                .doc(PetshopApp
                                                    .sharedPreferences
                                                    .getString(
                                                        PetshopApp.userUID))
                                                .set({
                                              'like': false,
                                              'uid': PetshopApp
                                                  .sharedPreferences
                                                  .getString(
                                                      PetshopApp.userUID),
                                            }).then((result) {
                                              print("new USer true");
                                            }).catchError((onError) {
                                              print("onError");
                                            });
                                          } else {
                                            check = true;

                                            FirebaseFirestore.instance
                                                .collection("Productos")
                                                .doc(widget
                                                    .productoModel.productoId)
                                                .collection('Favoritos')
                                                .doc(PetshopApp
                                                    .sharedPreferences
                                                    .getString(
                                                        PetshopApp.userUID))
                                                .set({
                                              'like': true,
                                              'uid': PetshopApp
                                                  .sharedPreferences
                                                  .getString(
                                                      PetshopApp.userUID),
                                            }).then((result) {
                                              print("new USer true");
                                            }).catchError((onError) {
                                              print("onError");
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       SizedBox(
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.end,
                    //           children:
                    //           [
                    //             Text('Costo: ', style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                    //             Text('\$', style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                    //             Text(total.toString(), style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                    //           ],
                    //         ),
                    //       ),
                    //
                    //     ],
                    //   ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Checkbox(value: _value2, activeColor: Color(0xFF57419D), onChanged: (bool value){
                    //           setState(() {
                    //             _value2 = value;
                    //             if(value==true){
                    //               delivery = widget.productoModel.delivery;
                    //
                    //
                    //             }
                    //             else{
                    //               delivery = 0;
                    //             }
                    //           });
                    //         }
                    //
                    //         ),
                    //         Text('Cargo por Delivery', style: TextStyle(color: Color(0xFF57419D), fontWeight: FontWeight.bold, fontSize: 22),),
                    //       ],
                    //     ),
                    //
                    //     Row(
                    //       children: [
                    //         Text("\$", style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                    //         Text((widget.productoModel.delivery).toString(), style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                    //
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total: ',
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                PetshopApp.sharedPreferences
                                    .getString(PetshopApp.simboloMoneda),
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                (total + delivery).toStringAsFixed(2),
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          checkItemInCart(widget.productoModel.productoId, cant,
                              (total + delivery).toString(), context);
                          print(widget.productoModel.productoId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartFinal(
                                    petModel: widget.petModel,
                                    defaultChoiceIndex:
                                        widget.defaultChoiceIndex)),
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Color(0xFFEB9448),
                        padding: EdgeInsets.all(10.0),
                        child: Text("Agregar a mi pedido",
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 18.0)),
                      ),
                    ),
                  ],
                )
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

  void checkItemInCart(
      String itemID, String cant, String precio, BuildContext context) {
    // PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList).contains(itemID)
    //     ? Fluttertoast.showToast(msg: "El producto ya se encuentra en el carrito.")
    //
    //     : addItemtoCart(itemID, context);

    addItemtoCart(itemID, cant, precio, context);
  }

  addItemtoCart(
      String itemID, String cant, String precio, BuildContext context) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(widget.productoModel.aliadoId)
        .set({
      "aliadoId": widget.productoModel.aliadoId,
      "nombreComercial": widget.aliadoModel.nombreComercial,
      'sumaTotal': sumaTotal + (widget.productoModel.precio * cantidad),
      "pais": widget.aliadoModel.pais,
    });

// setState(() {
//   sumaTotal = 0;
// });
    //
    // var likeRef2 = db.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).collection('Cart').doc(widget.productoModel.aliadoId);
    // likeRef2.updateData({
    //   'sumaTotal': FieldValue.increment(widget.productoModel.precio),
    //
    // });

    databaseReference
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc((widget.productoModel.aliadoId).toString())
        .collection('Items')
        .doc(productId)
        .set({
      "aliadoId": widget.productoModel.aliadoId,
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "iId": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": widget.productoModel.precio,
      "cantidad": int.parse(cant),
      "productoId": itemID,
      "titulo": widget.productoModel.titulo,
      "createdOn": DateTime.now(),
    });

    // List tempCartList = PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList);
    // tempCartList.add(itemID);
    //
    // PetshopApp.firestore.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).updateData({
    //   PetshopApp.userCartList: tempCartList,
    // }).then((v){
    //  Fluttertoast.showToast(msg: "Se ha agregado su producto al carrito.");
    //  PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, tempCartList);
    // });
  }
}
